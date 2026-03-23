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

# uv Autocompletion
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# Zsh Autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh