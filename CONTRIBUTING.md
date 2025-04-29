# Contributing to ZSH NVM PNPM Auto Switch

Thank you for considering contributing to this project! Here's how you can help.

## Development Setup

1. Fork and clone the repository:

```bash
git clone https://github.com/yourusername/zsh-nvm-pnpm-auto-switch.git
cd zsh-nvm-pnpm-auto-switch
```

2. Install development dependencies:

```bash
pnpm install
```

## Code Style and Quality

This project uses:

- ESLint and Prettier for JavaScript/TypeScript code formatting
- ShellCheck for shell script validation

Before submitting a pull request, please ensure your code passes all checks:

```bash
pnpm run format  # Format code with Prettier
pnpm run lint    # Check code with ESLint
pnpm run shellcheck  # Validate shell scripts
```

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) for semantic versioning. Please format your commit messages accordingly:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Where `<type>` is one of:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Changes that don't affect code logic (formatting, etc.)
- `refactor`: Code changes that neither fix bugs nor add features
- `perf`: Performance improvements
- `test`: Adding or fixing tests
- `chore`: Changes to the build process or auxiliary tools

## Pull Request Process

1. Ensure your code follows the coding standards
2. Update the README.md with details of significant changes if needed
3. Make sure all tests pass
4. Submit your pull request against the `main` branch

## Testing

To test your changes locally:

1. Apply your changes
2. Source the plugin: `source ./src/zsh-nvm-pnpm-auto-switch.plugin.zsh`
3. Navigate to a directory with a `.nvmrc` file to verify NVM switching works
4. Navigate to a directory with a `package.json` file containing PNPM engine requirements

## Questions?

If you have any questions about contributing, please open an issue for discussion.

Thank you for contributing!
