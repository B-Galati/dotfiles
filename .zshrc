export EDITOR=vim

if command -v tmux &> /dev/null \
    && command -v tmuxInit &> /dev/null \
    && ! tmux list-sessions &> /dev/null \
    && [ -n "$PS1" ] \
    && [ -n "$ALACRITTY_WINDOW_ID" ] \
    && [ -z "$TMUX" ] \
    && [[ ! "$TERM" =~ screen ]] \
    && [[ ! "$TERM" =~ tmux ]]
  then
    tmuxInit
    tmux attach -t home
fi

export ZSH=$HOME/.oh-my-zsh
export TERM='xterm-256color'
COMPLETION_WAITING_DOTS='true'

plugins=(docker docker-compose extract colored-man-pages \
    supervisor sudo systemd tmux fzf rust kubectl k3d helm)

zstyle ':omz:update' mode disabled
source $ZSH/oh-my-zsh.sh


for file in ~/.{aliases,exports,functions,extra,dockerfunc}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

HISTFILE=~/.zsh_history
SAVEHIST=10000

# See http://zsh.sourceforge.net/Doc/Release/Options.html
unsetopt SHARE_HISTORY
unsetopt INC_APPEND_HISTORY_TIME
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt BANG_HIST
setopt HIST_FCNTL_LOCK
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Prevent ZSH to print an error when no match can be found. (http://superuser.com/questions/584249/using-wildcards-in-commands-with-zsh)
unsetopt nomatch

# Bind up and down keys to search in history by the already entered characters
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Bind End and Home keys
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
#bindkey "${terminfo[khome]}" beginning-of-line
#bindkey "${terminfo[kend]}" end-of-line

[ -f ~/z/z.sh ] && . ~/z/z.sh
if command -v starship &> /dev/null; then eval "$(starship init zsh)"; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
