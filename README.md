# KaliVM-Setup
My files and scripts for setting up my KaliVM how I like it.

## Steps
1. Download the 3 files
2. Make the follwing files executable with `chmod +x` | `githubdownload.py` , `kali-additions.sh`, and `install-homebrew.sh`
3. Execute `sudo -l` to be in sudo privilege level
4. Run `./kali-additions.sh`

* TO DO: Add on mounts and include fonts
* TO DO: Add jq install to the script
* TO DO: Add ncat install to the script

ZSHRC Aliases
```bash
# LS aliases - Requires LSD and Nerd Fonts installed for best experience
alias la='lsd -Alh' # show hidden files
alias ls='lsd -l --color=auto'
alias la='lsd -a'
alias lx='lsd -lXBh' # sort by extension
alias lk='lsd -lSrh' # sort by size
alias lc='lsd -lcrh' # sort by change time
alias lu='lsd -lurh' # sort by access time
alias lr='lsd -lRh' # recursive ls
alias lt='lsd -ltrh' # sort by date
alias lm='lsd -alh |more' # pipe through 'more'
alias lw='lsd -xAh' # wide listing format
alias ll='lsd -alFh' # long listing format
alias labc='lsd -lap' #alphabetical sort
alias lf="lsd -l | egrep -v '^d'" # files only
alias ldir="lsd -l | egrep '^d'" # directories only
alias l='lsd'
alias l.="lsd -A | egrep '^\.'"

# VPN Aliases
# alias thmvpn="sudo openvpn ~/thmvpn/Nexxsys.ovpn"
# alias htbvpn="sudo openvpn ~/vpns/lab_Nexxsys.ovpn"
# alias htbacad="sudo openvpn ~/vpns/academy-regular.ovpn"
# alias htbstart="sudo openvpn ~/htbvpn/starting_point_Nexxsys.ovpn"

# Aliases for CTF Scripts
alias finish="source /opt/finish.sh"
alias save="source /opt/save.sh"
alias vulscanup="sudo bash /usr/share/nmap/scripts/vulscan/update.sh"
alias removecomments "source /opt/removecomments.sh"

# Utility Aliases
alias sysup="sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y"
alias xclip="xclip -selection c"
alias chmox="chmod"
alias pyserver='python3 -m http.server'
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

# Display IP address
alias myip="ip a s | grep ens33"
# alias vpnip="ip a s | grep tun0"
# alias vpnip="ip -4 a show tun0"
# alias vpnip="source /opt/vpnip.sh"
# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
# Count all files (recursively) in the current folder
alias countfiles="bash -c \"for t in files links directories; do echo \\\$(find . -type \\\${t:0:1} | wc -l) \\\$t; done 2> /dev/null\""
# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"
# Show open ports
alias openports='netstat -nape --inet'
# fuzz search seclists - send finding to xclip
alias secsearch="find /usr/share/seclists -type f | fzf | xclip"

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
```
