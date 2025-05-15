# Atriumn GitHub Actions Documentation

This directory contains documentation for the composite GitHub Actions in this repository.

## Available Actions

1. **[update-issue-status](../update-issue-status/README.md)** - Updates issue status based on workflow events
2. **[handle-issue-commands](../handle-issue-commands/README.md)** - Processes slash commands in issue comments
3. **[create-issue-branch](../create-issue-branch/README.md)** - Creates standardized branches for issues
4. **[setup-node](../.github/actions/setup-node/README.md)** - Sets up Node.js environment

## Architecture

These composite actions work together to provide automated issue management:

1. When a comment is made on an issue, `handle-issue-commands` processes any slash commands
2. If a `/start` command is found, `create-issue-branch` creates a feature branch
3. `update-issue-status` updates the issue labels/status throughout the workflow

## Repository Configuration

- **[Setup Guide](./SETUP.md)** - Manual setup steps for repository configuration
- **[Repository Settings](./repository-settings.md)** - Required repository settings documentation

## Contributing

To add a new composite action:

1. Create a new directory with a descriptive name
2. Add an `action.yml` file defining the composite action
3. Add a `README.md` documenting usage and inputs
4. Add tests in `.github/workflows/`
5. Update this documentation index
