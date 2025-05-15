# PRD: GitHub Actions Composite Actions Migration

## Overview
Create reusable composite actions from our existing GitHub Actions workflows to enable centralized management and reuse across multiple projects. This involves extracting workflow logic into standalone actions, creating repositories to host them, and migrating existing workflows to use the new actions.

## Goals
- Eliminate code duplication across projects
- Enable version-controlled, centralized workflow management
- Simplify workflow maintenance and updates
- Create a library of reusable GitHub automation components

## Implementation Plan

### Phase 1: Repository Structure Setup

**New Repositories to Create:**
1. `atriumn/atriumn-github-actions` (main repository)
   - Houses all composite actions
   - Structure:
     ```
     /update-issue-status/
       action.yml
       README.md
     /handle-issue-commands/
       action.yml
       README.md
     /create-issue-branch/
       action.yml
       README.md
     ```

### Phase 2: Extract Composite Actions

**Actions to Create:**

1. **update-issue-status**
   - Inputs: issue-number, status, token, organization, project-name
   - Functionality: Updates GitHub project issue status via GraphQL
   - Source: Extract from `.github/actions/update-issue-status/action.yml`
   
   **Current Implementation:**
   ```yaml
   name: 'Update Issue Status'
   description: 'Update GitHub issue status in project board using GraphQL API'
   inputs:
     issue-number:
       description: 'The issue number to update'
       required: true
     status:
       description: 'The new status to set'
       required: true
     token:
       description: 'GitHub token with project permissions'
       required: true
     organization:
       description: 'Organization name'
       default: 'atriumn'
       required: false
     project-name:
       description: 'Project name to search for (defaults to "{repo} project")'
       required: false
     project-number:
       description: 'Project number in the organization (deprecated - use project-name)'
       required: false

   runs:
     using: 'composite'
     steps:
       - name: Validate inputs
         shell: bash
         run: |
           echo "🔍 Validating inputs..."
           
           if [ -z "${{ inputs.issue-number }}" ]; then
             echo "❌ ERROR: issue-number is required"
             exit 1
           fi
           
           if [ -z "${{ inputs.status }}" ]; then
             echo "❌ ERROR: status is required"
             exit 1
           fi
           
           if [ -z "${{ inputs.token }}" ]; then
             echo "❌ ERROR: token is required"
             exit 1
           fi
           
           echo "✅ Input validation passed"
           echo "Issue: #${{ inputs.issue-number }}"
           echo "Status: ${{ inputs.status }}"
           echo "Organization: ${{ inputs.organization }}"
           
           # Get repository name from GITHUB_REPOSITORY
           REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d'/' -f2)
           
           # Determine project name
           if [ -n "${{ inputs.project-name }}" ]; then
             PROJECT_NAME="${{ inputs.project-name }}"
           else
             # Default to "{repo} project"
             PROJECT_NAME="$REPO_NAME project"
           fi
           echo "Project Name: $PROJECT_NAME"

       - name: Update status
         shell: bash
         env:
           GITHUB_TOKEN: ${{ inputs.token }}
         run: |
           echo "📝 Updating issue #${{ inputs.issue-number }} status to '${{ inputs.status }}'..."
           
           # Get repository owner and name
           REPO_OWNER=$(echo $GITHUB_REPOSITORY | cut -d'/' -f1)
           REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d'/' -f2)
           
           # Determine project name for search
           if [ -n "${{ inputs.project-name }}" ]; then
             PROJECT_NAME="${{ inputs.project-name }}"
           else
             # Default to "{repo} project"
             PROJECT_NAME="$REPO_NAME project"
           fi
           
           # GraphQL query to find project by name
           echo "🔍 Searching for project: $PROJECT_NAME"
           PROJECTS_QUERY=$(cat <<EOF
           {
             organization(login: "${{ inputs.organization }}") {
               projectsV2(first: 50, query: "$PROJECT_NAME") {
                 nodes {
                   id
                   title
                   field(name: "Status") {
                     ... on ProjectV2SingleSelectField {
                       id
                       options {
                         id
                         name
                       }
                     }
                   }
                 }
               }
             }
           }
           EOF
           )
           
           REQUEST_BODY=$(jq -n --arg query "$PROJECTS_QUERY" '{ query: $query }')
           
           PROJECTS_RESPONSE=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" \
             -H "Content-Type: application/json" \
             -X POST \
             -d "$REQUEST_BODY" \
             https://api.github.com/graphql)
           
           # Extract field ID and option ID
           PROJECT_DATA=$(echo $PROJECTS_RESPONSE | jq -r ".data.organization.projectsV2.nodes[] | select(.title == \"$PROJECT_NAME\")")
           PROJECT_ID=$(echo $PROJECT_DATA | jq -r '.id')
           FIELD_ID=$(echo $PROJECT_DATA | jq -r '.field.id')
           OPTION_ID=$(echo $PROJECT_DATA | jq -r ".field.options[] | select(.name == \"${{ inputs.status }}\") | .id")
           
           # Get the issue's project item ID
           ISSUE_QUERY=$(cat <<EOF
           {
             repository(owner: "$REPO_OWNER", name: "$REPO_NAME") {
               issue(number: ${{ inputs.issue-number }}) {
                 projectItems(first: 10) {
                   nodes {
                     id
                     project {
                       id
                     }
                   }
                 }
               }
             }
           }
           EOF
           )
           
           ISSUE_REQUEST_BODY=$(jq -n --arg query "$ISSUE_QUERY" '{ query: $query }')
           ISSUE_RESPONSE=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" \
             -H "Content-Type: application/json" \
             -X POST \
             -d "$ISSUE_REQUEST_BODY" \
             https://api.github.com/graphql)
           
           ITEM_ID=$(echo $ISSUE_RESPONSE | jq -r ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"$PROJECT_ID\") | .id")
           
           # Update the status
           UPDATE_MUTATION=$(cat <<EOF
           mutation {
             updateProjectV2ItemFieldValue(input: {
               projectId: "$PROJECT_ID"
               itemId: "$ITEM_ID"
               fieldId: "$FIELD_ID"
               value: {
                 singleSelectOptionId: "$OPTION_ID"
               }
             }) {
               projectV2Item {
                 id
               }
             }
           }
           EOF
           )
           
           UPDATE_REQUEST_BODY=$(jq -n --arg query "$UPDATE_MUTATION" '{ query: $query }')
           
           UPDATE_RESPONSE=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" \
             -H "Content-Type: application/json" \
             -X POST \
             -d "$UPDATE_REQUEST_BODY" \
             https://api.github.com/graphql)
           
           echo "✅ Successfully updated issue #${{ inputs.issue-number }} to status: ${{ inputs.status }}"
           
           # Add a comment to the issue
           gh issue comment ${{ inputs.issue-number }} \
             --body "✅ Status automatically updated to: **${{ inputs.status }}**" || true
   ```

