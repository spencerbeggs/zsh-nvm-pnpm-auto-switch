# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `pnpm run lint`: Check code with ESLint
- `pnpm run lint:fix`: Fix ESLint issues automatically
- `pnpm run lint:inspect`: Run ESLint config inspector
- `pnpm run test`: Run tests with Vitest (includes ShellCheck validation)
- `pnpm run test:watch`: Run tests in watch mode
- `pnpm run test -- -t "shell scripts"`: Run only shell script tests
- `pnpm run test -- -t "plugin"`: Run only plugin functionality tests
- `pnpm run prepare-commit`: Fix lint issues and run tests in one step
- `pnpm run validate`: Run both lint and tests without fixing issues
- `pnpm preview:changelog`: Test changelog generation with semantic-release dry run
- Manual testing: Source the plugin in directories with .nvmrc/package.json: `source ./src/zsh-nvm-pnpm-auto-switch.plugin.zsh`

## Code Style

- Use TypeScript with strict mode
- Follow ESLint recommendations
- ES Modules (type: "module")
- Target: ESNext with Node module resolution
- Conventional Commits pattern (feat, fix, docs, style, etc.)
- Auto-formatting with Prettier
- All shell scripts must pass ShellCheck validation
    - Tests will fail if ShellCheck detects issues
    - Use `printf` instead of `echo` for escape sequences
- Always maintain consistent file casing

## Development

- Package manager: pnpm@10.10.0
- Create/edit TypeScript files for TS configurations
- Shell scripts should follow ZSH best practices:
    - Use `printf` instead of `echo` for strings with escape sequences
    - Handle errors explicitly in shell scripts
    - Quote variables properly to avoid word splitting
- Comments should explain "why" not "what"
- Keep code modular and maintainable
- When working with dependency patches, follow the guidelines in `docs/development/patching-dependencies.md`
- Add tests in `__test__` directory:
    - Tests must be written in TypeScript
    - Use native shellcheck npm module for shell script validation
    - Include syntax checking for both Bash and Zsh scripts
    - Test filename pattern: `*.test.ts`
    - Each test should have descriptive it/test statements
    - Run tests with `pnpm test` before submitting PRs

## Code Quality Workflow

When completing a task, always follow this workflow:

1. Run `pnpm prepare-commit` to automatically fix easy linting issues and run tests
2. If there are remaining issues, run `pnpm lint` to see detailed errors
3. Manually fix any remaining issues that can't be auto-fixed
4. Run `pnpm validate` to verify all issues are fixed
5. Commit changes when validation passes (a pre-commit hook will run validation automatically)

Common ESLint issues to watch for:

- Type safety issues with TypeScript (`no-unsafe-*` rules)
- Import ordering (`import-x/order`)
- Consistent quotes (use double quotes)
- Proper indentation with tabs, not spaces
- Trailing commas and semicolons according to project style

## Continuous Integration

- GitHub Actions automate validation of code changes:
    - **Linting**: `pnpm lint` checks code style and quality
    - **Testing**: `pnpm test` runs Vitest tests which includes:
        - ShellCheck validation of shell scripts
        - Syntax checking for Bash and Zsh scripts
        - Plugin functionality tests
    - **Commit Format**: Enforces Conventional Commits format
- All checks must pass before PRs can be merged
- CI workflows:
    - **Pull Request Validation**: Runs on all PRs to main branch
    - **Release Workflow**: Runs on pushes to main and weekly (Sunday 1:30 AM UTC)
- Reusable components:
    - Custom GitHub Action `.github/actions/setup` provides standardized environment setup
    - Zsh is installed in CI environments for script syntax validation

## ESLint Configuration

The project uses a modern flat ESLint configuration in `eslint.config.ts` with TypeScript integration.

### Key ESLint Features

- TypeScript strict checking enabled
- Prettier integration for consistent formatting
- Import/export validation with eslint-plugin-import-x
- Package.json validation with eslint-plugin-package-json

### Inspecting ESLint Configuration

To visualize and explore the ESLint configuration:

1. Run `pnpm lint:inspect` to start the ESLint inspector UI
2. Open http://localhost:7777 in your browser
3. Browse rules, plugins, and configurations

For detailed information about analyzing the ESLint configuration, see `docs/examples/eslint-config-inspector.md`.

### Linting Commands

- `pnpm lint`: Run ESLint to check for issues
- `pnpm lint:fix`: Automatically fix ESLint issues where possible
- `pnpm lint:inspect`: Launch the ESLint inspector UI

## Browser MCP Integration

The `@browsermcp/mcp` package is available in devDependencies for browser automation needs. This could be used to test documentation sites or create browser-based demos of the plugin.

For detailed guidance on using browser automation with this project, see `docs/examples/mcp-browser-automation.md`.
