#!/usr/bin/env bash

# Installation script for zsh-nvm-pnpm-auto-switch

# Create plugin directory
PLUGIN_DIR="${HOME}/.zsh-nvm-pnpm-auto-switch"

echo "\n🔧 Installing zsh-nvm-pnpm-auto-switch plugin..."

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "\n⚠️  Git is required but not installed. Please install git first."
  exit 1
fi

# Clone repository if needed
if [ -d "$PLUGIN_DIR" ]; then
  echo "\n🔄 Updating existing installation..."
  cd "$PLUGIN_DIR" && git pull
else
  echo "\n📥 Downloading plugin..."
  git clone https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git "$PLUGIN_DIR"
fi

# Run the local install script
bash "${PLUGIN_DIR}/src/install.sh"
