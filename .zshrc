# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export TERM='xterm-256color'
ZSH_THEME='powerlevel9k/powerlevel9k'
ZSH_CUSTOM=$HOME/.custom-oh-my-zsh
COMPLETION_WAITING_DOTS='true' # Uncomment the following line to display red dots whilst waiting for completion.
ZSH_AUTOSUGGEST_STRATEGY='match_prev_cmd'

# Theme customization
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs_joined time)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs symfony2_version)
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%B%}❯%{%b%} "

plugins=(docker docker-compose debian extract colored-man-pages \
    phing supervisor colorize sudo systemd git-remote-branch git-extras tmux zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
source /usr/share/powerline/bindings/zsh/powerline.zsh

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.z.sh ] && . ~/.z.sh
