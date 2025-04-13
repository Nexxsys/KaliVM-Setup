# KaliVM-Setup
My files and scripts for setting up my KaliVM how I like it.

## Steps 
1. Download the zip archive of the files
2. Execute the main script `kali-additions.sh` by using this command `sudo bash ./kali-additions.sh`

* TO DO: Separate out main script into task based scripts for simple maintenance
* TO DO: Update the Homebrew Install Script
* TO DO: Add on mounts and include fonts
* TO DO: Add jq install to the script
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
# Alias 'la' to run lsd -Alh, which shows hidden files
alias la='lsd -Alh'

# Alias 'ls' to run lsd -l --color=auto, which displays file lists with color
alias ls='lsd -l --color=auto'

# Alias 'la' to run lsd -a, which shows all files and directories in a long format
alias la='lsd -a'

# Alias 'lx' to run lsd -lXBh, which sorts by extension
alias lx='lsd -lXBh'

# Alias 'lk' to run lsd -lSrh, which sorts by size
alias lk='lsd -lSrh'

# Alias 'lc' to run lsd -lcrh, which sorts by change time
alias lc='lsd -lcrh'

# Alias 'lu' to run lsd -lurh, which sorts by access time
alias lu='lsd -lurh'

# Alias 'lr' to run lsd -lRh, which runs recursively
alias lr='lsd -lRh'

# Alias 'lt' to run lsd -ltrh, which shows all files and directories in a list format sorted by date
alias lt='lsd -ltrh'

# Alias 'lm' to pipe the output of lsd through 'more'
alias lm='lsd -alh |more'

# Alias 'lw' to run lsd -xAh, which displays wide listings
alias lw='lsd -xAh'

# Alias 'll' to run lsd -alFh, which displays long listings
alias ll='lsd -alFh'

# Alias 'labc' to run lsd -lap, which sorts alphabetically
alias labc='lsd -lap'

# Alias 'lf' to display files only with the command 'egrep'
alias lf="lsd -l | egrep -v '^d'"

# Alias 'ldir' to display directories only with the command 'egrep'
alias ldir="lsd -l | egrep '^d'"

# Alias 'l' to run lsd by default
alias l='lsd'

# Alias '.' to run lsd -A and filter out hidden files with 'egrep'
alias l.="lsd -A | egrep '^\.'"

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
