# Prompt

# Interactive prompt
autoload -Uz vcs_info
precmd_functions+=( vcs_info )
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '%F{200}[%b%u%c]%f'
zstyle ':vcs_info:*' enable git

PROMPT='[${HOSTNAME}]%(?.%F{green}√.%F{red}?%?)%f %B%~%b $vcs_info_msg_0_ $ '

git_new_branch() {
  # Check if a branch name was provided
  if [ -z "$1" ]; then
  echo "Error: Please provide a branch name."
    return 1
  fi

  # Get current date in yyyymmdd format
  current_date=$(date +"%Y%m%d")

  # Create the branch name
  branch_name="tg-${current_date}-$1"

  # Create and checkout the new branch
  git checkout -b "$branch_name"
}

alias g=git
alias gco='git_new_branch'
alias t=bin/test 
