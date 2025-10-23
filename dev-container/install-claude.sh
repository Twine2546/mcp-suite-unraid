#!/bin/bash
set -e

echo ========================================
echo 🤖 Installing Claude Code CLI
echo ========================================

# Uninstall wrong package if it exists
if npm list -g claude-code 2>/dev/null; then
    echo Removing incorrect claude-code package...
    npm uninstall -g claude-code
fi

# Install correct package
echo Installing @anthropic-ai/claude-code...
npm install -g @anthropic-ai/claude-code

# Verify installation
echo 
echo Verifying installation...
if command -v claude &> /dev/null; then
    echo ✅ Claude Code installed successfully!
    claude --version
else
    echo ❌ Claude Code installation failed!
    exit 1
fi

echo ========================================
