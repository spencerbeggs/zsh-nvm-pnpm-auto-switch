# ESLint Configuration Inspector

This document provides guidance on analyzing the ESLint configuration using the ESLint inspector UI.

## Starting the ESLint Inspector

To visualize and explore the ESLint configuration:

1. Run the ESLint inspector:
   ```bash
   pnpm lint:inspect
   ```

2. Open http://localhost:7777 in your browser

3. Browse the rules, plugins, and configurations

## Extracting Configuration Information

You can use browser developer tools to extract information about the ESLint configuration. Copy and paste this JavaScript into the browser console when the ESLint inspector is open:

```javascript
// Get configuration items
const configItems = Array.from(document.querySelectorAll('.config-item')).map(item => {
  const name = item.querySelector('.config-item-name')?.textContent?.trim() || '';
  const files = Array.from(item.querySelectorAll('.config-item-files .file')).map(
    f => f.textContent?.trim()
  ).filter(Boolean);
  return { name, files };
});

// Get active rules
const activeRules = Array.from(document.querySelectorAll('.rule-list .rule.active')).map(rule => {
  const name = rule.querySelector('.rule-name')?.textContent?.trim() || '';
  const severity = rule.querySelector('.rule-severity')?.textContent?.trim() || '';
  return { name, severity };
});

// Get plugin information
const plugins = Array.from(document.querySelectorAll('.plugin-list .plugin')).map(plugin => {
  return plugin.querySelector('.plugin-name')?.textContent?.trim() || '';
});

// Log the summary data
console.log(JSON.stringify({
  configItems,
  activeRules: activeRules.slice(0, 20), // Limiting to 20 for brevity
  plugins,
  totalRules: document.querySelectorAll('.rule-list .rule').length,
  activeRuleCount: document.querySelectorAll('.rule-list .rule.active').length
}, null, 2));
```

## Example ESLint Configuration Summary

Here's a sample of what the ESLint configuration might look like:

```markdown
# ESLint Configuration Summary

## Overview
- Total ESLint rules available: 450
- Active rules: 200
- Configuration file: `eslint.config.ts`

## Configuration Items
- **eslint:recommended**: Global
- **typescript-eslint/strict**: Applies to: **/*.ts, **/*.tsx
- **prettier**: Global

## Plugins
- @typescript-eslint
- import-x
- prettier
- package-json

## Sample Active Rules
- @typescript-eslint/no-explicit-any: error
- import-x/order: error
- prettier/prettier: error
```

## Using with Browser MCP

If you're using browser automation with MCP, you can programmatically extract this information:

1. Start the ESLint inspector: `pnpm lint:inspect`
2. Use browser automation to navigate to http://localhost:7777
3. Extract the configuration information using JavaScript evaluation
4. Generate a report or use the data for further analysis

For more information on browser automation, see [mcp-browser-automation.md](./mcp-browser-automation.md).