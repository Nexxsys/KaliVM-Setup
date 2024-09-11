#!/bin/bash

# Update apt cache and upgrade packages
sudo apt update && sudo apt dist-upgrade -y

# Add Sublime Text GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

# Add Sublime Text repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Install necessary packages
sudo apt install -y pipx gdb git sublime-text apt-transport-https xclip terminator cifs-utils byobu exiftool jq ruby-full docker.io docker-compose locate tldr btop thefuck kali-tools-passwords feroxbuster gobuster kali-linux-headless
# Ensure pipx path is available
pipx ensurepath

# Install package with pipx
# netexec
pipx install git+https://github.com/Pennyw0rth/NetExec || true
# crackmapexec
pipx install git+https://github.com/Porchetta-Industries/CrackMapExec.git || true
# updog
pipx install updog || true
# impacket
pipx install git+https://github.com/fortra/impacket.git || true
# certipy-ad 
pipx install git+https://github.com/ly4k/Certipy.git || true
# oletools
pipx install oletools

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
# Path to the install_homebrew.sh script
INSTALL_SCRIPT="./install_homebrew.sh"

# Check if the install_homebrew.sh script exists
if [[ -f "$INSTALL_SCRIPT" ]]; then
    echo "Found install_homebrew.sh. Running the script..."
    # Make the install_homebrew.sh script executable
    chmod +x "$INSTALL_SCRIPT"
    # Run the install_homebrew.sh script
    "$INSTALL_SCRIPT"
else
    echo "install_homebrew.sh not found!"
    exit 1
fi

# Update zsh shell
# Append the command to the .zshrc file for the current user
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.zshrc

# Run the command to set the environment variables for brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install gcc
brew install gcc lsd fzf jless powerlevel10k

# update brew
brew update

# Clone useful GitHub repositories
sudo git clone https://github.com/Flangvik/SharpCollection /opt/SharpCollection || true
sudo git clone https://github.com/danielmiessler/SecLists /opt/SecLists || true

# Install tools from Gems
sudo gem install logger stringio winrm builder erubi gssapi gyoku httpclient logging little-plugger nori rubyntlm winrm-fs evil-winrm

# Define the shell aliases
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
"

# Check if the aliases already exist in .zshrc
if ! grep -q "alias xclip" ~/.zshrc; then
  echo "Adding aliases to ~/.zshrc"
  echo "$shell_aliases" >> ~/.zshrc
else
  echo "Aliases already exist in ~/.zshrc"
fi

# Reload .zshrc to apply the changes
echo "Reloading .zshrc"
source ~/.zshrc

echo "Aliases successfully added and applied."


# Add aliases to the appropriate shell configuration file
if [ -n "$BASH_VERSION" ]; then
  echo "$shell_aliases" >> ~/.bashrc
elif [ -n "$ZSH_VERSION" ]; then
  echo "$shell_aliases" >> ~/.zshrc
fi

# Clean up
sudo apt autoremove -y

# Create temporary build directory
build_dir=$(mktemp -d)

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
