# ESLint Configuration Summary

## Overview
- Total ESLint rules available: ~450
- Active rules: ~200
- Configuration file: `eslint.config.ts`

## Key Configuration Elements
- **TypeScript Integration**: Uses typescript-eslint for strict type checking
- **Prettier Integration**: ESLint and Prettier work together for consistent formatting
- **Modern Flat Config**: Uses the new ESLint flat config format
- **Package.json Validation**: Ensures package.json follows best practices
- **Import Organization**: Rules for import/export organization and validation

## Major Plugins
- @typescript-eslint
- eslint-plugin-import-x
- eslint-plugin-prettier
- eslint-plugin-package-json

## Critical Rules
- @typescript-eslint/no-explicit-any (error)
- @typescript-eslint/no-unsafe-assignment (error)
- @typescript-eslint/consistent-type-imports (error)
- import-x/order (error)
- prettier/prettier (error)

## Inspecting Configuration
To explore the full configuration:
1. Run `pnpm lint:inspect`
2. Open http://localhost:7777 in your browser
3. Use the interactive UI to browse all rules, plugins, and configuration details

_This is a template summary. To get exact configuration details, use the ESLint inspector UI._