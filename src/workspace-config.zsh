#!/usr/bin/env zsh

# Check if we've shown the configuration setup prompts before
if [[ ! -f "${ZSH_NPA_DIR}/.configured" ]]; then
  echo "\n🔧 zsh-nvm-pnpm-auto-switch setup"
  
  # Check if nvm is installed
  if ! command -v nvm &> /dev/null; then
    echo "\n⚠️  NVM not found. You need to install NVM first:"
    echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
    echo "\nAfter installing, restart your terminal and run 'source ${ZSH_NPA_DIR}/src/zsh-nvm-pnpm-auto-switch.plugin.zsh'\n"
    return 1
  fi
  
  # Everything is set up correctly
  echo "\n✅ Configuration complete!"
  echo "The plugin will automatically switch Node.js versions when you change directories."
  echo "Just add an .nvmrc file to your projects with the desired Node.js version.\n"
  
  # Create a marker file to avoid showing this again
  touch "${ZSH_NPA_DIR}/.configured"
fi