2. **handle-issue-commands**
   - Inputs: command, issue-number, github-token, repository, comment-user
   - Functionality: Parses and executes issue comment commands (/start, etc.)
   - Source: Extract from `.github/workflows/issue-comment-commands.yml`
   
   **Full Implementation:**
   ```yaml
   name: 'Handle Issue Commands'
   description: 'Handle slash commands in issue comments'
   inputs:
     command:
       description: 'The command to handle (e.g., start)'
       required: true
     issue-number:
       description: 'The issue number'
       required: true
     github-token:
       description: 'GitHub token'
       required: true
     repository:
       description: 'Repository in owner/name format'
       required: true
     comment-user:
       description: 'User who made the comment'
       required: true
   
   runs:
     using: 'composite'
     steps:
       - name: Check command authorization
         id: check-auth
         shell: bash
         env:
           GITHUB_TOKEN: ${{ inputs.github-token }}
         run: |
           # Check if the commenter has write permissions
           PERMISSION_LEVEL=$(gh api repos/${{ inputs.repository }}/collaborators/${{ inputs.comment-user }}/permission -q '.permission')
           
           if [[ "$PERMISSION_LEVEL" != "write" && "$PERMISSION_LEVEL" != "admin" ]]; then
             echo "User does not have write permissions"
             echo "authorized=false" >> $GITHUB_OUTPUT
             
             # Add unauthorized message
             gh issue comment ${{ inputs.issue-number }} \
               --repo ${{ inputs.repository }} \
               --body "❌ @${{ inputs.comment-user }} - You don't have permission to use this command. Only repository collaborators with write access can start work on issues."
           else
             echo "User has write permissions"
             echo "authorized=true" >> $GITHUB_OUTPUT
             
             # Add reaction to acknowledge command
             gh api --method POST \
               repos/${{ inputs.repository }}/issues/comments/${{ github.event.comment.id }}/reactions \
               -f content='+1'
           fi
   ```

