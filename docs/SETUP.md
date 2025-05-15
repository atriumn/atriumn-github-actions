# Repository Setup Guide

This guide walks through the manual steps required to configure the repository settings after initial creation.

## Automated Configuration

Some settings are automatically applied via:
- `.github/settings.yml` (requires [Settings app](https://probot.github.io/apps/settings/) to be installed)
- `.github/workflows/validate-branch-protection.yml` validates configuration

## Manual Configuration Required

### 1. Enable Discussions
1. Go to Settings > Options
2. Under "Features", check "Discussions"
3. Click "Save"

### 2. Configure Branch Protection
1. Go to Settings > Branches
2. Click "Add rule"
3. Branch name pattern: `main`
4. Configure:
   - ✅ Require a pull request before merging
     - ✅ Required approvals: 1
     - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - Status checks: `test-setup-node`
   - ✅ Include administrators
5. Click "Create"

### 3. Configure GitHub Pages (if needed)
1. Go to Settings > Pages
2. Source: Deploy from a branch
3. Branch: main
4. Folder: /docs
5. Click "Save"

## Verification

Run the validation workflow to check configuration:
```bash
gh workflow run validate-branch-protection.yml
```

Or wait for the weekly scheduled run to verify settings are maintained.