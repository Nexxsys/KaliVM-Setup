#!/bin/bash
# STAGE 1
# Required for each script
# Function to print colored messages
print_color() {
  local color_code="$1"
  shift
  echo -e "\033[${color_code}m$@\033[0m"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Determine the real user even when script is run with sudo
get_real_user() {
  if [ "$(id -u)" -eq 0 ]; then
    echo "${SUDO_USER:-$(who am i | awk '{print $1}')}"
  else
    echo "$(id -un)"
  fi
}

# Store the real user in a variable
REAL_USER=$(get_real_user)
USER_HOME=$(eval echo ~$REAL_USER)

# Function to safely modify user files
modify_user_file() {
  local file="$1"
  local action="$2"
  local content="$3"
  
  if [ "$(id -u)" -eq 0 ]; then
    # Running as root, use sudo -u to preserve ownership
    if [ -n "$REAL_USER" ]; then
      case "$action" in
        append)
          sudo -u "$REAL_USER" bash -c "echo '$content' >> '$file'"
          ;;
        write)
          sudo -u "$REAL_USER" bash -c "echo '$content' > '$file'"
          ;;
        *)
          print_color "31" "[!] Unknown action: $action"
          ;;
      esac
    fi
  else
    # Running as normal user
    case "$action" in
      append)
        echo "$content" >> "$file"
        ;;
      write)
        echo "$content" > "$file"
        ;;
      *)
        print_color "31" "[!] Unknown action: $action"
        ;;
    esac
  fi
}

# Install Oh-My-Zsh if not already installed
if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
  print_color "32" "[i] Installing Oh-My-Zsh"
  if [ "$(id -u)" -eq 0 ]; then
    sudo -u "$REAL_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
else
  print_color "32" "[i] Oh-My-Zsh is already installed"
fi

# Start installing basic applications and tools
# Install grc for color support
print_color "32" "[i] Installing grc"
sudo apt install -y grc

# Add Sublime Text GPG key
print_color "32" "[i] Adding Sublime Text repository"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

# Add Sublime Text repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Brave Browser GPG Key
print_color "32" "[i] Adding Brave Browser repository"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

print_color "32" "[i] Updating system"
# Update apt cache and upgrade packages
sudo apt update && sudo apt dist-upgrade -y

print_color "32" "[i] Installing preferred packages"
# Install necessary packages, including rust
sudo apt install -y pipx gdb git sublime-text apt-transport-https xclip terminator cifs-utils byobu exiftool jq ruby-full docker.io docker-compose locate btop thefuck brave-browser flatpak 7zip rlwrap curl build-essential cargo rustc flameshot dirsearch