3. **create-issue-branch**
   - Inputs: issue-number, branch-prefix, github-token, repository
   - Functionality: Creates and pushes new branch for issue
   - Source: Extract from `.github/workflows/issue-comment-commands.yml`
   
   **Full Implementation:**
   ```yaml
   name: 'Create Issue Branch'
   description: 'Create and push a branch for an issue'
   inputs:
     issue-number:
       description: 'The issue number'
       required: true
     branch-prefix:
       description: 'Prefix for the branch name'
       default: 'issue'
       required: false
     github-token:
       description: 'GitHub token'
       required: true
     repository:
       description: 'Repository in owner/name format'
       required: true
   
   outputs:
     branch-name:
       description: 'The name of the created branch'
       value: ${{ steps.create-branch.outputs.branch_name }}
   
   runs:
     using: 'composite'
     steps:
       - name: Create and push branch
         id: create-branch
         shell: bash
         env:
           GITHUB_TOKEN: ${{ inputs.github-token }}
         run: |
           # Configure git
           git config user.name "github-actions[bot]"
           git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
           
           # Ensure we're on main and up to date
           git checkout main
           git pull origin main
           
           # Create new branch
           BRANCH_NAME="${{ inputs.branch-prefix }}-${{ inputs.issue-number }}-$(date +%s)"
           git checkout -b "$BRANCH_NAME"
           
           # Push the branch
           git push origin "$BRANCH_NAME"
           
           echo "branch_name=$BRANCH_NAME" >> $GITHUB_OUTPUT
           echo "✅ Created and pushed branch: $BRANCH_NAME"
           
       - name: Add comment with branch info
         shell: bash
         env:
           GITHUB_TOKEN: ${{ inputs.github-token }}
         run: |
           BRANCH_NAME="${{ steps.create-branch.outputs.branch_name }}"
           
           COMMENT_BODY="✅ Created and pushed branch: \`$BRANCH_NAME\`"$'\n\n'"To start working:"$'\n'"\`\`\`bash"$'\n'"git fetch origin"$'\n'"git checkout $BRANCH_NAME"$'\n'"\`\`\`"
           
           gh issue comment ${{ inputs.issue-number }} --repo ${{ inputs.repository }} --body "$COMMENT_BODY"
   ```

### Phase 3: Update Existing Workflows

**Files to Modify:**
1. `.github/workflows/issue-status.yml`
   - Replace inline steps with: `uses: atriumn/atriumn-github-actions/update-issue-status@v1`
   - Remove duplicated logic
   
   **Updated Workflow:**
   ```yaml
   name: Update Issue Status

   on:
     pull_request:
       types: [opened, ready_for_review, closed]
       branches:
         - main

   jobs:
     update-status:
       runs-on: ubuntu-latest
       steps:
         - name: Extract issue number
           id: extract-issue
           env:
             PR_TITLE: ${{ github.event.pull_request.title }}
             PR_BODY: ${{ github.event.pull_request.body }}
             PR_BRANCH: ${{ github.event.pull_request.head.ref }}
           run: |
             # Extract issue number logic as before
             # (Keep this inline as it's specific to PR context)

         - name: Determine new status
           if: steps.extract-issue.outputs.skip != 'true'
           id: determine-status
           run: |
             # Status determination logic as before
             # (Keep this inline as it's specific to PR events)

         - name: Update issue status
           if: |
             steps.extract-issue.outputs.skip != 'true' && 
             steps.determine-status.outputs.skip != 'true'
           uses: atriumn/atriumn-github-actions/update-issue-status@v1
           with:
             issue-number: ${{ steps.extract-issue.outputs.issue_number }}
             status: ${{ steps.determine-status.outputs.status }}
             token: ${{ secrets.PROJECT_TOKEN }}
             organization: 'atriumn'
   ```

2. `.github/workflows/issue-comment-commands.yml`
   - Replace inline steps with composite actions
   - Simplify to just orchestration logic
   
   **Updated Workflow:**
   ```yaml
   name: Issue Comment Commands

   on:
     issue_comment:
       types: [created]

   permissions:
     issues: write
     contents: write
     pull-requests: write

   jobs:
     handle-start-command:
       runs-on: ubuntu-latest
       if: |
         github.event.issue.pull_request == null &&
         contains(github.event.comment.body, '/start')
       steps:
         - name: Checkout repository
           uses: actions/checkout@v4
           with:
             token: ${{ secrets.GITHUB_TOKEN }}

         - name: Handle start command
           uses: atriumn/atriumn-github-actions/handle-issue-commands@v1
           with:
             command: 'start'
             issue-number: ${{ github.event.issue.number }}
             github-token: ${{ secrets.GITHUB_TOKEN }}
             repository: ${{ github.repository }}
             comment-user: ${{ github.event.comment.user.login }}

         - name: Create branch for issue
           if: steps.handle-start-command.outputs.authorized == 'true'
           uses: atriumn/atriumn-github-actions/create-issue-branch@v1
           with:
             issue-number: ${{ github.event.issue.number }}
             github-token: ${{ secrets.GITHUB_TOKEN }}
             repository: ${{ github.repository }}

         - name: Update issue status to In Progress
           if: steps.handle-start-command.outputs.authorized == 'true'
           uses: atriumn/atriumn-github-actions/update-issue-status@v1
           with:
             issue-number: ${{ github.event.issue.number }}
             status: 'In Progress'
             token: ${{ secrets.PROJECT_TOKEN }}
             organization: 'atriumn'
   ```

