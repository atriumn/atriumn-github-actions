# Repository Settings Configuration

This document outlines the required repository settings for the atriumn-github-actions repository.

## Issues and Discussions
- ✅ **Issues**: Already enabled
- ⚠️ **Discussions**: Needs to be enabled for user questions

## Branch Protection Rules

### Main Branch Protection
Configure the following protection rules for the `main` branch:

1. **Require pull request reviews before merging**
   - Dismiss stale pull request approvals when new commits are pushed
   - Require review from CODEOWNERS
   - Required approvals: 1

2. **Require status checks to pass before merging**
   - Require branches to be up to date before merging
   - Status checks: `test-setup-node`

3. **Enforce all rules for administrators**

## Repository Permissions

Configure the following access levels:
- **Admin**: Repository owners
- **Maintain**: Core maintainers
- **Write**: Contributors
- **Read**: General access

## Features to Configure
- ⚠️ **GitHub Pages**: Enable if documentation site is needed
- ✅ **Wiki**: Disable (not needed - using docs/ directory)
- ✅ **Projects**: Disable (using organization-level projects)

## Implementation Steps

1. Go to Settings > Options
   - Enable Discussions
   - Disable Wiki
   - Disable Projects

2. Go to Settings > Branches
   - Add rule for `main`
   - Configure protection as specified above

3. Go to Settings > Manage access
   - Configure team permissions as needed

4. Go to Settings > Pages (if needed)
   - Source: Deploy from a branch
   - Branch: main
   - Folder: /docs