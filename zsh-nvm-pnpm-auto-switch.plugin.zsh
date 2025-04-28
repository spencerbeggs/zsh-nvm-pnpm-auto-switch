#!/usr/bin/env zsh
# zsh-nvm-pnpm-auto-switch.plugin.zsh - Automatic Node.js version and pnpm package manager switcher

# Define variables to control plugin behavior
NVM_PNPM_AUTO_SWITCH_DEBUG=${NVM_PNPM_AUTO_SWITCH_DEBUG:-0}
export NVM_PNPM_AUTO_SWITCH_WORKSPACE=${NVM_PNPM_AUTO_SWITCH_WORKSPACE:-"$HOME/workspace"}
export NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS=${NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS:-0}

# Debug output function
_nvm_pnpm_auto_switch_debug() {
  if [[ "$NVM_PNPM_AUTO_SWITCH_DEBUG" == "1" ]]; then
    echo "[zsh-nvm-pnpm-auto-switch] $1"
  fi
}

# Function to detect and switch Node.js environment when changing directories
nvm_pnpm_auto_switch() {
  local current_path=$(pwd)
  
  # Check if we're in the workspace directory and source our workspace config
  if [[ "$current_path" == "$NVM_PNPM_AUTO_SWITCH_WORKSPACE" ]]; then
    _nvm_pnpm_auto_switch_debug "In workspace directory: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
    local workspace_config="$ZSH_CUSTOM/plugins/zsh-nvm-pnpm-auto-switch/workspace-config.zsh"
    if [[ -f "$workspace_config" ]]; then
      _nvm_pnpm_auto_switch_debug "Sourcing workspace config"
      source "$workspace_config"
    fi
  fi

  # Check if we're in a Node.js package directory
  if [[ -f "package.json" ]]; then
    _nvm_pnpm_auto_switch_debug "Node.js project detected"
    local current_node_version=$(node -v 2>/dev/null || echo "none")
    local desired_node_version=""
    local packageManager=""
    
    # Check for .npmrc file with Node.js version
    if [[ -f ".npmrc" ]]; then
      _nvm_pnpm_auto_switch_debug ".npmrc file found"
      desired_node_version=$(grep "node-version" .npmrc | cut -d'=' -f2 | tr -d '[:space:]')
      
      # If we found a desired Node.js version
      if [[ -n "$desired_node_version" ]]; then
        _nvm_pnpm_auto_switch_debug "Found node-version=$desired_node_version in .npmrc"
        
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
          _nvm_pnpm_auto_switch_debug "Already using correct Node.js version: $current_node_version"
        fi
      else
        _nvm_pnpm_auto_switch_debug "No node-version found in .npmrc"
      fi
    else
      _nvm_pnpm_auto_switch_debug "No .npmrc file found"
    fi
    
    # Get the package manager from package.json
    if [[ -f "package.json" ]]; then
      packageManager=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null | cut -d'"' -f4 | cut -d'@' -f1)
      
      # If pnpm is the package manager, ensure corepack is enabled
      if [[ "$packageManager" == "pnpm" ]]; then
        _nvm_pnpm_auto_switch_debug "pnpm detected as package manager"
        
        # Check if corepack is enabled
        if ! corepack --version &>/dev/null; then
          echo "🔧 Enabling corepack"
          corepack enable &>/dev/null
        else
          _nvm_pnpm_auto_switch_debug "Corepack is already enabled"
        fi
        
        # Get desired pnpm version
        local desired_pnpm_version=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null | cut -d'"' -f4 | cut -d'@' -f2)
        local current_pnpm_version=$(pnpm --version 2>/dev/null || echo "none")
        
        _nvm_pnpm_auto_switch_debug "Current pnpm: $current_pnpm_version, Desired: $desired_pnpm_version"
        
        # Check if we need to switch pnpm version
        if [[ "$current_pnpm_version" != "$desired_pnpm_version" ]]; then
          echo "🔄 Activating pnpm@$desired_pnpm_version"
          corepack prepare pnpm@$desired_pnpm_version --activate &>/dev/null
        else
          _nvm_pnpm_auto_switch_debug "Already using correct pnpm version: $current_pnpm_version"
        fi
      else
        _nvm_pnpm_auto_switch_debug "Package manager is not pnpm: $packageManager"
      fi
    fi
  fi
}

