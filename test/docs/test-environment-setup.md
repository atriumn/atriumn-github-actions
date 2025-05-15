# Test Environment Setup

This document describes how to set up a test environment for validating the Atriumn GitHub Actions composite actions.

## Prerequisites

- GitHub account with permissions to create repositories
- GitHub CLI (`gh`) installed and authenticated
- GitHub Personal Access Token with project permissions

## Test Repository

The test repository `atriumn/atriumn-github-actions-test-repo` has been created for testing purposes.

## Setting Up the Test Environment

### 1. Configure Repository Access

Ensure you have the following environment variables set:
```bash
export GITHUB_TOKEN="your-personal-access-token"
export PROJECT_TOKEN="your-project-access-token"
```

### 2. Create Project Board

The test repository should have a project board with the following columns:
- Todo
- In Progress  
- Done
- Waiting for Review

### 3. Create Sample Issues

Use the test data generation script to create sample issues:
```bash
./test/scripts/generate-test-data.sh
```

This will create 10 sample issues with various states and labels.

### 4. Configure Repository Settings

The test repository needs the following settings:
- Issues enabled
- Projects enabled
- GitHub Actions enabled
- Branch protection rules (optional)

### 5. Set Up Secrets

Add the following secrets to the test repository:
- `PROJECT_TOKEN`: Token with organization project permissions
- `GITHUB_TOKEN`: GitHub token for API access

## Verifying the Setup

Run the verification script to ensure everything is configured correctly:
```bash
./test/scripts/verify-test-setup.sh
```

## Test Workflows

The following workflows can be tested:

1. **Issue Status Updates**
   - Test changing issue status through project board
   - Test status updates via issue comments

2. **Issue Command Handling**
   - Test `/start` command to move issue to In Progress
   - Test `/ready` command to move issue to Waiting for Review
   - Test `/done` command to move issue to Done

3. **Branch Creation**
   - Test automatic branch creation when issue is moved to In Progress
   - Test branch naming conventions

## Troubleshooting

If you encounter issues:

1. Check token permissions
2. Verify repository settings
3. Ensure project board is configured correctly
4. Check GitHub Actions logs for errors

## Maintenance

The test environment should be periodically cleaned up:
- Close old issues
- Delete stale branches
- Archive completed projects