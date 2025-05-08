# zsh-nvm-pnpm-auto-switch

[![Main Branch](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/actions/workflows/release.yml/badge.svg?branch=main&event=push)](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/actions/workflows/release.yml)
[![Pull Request](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/actions/workflows/pull-request.yml/badge.svg?event=pull_request)](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/actions/workflows/pull-request.yml)
[![Semantic Release](https://img.shields.io/badge/semantic--release-conventional-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

A ZSH plugin that automatically switches Node.js versions (using `nvm`) and manages `pnpm` package manager versions (using `corepack`) when changing directories.

## Features

- 🔄 Automatically detects and switches to the correct Node.js version specified in `.npmrc` files
- 📦 Handles `pnpm` package manager versions via Corepack
- 🚀 Seamlessly activates the correct environment when you `cd` into a project
- 🔧 Installs missing Node.js versions automatically when needed
- 🏠 Special workspace directory integration with optional project listing
- 😶 Silent operation by default - only shows messages when needed
- ⚙️ Interactive configuration via command line
- 🔁 Smart installation/update process that preserves existing settings
- 📖 Built-in help system with detailed command documentation
- 🔄 Self-update capability to keep the plugin current
- 🗑️ Clean uninstallation option to remove all traces of the plugin

## Requirements

- ZSH shell
- [Oh My Zsh](https://ohmyz.sh/) (recommended)
- [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager)
- Node.js with [Corepack](https://nodejs.org/api/corepack.html) support

## Installation

You can install the plugin directly from GitHub using one of the following methods:

### From GitHub (reccomended)

For automated/unattended installation (using default settings):

```bash
git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch && ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/src/install.sh --unattended
```

Download and run the installer wizard:

```bash
git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch && ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/src/install.sh
```

### Using curl

For automated/unattended installation (using default settings):

```bash
curl -fsSL https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/releases/latest/download/install-remote.sh | zsh -c "zsh /dev/stdin --unattended"
```

Download and run the installer wizard:

```bash
curl -fsSL https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/releases/latest/download/install-remote.sh -o /tmp/install-remote.sh && zsh /tmp/install-remote.sh
```

### Using wget

For automated/unattended installation (using default settings):

```bash
wget -O- https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/releases/latest/download/install-remote.sh | zsh -c "zsh /dev/stdin --unattended"
```

Download and run the installer wizard:

```bash
wget -O /tmp/install-remote.sh https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/releases/latest/download/install-remote.sh && zsh /tmp/install-remote.sh
```

> **Note:** These installation methods use GitHub's `/releases/latest` endpoint, which automatically redirects to the most recent stable release.

### Updating the Plugin

To update the plugin to the latest version, you can use the built-in update command:

```bash
# Update the plugin to the latest version
nvm_pnpm_auto_switch_update
```

This command will automatically detect the best method to update the plugin (Git, curl, or wget), and will handle the update process for you.

Alternatively, you can manually update using one of the installation methods:

```bash
# If you used Git
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch
git pull
./src/install.sh

# Or use the remote installer again
curl -fsSL https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/releases/latest/download/install-remote.sh | zsh
```

Using the `nvm_pnpm_auto_switch_update` command will run the update in unattended mode, preserving your existing configuration. If you want to update and reconfigure your settings, you can use one of the manual update methods.

### Uninstalling the Plugin

To remove the plugin and all related files and settings, use the built-in uninstall command:

```bash
# Uninstall the plugin
nvm_pnpm_auto_switch_uninstall
```

This command will:

- Remove all environment variables from your `.zshenv` file
- Remove the plugin from your `.zshrc` file
- Delete the plugin directory
- Unset all environment variables for the current session
- Provide instructions for completing the uninstallation

### Manual installation

1. Copy the plugin files to your ZSH plugins directory:

    ```bash
    # Create the plugin directory if it doesn't exist
    mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch

    # Copy the main plugin file
    cp src/zsh-nvm-pnpm-auto-switch.plugin.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/

    # Copy the workspace configuration file
    cp src/workspace-config.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/
    ```

2. Add the plugin to your `.zshrc`:

    ```bash
    plugins=(... zsh-nvm-pnpm-auto-switch)
    ```

3. Add the required environment variables to your `.zshenv`:

    ```bash
    # Workspace directory for zsh-nvm-pnpm-auto-switch plugin
    export NVM_PNPM_AUTO_SWITCH_WORKSPACE="$HOME/workspace"

    # Enable project listing in workspace (0=off, 1=on)
    export NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS=0

    # Enable debug mode for zsh-nvm-pnpm-auto-switch (0=off, 1=on)
    export NVM_PNPM_AUTO_SWITCH_DEBUG=0
    ```

4. Restart your shell or run:
    ```bash
    source ~/.zshrc
    ```

## Usage

Once installed, the plugin works automatically:

1. When you `cd` into a directory containing a `package.json` file, the plugin activates.
2. If a `.npmrc` file exists with a `node-version` specification, the plugin switches to that version.
3. If the project uses `pnpm` (specified in the `packageManager` field of `package.json`), the plugin ensures Corepack is enabled and the correct pnpm version is activated.

The plugin only displays messages when it needs to switch Node.js versions or update package managers.

## Available Commands

After installation, the following commands are available to help you manage the plugin:

| Command                                 | Description                                                      |
| --------------------------------------- | ---------------------------------------------------------------- |
| `nvm_pnpm_auto_switch_help`             | Display detailed help information about all available commands   |
| `nvm_pnpm_auto_switch_man`              | Alias for `nvm_pnpm_auto_switch_help`                            |
| `nvm_pnpm_auto_switch_configure`        | Run the interactive configuration wizard                         |
| `nvm_pnpm_auto_switch_workspace [path]` | View or change the workspace directory                           |
| `nvm_pnpm_auto_switch_list_projects`    | Toggle automatic project listing on/off                          |
| `nvm_pnpm_auto_switch_debug`            | Toggle debug mode on/off                                         |
| `nvm_pnpm_auto_switch_update`           | Update the plugin to the latest version from GitHub              |
| `nvm_pnpm_auto_switch_uninstall`        | Uninstall the plugin and clean up all related files and settings |

### Help and Documentation

```bash
# Display full help information
nvm_pnpm_auto_switch_help

# Alias for help (same as above)
nvm_pnpm_auto_switch_man
```

The help command provides detailed information about all available commands and environment variables. It's a great starting point if you're new to the plugin or need a refresher on what commands are available.

### Interactive Configuration

```bash
# Run the interactive configuration wizard
nvm_pnpm_auto_switch_configure
```

This command launches an interactive configuration wizard that helps you set up or change the plugin's settings. It shows current settings and allows you to update them with guided prompts. Changes are saved to your `.zshenv` file automatically.

### Workspace Directory Management

```bash
# Check the current workspace directory
nvm_pnpm_auto_switch_workspace

# Set a new workspace directory
nvm_pnpm_auto_switch_workspace ~/dev
```

The workspace directory is a special directory where you can enable additional features like project listing. By default, this is set to `~/workspace`, but you can change it to any directory you prefer.

### Project Listing Control

```bash
# Toggle project listing on/off
nvm_pnpm_auto_switch_list_projects
```

When project listing is enabled, the plugin will display a list of available projects when you enter your workspace directory. This is useful for quickly seeing what projects are available.

### Debug Mode

```bash
# Toggle debug mode on/off
nvm_pnpm_auto_switch_debug
```

Debug mode provides detailed information about what the plugin is doing, which can be helpful for troubleshooting. When enabled, you'll see messages about detected Node.js versions, package managers, and more.

### Updating the Plugin

```bash
# Update the plugin to the latest version
nvm_pnpm_auto_switch_update
```

This command will automatically update the plugin to the latest version from GitHub. It will try to use Git if you installed via git clone, or fall back to curl or wget if necessary.

### Uninstalling the Plugin

```bash
# Remove the plugin and clean up all related files and settings
nvm_pnpm_auto_switch_uninstall
```

If you no longer want to use the plugin, this command will completely remove it and clean up all related files and settings. It will ask for confirmation before proceeding.

## Environment Variables

The plugin uses the following environment variables to control its behavior:

| Variable                             | Description                                       | Default           |
| ------------------------------------ | ------------------------------------------------- | ----------------- |
| `NVM_PNPM_AUTO_SWITCH_WORKSPACE`     | Path to your workspace directory                  | `$HOME/workspace` |
| `NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS` | Enable project listing in workspace (0=off, 1=on) | `0`               |
| `NVM_PNPM_AUTO_SWITCH_DEBUG`         | Enable debug mode (0=off, 1=on)                   | `0`               |

You can set these variables in your `.zshenv` file manually, or use the `nvm_pnpm_auto_switch_configure` command to set them interactively.

## Example Files

### .npmrc with Node.js version

```
node-version=18.16.0
```

### package.json with package manager specification

```json
{
	"name": "my-project",
	"packageManager": "pnpm@8.15.1"
}
```

## How It Works

The plugin hooks into ZSH's `chpwd` function which is triggered whenever you change directories. It then:

1. Checks if the current directory is your configured workspace
2. Checks if the current directory is a Node.js project
3. Reads the Node.js version from `.npmrc`
4. Switches Node versions using nvm if needed
5. Checks if the project uses pnpm as its package manager
6. Enables Corepack and activates the correct pnpm version if needed

## License

MIT

## Contributing

Contributions are welcome! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute to this project. For security-related issues, please review our [SECURITY.md](SECURITY.md) file.
