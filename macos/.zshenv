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
export AWS_PAGER=""       # Prevents AWS CLI from trapping output in a pager like 'less'

# --- Custom Paths ---
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi