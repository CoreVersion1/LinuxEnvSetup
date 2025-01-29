#!/bin/bash
set -e

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "[ERROR] Please run this script with sudo.\n"
    exit 1
fi

echo -e "[INFO] Starting Zsh and Oh My Zsh installation...\n"

# Module 1: Install Zsh
echo -e "[INFO] Installing Zsh...\n"
sudo apt update && sudo apt install -y zsh

# Module 2: Set Zsh as the default shell
echo -e "[INFO] Setting Zsh as the default shell...\n"
chsh -s "$(which zsh)"

# Resolve the user's home directory (handles sudo environment)
if [[ -n "$SUDO_USER" ]]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

ZSHRC="$USER_HOME/.zshrc"

# Module 3: Install Oh My Zsh
echo -e "[INFO] Installing Oh My Zsh...\n"
if command -v curl >/dev/null 2>&1; then
    sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
elif command -v wget >/dev/null 2>&1; then
    sudo -u "$SUDO_USER" sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
else
    echo -e "[ERROR] Neither curl nor wget is installed. Cannot proceed with Oh My Zsh installation.\n"
    exit 1
fi

# Module 4: Configure Zsh
echo -e "[INFO] Configuring Zsh...\n"

# Change theme
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="jreese"/' "$ZSHRC"
else
    echo 'ZSH_THEME="jreese"' >>"$ZSHRC"
fi

# Uncomment auto-update disable
if grep -q "^# zstyle ':omz:update' mode disabled" "$ZSHRC"; then
    sed -i 's/^# \(zstyle .*:omz:update.* mode disabled\)/\1/' "$ZSHRC"
else
    echo "zstyle ':omz:update' mode disabled" >>"$ZSHRC"
fi

# Module 5: Install plugins
echo -e "[INFO] Installing Oh My Zsh plugins...\n"
ZSH_CUSTOM="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo -e "[INFO] zsh-syntax-highlighting already exists. Skipping installation.\n"
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo -e "[INFO] zsh-autosuggestions already exists. Skipping installation.\n"
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo -e "[INFO] zsh-completions already exists. Skipping installation.\n"
fi

# Module 6: Enable plugins
echo -e "[INFO] Enabling plugins in .zshrc...\n"
if grep -q '^plugins=' "$ZSHRC"; then
    sed -i 's/^plugins=.*/plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/' "$ZSHRC"
else
    echo 'plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' >>"$ZSHRC"
fi

# Module 7: Update Oh My Zsh and source .zshrc
echo -e "[INFO] Updating Oh My Zsh...\n"
sudo -u "$SUDO_USER" omz update

echo -e "[INFO] Applying Zsh configuration...\n"
sudo -u "$SUDO_USER" zsh -c "source $ZSHRC"

echo -e "[INFO] You can manually update Oh My Zsh at any time using the command: omz update\n"
echo -e "[INFO] Zsh and Oh My Zsh setup completed! Please restart your terminal to apply the changes.\n"
