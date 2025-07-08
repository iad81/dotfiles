#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting comprehensive Fedora setup script..."

# --- Request sudo password upfront ---
echo "This script requires sudo privileges. Please enter your password once."
# Keep-alive sudo session
if ! sudo -n true; then
    sudo -v
fi

# Define DOTFILES_REPO_URL and DOTFILES_DIR
# IMPORTANT: Replace with your actual GitHub dotfiles repository URL
DOTFILES_REPO_URL="https://github.com/iad81/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"


# 1. System Settings
echo -e "\n--- Configuring System Settings ---"

echo "1. Updating system..."
sudo dnf upgrade -y

echo "2. Enabling Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "3. Enabling RPM Fusion..."
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "4. Installing Multimedia Codecs..."
sudo dnf install -y libavcodec-freeworld

# Additional GNOME gsettings
echo "Applying GNOME desktop settings..."
# Remove keyboard input settings from status bar
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'gb')]"
# Enable maximise/minimise buttons
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# Turn on dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Ulauncher keybinding settings
echo "Setting up Ulauncher keybinding..."
dconf write /org/gnome/desktop/wm/keybindings/activate-window-menu "['']"

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" # Corrected typo "meldia-keys" to "media-keys"
FULL="$SCHEMA.custom-keybinding:$BINDING_PATH"
gsettings set "$FULL" name "'Ulauncher Toggle'"
gsettings set "$FULL" command "'/usr/bin/ulauncher-toggle'"
gsettings set "$FULL" binding "'<Alt>space'"
# This line appends the new custom binding to the existing list, ensuring others are not overwritten.
# It's important to read the current list, append, and then set.
CURRENT_BINDINGS=$(gsettings get "$SCHEMA" custom-keybindings)
if [[ "$CURRENT_BINDINGS" == *"'$BINDING_PATH'"* ]]; then
    echo "  Ulauncher custom keybinding already present."
else
    # Remove brackets, add new binding, then re-add brackets
    NEW_BINDINGS=$(echo "$CURRENT_BINDINGS" | sed "s/]$/, '$BINDING_PATH']/")
    gsettings set "$SCHEMA" custom-keybindings "$NEW_BINDINGS"
    echo "  Ulauncher custom keybinding added."
fi


# 2. GNOME Extensions
echo -e "\n--- Installing and Configuring GNOME Extensions ---"

echo "Installing gnome-extensions-cli..."
pip install --user gnome-extensions-cli
export PATH="$PATH:$HOME/.local/bin" # Add to PATH for current session
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc # Add to bashrc for future sessions

echo "Installing specific GNOME extensions via CLI..."
gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install just-perfection-desktop@just-perfection
gnome-extensions-cli install dash-in-panel@fthx
gnome-extensions-cli install dash-to-panel@jderose9.github.com


# 3. App Installs
echo -e "\n--- Installing Applications ---"

# DNF packages
echo "Installing DNF packages..."
sudo dnf install -y gnome-tweaks python3-pip ulauncher wmctrl dconf-editor

# Brave Browser
echo "Installing Brave Browser..."
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

# Flatpak applications
echo "Installing Flatpak applications..."
flatpak install -y flathub com.mattjakeman.ExtensionManager org.mozilla.firefox com.discordapp.Discord app.zen_browser.zen


# 4. App Data (Dotfiles)
echo -e "\n--- Setting up App Data (Dotfiles) from Repository ---"

# Clone your dotfiles repository
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles repository from $DOTFILES_REPO_URL..."
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists. Pulling latest changes..."
    # Ensure we are in the correct directory before pulling
    (cd "$DOTFILES_DIR" && git pull)
fi

echo "Creating symbolic links for dotfiles..."

# Function to create symbolic link, handling existing targets
create_symlink() {
    SOURCE="$1"
    TARGET="$2"
    echo "  Linking $(basename "$SOURCE") to $TARGET"

    # Ensure parent directory of target exists
    mkdir -p "$(dirname "$TARGET")"

    # Remove existing file or directory at target to prevent conflicts
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then # Is a real directory, not a symlink
            echo "    - Removing existing directory $TARGET"
            rm -rf "$TARGET"
        elif [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then # Is a real file, not a symlink
            echo "    - Removing existing file $TARGET"
            rm "$TARGET"
        elif [ -L "$TARGET" ]; then # Is an existing symlink
            echo "    - Removing existing symlink $TARGET"
            rm "$TARGET"
        fi
    fi

    # Create the symbolic link
    ln -sf "$SOURCE" "$TARGET"
}

# Symlink dotfiles directly in home directory
create_symlink "$DOTFILES_DIR/.bash_logout" "$HOME/.bash_logout"
create_symlink "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
# Add any other dotfiles directly in home you included in your repo
# create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
# create_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# Symlink dotfiles/directories from ~/.config/
create_symlink "$DOTFILES_DIR/.config/autostart" "$CONFIG_DIR/autostart"
create_symlink "$DOTFILES_DIR/.config/gtk-3.0" "$CONFIG_DIR/gtk-3.0"
create_symlink "$DOTFILES_DIR/.config/gtk-4.0" "$CONFIG_DIR/gtk-4.0"
create_symlink "$DOTFILES_DIR/.config/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
create_symlink "$DOTFILES_DIR/.config/nautilus" "$CONFIG_DIR/nautilus"
create_symlink "$DOTFILES_DIR/.config/org.gnome.Ptyxis" "$CONFIG_DIR/org.gnome.Ptyxis"
create_symlink "$DOTFILES_DIR/.config/ulauncher" "$CONFIG_DIR/ulauncher"
create_symlink "$DOTFILES_DIR/.config/user-dirs.dirs" "$CONFIG_DIR/user-dirs.dirs"
# Add any other specific directories/files from ~/.config/ you included
# create_symlink "$DOTFILES_DIR/.config/nvim" "$CONFIG_DIR/nvim"

# Symlink specific directories from ~/.local/
# Assuming you included ~/.local/bin
# create_symlink "$DOTFILES_DIR/.local/bin" "$HOME/.local/bin"

# Symlink .ssh/config if you included it (DO NOT include private keys)
# create_symlink "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"


# Load dconf settings for GNOME and extensions
echo "Loading dconf settings for GNOME and extensions..."
# Load all GNOME extension settings
if [ -f "$DOTFILES_DIR/dconf/gnome-extensions-all.dconf" ]; then
    dconf load /org/gnome/shell/extensions/ < "$DOTFILES_DIR/dconf/gnome-extensions-all.dconf"
else
    echo "  - Warning: gnome-extensions-all.dconf not found. Skipping extension settings load."
fi

# Add other dconf dumps you might have (e.g., general GNOME settings)
# Example:
# if [ -f "$DOTFILES_DIR/dconf/gnome-desktop-interface.dconf" ]; then
#     dconf load /org/gnome/desktop/interface/ < "$DOTFILES_DIR/dconf/gnome-desktop-interface.dconf"
# fi


echo -e "\n--- Fedora setup script completed! ---"
echo "You may need to reboot or log out/in for all graphical changes to take effect."
