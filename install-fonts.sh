# Define variables
NFS_SERVER="10.0.0.24"
NFS_SHARE="/chronicles"
MOUNT_POINT="/mnt/chronicles2"
FONTS_DIR="$HOME/.local/share/fonts"
REMOTE_FONTS_DIR="//10.0.0.24/chronicles2/Infosec/CTF-Linux-docs/Fonts"

# Step 1: Create the mount point directory
if [ ! -d "$MOUNT_POINT" ]; then
  print_color "34" "Creating mount point at $MOUNT_POINT"
  sudo mkdir -p "$MOUNT_POINT"
else
  print_color "31" "Mount point already exists at $MOUNT_POINT"
fi

# Step 2: Mount the NFS share
print_color "34" "Mounting NFS share $NFS_SERVER:$NFS_SHARE to $MOUNT_POINT"
sudo mount -t nfs "$NFS_SERVER:$NFS_SHARE" "$MOUNT_POINT"

# Step 3: Create the local fonts directory
if [ ! -d "$FONTS_DIR" ]; then
  print_color "34" "Creating fonts directory at $FONTS_DIR"
  mkdir -p "$FONTS_DIR"
else
  print_color "33" "Fonts directory already exists at $FONTS_DIR"
fi

# Step 4: Copy fonts from the NFS share to the local fonts directory
print_color "34" "Copying fonts from $REMOTE_FONTS_DIR to $FONTS_DIR"
cp -r "$MOUNT_POINT/Infosec/CTF-Linux-docs/Fonts/"* "$FONTS_DIR/"

# Step 5: Update the font cache
print_color "34" "Updating font cache"
fc-cache -f -v

print_color "34" "All done!"
