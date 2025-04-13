#!/bin/bash
# STAGE 5 - ZSH Plugin install
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

# Set the path to the zsh autosuggestions plugin
autosuggestions_plugin_path="https://github.com/zsh-users/zsh-autosuggestions.git"

# Set the paths for the zsh-syntax-highlighting and zsh-fast-syntax-highlighting plugins
syntax_highlighting_plugin_path="https://github.com/zsh-users/zsh-syntax-highlighting.git"
fast_syntax_highlighting_plugin_path="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"

# Set the path for the zsh-autocomplete plugin
autocomplete_plugin_path="https://github.com/marlonrichert/zsh-autocomplete.git"

# Define a function to clone and install plugins
clone_plugins() {
  # Clone the autosuggestions plugin
  git clone --depth 1 $autosuggestions_plugin_path "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  
  # Clone and install the syntax-highlighting plugin
  git clone --depth 1 $syntax_highlighting_plugin_path "$ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom"/plugins/zsh-syntax-highlighting
  
  # Clone and install the fast-syntax-highlighting plugin
  git clone --depth 1 $fast_syntax_highlighting_plugin_path "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
  
  # Clone and install the autocomplete plugin
  git clone --depth 1 $autocomplete_plugin_path "$ZSH_CUSTOM/plugins/zsh-autocomplete"
}

# Call the function to clone and install plugins
clone_plugins



print_color "32" "ZSH Plugins installed."
print_color "32" "[i] Stage 5 Script Completed!"
print_color "32" "[i] Be sure to update your zshrc file with aliases and other changes"
print_color "32" "[i] DONE!"