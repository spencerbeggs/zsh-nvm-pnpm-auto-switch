#!/usr/bin/env zsh
# zsh-nvm-pnpm-auto-switch.plugin.zsh - Automatic Node.js version and pnpm package manager switcher

# Define variables to control plugin behavior
NODE_AUTO_SWITCH_DEBUG=${NODE_AUTO_SWITCH_DEBUG:-0}
export NODE_AUTO_SWITCH_WORKSPACE=${NODE_AUTO_SWITCH_WORKSPACE:-"$HOME/workspace"}
export NODE_AUTO_SWITCH_LIST_PROJECTS=${NODE_AUTO_SWITCH_LIST_PROJECTS:-0}

# Debug output function
_node_auto_switch_debug() {
  if [[ "$NODE_AUTO_SWITCH_DEBUG" == "1" ]]; then
    echo "[zsh-nvm-pnpm-auto-switch] $1"
  fi
}

# Function to detect and switch Node.js environment when changing directories
node_auto_switch() {
  local current_path=$(pwd)
  
  # Check if we're in the workspace directory and source our workspace config
  if [[ "$current_path" == "$NODE_AUTO_SWITCH_WORKSPACE" ]]; then
    _node_auto_switch_debug "In workspace directory: $NODE_AUTO_SWITCH_WORKSPACE"
    local workspace_config="$ZSH_CUSTOM/plugins/zsh-nvm-pnpm-auto-switch/workspace-config.zsh"
    if [[ -f "$workspace_config" ]]; then
      _node_auto_switch_debug "Sourcing workspace config"
      source "$workspace_config"
    fi
  fi

  # Check if we're in a Node.js package directory
  if [[ -f "package.json" ]]; then
    _node_auto_switch_debug "Node.js project detected"
    local current_node_version=$(node -v 2>/dev/null || echo "none")
    local desired_node_version=""
    local packageManager=""
    
    # Check for .npmrc file with Node.js version
    if [[ -f ".npmrc" ]]; then
      _node_auto_switch_debug ".npmrc file found"
      desired_node_version=$(grep "node-version" .npmrc | cut -d'=' -f2 | tr -d '[:space:]')
      
      # If we found a desired Node.js version
      if [[ -n "$desired_node_version" ]]; then
        _node_auto_switch_debug "Found node-version=$desired_node_version in .npmrc"
        
        # Add 'v' prefix if it doesn't have one
        if [[ ! "$desired_node_version" =~ ^v ]]; then
          desired_node_version="v$desired_node_version"
        fi
        
        # Check if we need to switch Node version
        if [[ "$current_node_version" != "$desired_node_version" ]]; then
          echo "📦 Switching to Node.js $desired_node_version"
          
          # Check if the version is installed
          if ! nvm ls "$desired_node_version" &>/dev/null; then
            echo "📥 Installing Node.js $desired_node_version"
            nvm install "$desired_node_version"
          fi
          
          # Switch to the desired version
          nvm use "$desired_node_version" &>/dev/null
        else
          _node_auto_switch_debug "Already using correct Node.js version: $current_node_version"
        fi
      else
        _node_auto_switch_debug "No node-version found in .npmrc"
      fi
    else
      _node_auto_switch_debug "No .npmrc file found"
    fi
    
    # Get the package manager from package.json
    if [[ -f "package.json" ]]; then
      packageManager=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null | cut -d'"' -f4 | cut -d'@' -f1)
      
      # If pnpm is the package manager, ensure corepack is enabled
      if [[ "$packageManager" == "pnpm" ]]; then
        _node_auto_switch_debug "pnpm detected as package manager"
        
        # Check if corepack is enabled
        if ! corepack --version &>/dev/null; then
          echo "🔧 Enabling corepack"
          corepack enable &>/dev/null
        else
          _node_auto_switch_debug "Corepack is already enabled"
        fi
        
        # Get desired pnpm version
        local desired_pnpm_version=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null | cut -d'"' -f4 | cut -d'@' -f2)
        local current_pnpm_version=$(pnpm --version 2>/dev/null || echo "none")
        
        _node_auto_switch_debug "Current pnpm: $current_pnpm_version, Desired: $desired_pnpm_version"
        
        # Check if we need to switch pnpm version
        if [[ "$current_pnpm_version" != "$desired_pnpm_version" ]]; then
          echo "🔄 Activating pnpm@$desired_pnpm_version"
          corepack prepare pnpm@$desired_pnpm_version --activate &>/dev/null
        else
          _node_auto_switch_debug "Already using correct pnpm version: $current_pnpm_version"
        fi
      else
        _node_auto_switch_debug "Package manager is not pnpm: $packageManager"
      fi
    fi
  fi
}

# Function to toggle debug mode
node_auto_switch_debug() {
  if [[ "$NODE_AUTO_SWITCH_DEBUG" == "1" ]]; then
    export NODE_AUTO_SWITCH_DEBUG=0
    echo "zsh-nvm-pnpm-auto-switch debug mode: OFF"
  else
    export NODE_AUTO_SWITCH_DEBUG=1
    echo "zsh-nvm-pnpm-auto-switch debug mode: ON"
  fi
}

# Function to toggle project listing
node_auto_switch_list_projects() {
  if [[ "$NODE_AUTO_SWITCH_LIST_PROJECTS" == "1" ]]; then
    export NODE_AUTO_SWITCH_LIST_PROJECTS=0
    echo "zsh-nvm-pnpm-auto-switch project listing: OFF"
  else
    export NODE_AUTO_SWITCH_LIST_PROJECTS=1
    echo "zsh-nvm-pnpm-auto-switch project listing: ON"
  fi
}

# Function to display and set workspace directory
node_auto_switch_workspace() {
  if [[ -n "$1" ]]; then
    export NODE_AUTO_SWITCH_WORKSPACE="$1"
    echo "Workspace directory set to: $NODE_AUTO_SWITCH_WORKSPACE"
  else
    echo "Current workspace directory: $NODE_AUTO_SWITCH_WORKSPACE"
    echo "To change it, run: node_auto_switch_workspace <new_path>"
  fi
}

# Add the function as a hook when directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd node_auto_switch

# Run once when a shell session starts
node_auto_switch