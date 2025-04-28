# zsh-nvm-pnpm-auto-switch

A ZSH plugin that automatically switches Node.js versions (using `nvm`) and manages `pnpm` package manager versions (using `corepack`) when changing directories.

## Features

- 🔄 Automatically detects and switches to the correct Node.js version specified in `.npmrc` files
- 📦 Handles `pnpm` package manager versions via Corepack
- 🚀 Seamlessly activates the correct environment when you `cd` into a project
- 🔧 Installs missing Node.js versions automatically when needed
- 🏠 Special workspace directory integration with optional project listing
- 😶 Silent operation by default - only shows messages when needed
- ⚙️ Interactive configuration via command line

## Requirements

- ZSH shell
- [Oh My Zsh](https://ohmyz.sh/) (recommended)
- [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager)
- Node.js with [Corepack](https://nodejs.org/api/corepack.html) support

## Installation

### From GitHub (recommended)

You can install the plugin directly from GitHub using one of the following methods:

#### Using Git

```bash
# Clone the repository into your oh-my-zsh custom plugins directory
git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch

# Run the interactive installation script
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/install.sh
```

#### Using curl

```bash
# Download and run the installer script
curl -fsSL https://raw.githubusercontent.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/main/install-remote.sh | zsh
```

#### Using wget

```bash
# Download and run the installer script
wget -O- https://raw.githubusercontent.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/main/install-remote.sh | zsh
```

### Unattended Installation

For automated/unattended installation (using default settings):

```bash
# Git-based installation with default settings
git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/install.sh --unattended

# Or with curl
curl -fsSL https://raw.githubusercontent.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/main/install-remote.sh | zsh -s -- --unattended

# Or with wget
wget -O- https://raw.githubusercontent.com/spencerbeggs/zsh-nvm-pnpm-auto-switch/main/install-remote.sh | zsh -s -- --unattended
```

### Manual installation

1. Copy `zsh-nvm-pnpm-auto-switch.plugin.zsh` to your ZSH plugins directory:
   ```bash
   cp zsh-nvm-pnpm-auto-switch.plugin.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/
   ```

2. Copy `workspace-config.zsh` to your ZSH plugins directory:
   ```bash
   cp workspace-config.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm-pnpm-auto-switch/
   ```

3. Add the plugin to your `.zshrc`:
   ```bash
   plugins=(... zsh-nvm-pnpm-auto-switch)
   ```

4. Add the required environment variables to your `.zshenv`:
   ```bash
   # Workspace directory for zsh-nvm-pnpm-auto-switch plugin
   export NODE_AUTO_SWITCH_WORKSPACE="$HOME/workspace"

   # Enable project listing in workspace (0=off, 1=on)
   export NODE_AUTO_SWITCH_LIST_PROJECTS=0

   # Enable debug mode for zsh-nvm-pnpm-auto-switch (0=off, 1=on)
   export NODE_AUTO_SWITCH_DEBUG=0
   ```

5. Restart your shell or run:
   ```bash
   source ~/.zshrc
   ```

## Usage

Once installed, the plugin works automatically:

1. When you `cd` into a directory containing a `package.json` file, the plugin activates.
2. If a `.npmrc` file exists with a `node-version` specification, the plugin switches to that version.
3. If the project uses `pnpm` (specified in the `packageManager` field of `package.json`), the plugin ensures Corepack is enabled and the correct pnpm version is activated.

The plugin only displays messages when it needs to switch Node.js versions or update package managers.

### Configuration Commands

The plugin provides several commands to control its behavior:

#### Interactive Configuration

```bash
# Run the interactive configuration wizard
node_auto_switch_configure
```

This command launches an interactive configuration wizard that helps you set up or change the plugin's settings. It shows current settings and allows you to update them with guided prompts. Changes are saved to your `.zshenv` file automatically.

#### Workspace Directory

```bash
# Set the workspace directory for the current session
node_auto_switch_workspace ~/dev

# Check the current workspace directory
node_auto_switch_workspace
```

#### Project Listing

```bash
# Toggle project listing on/off
node_auto_switch_list_projects
```

#### Debugging

```bash
# Toggle debug mode on/off
node_auto_switch_debug
```

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

Contributions are welcome! Please feel free to submit a Pull Request to the [GitHub repository](https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch).