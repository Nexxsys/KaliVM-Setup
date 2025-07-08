#!/bin/bash
# STAGE 3
# Install Homebrew using the official installation script

# Color printing function
print_color() {
    printf "\033[%sm%s\033[0m\n" "$1" "$2"
}

# Track installation status
P10K_INSTALLED=false

# Install Homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true

# Wait a moment for installation to complete
sleep 2

# Check for Homebrew installation and set up PATH
BREW_PATH=""
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
elif [ -f /opt/homebrew/bin/brew ]; then
    BREW_PATH="/opt/homebrew/bin/brew"
    export PATH="/opt/homebrew/bin:$PATH"
elif [ -f /usr/local/bin/brew ]; then
    BREW_PATH="/usr/local/bin/brew"
    export PATH="/usr/local/bin:$PATH"
else
    echo "Error: Homebrew installation not found in expected locations."
    echo "Please check if Homebrew installed correctly."
    exit 1
fi

# Set up Homebrew environment
echo "Setting up Homebrew environment..."
eval "$($BREW_PATH shellenv)"

# Add Homebrew to shell configuration
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "brew shellenv" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Homebrew environment" >> "$HOME/.zshrc"
        echo "eval \"\$($BREW_PATH shellenv)\"" >> "$HOME/.zshrc"
        echo "Homebrew environment added to .zshrc"
    fi
fi

# Verify brew command is now available
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: brew command still not available after setup."
    echo "Trying direct path..."
    if [ -n "$BREW_PATH" ] && [ -f "$BREW_PATH" ]; then
        alias brew="$BREW_PATH"
        echo "Using direct path to brew: $BREW_PATH"
    else
        echo "Failed to set up brew command."
        exit 1
    fi
fi

echo "Homebrew installed and configured successfully!"

# Update Homebrew
echo "Updating Homebrew..."
$BREW_PATH update || echo "Warning: Homebrew update failed, but continuing..."

# Install build essentials if needed (Linux)
if [ "$(uname)" = "Linux" ]; then
    echo "Installing build essentials..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update >/dev/null 2>&1 || true
        sudo apt-get install -y build-essential >/dev/null 2>&1 || true
    fi
    
    echo "Installing GCC via Homebrew..."
    $BREW_PATH install gcc || echo "Warning: GCC installation failed, but continuing..."
fi

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
if $BREW_PATH install powerlevel10k; then
    echo "Powerlevel10k theme installed successfully!"
    P10K_INSTALLED=true
else
    echo "Failed to install Powerlevel10k theme. Skipping..."
fi

# Install FZF
echo "Installing FZF..."
if $BREW_PATH install fzf; then
    echo "FZF installed successfully!"
else
    echo "Failed to install FZF. Skipping..."
fi

# Install BAT
echo "Installing BAT (alternative to CAT)..."
if $BREW_PATH install bat; then
    echo "BAT installed successfully!"
else
    echo "Failed to install BAT. Skipping..."
fi

# Install LSD (alternative to ls)
echo "Installing LSD (alternative to ls)..."
if $BREW_PATH install lsd; then
    echo "LSD installed successfully!"
else
    echo "Failed to install LSD. Skipping..."
fi

# Install jless (JSON viewer)
echo "Installing jless (JSON viewer)..."
if $BREW_PATH install jless; then
    echo "jless installed successfully!"
else
    echo "Failed to install jless. Skipping..."
fi

# Update shell configuration for Powerlevel10k
if [ "$P10K_INSTALLED" = true ]; then
    echo "Configuring Powerlevel10k in shell..."
    if [ -f "$HOME/.zshrc" ]; then
        # Check if powerlevel10k is already sourced
        if ! grep -q "powerlevel10k.zsh-theme" "$HOME/.zshrc"; then
            echo "Adding Powerlevel10k theme to zsh configuration..."
            echo "" >> "$HOME/.zshrc"
            echo "# Powerlevel10k theme" >> "$HOME/.zshrc"
            echo "source \$($BREW_PATH --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> "$HOME/.zshrc"
            echo "Powerlevel10k theme added to zsh configuration successfully!"
        else
            echo "Powerlevel10k theme already configured in zsh."
        fi
    fi
fi

# Print success message
echo ""
print_color "32" "========================================="
print_color "32" "Stage 3 Installation Complete!"
print_color "32" "========================================="
echo ""
echo "Installed packages:"
echo "  ✓ Homebrew"
if [ "$P10K_INSTALLED" = true ]; then
    echo "  ✓ Powerlevel10k"
fi
echo "  ✓ FZF (fuzzy finder)"
echo "  ✓ BAT (cat alternative)"
echo "  ✓ LSD (ls alternative)"
echo "  ✓ jless (JSON viewer)"
echo ""
print_color "33" "Important: Please restart your terminal or run:"
print_color "36" "  source ~/.zshrc"
echo ""
print_color "32" "[i] Stage 4 - Now execute the stage4.sh script with the command: bash ./stage4.sh"
printf "\033[36m  bash ./stage4.sh\033[0m\n"