# Install tldr - try multiple methods
print_color "32" "[i] Installing tldr"
if ! command_exists tldr; then
    # First try: Using npm
    if command_exists npm; then
        print_color "32" "[i] Installing tldr using npm"
        sudo npm install -g tldr
    else
        # Install npm first
        print_color "32" "[i] Installing Node.js and npm"
        sudo apt install -y nodejs npm
        sudo npm install -g tldr
    fi
    
    # Second try: Using the bash client if npm installation fails
    if ! command_exists tldr; then
        print_color "33" "[!] Installing tldr bash client"
        if [ "$(id -u)" -eq 0 ]; then
            sudo -u "$REAL_USER" mkdir -p "$USER_HOME/bin"
            curl -o "$USER_HOME/bin/tldr" https://raw.githubusercontent.com/raylee/tldr-sh-client/master/tldr
            sudo -u "$REAL_USER" chmod +x "$USER_HOME/bin/tldr"
        else
            mkdir -p ~/bin
            curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr-sh-client/master/tldr
            chmod +x ~/bin/tldr
        fi
        
        # Make sure bin directory is in PATH
        for shell_rc in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
            if [ -f "$shell_rc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$shell_rc"; then
                if [ "$(id -u)" -eq 0 ]; then
                    sudo -u "$REAL_USER" bash -c "echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> '$shell_rc'"
                else
                    echo 'export PATH="$HOME/bin:$PATH"' >> "$shell_rc"
                fi
            fi
        done
    fi
else
    print_color "32" "[i] tldr is already installed"
fi

# Add Flatpak repository
print_color "32" "[i] Adding Flatpak repository"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

print_color "32" "[i] Ensuring pipx is available"
# Ensure pipx path is available
if [ "$(id -u)" -eq 0 ]; then
    sudo -u "$REAL_USER" pipx ensurepath
else
    pipx ensurepath
fi

print_color "32" "[i] Installing pipx preferred packages"
# Install packages with pipx, with proper error handling
install_with_pipx() {
    local package=$1
    local package_name=${2:-$(basename "$package")}
    
    print_color "32" "[i] Installing $package_name"
    if [ "$(id -u)" -eq 0 ]; then
        if sudo -u "$REAL_USER" pipx install "$package" 2>/dev/null; then
            print_color "32" "[i] Successfully installed $package_name"
        else
            print_color "33" "[!] Failed to install $package_name, trying with --system-site-packages"
            if sudo -u "$REAL_USER" pipx install --system-site-packages "$package" 2>/dev/null; then
                print_color "32" "[i] Successfully installed $package_name with system site packages"
            else
                print_color "31" "[!] Failed to install $package_name. Skipping."
            fi
        fi
    else
        if pipx install "$package" 2>/dev/null; then
            print_color "32" "[i] Successfully installed $package_name"
        else
            print_color "33" "[!] Failed to install $package_name, trying with --system-site-packages"
            if pipx install --system-site-packages "$package" 2>/dev/null; then
                print_color "32" "[i] Successfully installed $package_name with system site packages"
            else
                print_color "31" "[!] Failed to install $package_name. Skipping."
            fi
        fi
    fi
}

print_color "32" "[i] Installing Kali Metapackages"
# Install Kali specific packages
sudo apt install -y kali-tools-top10 kali-tools-passwords feroxbuster gobuster kali-linux-headless kali-tools-post-exploitation kali-tools-fuzzing kali-tools-exploitation

print_color "32" "[i] Installing Sharpcollection"
# Clone useful GitHub repositories
if [ ! -d "/opt/SharpCollection" ]; then
    sudo git clone https://github.com/Flangvik/SharpCollection /opt/SharpCollection || true
else
    print_color "32" "[i] SharpCollection already exists"
fi

print_color "32" "[i] Installing Gem Tools"
# Install tools from Gems
sudo gem install logger stringio winrm builder erubi gssapi gyoku httpclient logging little-plugger nori rubyntlm winrm-fs evil-winrm

# Clean up
sudo apt autoremove -y

# Create temporary build directory
build_dir=$(mktemp -d)

print_color "32" "[i] Executing githubdownload.py"
# Copy python script to download github releases
if [ -f "./githubdownload.py" ]; then
    cp ./githubdownload.py "$build_dir/githubdownload.py"
    
    # Create destination directories if they don't exist
    sudo mkdir -p /opt/chisel
    sudo mkdir -p "$USER_HOME/wwwtools/peas"
    
    # Ensure correct ownership for user directories
    if [ "$(id -u)" -eq 0 ]; then
        sudo chown -R "$REAL_USER:$REAL_USER" "$USER_HOME/wwwtools"
    fi
    
    # Download github releases
    sudo python3 "$build_dir/githubdownload.py" "jpillora/chisel" "_linux_amd64.gz" "/opt/chisel"
    sudo python3 "$build_dir/githubdownload.py" "jpillora/chisel" "_windows_amd64.gz" "/opt/chisel"
    sudo python3 "$build_dir/githubdownload.py" "carlospolop/PEASS-ng" "linpeas.sh" "$USER_HOME/wwwtools/peas"
    sudo python3 "$build_dir/githubdownload.py" "carlospolop/PEASS-ng" "winPEASx64.exe" "$USER_HOME/wwwtools/peas"
    sudo python3 "$build_dir/githubdownload.py" "WithSecureLabs/chainsaw" "chainsaw_all_" "/opt/"
    
    # Ensure correct ownership
    if [ "$(id -u)" -eq 0 ]; then
        sudo chown -R "$REAL_USER:$REAL_USER" "$USER_HOME/wwwtools"
    fi
else
    print_color "31" "[!] githubdownload.py not found. Skipping downloads."
fi

# Remove temporary build directory
sudo rm -rf "$build_dir"

# update the db
sudo updatedb 2>/dev/null

# Function to copy scripts to /opt and make them executable
install_scripts() {
  local scripts=("finish.sh" "removecomments.sh" "save.sh")
  local dest_dir="/opt"
  
  for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
      print_color "32" "[i] Copying $script to $dest_dir"
      sudo cp "$script" "$dest_dir"
      sudo chmod +x "$dest_dir/$script"
    else
      print_color "31" "[!] Warning: $script not found"
    fi
  done
}

# Install scripts
install_scripts
print_color "32" "[i] Stage 1 Script Completed!"
print_color "32" "[i] Stage 2 - Now execute the stage2.sh script with the command: bash ./stage2.sh"
echo -e "\033[36m  bash ./stage2.sh\033[0m"
