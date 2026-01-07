#!/bin/bash

# --- Function Definitions ---

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

add_to_path() {
	local dir="$1"

	if [[ -z "$dir" ]]; then
		echo "Error: directory argument required" >&2
		return 1
	fi

	if [[ ":$PATH:" != *":$dir:"* ]]; then
		export PATH="$dir:$PATH"
	fi
}

# Function to set Zsh as default shell
set_zsh_default() {
    local zsh_path=$(command -v zsh)
    if [ -z "$zsh_path" ]; then
        echo "Error: Zsh not found, cannot set as default shell."
        return 1
    fi

    echo "Setting Zsh as your default shell ($zsh_path)..."
    # Check if Zsh is already the default for the current user
    if [ "$SHELL" = "$zsh_path" ]; then
        echo "Zsh is already the default shell for the current user."
        return 0
    fi

    chsh -s "$zsh_path"

    if [ $? -eq 0 ]; then
        echo "Zsh has been set as your default shell. Please log out and log back in for changes to take effect."
        echo "Note: The first time Zsh runs, it may prompt for initial configuration. Type 'n' if you already have a .zshrc."
        return 0
    else
        echo "Failed to set Zsh as default shell. You may need to investigate why 'chsh' failed."
        return 1
    fi
}

create_symlink() {
    local target_name="$1"
    local link_dir="${2:-$HOME}" # Defaults to $HOME if $2 is empty

    if [ -z "$target_name" ]; then
        echo "Error: create_symlink requires a target_name (file/folder in CWD)."
        return 1
    fi

    # Ensure target_name exists in the current working directory
    if [ ! -e "$target_name" ]; then
        echo "Warning: Target '$target_name' not found in current directory ('$(pwd)'). Skipping symlink."
        return 0 # Not a fatal error, just skip
    fi

    # Get absolute path for the target (file/folder in CWD)
    local absolute_target="$(pwd)/$target_name"

    # Define the full path for the symlink
    local symlink_name="$link_dir/$target_name"

    # Ensure the link_dir exists
    if [ ! -d "$link_dir" ]; then
        echo "Creating directory: $link_dir"
        mkdir -p "$link_dir" || { echo "Error: Could not create directory $link_dir. Skipping symlink."; return 1; }
    fi

    # Check if a file/symlink already exists at the symlink destination
    if [ -e "$symlink_name" ]; then
        # Check if it's already a correct symlink
        if [ -L "$symlink_name" ] && [ "$(readlink "$symlink_name")" = "$absolute_target" ]; then
            echo "Symlink '$symlink_name' already exists and points correctly to '$absolute_target'."
        else
            echo "Removing existing file or incorrect symlink at '$symlink_name' to create new symlink."
            rm -rf "$symlink_name" # Use -rf for robust removal of file or directory/symlink
            ln -s "$absolute_target" "$symlink_name"
            echo "Symlink created: '$symlink_name' -> '$absolute_target'"
        fi
    else
        # No existing file/symlink, create it
        ln -s "$absolute_target" "$symlink_name"
        echo "Symlink created: '$symlink_name' -> '$absolute_target'"
    fi
    return 0
}

git_install() {
  local repo_url="$1"
  local dest_dir="$2"
  
  if [[ -z "$repo_url" || -z "$dest_dir" ]]; then
    echo "Error: repo URL and destination required" >&2
    return 1
  fi
  
  if [[ -d "$dest_dir" && -n "$(ls -A "$dest_dir")" ]]; then
    echo "Directory already exists and contains files: $dest_dir"
    return 0
  fi
  
  mkdir -p "$(dirname "$dest_dir")"
  git clone "$repo_url" "$dest_dir"
}

# --- Main Script Logic ---

# Installation of tools
## apt installable tools
sudo apt update
sudo apt install -y zsh git tmux gcc nodejs npm unzip curl build-essential ripgrep

## Git clone installations
## tmux package manager (TPM)
git_install https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

### Tmuxifier
git_install https://github.com/jimeh/tmuxifier.git $HOME/.tmuxifier

## Curl based installations
### Neovim installation
NVIM_INSTALL_DIR="/opt/nvim"
if [ ! -d "$NVIM_INSTALL_DIR" ]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    sudo chmod u+x nvim-linux-x86_64.appimage
    sudo mkdir -p /opt/nvim
    sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
    if [ ! -d "$NVIM_INSTALL_DIR" ]; then
        echo "Error: Neovim installation failed. Please check your internet connection or try manually."
        exit 1
    fi
    echo "Neovim installed successfully."
else
    echo "Neovim is already installed."
fi

### bun installation
BUN_INSTALL_DIR="$HOME/.bun/bin"
if [ ! -d "$BUN_INSTALL_DIR" ]; then
    curl -fsSL https://bun.sh/install | bash
    if [ ! -d "$BUN_INSTALL_DIR" ]; then
        echo "Error: bun installation failed. Please check your internet connection or try manually."
        exit 1
    fi
    echo "bun installed successfully."
else
    echo "bun is already installed."
fi

### Node Versiom Manager installation
NVM_INSTALL_DIR="$HOME/.nvm"
if [ ! -d "$NVM_INSTALL_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="/dev/null"  bash #Profile = dev/null prevents overwriting existing .zshrc file
    if [ ! -d "$NVM_INSTALL_DIR" ]; then
        echo "Error: NVM installation failed. Please check your internet connection or try manually."
        exit 1
    fi
    echo "NVM installed successfully."
else
    echo "NVM is already installed."
fi

### Claude code installation
CLAUDE_INSTALL_DIR="$HOME/.local/share/claude"
if [ ! -d "$CLAUDE_INSTALL_DIR" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
    if [ ! -d "$CLAUDE_INSTALL_DIR" ]; then
        echo "Error: Claude code installation failed. Please check your internet connection or try manually."
        exit 1
    fi
    echo "Claude code installed successfully."
else
    echo "Claude code is already installed."
fi


# 2. Set Zsh as default shell if not already
current_shell=$(basename "$SHELL")
if [ "$current_shell" != "zsh" ]; then
    echo "Zsh is installed but not your default shell (current: $current_shell)."
    set_zsh_default
else
    echo "Zsh is already your default shell."
fi

# 3. Install Oh My Zsh if not present
echo "--- Oh My Zsh Installation ---"
OMZ_INSTALL_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_INSTALL_DIR" ]; then
    echo "Oh My Zsh is not installed. Installing now..."
    # Suppress the default OMZ prompt to change default shell, as we handle it above
    # Also suppress the initial zsh execution
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    if [ ! -d "$OMZ_INSTALL_DIR" ]; then
        echo "Error: Oh My Zsh installation failed. Please check your internet connection or try manually."
        exit 1
    fi
    echo "Oh My Zsh installed successfully."
else
    echo "Oh My Zsh is already installed."
fi

# 4. Creating symlinks
echo "--- Creating Symlinks ---"

create_symlink ".zshrc"
create_symlink ".zsh"
create_symlink ".tmux.conf"
create_symlink "nvim" "$HOME/.config"

echo "--- Setup Complete ---"
