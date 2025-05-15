# Release Process

This document outlines the process for creating releases of Atriumn GitHub Actions.

## Pre-Release Checklist

Before creating a release, ensure:

- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] CHANGELOG.md includes all changes
- [ ] Version examples in READMEs are ready to update
- [ ] Breaking changes have migration guides

## Creating a Release

### 1. Prepare Release Branch

```bash
# Create release branch
git checkout -b release/v1.2.3
```

### 2. Update Documentation

Update version references in:
- README files (action examples)
- Documentation
- CHANGELOG.md (move unreleased items)

### 3. Create Pull Request

```bash
# Commit changes
git add .
git commit -m "chore: prepare release v1.2.3"
git push origin release/v1.2.3

# Create PR
gh pr create --title "Release v1.2.3" --body "Preparing release v1.2.3"
```

### 4. Merge and Tag

After PR approval:

```bash
# Merge PR
gh pr merge --merge

# Checkout main and pull latest
git checkout main
git pull

# Create and push tag
git tag v1.2.3
git push origin v1.2.3
```

### 5. Automated Release

The release workflow will automatically:
1. Create a GitHub release
2. Generate release notes
3. Update major version tag
4. Publish release

## Version Tag Management

### Creating Tags

```bash
# Create specific version tag
git tag v1.2.3
git push origin v1.2.3

# Major version tag is updated automatically
```

### Tag Format

- Full version: `v1.2.3`
- Pre-release: `v1.2.3-beta.1`
- Major version: `v1` (auto-updated)

## Release Types

### Standard Release

For stable releases:
1. Use standard version format: `v1.2.3`
2. Major version tag updates automatically
3. Full support provided

### Pre-Release

For testing releases:
1. Use pre-release format: `v1.2.3-alpha.1`
2. Major version tag not updated
3. Marked as pre-release on GitHub

## Post-Release Tasks

After release:

1. **Announce Release**
   - Update project documentation
   - Notify users of breaking changes
   - Share in relevant channels

2. **Monitor Issues**
   - Watch for bug reports
   - Address critical issues quickly
   - Plan patch releases if needed

3. **Update Examples**
   - Update external documentation
   - Update example repositories
   - Update integration guides

## Emergency Patches

For critical fixes:

1. Create patch from main:
   ```bash
   git checkout -b patch/v1.2.4
   git cherry-pick <commit-hash>
   ```

2. Fast-track review process
3. Release immediately
4. Backport to development branches

## Deprecation Process

When deprecating features:

1. Add deprecation warnings in minor release
2. Document in CHANGELOG.md
3. Provide migration guide
4. Remove in next major release
5. Maintain 3-month minimum deprecation period

## Support Timeline

- **Current major version**: Full support
- **Previous major version**: 6 months security patches
- **Older versions**: Best effort only

## Troubleshooting

### Release Workflow Failed

If the automated release fails:

1. Check workflow logs
2. Fix any issues
3. Re-run workflow or create release manually

### Tag Issues

If tags are incorrect:

```bash
# Delete remote tag
git push --delete origin v1.2.3

# Delete local tag
git tag -d v1.2.3

# Recreate and push
git tag v1.2.3
git push origin v1.2.3
```

## Best Practices

1. **Release Regularly**
   - Monthly for minor updates
   - Immediate for security fixes
   - Planned for major versions

2. **Communicate Clearly**
   - Detailed release notes
   - Migration guides
   - Breaking change warnings

3. **Test Thoroughly**
   - Run all tests
   - Test in real workflows
   - Validate migrations

4. **Document Everything**
   - Update all documentation
   - Include examples
   - Provide troubleshooting guides