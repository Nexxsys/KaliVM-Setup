#!/bin/bash

# Define variables
FONT_URLS=(
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
)
TEMP_DIR="/tmp/nerd-fonts-install"
USER_FONTS_DIR="$HOME/.local/share/fonts"
SYSTEM_FONTS_DIR="/usr/local/share/fonts"

# Define color print function
print_color() {
    COLOR_CODE="$1"
    MESSAGE="$2"
    echo -e "\e[${COLOR_CODE}m${MESSAGE}\e[0m"
}

# Function to check if required tools are installed
check_dependencies() {
    print_color "34" "Checking for required dependencies..."
    
    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        print_color "31" "Error: Neither curl nor wget is installed. Please install one of them."
        exit 1
    fi
    
    # Check for unzip
    if ! command -v unzip &> /dev/null; then
        print_color "31" "Error: unzip is not installed. Please install it first."
        print_color "33" "On Ubuntu/Debian: sudo apt install unzip"
        print_color "33" "On RHEL/CentOS/Fedora: sudo yum install unzip (or dnf install unzip)"
        exit 1
    fi
    
    print_color "32" "All dependencies are available."
}

# Function to download file
download_file() {
    local url="$1"
    local output="$2"
    
    print_color "34" "Downloading font archive from $url"
    
    if command -v curl &> /dev/null; then
        curl -L -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -O "$output" "$url"
    else
        print_color "31" "Error: No download tool available"
        exit 1
    fi
    
    # Check if download was successful
    if [ ! -f "$output" ]; then
        print_color "31" "Error: Download failed"
        exit 1
    fi
    
    print_color "32" "Download completed successfully"
}

# Function to cleanup temporary files
cleanup() {
    print_color "34" "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Set up cleanup trap
trap cleanup EXIT

# Step 1: Check dependencies
check_dependencies

# Step 2: Create temporary directory
print_color "34" "Creating temporary directory at $TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Step 3: Download and extract all font archives
print_color "34" "Downloading and extracting ${#FONT_URLS[@]} Nerd Font packages..."

TOTAL_FONT_COUNT=0

for font_url in "${FONT_URLS[@]}"; do
    # Extract filename from URL
    filename=$(basename "$font_url")
    font_name=$(basename "$filename" .zip)
    
    print_color "34" "Processing $font_name..."
    
    # Download the font archive
    font_archive="$TEMP_DIR/$filename"
    download_file "$font_url" "$font_archive"
    
    # Create subdirectory for this font package
    extract_dir="$TEMP_DIR/$font_name"
    mkdir -p "$extract_dir"
    
    # Extract the archive
    print_color "34" "Extracting $filename..."
    unzip -q "$font_archive" -d "$extract_dir"
    
    # Count font files in this package
    font_files=$(find "$extract_dir" -name "*.ttf" -o -name "*.otf" | wc -l)
    TOTAL_FONT_COUNT=$((TOTAL_FONT_COUNT + font_files))
    
    print_color "32" "$font_name: Found $font_files font files"
done

print_color "32" "Total font files to install: $TOTAL_FONT_COUNT"

# Step 4: Create the local fonts directories
# User fonts directory
if [ ! -d "$USER_FONTS_DIR" ]; then
    print_color "34" "Creating user fonts directory at $USER_FONTS_DIR"
    mkdir -p "$USER_FONTS_DIR"
else
    print_color "33" "User fonts directory already exists at $USER_FONTS_DIR"
fi

# System-wide fonts directory (requires sudo)
if [ ! -d "$SYSTEM_FONTS_DIR" ]; then
    print_color "34" "Creating system-wide fonts directory at $SYSTEM_FONTS_DIR"
    sudo mkdir -p "$SYSTEM_FONTS_DIR"
else
    print_color "33" "System-wide fonts directory already exists at $SYSTEM_FONTS_DIR"
fi

# Step 5: Find and copy font files
print_color "34" "Installing fonts..."

# Find all .ttf and .otf files in the extracted directories
FONT_FILES=$(find "$TEMP_DIR" -name "*.ttf" -o -name "*.otf")

if [ -z "$FONT_FILES" ]; then
    print_color "31" "Error: No font files (.ttf or .otf) found in any of the archives"
    exit 1
fi

# Verify total count matches what we calculated
ACTUAL_COUNT=$(echo "$FONT_FILES" | wc -l)
print_color "34" "Verified: Installing $ACTUAL_COUNT font files"

# Copy fonts to user directory
print_color "34" "Copying fonts to user directory $USER_FONTS_DIR"
echo "$FONT_FILES" | while read -r font_file; do
    cp "$font_file" "$USER_FONTS_DIR/"
done

# Copy fonts to system-wide directory
print_color "34" "Copying fonts to system-wide directory $SYSTEM_FONTS_DIR"
echo "$FONT_FILES" | while read -r font_file; do
    sudo cp "$font_file" "$SYSTEM_FONTS_DIR/"
done

# Step 6: Set proper permissions for system fonts
print_color "34" "Setting permissions for system-wide fonts"
sudo chmod -R 755 "$SYSTEM_FONTS_DIR"

# Step 7: Update the font cache
print_color "34" "Updating font cache"
fc-cache -f -v

print_color "32" "All done! Nerd Fonts (Meslo, Hack, Symbols, FiraCode) installed for current user and system-wide."
print_color "32" "Installed $ACTUAL_COUNT font files successfully."
