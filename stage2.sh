#!/bin/bash
# STAGE 2
# Required for each script
# Function to print colored messages
print_color() {
  local color_code="$1"
  shift
  echo -e "\033[${color_code}m$@\033[0m"
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

# INSTALL PIPX sourced tools
# NetExec
pipx install "git+https://github.com/Pennyw0rth/NetExec" "NetExec"

# Default creds search
pipx install "defaultcreds-cheat-sheet" "defaultcreds-cheat-sheet"

# updog
pipx install "updog" "updog"

# impacket (try with system site packages if regular install fails)
pipx install "git+https://github.com/fortra/impacket.git" "impacket"

# certipy-ad
pipx install "git+https://github.com/ly4k/Certipy.git" "certipy-ad"

# oletools
pipx install "oletools" "oletools"

# pwntools
pipx install "pwntools" "pwntools"

print_color "32" "[i] Stage 2 Script Completed!"
print_color "32" "[i] Stage 3 - Now execute the stage3.sh script with the command: bash ./stage3.sh"
echo -e "\033[36m  sudo bash ./stage3.sh\033[0m"
