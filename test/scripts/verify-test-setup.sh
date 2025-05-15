#!/bin/bash

# Verification script to ensure test environment is properly configured
# Checks repository, project board, issues, and permissions

set -e

echo "🔍 Verifying test environment setup..."
echo ""

# Check if gh is authenticated
echo "📋 Checking gh CLI authentication..."
if ! gh auth status &>/dev/null; then
    echo "❌ gh CLI is not authenticated. Run 'gh auth login' first"
    exit 1
else
    echo "✅ gh CLI is authenticated"
fi

# Configuration
ORG="atriumn"
REPO="atriumn-github-actions-test-repo"
PROJECT_NAME="atriumn-github-actions-test-repo project"

echo ""
echo "🏗️ Checking repository..."

# Check if repository exists
REPO_CHECK=$(gh api "repos/$ORG/$REPO" 2>/dev/null || echo "NOT_FOUND")

if [ "$REPO_CHECK" = "NOT_FOUND" ]; then
    echo "❌ Repository $ORG/$REPO does not exist"
    echo "  Please create the test repository first"
    exit 1
else
    echo "✅ Repository exists: $ORG/$REPO"
fi

# Check repository settings
echo ""
echo "⚙️ Checking repository settings..."
REPO_DATA=$(gh api "repos/$ORG/$REPO")

HAS_ISSUES=$(echo "$REPO_DATA" | jq -r '.has_issues')
HAS_PROJECTS=$(echo "$REPO_DATA" | jq -r '.has_projects')

if [ "$HAS_ISSUES" = "true" ]; then
    echo "✅ Issues are enabled"
else
    echo "❌ Issues are not enabled"
fi

if [ "$HAS_PROJECTS" = "true" ]; then
    echo "✅ Projects are enabled"
else
    echo "❌ Projects are not enabled"
fi

# Check for project board
echo ""
echo "📊 Checking project board..."

FIND_PROJECT_QUERY=$(cat <<EOF
{
  organization(login: "$ORG") {
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

PROJECT_DATA=$(gh api graphql -f query="$FIND_PROJECT_QUERY")
PROJECT_EXISTS=$(echo "$PROJECT_DATA" | jq -r ".data.organization.projectsV2.nodes[] | select(.title == \"$PROJECT_NAME\")")

if [ -n "$PROJECT_EXISTS" ]; then
    echo "✅ Project board exists: $PROJECT_NAME"
    
    # Check status field
    STATUS_OPTIONS=$(echo "$PROJECT_EXISTS" | jq -r '.field.options[].name')
    echo "  Status options found:"
    echo "$STATUS_OPTIONS" | sed 's/^/    - /'
else
    echo "❌ Project board not found: $PROJECT_NAME"
    echo "  Run ./test/scripts/setup-project-board.sh to create it"
fi

# Check for issues
echo ""
echo "📝 Checking issues..."

ISSUES=$(gh issue list --repo "$ORG/$REPO" --json number,title --jq '.[].number')
ISSUE_COUNT=$(echo "$ISSUES" | wc -l | tr -d ' ')

if [ "$ISSUE_COUNT" -eq 0 ] || [ -z "$ISSUES" ]; then
    echo "⚠️ No issues found in repository"
    echo "  Run ./test/scripts/generate-test-data.sh to create sample issues"
else
    echo "✅ Found $ISSUE_COUNT issue(s) in repository"
fi

# Check GitHub Actions
echo ""
echo "🤖 Checking GitHub Actions..."

WORKFLOWS=$(gh api "repos/$ORG/$REPO/actions/workflows" --jq '.workflows[].name' 2>/dev/null || echo "")

if [ -n "$WORKFLOWS" ]; then
    echo "✅ GitHub Actions workflows found:"
    echo "$WORKFLOWS" | sed 's/^/    - /'
else
    echo "⚠️ No GitHub Actions workflows found"
fi

# Check secrets
echo ""
echo "🔐 Checking repository secrets..."

SECRETS=$(gh api "repos/$ORG/$REPO/actions/secrets" --jq '.secrets[].name' 2>/dev/null || echo "")

if [ -n "$SECRETS" ]; then
    echo "✅ Repository secrets found:"
    echo "$SECRETS" | sed 's/^/    - /'
else
    echo "⚠️ No repository secrets found"
    echo "  Consider adding PROJECT_TOKEN for project operations"
fi

# Summary
echo ""
echo "📊 Verification Summary"
echo "====================="
echo "Repository: $ORG/$REPO"
echo "Project: $PROJECT_NAME"
echo "Issues: $ISSUE_COUNT"
echo ""

# Determine overall status
ERRORS=0
[ "$HAS_ISSUES" != "true" ] && ERRORS=$((ERRORS + 1))
[ "$HAS_PROJECTS" != "true" ] && ERRORS=$((ERRORS + 1))
[ -z "$PROJECT_EXISTS" ] && ERRORS=$((ERRORS + 1))
[ "$ISSUE_COUNT" -eq 0 ] && ERRORS=$((ERRORS + 1))

if [ $ERRORS -eq 0 ]; then
    echo "✅ Test environment is properly configured!"
else
    echo "❌ Test environment has $ERRORS issue(s) that need attention"
    echo ""
    echo "Recommended actions:"
    [ "$HAS_ISSUES" != "true" ] && echo "- Enable issues in repository settings"
    [ "$HAS_PROJECTS" != "true" ] && echo "- Enable projects in repository settings"
    [ -z "$PROJECT_EXISTS" ] && echo "- Run ./test/scripts/setup-project-board.sh"
    [ "$ISSUE_COUNT" -eq 0 ] && echo "- Run ./test/scripts/generate-test-data.sh"
fi