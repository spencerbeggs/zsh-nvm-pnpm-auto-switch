import eslint from "@eslint/js";
import { createTypeScriptImportResolver } from "eslint-import-resolver-typescript";
import importPlugin from "eslint-plugin-import-x";
import packageJsonPlugin from "eslint-plugin-package-json";
import prettierPlugin from "eslint-plugin-prettier/recommended";
import globals from "globals";
import tseslint from "typescript-eslint";
import type { FlatConfig } from "@typescript-eslint/utils/ts-eslint";

const config = tseslint.config(
	{
		ignores: ["**/dist/**", "**/node_modules/**", "**/.coverage/**"]
	},
	eslint.configs.recommended,
	tseslint.configs.strictTypeChecked,
	tseslint.configs.stylisticTypeChecked,
	importPlugin.flatConfigs.recommended,
	importPlugin.flatConfigs.typescript,
	{
		name: "typescript",
		files: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"],
		ignores: ["package.json"],
		languageOptions: {
			ecmaVersion: "latest",
			parserOptions: {
				projectService: true,
				allowDefaultProject: true,
				tsconfigRootDir: import.meta.dirname
			},
			globals: {
				...globals.node
			}
		},
		settings: {
			"import-x/resolver-next": [
				createTypeScriptImportResolver({
					alwaysTryTypes: true,
					project: ["tsconfig.json"]
				})
			]
		},
		rules: {
			"@typescript-eslint/consistent-type-imports": [
				"error",
				{
					prefer: "type-imports",
					fixStyle: "separate-type-imports"
				}
			],
			"@typescript-eslint/no-unused-vars": [
				"error",
				{
					args: "all",
					argsIgnorePattern: "^_",
					caughtErrors: "all",
					caughtErrorsIgnorePattern: "^_",
					destructuredArrayIgnorePattern: "^_",
					varsIgnorePattern: "^_",
					ignoreRestSiblings: true
				}
			],
			"import-x/order": [
				"error",
				{
					groups: ["builtin", "external", "internal", "parent", "sibling", "index", "object", "type"],
					"newlines-between": "never",
					alphabetize: {
						order: "asc",
						caseInsensitive: true
					}
				}
			],
			"import-x/no-named-as-default-member": ["off"]
		}
	},
	packageJsonPlugin.configs.recommended,
	{
		files: ["**/package.json"],
		extends: [tseslint.configs.disableTypeChecked]
	},
	prettierPlugin
);

export default config.filter(
	(item, index, self) => index === self.findIndex((t) => t.name === item.name)
) satisfies FlatConfig.ConfigArray;
