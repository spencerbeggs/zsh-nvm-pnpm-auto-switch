#!/usr/bin/env bash

# Installation script for zsh-nvm-pnpm-auto-switch
# This script downloads and installs the plugin from GitHub releases

# Create plugin directory
PLUGIN_DIR="${HOME}/.zsh-nvm-pnpm-auto-switch"

printf "\n🔧 Installing zsh-nvm-pnpm-auto-switch plugin...\n"

# Check for curl or wget
if command -v curl &> /dev/null; then
  DOWNLOADER="curl"
elif command -v wget &> /dev/null; then
  DOWNLOADER="wget"
else
  printf "\n⚠️ Error: Neither curl nor wget found. Please install one of them and try again.\n"
  exit 1
fi

# Create the plugin directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

# Download the plugin files
printf "\n📥 Downloading plugin files...\n"

REPO_URL="https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch"

if [ "$DOWNLOADER" = "curl" ]; then
  curl -fsSL "${REPO_URL}/releases/latest/download/zsh-nvm-pnpm-auto-switch.plugin.zsh" -o "${PLUGIN_DIR}/zsh-nvm-pnpm-auto-switch.plugin.zsh"
  curl -fsSL "${REPO_URL}/releases/latest/download/workspace-config.zsh" -o "${PLUGIN_DIR}/workspace-config.zsh"
else
  wget -q "${REPO_URL}/releases/latest/download/zsh-nvm-pnpm-auto-switch.plugin.zsh" -O "${PLUGIN_DIR}/zsh-nvm-pnpm-auto-switch.plugin.zsh"
  wget -q "${REPO_URL}/releases/latest/download/workspace-config.zsh" -O "${PLUGIN_DIR}/workspace-config.zsh"
fi

printf "\n✅ Plugin files downloaded to %s\n" "$PLUGIN_DIR"

# Add to .zshrc if not already there
if ! grep -q "zsh-nvm-pnpm-auto-switch" "$HOME/.zshrc"; then
  printf "\n# Load zsh-nvm-pnpm-auto-switch\nsource %s/zsh-nvm-pnpm-auto-switch.plugin.zsh\n" "$PLUGIN_DIR" >> "$HOME/.zshrc"
  printf "\n✅ Plugin added to .zshrc\n"
  printf "\n🎉 Installation complete! Please restart your terminal or run:\n"
  printf "   source ~/.zshrc\n\n"
else
  printf "\n✅ Plugin already in .zshrc\n"
  printf "\n🎉 Update complete! Please restart your terminal or run:\n"
  printf "   source ~/.zshrc\n\n"
fi