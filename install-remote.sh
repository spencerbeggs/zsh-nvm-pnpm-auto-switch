#!/usr/bin/env zsh
# Remote installer for zsh-nvm-pnpm-auto-switch plugin

echo "🚀 Installing/updating zsh-nvm-pnpm-auto-switch plugin..."

# Parse arguments
UNATTENDED=0
for arg in "$@"; do
  if [[ "$arg" == "--unattended" ]]; then
    UNATTENDED=1
    break
  fi
done

# Set up variables
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
PLUGIN_NAME="zsh-nvm-pnpm-auto-switch"
PLUGIN_DIR="$ZSH_CUSTOM/plugins/$PLUGIN_NAME"
REPO_URL="https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch"

# Check if the plugin is already installed
PLUGIN_INSTALLED=0
if [[ -d "$PLUGIN_DIR" ]]; then
  PLUGIN_INSTALLED=1
  if [[ "$UNATTENDED" -eq 0 ]]; then
    echo "🔄 Updating zsh-nvm-pnpm-auto-switch..."
  fi
else
  if [[ "$UNATTENDED" -eq 0 ]]; then
    echo "📥 Installing zsh-nvm-pnpm-auto-switch..."
  fi
fi

# Create plugin directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

echo "📥 Downloading plugin from $REPO_URL..."

# Download the plugin files
curl -fsSL "$REPO_URL/raw/main/$PLUGIN_NAME.plugin.zsh" -o "$PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh"
curl -fsSL "$REPO_URL/raw/main/workspace-config.zsh" -o "$PLUGIN_DIR/workspace-config.zsh"

# Make the plugin executable
chmod +x "$PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh"

# Skip configuration if it's an update and we're in unattended mode
if [[ "$PLUGIN_INSTALLED" -eq 1 && "$UNATTENDED" -eq 1 ]]; then
  echo "🔄 Updated plugin files successfully!"
  echo "Run 'node_auto_switch_configure' if you want to change your settings."
  exit 0
fi

# Default values
DEFAULT_WORKSPACE="$HOME/workspace"
DEFAULT_LIST_PROJECTS=0
DEFAULT_DEBUG=0

# Read existing values from .zshenv if present
if [[ -f "$HOME/.zshenv" ]]; then
  existing_workspace=$(grep "^export NODE_AUTO_SWITCH_WORKSPACE=" "$HOME/.zshenv" | sed 's/^export NODE_AUTO_SWITCH_WORKSPACE="\(.*\)".*$/\1/')
  existing_list_projects=$(grep "^export NODE_AUTO_SWITCH_LIST_PROJECTS=" "$HOME/.zshenv" | sed 's/^export NODE_AUTO_SWITCH_LIST_PROJECTS=\(.*\) #.*$/\1/')
  existing_debug=$(grep "^export NODE_AUTO_SWITCH_DEBUG=" "$HOME/.zshenv" | sed 's/^export NODE_AUTO_SWITCH_DEBUG=\(.*\) #.*$/\1/')
  
  [[ -n "$existing_workspace" ]] && DEFAULT_WORKSPACE="$existing_workspace"
  [[ -n "$existing_list_projects" ]] && DEFAULT_LIST_PROJECTS="$existing_list_projects"
  [[ -n "$existing_debug" ]] && DEFAULT_DEBUG="$existing_debug"
fi

# Interactive configuration unless unattended
if [[ "$UNATTENDED" -eq 0 ]]; then
  if [[ "$PLUGIN_INSTALLED" -eq 1 ]]; then
    echo "🔧 Would you like to update your plugin configuration?"
    echo -n "   (y/n, press Enter for n): "
    read update_config
    if [[ "$update_config" != "y" && "$update_config" != "Y" ]]; then
      echo "✅ Plugin updated without changing your configuration."
      echo "Run 'node_auto_switch_configure' if you want to change your settings later."
      exit 0
    fi
  fi

  echo "🔧 zsh-nvm-pnpm-auto-switch - Interactive Setup"
  echo "========================================"
  echo ""
  
  # Ask for workspace directory
  echo "📂 What is your preferred workspace directory?"
  echo "   Default: $DEFAULT_WORKSPACE"
  echo -n "   Directory path (press Enter for default): "
  read workspace_dir
  workspace_dir=${workspace_dir:-$DEFAULT_WORKSPACE}
  
  # Ask about project listing
  echo ""
  echo "📋 Do you want to enable automatic project listing when entering your workspace?"
  echo "   This will show a list of available projects in your workspace directory."
  echo "   0 = Disabled (silent operation), 1 = Enabled"
  echo -n "   Enable project listing? (0/1, press Enter for default: $DEFAULT_LIST_PROJECTS): "
  read list_projects
  list_projects=${list_projects:-$DEFAULT_LIST_PROJECTS}
  
  # Ask about debug mode
  echo ""
  echo "🐛 Do you want to enable debug mode by default?"
  echo "   This will show detailed debug information about the plugin's operations."
  echo "   0 = Disabled, 1 = Enabled"
  echo -n "   Enable debug mode? (0/1, press Enter for default: $DEFAULT_DEBUG): "
  read debug_mode
  debug_mode=${debug_mode:-$DEFAULT_DEBUG}
else
  # Use defaults in unattended mode
  workspace_dir=$DEFAULT_WORKSPACE
  list_projects=$DEFAULT_LIST_PROJECTS
  debug_mode=$DEFAULT_DEBUG
  echo "🤖 Running in unattended mode, using default or existing settings"
