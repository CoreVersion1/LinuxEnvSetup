#!/bin/bash
set -e

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run this script with sudo."
    exit 1
fi

echo -e "[INFO] Successfully executed with sudo.\n"

# Get actual user
USER_HOME=$(eval echo ~$(logname))
ZSHRC="$USER_HOME/.zshrc"

echo -e "[INFO] Current actual user: $(logname)\n"

# Install Python3 and pip3 if not installed
sudo apt update
echo -e "[INFO] System update completed.\n"
sudo apt install -y python3-pip python3-distutils

echo -e "[INFO] Installed Python3 and pip3.\n"

# Install thefuck as actual user
if ! sudo -u $(logname) pip install thefuck; then
    echo -e "[ERROR] If using WSL, system protection prevents using pip install in this script. Sorry.\n"
    exit 1
fi

echo -e "[INFO] Thefuck installation completed.\n"

# Ensure ~/.local/bin is in PATH
if ! grep -q 'export PATH=.*$HOME/.local/bin' "$ZSHRC"; then
    echo 'export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH' >> "$ZSHRC"
    echo -e "[INFO] Added ~/.local/bin to PATH.\n"
else
    echo -e "[INFO] ~/.local/bin already in PATH, no changes needed.\n"
fi

# Add thefuck alias and shortcut
if ! grep -q 'eval $(thefuck --alias fix)' "$ZSHRC"; then
    echo 'eval $(thefuck --alias fix)' >> "$ZSHRC"
    echo -e "[INFO] Added thefuck alias 'fix'.\n"
else
    echo -e "[INFO] Thefuck alias 'fix' already exists, no changes needed.\n"
fi

if ! grep -q 'bindkey \"^R\" fix_command' "$ZSHRC"; then
    cat >> "$ZSHRC" <<EOF

fix_command() {
    BUFFER="fix"
    zle accept-line
}
zle -N fix_command
bindkey "^R" fix_command
EOF
    echo -e "[INFO] Bound shortcut key Ctrl+R.\n"
else
    echo -e "[INFO] Shortcut key Ctrl+R already exists, no changes needed.\n"
fi

# Reload zsh configuration
sudo -u $(logname) zsh -c "source $ZSHRC"
echo -e "[INFO] Reloaded zsh configuration.\n"

echo -e "[INFO] Thefuck installation and configuration completed. Please reopen the terminal or run 'exec zsh' to apply changes.\n"
