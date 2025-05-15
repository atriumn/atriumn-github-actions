# Atriumn GitHub Actions

Reusable GitHub Actions composite actions for Atriumn projects.

## Available Actions

This repository contains composite GitHub Actions that can be used across Atriumn projects to standardize and simplify workflows.

### setup-node

Sets up a standard Node.js environment with caching and dependency installation.

```yaml
- uses: atriumn/atriumn-github-actions/.github/actions/setup-node@main
  with:
    node-version: '20'  # optional
```

### Usage

To use these actions in your workflows, reference them as:

```yaml
- uses: atriumn/atriumn-github-actions/.github/actions/action-name@main
```

## Contributing

To add a new composite action:
1. Create a new directory under `.github/actions/[action-name]`
2. Add `action.yml` with the action definition
3. Document the action in this README
4. Test the action in a workflow

## Topics

- `github-actions`
- `composite-actions`
- `automation`
