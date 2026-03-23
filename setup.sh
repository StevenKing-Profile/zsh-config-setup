#!/bin/bash

echo "Starting Zsh & Environment Setup..."

OS="$(uname -s)"

# 1. Install Linux Prerequisites for Homebrew (if applicable)
if [ "$OS" = "Linux" ]; then
    echo "Linux detected. Installing build dependencies for Homebrew..."
    if command -v yum &> /dev/null; then
        sudo yum update -y
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y procps-ng curl file git util-linux-user # util-linux-user provides chsh
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y build-essential procps curl file git
    fi
fi

# 2. Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load Homebrew into the current session securely based on OS/Arch
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 3. Install Tools, JDKs, and SWE Essentials (Replaced python with uv)
echo "Installing core tools, languages, and SWE utilities..."
brew install zsh nvm jenv zsh-autosuggestions wget uv
brew install openjdk@8 openjdk@11 openjdk@17 openjdk@21
brew install tmux jq htop fzf ripgrep awscli glab

# 4. Change default shell to Homebrew Zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -q "$BREW_ZSH" /etc/shells; then
    echo "$BREW_ZSH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$BREW_ZSH" ]; then
    chsh -s "$BREW_ZSH"
fi

# 5. Install Oh My Zsh (unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 6. Install Powerlevel10k theme
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# 7. Configure Python via uv
echo "Installing default Python using uv..."
uv python install

# 8. Configure Jenv with installed JDKs and set global
echo "Configuring jenv and adding Java versions..."
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

jenv add "$(brew --prefix)/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home" 2>/dev/null || jenv add "$(brew --prefix)/opt/openjdk@8"
jenv add "$(brew --prefix)/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home" 2>/dev/null || jenv add "$(brew --prefix)/opt/openjdk@11"
jenv add "$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" 2>/dev/null || jenv add "$(brew --prefix)/opt/openjdk@17"
jenv add "$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home" 2>/dev/null || jenv add "$(brew --prefix)/opt/openjdk@21"

jenv global 17 || jenv global 17.0

# 9. Configure NVM and install Node 22
echo "Configuring nvm and installing Node 22..."
mkdir -p "$HOME/.nvm"
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"

nvm install 22
nvm alias default 22
nvm use 22

# 10. Create the .zshenv file
echo "Configuring .zshenv..."
cat << 'EOF' > "$HOME/.zshenv"
# --- System Defaults ---
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# --- CLI Tool Defaults ---
export EDITOR="vim"
export PAGER="less"
export LESS="-R"

# --- AWS Defaults ---
export AWS_DEFAULT_REGION="us-east-1"
export AWS_PROFILE="default"
export AWS_PAGER=""

# --- Custom Paths ---
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
EOF

# 11. Create the .aliases file
echo "Configuring .aliases..."
cat << 'EOF' > "$HOME/.aliases"
# --- AWS Aliases ---
alias a="aws"
alias as3="aws s3"
alias aec2="aws ec2"

# --- GitLab Aliases ---
alias gl="glab"
alias glmr="glab mr"
alias glp="glab pipeline"
alias glc="glab ci"

# --- Python / uv Aliases ---
alias uvi="uv pip install"
alias uvenv="uv venv && source .venv/bin/activate"

# --- Navigation & Utilities ---
alias ll="ls -lah"
alias ..="cd .."
alias ...="cd ../.."
EOF

# 12. Create the .functions file
echo "Configuring .functions..."
cat << 'EOF' > "$HOME/.functions"
# Generate a reference file containing configuration details
export_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local out_file="$HOME/zsh_config_reference_${timestamp}.txt"
    
    echo "=== .aliases ===" > "$out_file"
    [ -f "$HOME/.aliases" ] && cat "$HOME/.aliases" >> "$out_file" || echo "No .aliases found." >> "$out_file"
    
    echo -e "\n\n=== .functions ===" >> "$out_file"
    [ -f "$HOME/.functions" ] && cat "$HOME/.functions" >> "$out_file" || echo "No .functions found." >> "$out_file"
    
    echo -e "\n\n=== CURRENT ACTIVE ALIASES (Includes Plugins) ===" >> "$out_file"
    alias >> "$out_file"
    
    echo -e "\n\n=== .zshrc ===" >> "$out_file"
    [ -f "$HOME/.zshrc" ] && cat "$HOME/.zshrc" >> "$out_file" || echo "No .zshrc found." >> "$out_file"
    
    echo -e "\n\n=== .zshenv ===" >> "$out_file"
    [ -f "$HOME/.zshenv" ] && cat "$HOME/.zshenv" >> "$out_file" || echo "No .zshenv found." >> "$out_file"
    
    echo "Configuration exported to: $out_file"
}
EOF

# 13. Backup existing and write the new .zshrc file
echo "Configuring .zshrc..."
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak"

cat << 'EOF' > "$HOME/.zshrc"
# Homebrew path (handles Apple Silicon, Intel Macs, and Linux)
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    alias-finder
    aws
    colored-man-pages
    copybuffer
    copydir
    copyfile
    docker
    docker-compose
    fzf
    git
    git-auto-fetch
    gradle
    jenv
    mvn
    npm
    nvm
    python
    yarn
)

source $ZSH/oh-my-zsh.sh

# --- User Configuration ---

# Load External Configs
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.functions" ] && source "$HOME/.functions"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

# jenv Configuration
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Zsh Autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "Setup complete! Your old .zshrc was backed up to .zshrc.bak."
echo "Please restart your terminal or run 'exec zsh' to apply changes."