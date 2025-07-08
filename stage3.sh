#!/bin/bash
# STAGE 3
# Install Homebrew using the official installation script

# Color printing function
print_color() {
    echo -e "\033[${1}m${2}\033[0m"
}

# Track installation status
P10K_INSTALLED=false

# Install Homebrew
echo "Installing Homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash

# Add Homebrew to PATH for this session and future sessions
echo "Setting up Homebrew environment..."
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    # Add to current session PATH
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    
    # Set up Homebrew environment for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Add to .zshrc for future sessions
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
            echo "Homebrew environment added to .zshrc"
        fi
    fi
    
    echo "Homebrew installed and configured successfully!"
elif [ -f /opt/homebrew/bin/brew ]; then
    # macOS case
    export PATH="/opt/homebrew/bin:$PATH"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Homebrew installed and configured successfully!"
else
    echo "Failed to install Homebrew. Please try again."
    exit 1
fi

# Verify brew command is now available
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: brew command still not available after setup."
    exit 1
fi

# Update Homebrew
echo "Updating Homebrew..."
if brew update; then
    echo "Homebrew updated successfully!"
else
    echo "Warning: Homebrew update failed, but continuing..."
fi

# Install build essentials if needed (Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing build essentials..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y build-essential
    fi
    
    echo "Installing GCC via Homebrew..."
    if brew install gcc; then
        echo "GCC installed successfully!"
    else
        echo "Warning: GCC installation failed, but continuing..."
    fi
fi

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
if brew install powerlevel10k; then
    echo "Powerlevel10k theme installed successfully!"
    P10K_INSTALLED=true
else
    echo "Failed to install Powerlevel10k theme. Skipping..."
fi

# Install FZF
echo "Installing FZF..."
if brew install fzf; then
    echo "FZF installed successfully!"
    
    # Set up FZF key bindings and fuzzy completion
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'source <(fzf --zsh)' "$HOME/.zshrc"; then
            echo 'source <(fzf --zsh)' >> "$HOME/.zshrc"
            echo "FZF key bindings added to .zshrc"
        fi
    fi
else
    echo "Failed to install FZF. Skipping..."
fi

# Install BAT
echo "Installing BAT (alternative to CAT)..."
if brew install bat; then
    echo "BAT installed successfully!"
else
    echo "Failed to install BAT. Skipping..."
fi

# Install LSD (alternative to ls)
echo "Installing LSD (alternative to ls)..."
if brew install lsd; then
    echo "LSD installed successfully!"
else
    echo "Failed to install LSD. Skipping..."
fi

# Install jless (JSON viewer)
echo "Installing jless (JSON viewer)..."
if brew install jless; then
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
            {
                echo ''
                echo '# Powerlevel10k theme'
                echo 'source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme'
            } >> "$HOME/.zshrc"
            echo "Powerlevel10k theme added to zsh configuration successfully!"
        else
            echo "Powerlevel10k theme already configured in zsh."
        fi
    fi
fi

# Configure Powerlevel10k if it was installed successfully
if [ "$P10K_INSTALLED" = true ]; then
    echo "Note: Powerlevel10k installed successfully!"
    echo "To configure it, restart your shell and run: p10k configure"
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
echo -e "\033[36m  bash ./stage4.sh\033[0m"
