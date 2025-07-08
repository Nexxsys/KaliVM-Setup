#!/bin/bash
# STAGE 4
# Install fonts Stage
# Define variables
NFS_SERVER="10.0.0.24"
NFS_SHARE="/chronicles"
MOUNT_POINT="/mnt/chronicles2"
USER_FONTS_DIR="$HOME/.local/share/fonts"
SYSTEM_FONTS_DIR="/usr/local/share/fonts"
# Define color print function
print_color() {
    COLOR_CODE="$1"
    MESSAGE="$2"
    echo -e "\e[${COLOR_CODE}m${MESSAGE}\e[0m"
}
# Step 1: Create the mount point directory
if [ ! -d "$MOUNT_POINT" ]; then
  print_color "34" "Creating mount point at $MOUNT_POINT"
  sudo mkdir -p "$MOUNT_POINT"
else
  print_color "33" "Mount point already exists at $MOUNT_POINT"
fi
# Step 2: Mount the NFS share
print_color "34" "Mounting NFS share $NFS_SERVER:$NFS_SHARE to $MOUNT_POINT"
sudo mount -t nfs "$NFS_SERVER:$NFS_SHARE" "$MOUNT_POINT"
# Step 3: Add entry to /etc/fstab for persistent mounting
FSTAB_ENTRY="$NFS_SERVER:$NFS_SHARE $MOUNT_POINT nfs defaults 0 0"
if ! grep -q "$MOUNT_POINT" /etc/fstab; then
  print_color "34" "Adding NFS mount to /etc/fstab for persistent mounting"
  echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
  print_color "32" "Entry added to /etc/fstab"
else
  print_color "33" "Mount point already exists in /etc/fstab"
fi
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
# Step 5: Copy fonts from the NFS share to the fonts directories
print_color "34" "Copying fonts to user directory $USER_FONTS_DIR"
cp -r "$MOUNT_POINT/Linux/Fonts/"* "$USER_FONTS_DIR/"
print_color "34" "Copying fonts to system-wide directory $SYSTEM_FONTS_DIR"
sudo cp -r "$MOUNT_POINT/Linux/Fonts/"* "$SYSTEM_FONTS_DIR/"
# Step 6: Set proper permissions for system fonts
print_color "34" "Setting permissions for system-wide fonts"
sudo chmod -R 755 "$SYSTEM_FONTS_DIR"
# Step 7: Update the font cache
print_color "34" "Updating font cache"
fc-cache -f -v
print_color "32" "All done! Fonts installed for current user and system-wide."
print_color "32" "[i] Stage 4 Script Completed!"
print_color "32" "[i] Stage 5 - Now execute the stage5.sh script with the command: bash ./stage5.sh"
echo -e "\033[36m sudo bash ./stage5.sh\033[0m"
