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
HOMEBREW_INSTALL_EXIT_CODE=$?

# Check if Homebrew is actually working, regardless of exit code
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew installed successfully!"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  echo "Homebrew installed successfully! Adding to PATH..."
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
elif [ -f /opt/homebrew/bin/brew ]; then
  echo "Homebrew installed successfully! Adding to PATH..."
  export PATH="/opt/homebrew/bin:$PATH"
else
  echo "Failed to install Homebrew. Please try again."
  exit 1
fi

# Update Homebrew
echo "Updating Homebrew..."
if brew update; then
  echo "Homebrew updated successfully!"
else
  echo "Warning: Homebrew update failed, but continuing..."
fi

# Install Powerlevel10k theme (if available)
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
else
  echo "Failed to install FZF. Skipping..."
fi

# Install BAT
echo "Installing BAT that alternative to CAT..."
if brew install bat; then
  echo "BAT installed successfully!"
else
  echo "Failed to install BAT. Skipping..."
fi

# Install packages (fixed the logic)
echo "Installing additional packages..."
if brew install lsd jless; then
  echo "Additional packages installed successfully!"
else
  echo "Warning: Some additional packages failed to install. Continuing..."
fi

# Update shell configuration (if necessary)
echo "Updating shell configuration..."
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" "$HOME/.zshrc"; then
    echo "Adding Powerlevel10k theme to zsh configuration..."
    {
      echo ''
      echo '# Powerlevel10k theme'
      echo 'source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme'
    } >> "$HOME/.zshrc"
    
    if [ $? -eq 0 ]; then
      echo "Powerlevel10k theme added to zsh configuration successfully!"
    else
      echo "Error adding Powerlevel10k theme to zsh configuration. Skipping..."
    fi
  else
    echo "Powerlevel10k theme already configured in zsh."
  fi
fi

# Configure Powerlevel10k if it was installed successfully
if [ "$P10K_INSTALLED" = true ]; then
  echo "Configuring Powerlevel10k..."
  if command -v p10k >/dev/null 2>&1; then
    p10k configure
  else
    echo "p10k command not found. You may need to restart your shell and run 'p10k configure' manually."
  fi
fi

# Print success message
echo "Installation process completed!"
print_color "32" "[i] Stage 3 Script Completed!"
print_color "32" "[i] Stage 4 - Now execute the stage4.sh script with the command: bash ./stage4.sh"
echo -e "\033[36m  bash ./stage4.sh\033[0m"
