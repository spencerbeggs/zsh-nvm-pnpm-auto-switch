#!/usr/bin/env zsh
# Remote installer for zsh-nvm-pnpm-auto-switch plugin

echo "🚀 Installing zsh-nvm-pnpm-auto-switch plugin..."

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

# Create plugin directory
mkdir -p "$PLUGIN_DIR"

echo "📥 Downloading plugin from $REPO_URL..."

# Download the plugin files
curl -fsSL "$REPO_URL/raw/main/$PLUGIN_NAME.plugin.zsh" -o "$PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh"
curl -fsSL "$REPO_URL/raw/main/workspace-config.zsh" -o "$PLUGIN_DIR/workspace-config.zsh"

# Make the plugin executable
chmod +x "$PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh"

# Default values
DEFAULT_WORKSPACE="$HOME/workspace"
DEFAULT_LIST_PROJECTS=0
DEFAULT_DEBUG=0

# Interactive configuration unless unattended
if [[ "$UNATTENDED" -eq 0 ]]; then
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
  echo "🤖 Running in unattended mode, using default settings"
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
  echo "Warning: oh-my-zsh.sh is not sourced in your .zshrc"
  echo "Adding 'source \$ZSH/oh-my-zsh.sh' to your .zshrc"
  echo "source \$ZSH/oh-my-zsh.sh" >> "$HOME/.zshrc"
fi

# Add the plugin to existing plugins list or create a new one
if grep -q "^plugins=(" "$HOME/.zshrc"; then
  # Check if the plugin is already in the list
  if grep -q "plugins=.*$PLUGIN_NAME" "$HOME/.zshrc"; then
    echo "Plugin already in plugins list in .zshrc"
  else
    # Replace the plugins line with a new one that includes our plugin
    sed -i.bak "s/^plugins=(/plugins=($PLUGIN_NAME /" "$HOME/.zshrc"
    echo "Added plugin to existing plugins list in .zshrc"
  fi
else
  # No plugins line exists, add it
  echo "plugins=($PLUGIN_NAME)" >> "$HOME/.zshrc"
  echo "Added new plugins line to .zshrc"
fi

if [[ "$UNATTENDED" -eq 0 ]]; then
  echo ""
  echo "✅ zsh-nvm-pnpm-auto-switch installed successfully with your custom settings!"
  echo "📂 Workspace directory: $workspace_dir"
  echo "📋 Project listing: $([ "$list_projects" -eq 1 ] && echo "enabled" || echo "disabled")"
  echo "🐛 Debug mode: $([ "$debug_mode" -eq 1 ] && echo "enabled" || echo "disabled")"
else
  echo "✅ zsh-nvm-pnpm-auto-switch installed successfully with default settings!"
fi

echo ""
echo "Restart your shell or run 'source ~/.zshrc' to activate the plugin."