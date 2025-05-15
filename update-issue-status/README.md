# Update Issue Status Action

This composite action updates the status of GitHub issues based on comments and workflow events.

## Usage

```yaml
- uses: atriumn/atriumn-github-actions/update-issue-status@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    issue-number: ${{ github.event.issue.number }}
    status: 'in-progress'
```

## Inputs

- `github-token`: GitHub token for authentication
- `issue-number`: Issue number to update
- `status`: New status to set

## Development Status

This action is pending implementation.
