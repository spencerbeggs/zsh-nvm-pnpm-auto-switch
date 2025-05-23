#!/usr/bin/env bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

printf "\n🔍 ZSH NVM PNPM Auto Switch - Debug Info\n\n"

# Check ZSH availability
echo "1. ZSH Check:"
if command -v zsh &> /dev/null; then
  echo "   ✅ ZSH is installed: $(zsh --version)"
else
  echo "   ❌ ZSH is not installed"
fi

# Check NVM availability
printf "\n2. NVM Check:\n"
if [ -d "${HOME}/.nvm" ] || [ -d "${NVM_DIR}" ]; then
  echo "   ✅ NVM installation detected"
  if command -v nvm &> /dev/null; then
    echo "   ✅ NVM is available in current shell: $(nvm --version)"
  else
    echo "   ⚠️  NVM is installed but not loaded in current shell"
  fi
else
  echo "   ❌ NVM installation not found"
fi

# Check plugin installation
printf "\n3. Plugin Installation Check:\n"
ZSHRC="${HOME}/.zshrc"
PLUGIN_SOURCE_LINE="source ${PLUGIN_DIR}/src/zsh-nvm-pnpm-auto-switch.plugin.zsh"

if [ -f "$ZSHRC" ]; then
  if grep -q "${PLUGIN_SOURCE_LINE}" "$ZSHRC"; then
    echo "   ✅ Plugin is correctly sourced in $ZSHRC"
  else
    echo "   ❌ Plugin is not sourced in $ZSHRC"
  fi
else
  echo "   ⚠️  $ZSHRC not found"
fi

# Check plugin files
printf "\n4. Plugin Files Check:\n"
if [ -f "${PLUGIN_DIR}/src/zsh-nvm-pnpm-auto-switch.plugin.zsh" ]; then
  echo "   ✅ Main plugin file exists"
else
  echo "   ❌ Main plugin file missing"
fi

if [ -f "${PLUGIN_DIR}/src/workspace-config.zsh" ]; then
  echo "   ✅ Config file exists"
else
  echo "   ❌ Config file missing"
fi

printf "\n5. PNPM Check:\n"
if command -v pnpm &> /dev/null; then
  echo "   ✅ PNPM is installed: $(pnpm --version)"
else
  echo "   ℹ️  PNPM is not installed (will be installed automatically when needed)"
fi

printf "\n🔧 If you're having issues, try running:\n\n"
printf "source %s/src/zsh-nvm-pnpm-auto-switch.plugin.zsh\n\n" "${PLUGIN_DIR}"
