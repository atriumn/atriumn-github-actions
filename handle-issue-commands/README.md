# Handle Issue Commands Action

This composite action processes slash commands in GitHub issue comments.

## Usage

```yaml
- uses: atriumn/atriumn-github-actions/handle-issue-commands@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    issue-number: ${{ github.event.issue.number }}
    comment-body: ${{ github.event.comment.body }}
```

## Supported Commands

- `/start` - Start work on an issue
- `/ready` - Mark issue as ready for review
- `/done` - Mark issue as complete

## Development Status

This action is pending implementation.
