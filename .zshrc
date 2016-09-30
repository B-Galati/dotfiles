# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export USER=''
ZSH_THEME='powerlevel9k/powerlevel9k'
ZSH_CUSTOM=$HOME/.custom-oh-my-zsh
COMPLETION_WAITING_DOTS='true' # Uncomment the following line to display red dots whilst waiting for completion.
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status symfony2_version time)

plugins=(symfony2 docker docker-compose composer debian extract colored-man-pages \
    phing supervisor colorize sudo sytemd git-remote-branch git-extras tmux)

source $ZSH/oh-my-zsh.sh
source /usr/share/powerline/bindings/zsh/powerline.zsh

for file in ~/.{aliases,exports,functions,extra,dockerfunc}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Bind up and down keys to search in history by the already entered characters
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Bind End and Home keys
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
#bindkey "${terminfo[khome]}" beginning-of-line
#bindkey "${terminfo[kend]}" end-of-line

screenfetch