fi

# Add environment variables to zshenv if they don't exist
ZSHENV="$HOME/.zshenv"
touch "$ZSHENV"

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

# Update environment variables
update_env_var "NODE_AUTO_SWITCH_WORKSPACE" "$workspace_dir" "Workspace directory for zsh-nvm-pnpm-auto-switch plugin"
update_env_var "NODE_AUTO_SWITCH_LIST_PROJECTS" "$list_projects" "Enable project listing in workspace (0=off, 1=on)"
update_env_var "NODE_AUTO_SWITCH_DEBUG" "$debug_mode" "Enable debug mode for zsh-nvm-pnpm-auto-switch (0=off, 1=on)"

# Check if oh-my-zsh is sourced in .zshrc
if ! grep -q "source \$ZSH/oh-my-zsh.sh" "$HOME/.zshrc"; then
  echo "⚠️ Warning: oh-my-zsh.sh is not sourced in your .zshrc"
  echo "Adding 'source \$ZSH/oh-my-zsh.sh' to your .zshrc"
  echo "source \$ZSH/oh-my-zsh.sh" >> "$HOME/.zshrc"
fi

# Function to add plugin to plugins array in .zshrc
add_plugin_to_zshrc() {
  local zshrc="$HOME/.zshrc"
  local plugin_name="$1"
  local plugins_added=0

  # Check if plugins array exists
  if grep -q "^plugins=(" "$zshrc"; then
    # Check if the plugin is already in the list
    if grep -q "plugins=.*$plugin_name" "$zshrc"; then
      echo "✅ Plugin already in plugins array in .zshrc"
      plugins_added=1
    else
      # Try to add the plugin to the existing plugins array
      # First, attempt to add it at the end of a single-line plugins definition
      if grep -q "^plugins=([^)]*)" "$zshrc"; then
        sed -i.bak "s/^plugins=(\([^)]*\))/plugins=(\1 $plugin_name)/" "$zshrc"
        if grep -q "plugins=.*$plugin_name" "$zshrc"; then
          echo "✅ Added plugin to existing plugins array in .zshrc"
          plugins_added=1
        fi
      fi
      
      # If that didn't work, try to add it to a multi-line plugins definition
      if [[ "$plugins_added" -eq 0 ]]; then
        # Find the line number of the closing parenthesis of the plugins array
        local closing_line=$(grep -n "^)" "$zshrc" | head -1 | cut -d':' -f1)
        if [[ -n "$closing_line" ]]; then
          # Insert the plugin before the closing parenthesis
          sed -i.bak "${closing_line}i\\  $plugin_name" "$zshrc"
          if grep -q "$plugin_name" "$zshrc"; then
            echo "✅ Added plugin to multi-line plugins array in .zshrc"
            plugins_added=1
          fi
        fi
      fi
    fi
  fi
  
  # If no plugins array found or couldn't add to existing one, create a new plugins array
  if [[ "$plugins_added" -eq 0 ]]; then
    echo "⚠️ Warning: Could not find or modify existing plugins array in .zshrc"
    echo "Adding a new plugins array with this plugin"
    echo "" >> "$zshrc"
    echo "# Added by $plugin_name installer" >> "$zshrc"
    echo "plugins=($plugin_name)" >> "$zshrc"
    if grep -q "plugins=.*$plugin_name" "$zshrc"; then
      echo "✅ Created new plugins array in .zshrc"
      plugins_added=1
    else
      echo "❌ Error: Failed to add plugin to .zshrc"
      echo "Please manually add the following line to your .zshrc:"
      echo "plugins=($plugin_name)"
    fi
  fi
  
  return $((1 - plugins_added))
}

# Only try to add to .zshrc if it's a fresh installation
if [[ "$PLUGIN_INSTALLED" -eq 0 ]]; then
  # Add the plugin to the plugins array
  add_plugin_to_zshrc "$PLUGIN_NAME"
fi

if [[ "$PLUGIN_INSTALLED" -eq 1 ]]; then
  if [[ "$UNATTENDED" -eq 0 ]]; then
    echo ""
    echo "✅ zsh-nvm-pnpm-auto-switch updated successfully with your settings!"
    echo "📂 Workspace directory: $workspace_dir"
    echo "📋 Project listing: $([ "$list_projects" -eq 1 ] && echo "enabled" || echo "disabled")"
    echo "🐛 Debug mode: $([ "$debug_mode" -eq 1 ] && echo "enabled" || echo "disabled")"
  else
    echo "✅ zsh-nvm-pnpm-auto-switch updated successfully with existing settings!"
  fi
else
  if [[ "$UNATTENDED" -eq 0 ]]; then
    echo ""
    echo "✅ zsh-nvm-pnpm-auto-switch installed successfully with your settings!"
    echo "📂 Workspace directory: $workspace_dir"
    echo "📋 Project listing: $([ "$list_projects" -eq 1 ] && echo "enabled" || echo "disabled")"
    echo "🐛 Debug mode: $([ "$debug_mode" -eq 1 ] && echo "enabled" || echo "disabled")"
  else
    echo "✅ zsh-nvm-pnpm-auto-switch installed successfully with default settings!"
  fi
fi

echo ""
echo "Restart your shell or run 'source ~/.zshrc' to activate the plugin."