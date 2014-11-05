# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export EDITOR=vim # Editeur par défaut

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export TERM='xterm-color'
export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s" # Coloration syntaxique LESS
export LESS=' -R '
GIT_PS1_SHOWCOlORHINTS=true # Active les couleurs fournis par .git-prompt.sh
HISTSIZE=1000 # Nombre de commande max dans l'historique
HISTFILESIZE=2000 # Taille maxi du fichier d'historique
HISTCONTROL=ignoreboth # Pas de duplication des lignes d'historique

shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # redimenssionne le terminal après l'exécution d'une commande
shopt -s cdspell # autocorrects cd misspellings

# Auto-Complétion
complete -cf sudo
complete -cf man

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Enable git prompt bash functions, usefull for PS1
if [ -f ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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

# PS1
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\e[01;31m\]$(__git_ps1)\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# ls indicators meaning : 
# / is a directory
# @ is a symlink
# | is a named pipe (fifo)
# = is a socket.
# * for executable files
# > is for a "door" -- a file type currently not implemented for Linux, but supported on Sun/Solaris.

# Coloration commande less
export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s"
export LESS=' -R '

# Configurer un proxy
#export http_proxy='http://csproxy:80'
#export https_proxy=$http_proxy
#export ftp_proxy=$http_proxy
#export rsync_proxy=$http_proxy
#export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

# ############################################## #
#                     FONCTIONS                  #
# ############################################## #

# colored man pages
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}

# Extraire automatiquement une archive
function extract()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# lecture colorée de logs
logview()
{
	ccze -A < $1 | less -R
}

# lecture colorée de logs en directfunction logview()
logtail()
{
	tail -f $1 | ccze
}

