# Contributing to Atriumn GitHub Actions

Thank you for your interest in contributing to Atriumn GitHub Actions! This guide will help you get started.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, inclusive, and constructive in all interactions.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch from `main`
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## Development Setup

See our [Development Guide](./docs/development.md) for detailed setup instructions.

## Contribution Guidelines

### Adding a New Action

1. Create a new directory with a descriptive name (use kebab-case)
2. Add an `action.yml` file with:
   - Clear name and description
   - Detailed input/output documentation
   - Examples in the description
3. Add a `README.md` with:
   - Usage examples
   - Input/output descriptions
   - Any limitations or requirements
4. Add tests in `.github/workflows/`
5. Update the main README.md action catalog

### Pull Request Process

1. **Title**: Use a clear, descriptive title
   - Good: "Add retry logic to create-issue-branch action"
   - Bad: "Update action"

2. **Description**: Include:
   - What changes you made
   - Why the changes are needed
   - Any breaking changes
   - Related issue numbers

3. **Testing**: Ensure:
   - All existing tests pass
   - New tests cover your changes
   - Actions work as expected

4. **Documentation**: Update:
   - Action-specific README files
   - Main repository documentation
   - Inline code comments for complex logic

### Coding Standards

- Use clear, descriptive names for actions and inputs
- Follow YAML best practices
- Keep actions focused on a single responsibility
- Use semantic versioning for releases
- Add appropriate error handling

### Testing

All actions must include:
- Unit tests where applicable
- Integration tests in workflow files
- Documentation of test scenarios

### Commit Messages

Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

Example:
```
feat(create-issue-branch): add support for custom branch prefixes

Allow users to specify custom prefixes for issue branches
instead of using the default 'issue-' prefix.

Closes #123
```

## Review Process

1. A maintainer will review your PR within 2-3 business days
2. Address any feedback or requested changes
3. Once approved, a maintainer will merge your PR

## Questions?

- Check existing [issues](https://github.com/atriumn/atriumn-github-actions/issues)
- Start a [discussion](https://github.com/atriumn/atriumn-github-actions/discussions)
- Review our [documentation](./docs/)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Atriumn GitHub Actions!