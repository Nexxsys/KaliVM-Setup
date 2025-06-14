#!/bin/bash
# STAGE 5 - ZSH Plugin install

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

# Set ZSH_CUSTOM directory - this was missing in your original script
ZSH_CUSTOM="${USER_HOME}/.oh-my-zsh/custom"

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

# Set the plugin repository URLs
autosuggestions_plugin_path="https://github.com/zsh-users/zsh-autosuggestions.git"
syntax_highlighting_plugin_path="https://github.com/zsh-users/zsh-syntax-highlighting.git"
fast_syntax_highlighting_plugin_path="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
autocomplete_plugin_path="https://github.com/marlonrichert/zsh-autocomplete.git"

# Check if Oh My Zsh is installed
if [ ! -d "$ZSH_CUSTOM" ]; then
  print_color "31" "[!] Oh My Zsh custom directory not found at $ZSH_CUSTOM"
  print_color "31" "[!] Please ensure Oh My Zsh is installed first"
  exit 1
fi

# Define a function to clone and install plugins
clone_plugins() {
  print_color "33" "[i] Installing ZSH plugins to $ZSH_CUSTOM/plugins/"
  
  # Create plugins directory if it doesn't exist
  mkdir -p "$ZSH_CUSTOM/plugins"
  
  # Clone the autosuggestions plugin
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_color "33" "[i] Installing zsh-autosuggestions..."
    if [ "$(id -u)" -eq 0 ]; then
      sudo -u "$REAL_USER" git clone --depth 1 "$autosuggestions_plugin_path" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
      git clone --depth 1 "$autosuggestions_plugin_path" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
  else
    print_color "33" "[i] zsh-autosuggestions already installed"
  fi
  
  # Clone and install the syntax-highlighting plugin
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_color "33" "[i] Installing zsh-syntax-highlighting..."
    if [ "$(id -u)" -eq 0 ]; then
      sudo -u "$REAL_USER" git clone --depth 1 "$syntax_highlighting_plugin_path" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
      git clone --depth 1 "$syntax_highlighting_plugin_path" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
  else
    print_color "33" "[i] zsh-syntax-highlighting already installed"
  fi
  
  # Clone and install the fast-syntax-highlighting plugin
  if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    print_color "33" "[i] Installing fast-syntax-highlighting..."
    if [ "$(id -u)" -eq 0 ]; then
      sudo -u "$REAL_USER" git clone --depth 1 "$fast_syntax_highlighting_plugin_path" "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    else
      git clone --depth 1 "$fast_syntax_highlighting_plugin_path" "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    fi
  else
    print_color "33" "[i] fast-syntax-highlighting already installed"
  fi
  
  # Clone and install the autocomplete plugin
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    print_color "33" "[i] Installing zsh-autocomplete..."
    if [ "$(id -u)" -eq 0 ]; then
      sudo -u "$REAL_USER" git clone --depth 1 "$autocomplete_plugin_path" "$ZSH_CUSTOM/plugins/zsh-autocomplete"
    else
      git clone --depth 1 "$autocomplete_plugin_path" "$ZSH_CUSTOM/plugins/zsh-autocomplete"
    fi
  else
    print_color "33" "[i] zsh-autocomplete already installed"
  fi
}

# Call the function to clone and install plugins
clone_plugins

print_color "32" "[✓] ZSH Plugins installed successfully!"
print_color "33" "[i] To enable these plugins, add them to your ~/.zshrc file:"
print_color "33" "    plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)"
print_color "32" "[i] Stage 5 Script Completed!"
print_color "32" "[i] Be sure to restart your terminal or run 'source ~/.zshrc' to apply changes"
print_color "32" "[i] DONE!"
