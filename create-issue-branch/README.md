# Create Issue Branch Action

This composite action creates standardized branches for GitHub issues.

## Usage

```yaml
- uses: atriumn/atriumn-github-actions/create-issue-branch@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    issue-number: ${{ github.event.issue.number }}
    base-branch: 'main'
```

## Inputs

- `github-token`: GitHub token for authentication
- `issue-number`: Issue number to create branch for
- `base-branch`: Base branch to create from (default: main)

## Development Status

This action is pending implementation.
