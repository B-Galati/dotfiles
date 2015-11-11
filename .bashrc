# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export EDITOR=vim # Editeur par défaut
export GIT_PS1_SHOWDIRTYSTATE=1 # Montre si modif de la copie locale (*) ou (+) pour l'index
export GIT_PS1_SHOWSTASHSTATE=1 # Montre si éléments stashés ($)
export GIT_PS1_SHOWUNTRACKEDFILES=1 # Montre si fichiers non versionnés (%)
export GIT_PS1_SHOWUPSTREAM=verbose # Avance/Retard par rapport à la branche distante (<) (>) (=)
export GIT_PS1_DESCRIBE_STYLE=branch # Si detached HAED alors affiche des infos utiles
export GIT_PS1_SHOWCOlORHINTS=true # Active les couleurs fournis par .git-prompt.sh
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND" # Ajoute les nouvelles commandes dans le fichier d'historique 

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

HISTSIZE=5000 # Nombre de commande max dans l'historique
HISTFILESIZE=2000 # Taille maxi du fichier d'historique
HISTCONTROL=ignoreboth # Pas de duplication des lignes d'historique
shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # redimensionne le terminal après l'exécution d'une commande
shopt -s cdspell # autocorrects cd misspellings
shopt -s expand_aliases # clear enoush :)
shopt -s cmdhist # save command long command in history

# Load the shell dotfiles, and then some:
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{bash_aliases,exports,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# PS1
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\e[01;31m\]$(__git_ps1)\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Auto-Complétion
complete -cf sudo
complete -cf man

# ls indicators meaning : 
# / is a directory
# @ is a symlink
# | is a named pipe (fifo)
# = is a socket.
# * for executable files
# > is for a "door" -- a file type currently not implemented for Linux, but supported on Sun/Solaris.

screenfetch
