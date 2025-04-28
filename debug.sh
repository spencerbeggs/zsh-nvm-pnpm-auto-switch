#!/usr/bin/env zsh
# Debug script to test node-auto-switch plugin

# Inform the user what's happening
echo "Testing node-auto-switch plugin..."
echo "Current directory: $(pwd)"

# Check if package.json exists
if [[ -f "package.json" ]]; then
  echo "✅ package.json found"
else
  echo "❌ package.json not found"
fi

# Check if .npmrc exists
if [[ -f ".npmrc" ]]; then
  echo "✅ .npmrc found"
  node_version=$(grep "node-version" .npmrc | cut -d'=' -f2 | tr -d '[:space:]')
  echo "   Node version specified in .npmrc: $node_version"
else
  echo "❌ .npmrc not found"
fi

# Check current Node.js version
current_node_version=$(node -v 2>/dev/null || echo "none")
echo "Current Node.js version: $current_node_version"

# Check if package.json has packageManager field
if [[ -f "package.json" ]]; then
  packageManager=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null || echo "none")
  if [[ "$packageManager" != "none" ]]; then
    echo "✅ packageManager found in package.json: $packageManager"
    
    # Check if corepack is enabled
    if corepack --version &>/dev/null; then
      echo "✅ Corepack is enabled"
    else
      echo "❌ Corepack is NOT enabled"
    fi
    
    # Check current pnpm version
    current_pnpm_version=$(pnpm --version 2>/dev/null || echo "none")
    echo "Current pnpm version: $current_pnpm_version"
    
    # Get desired pnpm version
    desired_pnpm_version=$(grep -o '"packageManager":[^,}]*' package.json 2>/dev/null | cut -d'"' -f4 | cut -d'@' -f2)
    echo "Desired pnpm version: $desired_pnpm_version"
  else
    echo "❌ No packageManager specified in package.json"
  fi
else
  echo "❌ package.json not found (check again)"
fi

echo "Debug completed"
