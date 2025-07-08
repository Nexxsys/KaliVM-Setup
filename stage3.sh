#!/bin/bash
# STAGE 3
# Install Homebrew using the official installation script

# Color printing function
print_color() {
    printf "\033[%sm%s\033[0m\n" "$1" "$2"
}

# Track installation status
P10K_INSTALLED=false

# Check if running with sudo and get the real user
if [ "$EUID" -eq 0 ]; then
    # Get the real user who ran sudo
    REAL_USER=${SUDO_USER:-$(logname)}
    REAL_HOME=$(eval echo ~$REAL_USER)
    echo "Running with sudo. Real user: $REAL_USER, Real home: $REAL_HOME"
else
    REAL_USER=$(whoami)
    REAL_HOME=$HOME
    echo "Running as regular user: $REAL_USER"
fi

# Install Homebrew (must NOT be run with sudo)
echo "Installing Homebrew as user $REAL_USER..."
if [ "$EUID" -eq 0 ]; then
    # Drop privileges and run as the real user
    sudo -u "$REAL_USER" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
fi

# Wait a moment for installation to complete
sleep 2

# Set up Homebrew environment exactly as recommended by Homebrew
echo "Setting up Homebrew environment..."
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    # Run the exact commands Homebrew suggests, as the real user
    if [ "$EUID" -eq 0 ]; then
        # Running with sudo, so modify the real user's .zshrc
        sudo -u "$REAL_USER" bash -c "echo >> $REAL_HOME/.zshrc"
        sudo -u "$REAL_USER" bash -c "echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> $REAL_HOME/.zshrc"
        sudo -u "$REAL_USER" bash -c "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
    else
        # Run normally
        echo >> "$REAL_HOME/.zshrc"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$REAL_HOME/.zshrc"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
    echo "Homebrew environment configured successfully!"
elif [ -f /opt/homebrew/bin/brew ]; then
    # macOS case
    if [ "$EUID" -eq 0 ]; then
        sudo -u "$REAL_USER" bash -c "echo >> $REAL_HOME/.zshrc"
        sudo -u "$REAL_USER" bash -c "echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> $REAL_HOME/.zshrc"
        sudo -u "$REAL_USER" bash -c "eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    else
        echo >> "$REAL_HOME/.zshrc"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$REAL_HOME/.zshrc"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    BREW_PATH="/opt/homebrew/bin/brew"
    echo "Homebrew environment configured successfully!"
else
    echo "Error: Homebrew installation not found in expected locations."
    echo "Please check if Homebrew installed correctly."
    exit 1
fi

# Verify brew command is now available
if [ "$EUID" -eq 0 ]; then
    # Check as the real user
    if ! sudo -u "$REAL_USER" command -v brew >/dev/null 2>&1; then
        echo "Error: brew command still not available after setup."
        echo "Trying direct path..."
        if [ -n "$BREW_PATH" ] && [ -f "$BREW_PATH" ]; then
            echo "Using direct path to brew: $BREW_PATH"
        else
            echo "Failed to set up brew command."
            exit 1
        fi
    fi
else
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: brew command still not available after setup."
        echo "Trying direct path..."
        if [ -n "$BREW_PATH" ] && [ -f "$BREW_PATH" ]; then
            echo "Using direct path to brew: $BREW_PATH"
        else
            echo "Failed to set up brew command."
            exit 1
        fi
    fi
fi

echo "Homebrew installed and configured successfully!"

# Update Homebrew
echo "Updating Homebrew..."
if [ "$EUID" -eq 0 ]; then
    sudo -u "$REAL_USER" $BREW_PATH update || echo "Warning: Homebrew update failed, but continuing..."
else
    $BREW_PATH update || echo "Warning: Homebrew update failed, but continuing..."
fi

# Install build essentials if needed (Linux) - this part uses existing sudo
if [ "$(uname)" = "Linux" ]; then
    echo "Installing build essentials..."
    if command -v apt-get >/dev/null 2>&1; then
        echo "Updating package list..."
        apt-get update >/dev/null 2>&1 || true
        echo "Installing build-essential..."
        apt-get install -y build-essential >/dev/null 2>&1 || true
    fi
    
    echo "Installing GCC via Homebrew (as user $REAL_USER)..."
    if [ "$EUID" -eq 0 ]; then
        sudo -u "$REAL_USER" $BREW_PATH install gcc || echo "Warning: GCC installation failed, but continuing..."
    else
        $BREW_PATH install gcc || echo "Warning: GCC installation failed, but continuing..."
    fi
