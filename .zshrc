alias g=git

export EDITOR="code --wait"
export VISUAL=$EDITOR
export GIT_SEQUENCE_EDITOR=$EDITOR

# Set editor based on current environment
if [[ "$TERM_PROGRAM" == "Cursor" ]]; then
  export EDITOR="cursor --wait"
  export VISUAL=$EDITOR
  export GIT_SEQUENCE_EDITOR=$EDITOR
fi

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicates
setopt HIST_REDUCE_BLANKS     # Remove unnecessary blanks
setopt HIST_VERIFY           # Show command with history expansion before running it

# System
alias reload='source ~/.zshrc'    # Reload zsh config
alias path='echo $PATH | tr -s ":" "\n"'  # Pretty print PATH

# Better defaults
alias cp='cp -i'       # Confirm before overwriting
alias mv='mv -i'       # Confirm before overwriting
alias mkdir='mkdir -p' # Create parent directories if needed

# Color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Add color to grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Better tab completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' [%b]'

# Set up the prompt with more detailed git info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'

# Set up the prompt
setopt PROMPT_SUBST
PROMPT='%F{cyan}%n%f@%F{magenta}%m%f %F{blue}%~%f${vcs_info_msg_0_} $ '

# Git branch completion
autoload -Uz compinit && compinit
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1 # only local branches
zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
fpath=(~/.zsh/completion $fpath)

# Download git completion script if it doesn't exist
if [ ! -f ~/.git-completion.bash ]; then
  curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
fi

# Create completion directory if it doesn't exist
if [ ! -d ~/.zsh/completion ]; then
  mkdir -p ~/.zsh/completion
fi

# Download zsh git completion if it doesn't exist
if [ ! -f ~/.zsh/completion/_git ]; then
  curl -o ~/.zsh/completion/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
fi

# Download git-prompt script if it doesn't exist
if [ ! -f ~/.git-prompt.sh ]; then
  curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi
