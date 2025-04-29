#!/usr/bin/env zsh

# Get absolute path to the directory where this script resides
ZSH_NPA_DIR="${0:a:h:h}"

# Load workspace config
source "${ZSH_NPA_DIR}/src/workspace-config.zsh"

# Function to switch Node.js version using nvm
autoload -U add-zsh-hook

zsh_nvm_auto_switch() {
  local node_version
  # Check for .nvmrc
  if [[ -f ".nvmrc" ]]; then
    node_version=$(cat .nvmrc)
    # Only switch if version is different
    if [[ "$(nvm current)" != "$node_version" ]]; then
      nvm use "$node_version"
    fi
  fi

  # Check for pnpm version
  if [[ -f "package.json" ]]; then
    # Check if pnpm is specified in package.json engines field
    if [[ -n $(grep -E '"pnpm"\s*:\s*".*"' package.json) ]]; then
      # Use pnpm if available, otherwise use the pnpm version specified in package.json
      if ! command -v pnpm &> /dev/null; then
        npm i -g pnpm
      else
        local pnpm_version
        pnpm_version=$(grep -E '"pnpm"\s*:\s*"(.*)"' package.json | sed -E 's/.*"pnpm"\s*:\s*"(.*)",.*/\1/')
        local current_pnpm_version
        current_pnpm_version=$(pnpm --version)
        
        if [[ "$pnpm_version" != "$current_pnpm_version" ]]; then
          echo "Switching to pnpm $pnpm_version (from $current_pnpm_version)"
          npm i -g "pnpm@$pnpm_version"
        fi
      fi
    fi
  fi
}

# Register hook to run on directory change
add-zsh-hook chpwd zsh_nvm_auto_switch

# Run once when shell starts
zsh_nvm_auto_switch
