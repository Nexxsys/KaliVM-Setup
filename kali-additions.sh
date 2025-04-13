#!/bin/bash
# Function to print colored messages
print_color() {
  local color_code="$1"
  shift
  echo -e "\033[${color_code}m$@\033[0m"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
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
sudo apt install -y pipx gdb git sublime-text apt-transport-https xclip terminator cifs-utils byobu exiftool jq ruby-full docker.io docker-compose locate btop thefuck brave-browser flatpak 7zip rlwrap curl build-essential cargo rustc

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

# NetExec
install_with_pipx "git+https://github.com/Pennyw0rth/NetExec" "NetExec"

# Default creds search
install_with_pipx "defaultcreds-cheat-sheet" "defaultcreds-cheat-sheet"

# updog
install_with_pipx "updog" "updog"

# impacket (try with system site packages if regular install fails)
install_with_pipx "git+https://github.com/fortra/impacket.git" "impacket"

# certipy-ad
install_with_pipx "git+https://github.com/ly4k/Certipy.git" "certipy-ad"

# oletools
install_with_pipx "oletools" "oletools"

# pwntools
install_with_pipx "pwntools" "pwntools"

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

# Define the shell aliases and functions
shell_aliases="
# Clipboard alias
alias xclip=\"xclip -selection c\"
# Vulnerability scan update
alias vulscanup=\"sudo bash /usr/share/nmap/scripts/vulscan/update.sh\"
# Remove comments script
alias removecomments=\"source /opt/removecomments.sh\"
# CrackMapExec alias
alias cme=\"crackmapexec\"
# chmod alias typo correction
alias chmox=\"chmod\"
# Pipx auto-completion if available
if command -v register-python-argcomplete > /dev/null 2>&1; then
    eval \"\$(register-python-argcomplete pipx)\"
fi

# Additional aliases
alias pyserver='python3 -m http.server'
alias countfiles=\"bash -c \\\"for t in files links directories; do echo \\\\\$(find . -type \\\\\${t:0:1} | wc -l) \\\\\$t; done 2> /dev/null\\\"\"
alias ipview=\"netstat -anpl | grep :80 | awk {'print \\\$5'} | cut -d\\\":\\\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'\"
alias openports='netstat -nape --inet'

# Functions
function hex-encode()
{
  echo \"\$@\" | xxd -p
}

function hex-decode()
{
  echo \"\$@\" | xxd -p -r
}

function rot13()
{
  echo \"\$@\" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# The Fuck (if installed)
if command -v thefuck > /dev/null 2>&1; then
    eval \$(thefuck --alias)
    eval \$(thefuck --alias FUCK)
fi
"

# Function to add aliases to the shell configuration file
add_aliases() {
  local config_file="$1"
  local marker="[#] BEGIN CUSTOM ALIASES"
  
  # Check if the aliases are already present
  if ! grep -q "$marker" "$config_file"; then
    if [ "$(id -u)" -eq 0 ]; then
      sudo -u "$REAL_USER" bash -c "echo '' >> '$config_file'"
      sudo -u "$REAL_USER" bash -c "echo '$marker' >> '$config_file'"
      sudo -u "$REAL_USER" bash -c "cat << 'EOF' >> '$config_file'
$shell_aliases
EOF"
      sudo -u "$REAL_USER" bash -c "echo '[#] END CUSTOM ALIASES' >> '$config_file'"
    else
      echo "" >> "$config_file"
      echo "$marker" >> "$config_file"
      echo "$shell_aliases" >> "$config_file"
      echo "[#] END CUSTOM ALIASES" >> "$config_file"
    fi
    print_color "32" "[i] Aliases added to $config_file"
  else
    print_color "33" "[-] Aliases already exist in $config_file"
  fi
}

# Function to add aliases to the correct shell configuration file based on the active shell
add_aliases_to_active_shell() {
  if [ -f "$USER_HOME/.zshrc" ]; then
    add_aliases "$USER_HOME/.zshrc"
  elif [ -f "$USER_HOME/.bashrc" ]; then
    add_aliases "$USER_HOME/.bashrc"
  fi
}

# Call the function to add aliases based on the active shell
print_color "32" "[i] Adding aliases to shell"
add_aliases_to_active_shell

# Update the Zshrc file with the appropriate plugins
# File path to .zshrc
ZSHRC_FILE="$USER_HOME/.zshrc"

# Check if .zshrc exists
if [ -f "$ZSHRC_FILE" ]; then
  # Make a backup
  if [ "$(id -u)" -eq 0 ]; then
    sudo -u "$REAL_USER" cp "$ZSHRC_FILE" "${ZSHRC_FILE}.bak"
  else
    cp "$ZSHRC_FILE" "${ZSHRC_FILE}.bak"
  fi
  print_color "32" "[i] Backed up zshrc to ${ZSHRC_FILE}.bak"
  
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  
  # Flag to track if plugins were found and replaced
  PLUGINS_UPDATED=0
  
  # Read the zshrc file line by line and update plugins
  if [ "$(id -u)" -eq 0 ]; then
    # Create temp file with updated content as user
    sudo cp "$ZSHRC_FILE" "$TEMP_FILE"
    sudo chown "$REAL_USER:$REAL_USER" "$TEMP_FILE"
    
    # Process the file and update plugins
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*plugins= ]]; then
        echo 'plugins=(git grc colorize)' >> "$TEMP_FILE.new"
        PLUGINS_UPDATED=1
      else
        echo "$line" >> "$TEMP_FILE.new"
      fi
    done < "$TEMP_FILE"
    
    # If plugins weren't found, add them
    if [ "$PLUGINS_UPDATED" -eq 0 ]; then
      sudo -u "$REAL_USER" bash -c "echo '' >> '$TEMP_FILE.new'"
      sudo -u "$REAL_USER" bash -c "echo '# Custom plugins configuration' >> '$TEMP_FILE.new'"
      sudo -u "$REAL_USER" bash -c "echo 'plugins=(git grc colorize)' >> '$TEMP_FILE.new'"
    fi
    
    # Replace original file with updated content
    sudo -u "$REAL_USER" cp "$TEMP_FILE.new" "$ZSHRC_FILE"
    sudo rm "$TEMP_FILE" "$TEMP_FILE.new"
  else
    # Running as normal user
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*plugins= ]]; then
        echo 'plugins=(git grc colorize)' >> "$TEMP_FILE"
        PLUGINS_UPDATED=1
      else
        echo "$line" >> "$TEMP_FILE"
      fi
    done < "$ZSHRC_FILE"
    
    # If plugins weren't found, add them
    if [ "$PLUGINS_UPDATED" -eq 0 ]; then
      echo "" >> "$TEMP_FILE"
      echo "# Custom plugins configuration" >> "$TEMP_FILE"
      echo "plugins=(git grc colorize)" >> "$TEMP_FILE"
    fi
    
    # Replace original file
    mv "$TEMP_FILE" "$ZSHRC_FILE"
  fi
  
  print_color "32" "[i] Successfully updated plugins in $ZSHRC_FILE"
