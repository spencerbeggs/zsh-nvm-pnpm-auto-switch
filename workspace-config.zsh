#!/usr/bin/env zsh
# workspace-config.zsh - Configuration for workspace directory

# This script runs automatically when you enter the workspace directory
# Customize it as needed for your specific workspace setup

# Check if we're in the configured workspace directory
if [[ "$(pwd)" == "$NODE_AUTO_SWITCH_WORKSPACE" ]]; then
  # You can set a default Node.js version for the workspace directory
  # Uncomment the next line and set your preferred version
  # nvm use 18

  # List project directories if enabled
  if [[ "$NODE_AUTO_SWITCH_LIST_PROJECTS" == "1" ]]; then
    # Output a welcome message
    echo "📂 Welcome to your workspace at $NODE_AUTO_SWITCH_WORKSPACE!"
    echo "🚀 Listing available projects..."
    
    # List project directories (without node_modules, .git, etc.)
    echo "\n📦 Available projects:"
    find . -maxdepth 1 -type d \
      ! -path "*/\.*" \
      ! -path "*/node_modules" \
      ! -path "." \
      -exec basename {} \; | sort | 
      awk '{print "  - " $0}'
      
    echo "\nTo disable project listing, run: node_auto_switch_list_projects"
  elif [[ "$NODE_AUTO_SWITCH_DEBUG" == "1" ]]; then
    # Only show messages in debug mode if project listing is off
    echo "[node-auto-switch] In workspace directory (project listing disabled)"
    echo "[node-auto-switch] To enable project listing, run: node_auto_switch_list_projects"
  fi
  # Silent operation when both project listing and debug are off
fi