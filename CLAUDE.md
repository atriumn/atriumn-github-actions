# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Claude Commands
**IMPORTANT**: Custom Claude commands are available in `.claude/commands/` directory. These commands provide automated workflows for common tasks:
- **implement-issue-updated**: Implements a GitHub issue following a strict workflow (checkout, branch creation, implementation, testing, PR submission)
- Check `.claude/commands/` for additional commands as the project evolves

Always check for and use these commands when appropriate instead of manually performing the steps.

## GitHub Actions Workflows
- **Location**: Store workflow files in `.github/workflows/` directory
- **Format**: Use YAML format (`.yml` or `.yaml`)
- **Test Workflows**: Use GitHub's `act` tool locally to test workflows before pushing

## Common Development Tasks
- **Create Workflow**: `mkdir -p .github/workflows` to create the workflows directory
- **Validate YAML**: Use online YAML validators or `yamllint` for syntax checking
- **Check Workflow Syntax**: Use GitHub's workflow syntax documentation

## Project Structure
This is a GitHub Actions repository for the Atriumn project. GitHub Actions workflows should be organized as follows:
- `.github/workflows/` - Contains all workflow YAML files
- Reusable workflows can be stored in separate files and called from main workflows

## Best Practices
- Use clear, descriptive names for workflows and jobs
- Include comments in YAML files to explain complex steps
- Use secrets for sensitive data (stored in repository settings)
- Test workflows in feature branches before merging to main