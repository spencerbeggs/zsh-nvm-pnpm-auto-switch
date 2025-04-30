# Patching Dependencies with pnpm

This document explains how to patch dependencies using pnpm's built-in patching system. This project uses patches to fix or enhance dependencies like `@semantic-release/git` without having to fork them.

## Overview

pnpm's patching system allows us to:

1. Extract a dependency to a temporary directory
2. Modify the code as needed
3. Create a patch file that can be applied automatically when installing dependencies
4. Track these patches in version control

## Working with Patches

### Creating a New Patch

To create a patch for a dependency:

```bash
# Replace 'package-name@version' with the dependency you want to patch
pnpm patch package-name@version
```

This will extract the package to a temporary directory and give you a path to edit the files.

### Modifying the Package

Once the package is extracted, you can edit any files within the package. Common modifications include:

- Fixing bugs
- Adding new features
- Enhancing compatibility with newer versions
- Adding TypeScript types

Make sure to test your changes thoroughly before committing them.

### Committing the Patch

After making your changes, commit the patch with:

```bash
pnpm patch-commit /path/to/extracted/package
```

This will create a patch file in the `patches/` directory of your project and update your `pnpm-workspace.yaml` file with a reference to the patch.

### Applying Patches

Patches are automatically applied when you run:

```bash
pnpm install
```

### Updating a Patch

To update an existing patch:

1. Delete the existing patch directory if it exists:
   ```bash
   rm -rf node_modules/.pnpm_patches/package-name@version
   ```

2. Create a new patch:
   ```bash
   pnpm patch package-name@version
   ```

3. Make your changes to the extracted package.

4. Commit the updated patch:
   ```bash
   pnpm patch-commit /path/to/extracted/package
   ```

## Example: Patching @semantic-release/git

We use patching for `@semantic-release/git` to add support for the `waitForCodeQL` option, which allows semantic-release to wait for GitHub's CodeQL analysis to complete before pushing changes.

1. Created a patch:
   ```bash
   pnpm patch @semantic-release/git@10.0.1
   ```

2. Modified these files:
   - `lib/verify.js`: Added validator for the `waitForCodeQL` option
   - `lib/resolve-config.js`: Updated to pass through the `waitForCodeQL` option
   - `lib/prepare.js`: Added logic to wait for CodeQL and handle the marker file
   - `lib/git.js`: Enhanced execa handling for ESM compatibility

3. Committed the patch:
   ```bash
   pnpm patch-commit /path/to/extracted/package
   ```

## Best Practices

1. **Document the need for each patch** in your commit messages.
2. **Keep patches minimal** - only change what's necessary.
3. **Test thoroughly** before committing a patch.
4. **Check if updates are available** for the original package that might fix the issue.
5. **Consider upstreaming your changes** by contributing to the original package.

## Troubleshooting

- If you encounter `ERR_PNPM_EDIT_DIR_NOT_EMPTY` when trying to create a patch, either commit the existing patch directory or delete it with:
  ```bash
  rm -rf node_modules/.pnpm_patches/package-name@version
  ```

- If patches are not being applied, check your `pnpm-workspace.yaml` file to ensure it includes the `patchedDependencies` section.

- To debug patch issues, you can use verbose mode with pnpm:
  ```bash
  pnpm install --verbose
  ```