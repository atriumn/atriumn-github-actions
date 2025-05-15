# Test Environment for Atriumn GitHub Actions

This directory contains scripts and documentation for setting up and managing a test environment to validate the Atriumn GitHub Actions composite actions.

## Overview

The test environment includes:
- Test repository: `atriumn/atriumn-github-actions-test-repo`
- Project board with standard workflow columns
- Sample issues for testing
- Configuration scripts
- Verification tools

## Directory Structure

```
test/
├── README.md              # This file
├── docs/                  # Documentation
│   └── test-environment-setup.md
├── scripts/               # Test scripts
│   ├── configure-permissions.sh
│   ├── generate-test-data.sh
│   ├── setup-project-board.sh
│   └── verify-test-setup.sh
└── data/                  # Test data (if needed)
```

## Quick Start

1. **Set up environment variables:**
   ```bash
   export GITHUB_TOKEN="your-github-token"
   export PROJECT_TOKEN="your-project-token"
   ```

2. **Configure permissions:**
   ```bash
   ./test/scripts/configure-permissions.sh
   ```

3. **Set up project board:**
   ```bash
   ./test/scripts/setup-project-board.sh
   ```

4. **Generate test data:**
   ```bash
   ./test/scripts/generate-test-data.sh
   ```

5. **Verify setup:**
   ```bash
   ./test/scripts/verify-test-setup.sh
   ```

## Scripts

### configure-permissions.sh
- Sets up repository secrets
- Configures repository settings
- Validates token permissions

### setup-project-board.sh
- Creates a project board with standard columns
- Configures Status field with options
- Sets up project for testing

### generate-test-data.sh
- Creates sample issues
- Adds various labels and descriptions
- Provides test data for validation

### verify-test-setup.sh
- Checks repository existence
- Validates project board configuration
- Verifies issues and permissions
- Provides setup status summary

## Testing Composite Actions

Use the test environment to validate:

1. **update-issue-status**: Test status updates via GraphQL
2. **handle-issue-commands**: Test command processing
3. **create-issue-branch**: Test branch creation

## Troubleshooting

If you encounter issues:

1. **Permission errors**: Ensure your token has proper scopes
2. **Project not found**: Run `setup-project-board.sh`
3. **No issues**: Run `generate-test-data.sh`
4. **API errors**: Check token validity and permissions

## Maintenance

Periodically clean up the test environment:
- Close old issues
- Delete stale branches
- Remove test data

## Documentation

See `docs/test-environment-setup.md` for detailed setup instructions.