else
  print_color "33" "[!] Warning: $ZSHRC_FILE not found."
fi

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

# Homebrew installation section
print_color "32" "[i] Initiating Homebrew install"

# Check if Homebrew is already installed
if command_exists brew; then
    print_color "32" "[i] Homebrew is already installed"
    HOMEBREW_INSTALLED=true
else
    # Look for install_homebrew.sh script
    INSTALL_SCRIPT="./install_homebrew.sh"
    
    if [ -f "$INSTALL_SCRIPT" ]; then
        print_color "32" "[i] Found install_homebrew.sh. Running the script..."
        chmod +x "$INSTALL_SCRIPT"
        
        # Run as non-root user
        if [ "$(id -u)" -eq 0 ]; then
            if [ -n "$REAL_USER" ]; then
                print_color "32" "[i] Running Homebrew installer as user: $REAL_USER"
                su - "$REAL_USER" -c "cd $(pwd) && $INSTALL_SCRIPT"
            else
                print_color "31" "[!] Cannot determine non-root user. Homebrew should not be installed as root."
            fi
        else
            bash "$INSTALL_SCRIPT"
        fi
        
        # Check if homebrew command exists after installation
        if command_exists brew || [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
            print_color "32" "[i] Homebrew installed successfully!"
            HOMEBREW_INSTALLED=true
        else
            print_color "31" "[!] Homebrew installation failed or not found at expected location."
            HOMEBREW_INSTALLED=false
        fi
    else
        print_color "31" "[!] install_homebrew.sh not found in current directory!"
        print_color "33" "[!] Skipping Homebrew installation..."
        HOMEBREW_INSTALLED=false
    fi
fi

# Configure Homebrew and install packages if installed
if [ "$HOMEBREW_INSTALLED" = true ]; then
    # Update shell configuration
    print_color "32" "[i] Updating shell configuration for Homebrew"
    
    for shell_rc in "$USER_HOME/.zshrc" "$USER_HOME/.bashrc"; do
        if [ -f "$shell_rc" ]; then
            if ! grep -q "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" "$shell_rc"; then
                if [ "$(id -u)" -eq 0 ]; then
                    sudo -u "$REAL_USER" bash -c "echo '' >> '$shell_rc'"
                    sudo -u "$REAL_USER" bash -c "echo '# Homebrew configuration' >> '$shell_rc'"
                    sudo -u "$REAL_USER" bash -c "echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> '$shell_rc'"
                else
                    echo '' >> "$shell_rc"
                    echo '# Homebrew configuration' >> "$shell_rc"
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$shell_rc"
                fi
            fi
        fi
    done
    
    # Install Homebrew packages
    print_color "32" "[i] Installing homebrew formulae"
    
    # Execute as the appropriate user
    if [ "$(id -u)" -eq 0 ]; then
        if [ -n "$REAL_USER" ]; then
            su - "$REAL_USER" -c "eval \$(/home/linuxbrew/.linuxbrew/bin/brew shellenv) && brew install gcc lsd fzf jless powerlevel10k"
        fi
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        brew install gcc lsd fzf jless powerlevel10k
    fi
    
    # Add powerlevel10k to zshrc
    if [ -f "$USER_HOME/.zshrc" ]; then
        if ! grep -q "source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" "$USER_HOME/.zshrc"; then
            if [ "$(id -u)" -eq 0 ]; then
                sudo -u "$REAL_USER" bash -c "echo '' >> '$USER_HOME/.zshrc'"
                sudo -u "$REAL_USER" bash -c "echo '# Powerlevel10k theme' >> '$USER_HOME/.zshrc'"
                sudo -u "$REAL_USER" bash -c "echo 'source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme' >> '$USER_HOME/.zshrc'"
            else
                echo "" >> "$USER_HOME/.zshrc"
                echo "# Powerlevel10k theme" >> "$USER_HOME/.zshrc"
                echo "source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" >> "$USER_HOME/.zshrc"
            fi
        fi
    fi
    
    # Add Homebrew-specific aliases
    BREW_ALIASES="
# Homebrew LSD Aliases
alias la='lsd -Alh' # show hidden files
alias ls='lsd --color=auto'
alias lx='lsd -lXBh' # sort by extension
alias lk='lsd -lSrh' # sort by size
alias lc='lsd -lcrh' # sort by change time
alias lu='lsd -lurh' # sort by access time
alias lr='lsd -lRh' # recursive ls
alias lt='lsd -ltrh' # sort by date
alias lm='lsd -alh | more' # pipe through more
alias lw='lsd -xAh' # wide listing format
alias ll='lsd -alFh' # long listing format
alias labc='lsd -lap' # alphabetical sort
alias lf=\"lsd -l | egrep -v '^d'\" # files only
alias ldir=\"lsd -l | egrep '^d'\" # directories only
alias l='lsd'
alias l.=\"lsd -A | egrep '^\\.'\"

# FZF configuration
export FZF_DEFAULT_OPTS=\"--height 40% --layout=reverse --border\"
if command -v batcat > /dev/null 2>&1; then
    export FZF_DEFAULT_OPTS=\"\$FZF_DEFAULT_OPTS --preview 'batcat --color=always {}'\"
fi

# Useful aliases with fzf
alias secsearch=\"find /usr/share/seclists -type f 2>/dev/null | fzf | xclip\"
alias review=\"fzf --preview 'bat --color=always {}'\"
alias dscan=\"find . -type d | fzf --preview='tree -C {}'\"
"
    
    # Add Homebrew aliases to shell config files
    for shell_rc in "$USER_HOME/.zshrc" "$USER_HOME/.bashrc"; do
        if [ -f "$shell_rc" ]; then
            if ! grep -q "# Homebrew LSD Aliases" "$shell_rc"; then
                if [ "$(id -u)" -eq 0 ]; then
                    sudo -u "$REAL_USER" bash -c "echo '' >> '$shell_rc'"
                    sudo -u "$REAL_USER" bash -c "echo '# Homebrew aliases and configurations' >> '$shell_rc'"
                    sudo -u "$REAL_USER" bash -c "cat << 'EOF' >> '$shell_rc'
$BREW_ALIASES
EOF"
                else
                    echo "" >> "$shell_rc"
                    echo "# Homebrew aliases and configurations" >> "$shell_rc"
                    echo "$BREW_ALIASES" >> "$shell_rc"
                fi
                print_color "32" "[i] Added Homebrew-specific aliases to $shell_rc"
            fi
        fi
    done
fi

# Final message
print_color "32" "[#] Aliases, functions, and scripts successfully added and applied."
print_color "32" "[#] Installation completed!"
print_color "33" "[!] Note: To use all the new features, please restart your terminal or run 'source ~/.zshrc' (or .bashrc)"