### Phase 4: Testing & Validation

**Test Requirements:**
1. Create test repository with sample issues
2. Test each composite action individually
3. Test full workflow integration
4. Verify backward compatibility

**Test Scripts from atriumn-build:**
- `test/test_update_issue_status_action.sh`
- `test/test_issue_comment_commands.sh`
- `test/test_e2e_status_updates.sh`

### Phase 5: Migration & Cleanup

**Tasks:**
1. Update all project repositories to use new actions
2. Remove duplicated workflow code
3. Archive old workflow versions
4. Update documentation

## Technical Specifications

### Composite Action Structure
```yaml
name: 'Update Issue Status'
description: 'Updates GitHub project issue status'
inputs:
  issue-number:
    description: 'Issue number to update'
    required: true
  status:
    description: 'New status value'
    required: true
  github-token:
    description: 'GitHub token with project permissions'
    required: true
runs:
  using: "composite"
  steps:
    - name: Update Status
      shell: bash
      run: |
        # GraphQL mutation logic from atriumn-build implementation
```

### Versioning Strategy
- Use semantic versioning (v1.0.0)
- Create releases for each version
- Allow repos to pin to specific versions or major version tags

### Required Permissions
Based on current implementation:
- Repository: read
- Issues: write
- Projects: write
- Pull requests: write (for comment commands)

## Success Criteria
- All workflows using composite actions
- Zero code duplication across projects
- Successful tests on 3+ sample repositories
- Documentation complete with examples

## Timeline
- Week 1: Repository setup and first action extraction
- Week 2: Complete all composite actions
- Week 3: Testing and refinement
- Week 4: Migration and cleanup

## Risks & Mitigations
- **Risk**: Breaking existing workflows
  - **Mitigation**: Extensive testing, gradual rollout
- **Risk**: Permission issues across repos
  - **Mitigation**: Document required permissions clearly
- **Risk**: Version conflicts
  - **Mitigation**: Clear versioning strategy, backward compatibility

## Implementation Notes from atriumn-build

### GraphQL API Usage
The current implementation uses GitHub's GraphQL API for project operations:
- Finding projects by name (not number)
- Getting issue project items
- Updating field values

### Token Requirements
- Requires PROJECT_TOKEN with organization-level project permissions
- Token must have access to both repository and project APIs

### Error Handling
Current implementation includes:
- Input validation
- Token permission testing
- Detailed error messages
- Fallback handling for missing issues in projects

## Repository Implementation Tasks

### atriumn-github-actions Repository Setup
1. Create new repository: `atriumn/atriumn-github-actions`
2. Add repository description: "Reusable GitHub Actions composite actions for Atriumn projects"
3. Add topics: `github-actions`, `composite-actions`, `automation`
4. Create initial directory structure
5. Add README.md with usage documentation
6. Set up GitHub Pages for documentation (optional)
7. Configure repository settings:
   - Enable issues
   - Enable discussions
   - Set up branch protection for main branch

### Task List for LLM Implementation
The following tasks should be completed in the `atriumn-github-actions` repository:

1. **Create update-issue-status action**
   - Path: `/update-issue-status/action.yml`
   - Copy implementation from this PRD
   - Add comprehensive README.md
   - Add test workflow

2. **Create handle-issue-commands action**
   - Path: `/handle-issue-commands/action.yml`
   - Copy implementation from this PRD
   - Add comprehensive README.md
   - Add test workflow

3. **Create create-issue-branch action**
   - Path: `/create-issue-branch/action.yml`
   - Copy implementation from this PRD
   - Add comprehensive README.md
   - Add test workflow

4. **Add repository documentation**
   - Create comprehensive README.md at repository root
   - Add usage examples
   - Add contribution guidelines
   - Add versioning policy

5. **Create test workflows**
   - `.github/workflows/test-update-issue-status.yml`
   - `.github/workflows/test-handle-issue-commands.yml`
   - `.github/workflows/test-create-issue-branch.yml`

6. **Create release process**
   - Set up semantic versioning
   - Create initial v1.0.0 release
   - Set up release automation workflow

### Notes for Implementation
- All code snippets needed are included in this PRD
- Test scripts can be adapted from `atriumn-build/test/` directory
- Error handling patterns are established in current implementations
- GraphQL queries are production-tested and working