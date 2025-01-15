#!/bin/bash
# Function to print colored messages
print_color() {
  local color_code="$1"
  shift
  echo -e "\033[${color_code}m$@\033[0m"
}

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt install grc

# Add Sublime Text GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

# Add Sublime Text repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Brave Browser GPG Key
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

print_color "32" "[i] Updating system"
# Update apt cache and upgrade packages
sudo apt update && sudo apt dist-upgrade -y

print_color "32" "[i] Installing preferred packages"
# Install necessary packages
sudo apt install -y pipx gdb git sublime-text apt-transport-https xclip terminator cifs-utils byobu exiftool jq ruby-full docker.io docker-compose locate tldr btop thefuck brave-browser flatpak 7zip rlwrap

# Add Flatpak repository
print_color "32" "[i] Adding Flatpak repository"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

print_color "32" "[i] Ensuring pipx is available"
# Ensure pipx path is available
pipx ensurepath

print_color "32" "[i] Installing pipx preferred packages"
# Install package with pipx
# netexec
pipx install git+https://github.com/Pennyw0rth/NetExec || true
# crackmapexec (don't install on Kali)
#pipx install git+https://github.com/Porchetta-Industries/CrackMapExec.git || true
# creds search (default creds)
pipx install defaultcreds-cheat-sheet
# updog
pipx install updog || true
# impacket
pipx install git+https://github.com/fortra/impacket.git || true
# certipy-ad 
pipx install git+https://github.com/ly4k/Certipy.git || true
# oletools
pipx install oletools
# pwn tools
pipx install pwntools

print_color "32" "[i] Installing Kali Metapackages"
# Install Kali specific packages
sudo apt install -y kali-tools-top10 kali-tools-passwords feroxbuster gobuster kali-linux-headless kali-tools-post-exploitation kali-tools-fuzzing kali-tools-exploitation

print_color "32" "[i] Installing Sharpcollection"
# Clone useful GitHub repositories
sudo git clone https://github.com/Flangvik/SharpCollection /opt/SharpCollection || true
#sudo git clone https://github.com/danielmiessler/SecLists /opt/SecLists || true

print_color "32" "[i] Installing Gem Tools"
# Install tools from Gems
sudo gem install logger stringio winrm builder erubi gssapi gyoku httpclient logging little-plugger nori rubyntlm winrm-fs evil-winrm

# Clean up
sudo apt autoremove -y

# Create temporary build directory
build_dir=$(mktemp -d)

print_color "32" "[i] Executing githubdownload.py"
# Copy python script to download github releases
cp ./githubdownload.py "$build_dir/githubdownload.py"

# Download github releases
sudo python3 "$build_dir/githubdownload.py" "jpillora/chisel" "_linux_amd64.gz" "/opt/chisel"
sudo python3 "$build_dir/githubdownload.py" "jpillora/chisel" "_windows_amd64.gz" "/opt/chisel"
sudo python3 "$build_dir/githubdownload.py" "carlospolop/PEASS-ng" "linpeas.sh" "~/wwwtools/peas"
sudo python3 "$build_dir/githubdownload.py" "carlospolop/PEASS-ng" "winPEASx64.exe" "/wwwtools/peas"
sudo python3 "$build_dir/githubdownload.py" "WithSecureLabs/chainsaw" "chainsaw_all_" "/opt/"
#sudo python3 "$build_dir/githubdownload.py" "BloodHoundAD/BloodHound" "BloodHound-linux-x64.zip" "/opt/"

# Remove temporary build directory
sudo rm -rf "$build_dir"

# update the db
sudo updatedb 2>/dev/null

# # Install Homebrew using the official installation script
# echo "Installing Homebrew..."

# # Run the Homebrew install script via curl
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# # Check if Homebrew was successfully installed
# if command -v brew >/dev/null 2>&1; then
#     echo "Homebrew installation successful!"
#     # Update Homebrew
#     echo "Updating Homebrew..."
#     brew update
# else
#     echo "Homebrew installation failed!"
# fi
print_color "32" "[i] Initiating Homebrew install"
# Path to the install_homebrew.sh script
INSTALL_SCRIPT="./install_homebrew.sh"

# Check if the install_homebrew.sh script exists
if [[ -f "$INSTALL_SCRIPT" ]]; then
    print_color "32" "[i] Found install_homebrew.sh. Running the script..."
    # Make the install_homebrew.sh script executable
    chmod +x "$INSTALL_SCRIPT"
    # Run the install_homebrew.sh script
    "$INSTALL_SCRIPT"
else
    print_color "31" "[!] install_homebrew.sh not found!"
    exit 1
fi
# Homebrew will say "installation failed" as it can't be installed with sudo
# Update zsh shell
# Append the command to the .zshrc file for the current user
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.zshrc

# Run the command to set the environment variables for brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

print_color "32" "[i] Installing homebrew formulae"
# install gcc
brew install gcc lsd fzf jless powerlevel10k

# Add powerlevel10k to the zshrc file
echo "source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
source ~/.zshrc

print_color "32" "[i] Adding aliases to shell"
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
# Pipx auto-completion
eval \"\$(register-python-argcomplete pipx)\"
# LSD Aliases for various listing formats
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
alias l.=\"lsd -A | egrep '^\.'\"

# Additional aliases
alias pyserver='python3 -m http.server'
alias countfiles=\"bash -c \"for t in files links directories; do echo \\\$(find . -type \\\${t:0:1} | wc -l) \\\$t; done 2> /dev/null\"\"
alias ipview=\"netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'\"
alias openports='netstat -nape --inet'
alias secsearch=\"find /usr/share/seclists -type f | fzf | xclip\"

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

# The Fuck | https://github.com/nvbn/thefuck
eval \$(thefuck --alias)
eval \$(thefuck --alias FUCK)

# FZF default options
export FZF_DEFAULT_OPTS=\"--height 40% --layout=reverse --border --preview 'batcat --color=always {}'\"
"

# Function to add aliases to the correct shell configuration file based on the active shell
add_aliases_to_active_shell() {
  case "$SHELL" in
    */zsh)
      add_aliases ~/.zshrc
      ;;
    */bash)
      add_aliases ~/.bashrc
      ;;
    *)
      print_color "31" "[!] Unsupported shell: $SHELL. Please use Bash or Zsh."
      ;;
  esac
}

# Function to add aliases to the shell configuration file
add_aliases() {
  local config_file="$1"
  local marker="[#] BEGIN CUSTOM ALIASES"
  
  # Check if the aliases are already present
  if ! grep -q "$marker" "$config_file"; then
    echo "$marker" >> "$config_file"
    echo "$shell_aliases" >> "$config_file"
    print_color "32" "[#] END CUSTOM ALIASES" >> "$config_file"
    print_color "32" "[i] Aliases added to $config_file"
  else
    print_color "33" "[-] Aliases already exist in $config_file"
  fi
}

# Call the function to add aliases based on the active shell
add_aliases_to_active_shell

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

# # Determine the shell and add aliases
# if [ -n "$BASH_VERSION" ]; then
#   add_aliases ~/.bashrc
# elif [ -n "$ZSH_VERSION" ]; then
#   add_aliases ~/.zshrc
# fi

# Install scripts
install_scripts

# Reload the shell configuration
print_color "32" "[i] Reloading shell configuration"
source ~/.zshrc 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

print_color "32" "[#] Aliases, functions, and scripts successfully added and applied."

