# Development Guide

This guide covers setting up a development environment for contributing to Atriumn GitHub Actions.

## Prerequisites

- Git
- GitHub CLI (`gh`)
- A GitHub account with access to the repository
- Basic knowledge of GitHub Actions

## Local Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/atriumn-github-actions.git
cd atriumn-github-actions
git remote add upstream https://github.com/atriumn/atriumn-github-actions.git
```

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Development Workflow

When developing composite actions:

1. Create your action directory structure:
```bash
mkdir -p my-new-action
touch my-new-action/action.yml
touch my-new-action/README.md
```

2. Define your action in `action.yml`:
```yaml
name: 'My New Action'
description: 'Description of what your action does'
inputs:
  my-input:
    description: 'Description of the input'
    required: true
    default: 'default-value'
outputs:
  my-output:
    description: 'Description of the output'
    value: ${{ steps.my-step.outputs.result }}
runs:
  using: "composite"
  steps:
    - name: My Step
      id: my-step
      shell: bash
      run: |
        echo "::set-output name=result::${{ inputs.my-input }}"
```

3. Document your action in `README.md`
4. Add tests in `.github/workflows/test-my-action.yml`

## Testing Actions Locally

### Using act (Recommended)

[act](https://github.com/nektos/act) allows you to run GitHub Actions locally:

```bash
# Install act
brew install act  # macOS
# or see https://github.com/nektos/act for other platforms

# Run a specific workflow
act -W .github/workflows/test-my-action.yml

# Run with specific event
act push -W .github/workflows/test-my-action.yml
```

### Testing in a Fork

1. Push your changes to your fork
2. Create test workflows in your fork
3. Verify actions work as expected
4. Submit PR to main repository

## Action Development Best Practices

### 1. Input Validation

Always validate inputs in your actions:

```yaml
steps:
  - name: Validate inputs
    shell: bash
    run: |
      if [ -z "${{ inputs.required-input }}" ]; then
        echo "Error: required-input is not set"
        exit 1
      fi
```

### 2. Error Handling

Use proper error handling:

```yaml
steps:
  - name: Run with error handling
    shell: bash
    run: |
      set -e  # Exit on error
      # Your commands here
```

### 3. Output Management

Set outputs correctly:

```yaml
steps:
  - name: Set output
    id: my-step
    shell: bash
    run: |
      result="some-value"
      echo "::set-output name=result::$result"
```

### 4. Logging

Use GitHub Actions logging commands:

```yaml
steps:
  - name: Log information
    shell: bash
    run: |
      echo "::debug::Debug information"
      echo "::notice::Important information"
      echo "::warning::Warning message"
      echo "::error::Error message"
```

## Debugging Actions

### Enable Debug Logging

Set these repository secrets:
- `ACTIONS_STEP_DEBUG`: `true`
- `ACTIONS_RUNNER_DEBUG`: `true`

### Common Issues

1. **Permission errors**: Ensure your action has the correct permissions
2. **Path issues**: Use absolute paths or GitHub Actions environment variables
3. **Shell differences**: Be aware of shell differences between runners

## Submitting Changes

1. Test your changes thoroughly
2. Update documentation
3. Commit with conventional commit messages
4. Push to your fork
5. Create a pull request

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Composite Actions Guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [Actions Toolkit](https://github.com/actions/toolkit)

## Getting Help

- Check existing issues
- Start a discussion
- Review action examples in this repository