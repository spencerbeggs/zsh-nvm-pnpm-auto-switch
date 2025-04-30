#!/usr/bin/env bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Function to detect shell and config file
setup_shell_integration() {
  local zshrc="${HOME}/.zshrc"
  local plugin_source_line="source ${PLUGIN_DIR}/src/zsh-nvm-pnpm-auto-switch.plugin.zsh"
  
  # Check if zshrc file exists
  if [ -f "$zshrc" ]; then
    # Check if plugin is already sourced in zshrc
    if ! grep -q "${plugin_source_line}" "$zshrc"; then
      printf "\nAdding plugin to %s\n" "$zshrc"
      echo "$plugin_source_line" >> "$zshrc"
      echo "✅ Installation complete! Please restart your terminal or run 'source $zshrc'."
    else
      echo "✅ Plugin is already installed in $zshrc"
    fi
  else
    printf "\n⚠️  Could not find %s\n" "$zshrc"
    echo "Please add the following line to your shell configuration file:"
    echo "$plugin_source_line"
  fi
}

# Ensure script has execute permissions
chmod +x "${PLUGIN_DIR}/src/zsh-nvm-pnpm-auto-switch.plugin.zsh"
chmod +x "${PLUGIN_DIR}/src/workspace-config.zsh"

# Main installation
printf "\n🔧 Installing zsh-nvm-pnpm-auto-switch plugin...\n"
setup_shell_integration