fi

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
if [ "$EUID" -eq 0 ]; then
    if sudo -u "$REAL_USER" $BREW_PATH install powerlevel10k; then
        echo "Powerlevel10k theme installed successfully!"
        P10K_INSTALLED=true
    else
        echo "Failed to install Powerlevel10k theme. Skipping..."
    fi
else
    if $BREW_PATH install powerlevel10k; then
        echo "Powerlevel10k theme installed successfully!"
        P10K_INSTALLED=true
    else
        echo "Failed to install Powerlevel10k theme. Skipping..."
    fi
fi

# Install FZF
echo "Installing FZF..."
if [ "$EUID" -eq 0 ]; then
    if sudo -u "$REAL_USER" $BREW_PATH install fzf; then
        echo "FZF installed successfully!"
    else
        echo "Failed to install FZF. Skipping..."
    fi
else
    if $BREW_PATH install fzf; then
        echo "FZF installed successfully!"
    else
        echo "Failed to install FZF. Skipping..."
    fi
fi

# Install BAT
echo "Installing BAT (alternative to CAT)..."
if [ "$EUID" -eq 0 ]; then
    if sudo -u "$REAL_USER" $BREW_PATH install bat; then
        echo "BAT installed successfully!"
    else
        echo "Failed to install BAT. Skipping..."
    fi
else
    if $BREW_PATH install bat; then
        echo "BAT installed successfully!"
    else
        echo "Failed to install BAT. Skipping..."
    fi
fi

# Install LSD (alternative to ls)
echo "Installing LSD (alternative to ls)..."
if [ "$EUID" -eq 0 ]; then
    if sudo -u "$REAL_USER" $BREW_PATH install lsd; then
        echo "LSD installed successfully!"
    else
        echo "Failed to install LSD. Skipping..."
    fi
else
    if $BREW_PATH install lsd; then
        echo "LSD installed successfully!"
    else
        echo "Failed to install LSD. Skipping..."
    fi
fi

# Install jless (JSON viewer)
echo "Installing jless (JSON viewer)..."
if [ "$EUID" -eq 0 ]; then
    if sudo -u "$REAL_USER" $BREW_PATH install jless; then
        echo "jless installed successfully!"
    else
        echo "Failed to install jless. Skipping..."
    fi
else
    if $BREW_PATH install jless; then
        echo "jless installed successfully!"
    else
        echo "Failed to install jless. Skipping..."
    fi
fi

# Update shell configuration for Powerlevel10k
if [ "$P10K_INSTALLED" = true ]; then
    echo "Configuring Powerlevel10k in shell..."
    if [ -f "$REAL_HOME/.zshrc" ]; then
        # Check if powerlevel10k is already sourced
        if ! grep -q "powerlevel10k.zsh-theme" "$REAL_HOME/.zshrc"; then
            echo "Adding Powerlevel10k theme to zsh configuration..."
            if [ "$EUID" -eq 0 ]; then
                sudo -u "$REAL_USER" bash -c "echo '' >> $REAL_HOME/.zshrc"
                sudo -u "$REAL_USER" bash -c "echo '# Powerlevel10k theme' >> $REAL_HOME/.zshrc"
                sudo -u "$REAL_USER" bash -c "echo 'source \$($BREW_PATH --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme' >> $REAL_HOME/.zshrc"
            else
                echo "" >> "$REAL_HOME/.zshrc"
                echo "# Powerlevel10k theme" >> "$REAL_HOME/.zshrc"
                echo "source \$($BREW_PATH --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> "$REAL_HOME/.zshrc"
            fi
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

# Source .zshrc as the real user to apply changes
echo "Applying shell configuration changes..."
if [ "$EUID" -eq 0 ]; then
    sudo -u "$REAL_USER" bash -c "source $REAL_HOME/.zshrc" 2>/dev/null || echo "Note: .zshrc sourced (some warnings are normal)"
else
    source "$REAL_HOME/.zshrc" 2>/dev/null || echo "Note: .zshrc sourced (some warnings are normal)"
fi

print_color "32" "Shell configuration updated successfully!"
echo ""
print_color "32" "[i] Stage 4 - Now execute the stage4.sh script with the command: bash ./stage4.sh"
printf "\033[36m  sudo bash ./stage4.sh\033[0m\n"
