#!/bin/bash
set -e

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Log separator function
log_separator() {
    echo ""
}

echo "Starting Zsh and Oh My Zsh installation..."

# Module 1: Install Zsh
echo "Installing Zsh..."
sudo apt update && sudo apt install -y zsh
log_separator

# Module 2: Set Zsh as the default shell
echo "Setting Zsh as the default shell..."
chsh -s "$(which zsh)"
log_separator

# Resolve the user's home directory (handles sudo environment)
if [[ -n "$SUDO_USER" ]]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

ZSHRC="$USER_HOME/.zshrc"

# Module 3: Install Oh My Zsh
echo "Installing Oh My Zsh..."
if command -v curl >/dev/null 2>&1; then
    sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
elif command -v wget >/dev/null 2>&1; then
    sudo -u "$SUDO_USER" sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
else
    echo "Neither curl nor wget is installed. Cannot proceed with Oh My Zsh installation."
    exit 1
fi
log_separator

# Module 4: Configure Zsh
echo "Configuring Zsh..."

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
    echo "auto update mode disabled" >>"$ZSHRC"
fi
log_separator

# Module 5: Install plugins
echo "Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already exists. Skipping installation."
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions already exists. Skipping installation."
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    sudo -u "$SUDO_USER" git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo "zsh-completions already exists. Skipping installation."
fi
log_separator

# Module 6: Enable plugins
echo "Enabling plugins in .zshrc..."
if grep -q '^plugins=' "$ZSHRC"; then
    sed -i 's/^plugins=.*/plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/' "$ZSHRC"
else
    echo 'plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' >>"$ZSHRC"
fi
log_separator

# Module 7: Update Oh My Zsh and source .zshrc
echo "Updating Oh My Zsh..."
sudo -u "$SUDO_USER" omz update

echo "Applying Zsh configuration..."
sudo -u "$SUDO_USER" zsh -c "source $ZSHRC"
log_separator

echo "You can manually update Oh My Zsh at any time using the command: omz update"
echo "Zsh and Oh My Zsh setup completed! Please restart your terminal to apply the changes."