# Function to toggle debug mode
nvm_pnpm_auto_switch_debug() {
  if [[ "$NVM_PNPM_AUTO_SWITCH_DEBUG" == "1" ]]; then
    export NVM_PNPM_AUTO_SWITCH_DEBUG=0
    echo "zsh-nvm-pnpm-auto-switch debug mode: OFF"
  else
    export NVM_PNPM_AUTO_SWITCH_DEBUG=1
    echo "zsh-nvm-pnpm-auto-switch debug mode: ON"
  fi
}

# Function to toggle project listing
nvm_pnpm_auto_switch_list_projects() {
  if [[ "$NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS" == "1" ]]; then
    export NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS=0
    echo "zsh-nvm-pnpm-auto-switch project listing: OFF"
  else
    export NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS=1
    echo "zsh-nvm-pnpm-auto-switch project listing: ON"
  fi
}

# Function to display and set workspace directory
nvm_pnpm_auto_switch_workspace() {
  if [[ -n "$1" ]]; then
    export NVM_PNPM_AUTO_SWITCH_WORKSPACE="$1"
    echo "Workspace directory set to: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
  else
    echo "Current workspace directory: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
    echo "To change it, run: nvm_pnpm_auto_switch_workspace <new_path>"
  fi
}

# Function to show help information
nvm_pnpm_auto_switch_help() {
  echo "🚀 zsh-nvm-pnpm-auto-switch - Help"
  echo "======================================"
  echo ""
  echo "This plugin automatically switches Node.js versions and manages pnpm package"
  echo "manager versions when changing directories."
  echo ""
  echo "Available Commands:"
  echo ""
  echo "  nvm_pnpm_auto_switch_configure"
  echo "    Run the interactive configuration wizard to set up or update your settings."
  echo ""
  echo "  nvm_pnpm_auto_switch_workspace [path]"
  echo "    Without arguments, shows the current workspace directory."
  echo "    With a path argument, sets the workspace directory to the specified path."
  echo ""
  echo "  nvm_pnpm_auto_switch_list_projects"
  echo "    Toggle automatic project listing when entering your workspace directory."
  echo ""
  echo "  nvm_pnpm_auto_switch_debug"
  echo "    Toggle debug mode to show/hide detailed operation information."
  echo ""
  echo "  nvm_pnpm_auto_switch_help"
  echo "    Display this help information."
  echo ""
  echo "Environment Variables:"
  echo ""
  echo "  NVM_PNPM_AUTO_SWITCH_WORKSPACE"
  echo "    Path to your workspace directory. Default: $HOME/workspace"
  echo ""
  echo "  NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS"
  echo "    Enable project listing in workspace (0=off, 1=on). Default: 0"
  echo ""
  echo "  NVM_PNPM_AUTO_SWITCH_DEBUG"
  echo "    Enable debug mode (0=off, 1=on). Default: 0"
  echo ""
  echo "For more information, visit:"
  echo "https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch"
}

