alias g='git'
alias c='claude --enable-auto-mode'
alias c!='claude --dangerously-skip-permissions'
alias reload='source ~/.zshrc 2>/dev/null || source ~/.bashrc'

alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias grep='grep --color=auto'

alias path='echo $PATH | tr -s ":" "\n"'

clone() { cd ~/code && git clone "$@"; }

# User scripts
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Machine-local overrides (not tracked in dotfiles)
[ -f ~/.aliases.local ] && . ~/.aliases.local
