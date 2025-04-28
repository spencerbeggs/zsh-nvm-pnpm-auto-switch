# Security Policy

## Supported Versions

We currently support the following versions of zsh-nvm-pnpm-auto-switch with security updates:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Security Considerations

This plugin operates with the following security considerations:

1. **Shell Script Execution**: The plugin executes shell commands and runs script code in your shell environment. Only install this plugin if you trust the source.

2. **Node.js Version Management**: This plugin automatically switches Node.js versions based on `.npmrc` configuration files in your projects. Review these configuration files carefully, especially in projects you don't fully trust.

3. **Package Manager Integration**: The plugin interfaces with the pnpm package manager via Corepack. Be aware of the security implications of automatic package manager version switching.

## Reporting a Vulnerability

If you discover a security vulnerability within zsh-nvm-pnpm-auto-switch, please follow these steps:

1. **Do Not** disclose the vulnerability publicly until it has been addressed.
2. Report the vulnerability by opening an issue on GitHub with the title "Security Issue - Private" and we will change it to a private security issue.
3. Provide a detailed description of the vulnerability and steps to reproduce if possible.
4. We will acknowledge receipt of your vulnerability report as soon as possible and keep you informed of our progress towards a fix.

## Best Practices for Users

To use this plugin securely:

1. Always review the plugin code before installation, especially after updates.
2. Verify shell scripts using the built-in syntax check: `zsh -n script.zsh`
3. Use the debug mode (`nvm_pnpm_auto_switch_debug`) to monitor the plugin's actions when working with untrusted projects.
4. Keep the plugin updated to the latest version to receive security fixes.

## Development Practices

This project follows these security development practices:

1. All code is reviewed for security issues before being merged into the main branch.
2. Automated syntax checks are run on all pull requests.
3. Dependencies are kept to a minimum to reduce the attack surface.
4. We regularly scan the codebase for security vulnerabilities.

## Contact

For sensitive security issues, please contact the project maintainer directly rather than opening a public GitHub issue.
