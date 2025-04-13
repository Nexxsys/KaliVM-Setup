# KaliVM-Setup
My files and scripts for setting up my KaliVM how I like it.

## Steps 
1. Download the zip archive of the files
2. Execute the main script `kali-additions.sh` by using this command `sudo bash ./kali-additions.sh`

* TO DO: Separate out main script into task based scripts for simple maintenance
* TO DO: Update the Homebrew Install Script
* TO DO: Add on mounts and include fonts
* TO DO: Add addition oh my zsh plugins https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df
* TO DO: Add Obsidian install to the script(s)

ZSHRC Aliases
```bash
# Export the PATH environment variable to include the home directory's local bin folder
export PATH="$PATH:/home/nexxsys/.local/bin"

# Set the POWERLEVEL9K_INSTANT_PROMPT type to 'quiet', which means that the prompt will not be displayed on a new line
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Evaluate the shell environment variables set by Homebrew, so they can be used in the script
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Source the Powerlevel10k theme from the Linuxbrew share directory
source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme

# LS aliases - Requires LSD and Nerd Fonts installed for best experience
alias la='lsd -Alh' # show hidden files
alias ls='lsd -l --color=auto'
alias lr='lsd -lRh' # recursive ls
alias lt='lsd -ltrh' # sort by date
alias ll='lsd -alFh' # long listing format
alias lf="lsd -l | egrep -v '^d'" # files only
alias ldir="lsd -l | egrep '^d'" # directories only
alias l='lsd'

# VPN Aliases


# Aliases for CTF Scripts
alias finish="source /opt/finish.sh"  # To run the finish script

alias save="source /opt/save.sh"  # To run the save script

alias vuln="thefuck --vuln"  # To find vulnerabilities in your code

# Functions for encoding and decoding
function hex-encode()
{
    echo "$@" | xxd -p
}

function hex-decode()
{
    echo "$@" | xxd -p -r
}

function rot13()
{
    echo "$@" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```
