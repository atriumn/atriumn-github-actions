# Setup Node.js Environment

This composite action sets up a standard Node.js environment for Atriumn projects.

## Usage

```yaml
- uses: atriumn/atriumn-github-actions/.github/actions/setup-node@main
  with:
    node-version: '20'  # optional, defaults to 20
```

## Inputs

- `node-version`: Node.js version to use (default: '20')
- `registry-url`: NPM registry URL (default: 'https://registry.npmjs.org')

## What it does

1. Sets up Node.js with the specified version
2. Configures NPM caching for faster subsequent runs
3. Automatically detects and installs dependencies if package.json exists
4. Uses `npm ci` for lockfile-based installs or `npm install` otherwise