# Function to run interactive configuration
nvm_pnpm_auto_switch_configure() {
  echo "🔧 zsh-nvm-pnpm-auto-switch - Interactive Configuration"
  echo "================================================="
  echo ""
  
  # Current settings
  echo "Current settings:"
  echo "📂 Workspace directory: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
  echo "📋 Project listing: $([ "$NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS" -eq 1 ] && echo "enabled" || echo "disabled")"
  echo "🐛 Debug mode: $([ "$NVM_PNPM_AUTO_SWITCH_DEBUG" -eq 1 ] && echo "enabled" || echo "disabled")"
  echo ""
  
  # Ask for workspace directory
  echo "📂 What is your preferred workspace directory?"
  echo "   Current: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
  echo -n "   New directory path (press Enter to keep current): "
  read new_workspace_dir
  if [[ -n "$new_workspace_dir" ]]; then
    export NVM_PNPM_AUTO_SWITCH_WORKSPACE="$new_workspace_dir"
  fi
  
  # Ask about project listing
  echo ""
  echo "📋 Automatic project listing when entering your workspace?"
  echo "   This will show a list of available projects in your workspace directory."
  echo "   0 = Disabled (silent operation), 1 = Enabled"
  echo "   Current: $NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS"
  echo -n "   Enable project listing? (0/1, press Enter to keep current): "
  read new_list_projects
  if [[ -n "$new_list_projects" ]]; then
    export NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS="$new_list_projects"
  fi
  
  # Ask about debug mode
  echo ""
  echo "🐛 Debug mode?"
  echo "   This will show detailed debug information about the plugin's operations."
  echo "   0 = Disabled, 1 = Enabled"
  echo "   Current: $NVM_PNPM_AUTO_SWITCH_DEBUG"
  echo -n "   Enable debug mode? (0/1, press Enter to keep current): "
  read new_debug_mode
  if [[ -n "$new_debug_mode" ]]; then
    export NVM_PNPM_AUTO_SWITCH_DEBUG="$new_debug_mode"
  fi
  
  echo ""
  echo "Updated settings:"
  echo "📂 Workspace directory: $NVM_PNPM_AUTO_SWITCH_WORKSPACE"
  echo "📋 Project listing: $([ "$NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS" -eq 1 ] && echo "enabled" || echo "disabled")"
  echo "🐛 Debug mode: $([ "$NVM_PNPM_AUTO_SWITCH_DEBUG" -eq 1 ] && echo "enabled" || echo "disabled")"
  
  # Update environment variables in .zshenv
  local ZSHENV="$HOME/.zshenv"
  
  # Function to update or add environment variable
  update_env_var() {
    local var_name="$1"
    local var_value="$2"
    local var_comment="$3"
    
    # Check if variable exists in file
    if grep -q "^export $var_name=" "$ZSHENV"; then
      # Update existing variable
      sed -i.bak "s|^export $var_name=.*|export $var_name=\"$var_value\" # $var_comment|" "$ZSHENV"
    else
      # Add new variable
      echo "" >> "$ZSHENV"
      echo "# $var_comment" >> "$ZSHENV"
      echo "export $var_name=\"$var_value\"" >> "$ZSHENV"
    fi
  }
  
  echo ""
  echo "Saving settings to ~/.zshenv..."
  update_env_var "NVM_PNPM_AUTO_SWITCH_WORKSPACE" "$NVM_PNPM_AUTO_SWITCH_WORKSPACE" "Workspace directory for zsh-nvm-pnpm-auto-switch plugin"
  update_env_var "NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS" "$NVM_PNPM_AUTO_SWITCH_LIST_PROJECTS" "Enable project listing in workspace (0=off, 1=on)"
  update_env_var "NVM_PNPM_AUTO_SWITCH_DEBUG" "$NVM_PNPM_AUTO_SWITCH_DEBUG" "Enable debug mode for zsh-nvm-pnpm-auto-switch (0=off, 1=on)"
  
  echo "✅ Configuration saved successfully!"
}

# Add the function as a hook when directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd nvm_pnpm_auto_switch

# Run once when a shell session starts
nvm_pnpm_auto_switch

# Alias 'man' to 'help' for easier discovery
alias nvm_pnpm_auto_switch_man="nvm_pnpm_auto_switch_help"

# For backward compatibility, create aliases for old function names
alias node_auto_switch_debug="nvm_pnpm_auto_switch_debug"
alias node_auto_switch_list_projects="nvm_pnpm_auto_switch_list_projects"
alias node_auto_switch_workspace="nvm_pnpm_auto_switch_workspace"
alias node_auto_switch_configure="nvm_pnpm_auto_switch_configure"
alias node_auto_switch_help="nvm_pnpm_auto_switch_help"
alias node_auto_switch_man="nvm_pnpm_auto_switch_help"