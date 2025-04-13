# KaliVM-Setup
My files and scripts for setting up my KaliVM how I like it.

## Steps 
1. Download the zip archive of the files
2. Extract the zip archive
3. Execute stage 1 script `stage1.sh` by using this command `sudo bash ./stage1.sh`
4. Execute stage 2 script `stage2.sh` by using this command `bash ./stage2.sh`
5. Execute stage 3 script `stage3.sh` by using this command `bash ./stage3.sh`
6. Execute stage 4 script `stage4.sh` by using this command `bash ./stage4.sh`
7. Execute stage 5 script `stage5.sh` by using this command `bash ./stage5.sh`
8. Add the aliases and zsh plugins to the existing `.zshrc` file
   


ZSHRC Aliases
```bash
plugins=(git grc colorize zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)

# Created by `pipx` on 2025-04-13 14:20:37
export PATH="$PATH:/home/nexxsys/.local/bin"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
alias lsdtree='lsd --tree -d'

# Aliases for CTF Scripts
alias finish="source /opt/finish.sh"
alias save="source /opt/save.sh"
alias removecomments="source /opt/removecomments.sh"

# Vulnerability Scanning with nmap https://scipag.github.io/vulscan/
# alias vulscanup="sudo bash /usr/share/nmap/scripts/vulscan/update.sh"


# Utility Aliases
alias sysup="sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y"
alias xclip="xclip -selection c"
alias chmox="chmod"
alias pyserver='python3 -m http.server'
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
# Count all files (recursively) in the current folder
alias countfiles="bash -c 'for t in files links directories; do echo \$(find . -type \${t:0:1} | wc -l) \$t; done 2> /dev/null'"
# Show current network connections to the server
# alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d ':' -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"
# Show open ports
alias openports='netstat -nape --inet'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --preview 'batcat --color=always {}'"
alias secsearch="find /usr/share/seclists -type f | fzf | xclip"
# review a file
alias review="fzf --preview 'bat --color=always {}'"
# scan directories with tree preview
alias dscan="find . -type d | fzf --preview='tree -C {}'"

# The Fuck | https://github.com/nvbn/thefuck
eval $(thefuck --alias)
# You can use whatever you want as an alias, like for Mondays:
eval $(thefuck --alias FUCK)

# Functions
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

# VPN Aliases
# alias thmvpn="sudo openvpn ~/thmvpn/Nexxsys.ovpn"
# alias htbvpn="sudo openvpn ~/vpns/lab_Nexxsys.ovpn"
# alias htbacad="sudo openvpn ~/vpns/academy-regular.ovpn"
# alias htbstart="sudo openvpn ~/htbvpn/starting_point_Nexxsys.ovpn"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```
