#!/usr/bin/env bash
# Credits :
#   https://github.com/willdurand/dotfiles/blob/master/bin/install
#   https://github.com/mathiasbynens/dotfiles
#

info () {
    printf "  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

success () {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

fail () {
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
}

linkFiles () {
    if [ -d "$2" ] ; then
        if [ -L "$2" ]; then
            info "SKIP folder '$1' -> symlink already exists in '$2'"
        else
            fail "SKIP folder '$1' -> already exists in '$2'"
        fi
        return 0
    fi

    # proposer un autosync du genre
    # rsync -ah $2 $1
    # rm -rf $2
    # puis le symlink

    # if ln -snf "$1" "$2"; then
    #     success "linked $1 to $2"
    # else
    #     fail "linked $1 to $2"
    # fi
}

doIt () {
    # Création des fichiers de config
    for file in $(find $PWD \
        -maxdepth 1 \
        -name ".*" \
        -not -name ".gitignore" \
        -not -name ".extra" \
        -not -name ".gitconfig_private" \
        -not -name ".git" \
        -not -name "*.swp" \
        -not -path "*.oh-my-zsh*" \
        -not -path "*.gitmodules*" \
        -not -path "*.git/*")
    do
        linkFiles $file "$HOME/$(basename $file)"
    done

    # btsync ne suit pas les symlinks...
    # en principe on va directement aller chercher le répertoire de btsync
    # if ln -f "$PWD/.btsync/btsync.conf" "$HOME/.btsync/btsync.conf"; then
    #     success "Hardlink for btsync"
    # else
    #     fail "Hardlink for btsync"
    # fi

    # Création des fichiers privés s'ils n'existent pas
    for file in ".extra" ".gitconfig_private"
    do
        if [ ! -f "$HOME/$file" ]; then
            cp $file $HOME
            success "Create $file in home $HOME"
        else
            info "SKIP private file '$file' -> already exists"
        fi
    done
}

cd "$(dirname "${BASH_SOURCE}")"

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi

unset doIt

