# Contributing to zsh-nvm-pnpm-auto-switch

Thank you for your interest in contributing to zsh-nvm-pnpm-auto-switch! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## How Can I Contribute?

### Reporting Bugs

Before submitting a bug report:

1. Check the [GitHub Issues](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/issues) to see if the problem has already been reported.
2. Ensure you're using the latest version of the plugin.
3. Verify that the issue is reproducible and not specific to your configuration.

When submitting a bug report:

1. Use the bug report template provided.
2. Include detailed steps to reproduce the issue.
3. Provide relevant information about your environment.
4. Include any error messages or logs that might help diagnose the problem.

### Suggesting Features

We welcome feature suggestions! When suggesting a feature:

1. Use the feature request template provided.
2. Clearly describe the feature and the problem it solves.
3. Consider if the feature aligns with the project's scope and goals.

### Pull Requests

We actively welcome your pull requests:

1. Fork the repo and create a branch from `main`.
2. If you've added code that should be tested, add tests.
3. Update the documentation if needed.
4. Ensure the test suite passes.
5. Make sure your code follows the existing style.
6. Submit a pull request!

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git
   cd zsh-nvm-pnpm-auto-switch
   ```

2. Install development dependencies:
   ```bash
   npm install
   ```

3. Set up the pre-commit hooks:
   ```bash
   npm run prepare
   ```

## Development Workflow

### Directory Structure

- `src/` - The main plugin source files
- `.github/` - GitHub-specific files (issue templates, workflows)
- `tests/` - Test files (if applicable)

### Coding Standards

- Follow the existing coding style in the project.
- Use meaningful variable and function names.
- Add comments for complex logic.
- Keep functions focused on a single responsibility.

### Commit Messages

We follow conventional commit messages:

- `feat:` - A new feature
- `fix:` - A bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semi-colons, etc)
- `refactor:` - Code changes that neither fix bugs nor add features
- `perf:` - Performance improvements
- `test:` - Adding or modifying tests
- `chore:` - Changes to the build process or auxiliary tools

Example: `feat: add support for custom Node.js versions`

### Testing

Before submitting a pull request, test your changes thoroughly. We recommend testing in different environments if possible (MacOS, Linux, etc).

## Release Process

The maintainers will handle the release process, which typically includes:

1. Updating the version in relevant files
2. Creating a new GitHub release
3. Publishing the release

## Additional Resources

- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh My Zsh Plugin Development](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#developing-plugins)
- [nvm Documentation](https://github.com/nvm-sh/nvm#readme)
- [Corepack Documentation](https://nodejs.org/api/corepack.html)

## Questions?

If you have any questions, feel free to create a discussion on GitHub or reach out to the maintainers.

Thank you for contributing!
