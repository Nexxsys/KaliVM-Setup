#!/bin/bash
# STAGE 3
# Install Homebrew using the official installation script

set -e

# Install Homebrew
echo "Installing Homebrew..."
if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash; then
  echo "Error installing Homebrew. Please try again."
  exit 1
fi

# Check Homebrew installation
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew installed successfully!"
else
  echo "Failed to install Homebrew. Please try again."
  exit 1
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update || { echo "Error updating Homebrew. Please try again."; exit 1; }

# Install Powerlevel10k theme (if available)
echo "Installing Powerlevel10k theme..."
if brew install powerlevel10k; then
  echo "Powerlevel10k theme installed successfully!"
else
  echo "Failed to install Powerlevel10k theme. Skipping..."
fi

# Install FZF
echo "Installing FZF..."
if brew install FZF; then
  echo "FZF installed successfully!"
else
  echo "Failed to install FZF. Skipping..."
fi

# Install BAT
echo "Installing BAT that alternative to CAT..."
if brew install powerlevel10k; then
  echo "BAT installed successfully!"
else
  echo "Failed to install BAT. Skipping..."
fi

# Install packages (in a controlled order)
echo "Installing packages:"
if command -v gcc >/dev/null 2>&1; then
  brew install --cask gcc lsd fzf jless powerlevel10k || { echo "Error installing packages. Please try again."; exit 1; }
else
  echo "Error: 'gcc' package not found. Skipping installation."
fi

# Update shell configuration (if necessary)
echo "Updating shell configuration..."
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" "$HOME/.zshrc"; then
    echo "Adding Powerlevel10k theme to zsh configuration..."
    if sudo bash -c "echo '' >> '$HOME/.zshrc' && echo '# Powerlevel10k theme' >> '$HOME/.zshrc' && echo 'source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme' >> '$HOME/.zshrc'"; then
      echo "Powerlevel10k theme added to zsh configuration successfully!"
    else
      echo "Error adding Powerlevel10k theme to zsh configuration. Skipping..."
    fi
  fi
fi

# Print success message (or error message if any command fails)
if [ $? -eq 0 ]; then
  echo "Installation complete!"
else
  echo "Installation failed. Please try again."
fi

print_color "32" "[i] Stage 3 Script Completed!"
print_color "32" "[i] Stage 4 - Now execute the stage4.sh script with the command: bash ./stage4.sh"
echo -e "\033[36m  bash ./stage4.sh\033[0m"
