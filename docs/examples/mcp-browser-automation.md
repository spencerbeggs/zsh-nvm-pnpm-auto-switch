# Browser Automation with MCP

This document provides guidance on how to use the Browser MCP for testing or automation tasks related to this project.

## Overview

The `@browsermcp/mcp` package is available in the project devDependencies and can be used for browser automation needs, such as:

- Testing documentation sites
- Automating browser-based workflows
- Creating visual demonstrations of plugin functionality
- Inspecting web-based tools like the ESLint inspector

## MCP Server

To use the MCP server for browser automation:

1. Start an MCP server:
   ```bash
   npx mcp-server-browsermcp
   ```

2. Connect to the server programmatically or via the MCP inspector

## Example: Browser-Based Testing

Here's a conceptual example of how you might use browser automation to test the project repository:

```typescript
// Example browser automation pseudo-code
async function testRepository() {
  // 1. Initialize a browser session
  const browser = await automationTool.launch();
  
  // 2. Navigate to the repository
  await browser.navigateTo('https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch');
  
  // 3. Interact with the page
  const repoTitle = await browser.querySelector('strong[itemprop="name"] a').getText();
  
  // 4. Make assertions
  if (repoTitle !== 'zsh-nvm-pnpm-auto-switch') {
    throw new Error('Repository title mismatch');
  }
  
  // 5. Take a screenshot
  await browser.screenshot('repo-screenshot.png');
  
  // 6. Close the browser
  await browser.close();
}
```

## Manual Testing Approach

When testing documentation or examples manually:

1. Open the documentation site
2. Look for code examples and verify they're correct/up-to-date
3. Check installation instructions match the current version
4. Test code snippets in a local terminal

You can use browser developer tools to:
- Inspect the DOM
- Run JavaScript in the console
- Monitor network requests
- Capture screenshots

## Integration with ESLint Inspector

The MCP can be particularly useful for interacting with the ESLint inspector:

1. Launch the ESLint inspector with `pnpm lint:inspect`
2. Open http://localhost:7777 in your browser
3. Use browser automation to extract configuration information

Refer to the [eslint-config-inspector.md](./eslint-config-inspector.md) document for more details on this approach.