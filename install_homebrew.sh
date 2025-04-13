#!/bin/bash
# Nexxsys
# Install Homebrew using the official installation script
echo "Installing Homebrew..."

# Run the Homebrew install script via curl
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Check if Homebrew was successfully installed
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew installation successful!"
    # Update Homebrew
    echo "Updating Homebrew..."
    brew update
else
    echo "Homebrew installation failed!"
fi
