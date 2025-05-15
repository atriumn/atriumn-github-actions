# Versioning Strategy

Atriumn GitHub Actions follows [Semantic Versioning](https://semver.org/) principles to ensure predictable and reliable releases.

## Version Format

We use the format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes that require workflow updates
- **MINOR**: New features that are backward compatible
- **PATCH**: Bug fixes and minor improvements

## Versioning Strategy

### Release Tags

Each release creates two tags:
1. Full version: `v1.2.3`
2. Major version: `v1` (moves with latest release)

### Usage Examples

```yaml
# Use a specific version (recommended for production)
- uses: atriumn/atriumn-github-actions/setup-node@v1.2.3

# Use latest major version (auto-updates within major version)
- uses: atriumn/atriumn-github-actions/setup-node@v1

# Use main branch (not recommended for production)
- uses: atriumn/atriumn-github-actions/setup-node@main
```

## Version Increment Guidelines

### Major Version (Breaking Changes)
Increment when:
- Removing action inputs or outputs
- Changing required inputs
- Modifying behavior in incompatible ways
- Renaming actions

Example: `v1.0.0` → `v2.0.0`

### Minor Version (New Features)
Increment when:
- Adding new optional inputs
- Adding new outputs
- Adding new actions
- Enhancing functionality (backward compatible)

Example: `v1.0.0` → `v1.1.0`

### Patch Version (Bug Fixes)
Increment when:
- Fixing bugs
- Improving documentation
- Performance improvements
- Security patches

Example: `v1.0.0` → `v1.0.1`

## Pre-release Versions

For testing and preview releases:
- Alpha: `v1.0.0-alpha.1`
- Beta: `v1.0.0-beta.1`
- Release Candidate: `v1.0.0-rc.1`

## Major Version Tag Strategy

Major version tags (`v1`, `v2`, etc.) automatically point to the latest release within that major version:

1. Release `v1.0.0` → `v1` points to `v1.0.0`
2. Release `v1.1.0` → `v1` moves to `v1.1.0`
3. Release `v2.0.0` → `v2` points to `v2.0.0`, `v1` stays at `v1.1.0`

This allows users to:
- Pin to a major version for automatic updates
- Pin to a specific version for stability

## Release Process

1. **Create Release Branch**
   ```bash
   git checkout -b release/v1.2.3
   ```

2. **Update Version References**
   - Update action examples in READMEs
   - Update CHANGELOG.md

3. **Create Pull Request**
   - Title: `Release v1.2.3`
   - Use release template

4. **Merge and Tag**
   - Merge PR to main
   - Create release with tags

5. **Update Major Version Tag**
   - Move major version tag to new release

## Deprecation Policy

- Deprecation warnings added in minor releases
- Deprecated features removed in next major release
- Minimum 3 months between deprecation and removal
- Clear migration guides provided

## Version Support

- Latest major version: Full support
- Previous major version: Security patches for 6 months
- Older versions: Best effort support

## Examples

### Breaking Change Scenario
```yaml
# v1.0.0 (old)
- uses: atriumn/atriumn-github-actions/setup-node@v1
  with:
    node-version: '20'
    install-deps: true

# v2.0.0 (new) - removed install-deps, changed input name
- uses: atriumn/atriumn-github-actions/setup-node@v2
  with:
    version: '20'  # renamed from node-version
```

### Feature Addition Scenario
```yaml
# v1.0.0 (before)
- uses: atriumn/atriumn-github-actions/create-issue-branch@v1
  with:
    issue-number: 123

# v1.1.0 (after) - added optional prefix input
- uses: atriumn/atriumn-github-actions/create-issue-branch@v1
  with:
    issue-number: 123
    branch-prefix: 'feature/'  # new optional input
```

## Best Practices for Users

1. **Production Workflows**
   - Use major version tags (`@v1`) for automatic updates
   - Or pin to specific versions (`@v1.2.3`) for stability

2. **Development Workflows**
   - Test with `@main` or pre-release versions
   - Validate before updating production

3. **Migration**
   - Read release notes before major version updates
   - Test in non-production environments first
   - Follow migration guides