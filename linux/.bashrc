# --- Directory Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# --- Directory Listing ---
# Enables colorized output for ls
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
alias ls='ls --color=auto'

alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

# --- Directory Operations ---
alias md='mkdir -p'
alias rd='rmdir'

# --- Quick Directory Stack (Mimics zsh 'd', '1', '2', etc. behavior loosely) ---
alias d='dirs -v | head -n 10'