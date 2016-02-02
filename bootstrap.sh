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
        rm -rf "$2"
    fi

    if ln -snf "$1" "$2"; then
        success "linked $1 to $2"
    else
        fail "linked $1 to $2"
    fi
}

doIt () {
#	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
 #   	  --exclude "README.md" --exclude "LICENSE-MIT.txt" --exclude ".extra" -avh --no-perms . ~;

    # Création des fichiers de config
    for file in \
        ".gitconfig" \
        ".bashrc" \
        ".bash_aliases" \
        ".bash_logout" \
        ".exports" \
        ".functions" \
        ".gitignore_global" \
        ".inputrc" \
        ".profile" \
        ".tmux.conf" \
        ".vimrc" \
        ".xsessionrc" \
        ".composer/config.json" \
        ".btsync/btsync.conf" \
        ".config/redshift.conf" \
        ".config/gtk-3.0/settings.ini" \
        ".config/gtk-3.0/gtk.css" \
        ".config/htop/htoprc" \
        ".config/nautilus/accels" \
        ".config/xfce4/terminal/terminalrc" \
        ".config/xfce4/terminal/accels.scm" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" \
        ".config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" \
        ".config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap" \
        ".config/sublime-text-3/Packages/User/Evernote.sublime-settings" \
        ".config/sublime-text-3/Packages/User/Markdown.sublime-settings" \
        ".config/sublime-text-3/Packages/User/Package Control.sublime-settings" \
        ".config/sublime-text-3/Packages/User/Preferences.sublime-settings" \
        ".WebIde100/config/installed.txt" \
        ".WebIde100/config/codestyles/Default _1_.xml" \
        ".WebIde100/config/keymaps/Azerty.xml" \
        ".WebIde100/config/keymaps/Bepo.xml" \
        ".WebIde100/config/templates/PHP.xml" \
        ".WebIde100/config/templates/Twig.xml" \
        ".WebIde100/config/tools/External Tools.xml" \
        ".WebIde100/config/options/appComponentVersions.xml" \
        ".WebIde100/config/options/baseRefactoring.xml" \
        ".WebIde100/config/options/cachedDictionary.xml" \
        ".WebIde100/config/options/code.style.schemes.xml" \
        ".WebIde100/config/options/colors.scheme.xml" \
        ".WebIde100/config/options/editor.codeinsight.xml" \
        ".WebIde100/config/options/editor.xml" \
        ".WebIde100/config/options/GrepConsole.xml" \
        ".WebIde100/config/options/ignore.xml" \
        ".WebIde100/config/options/keymap.xml" \
        ".WebIde100/config/options/markdown.xml" \
        ".WebIde100/config/options/remote-servers.xml" \
        ".WebIde100/config/options/ui.lnf.xml" \
        ".WebIde100/config/options/usageView.xml" \
        "supervisor.conf" \
        "bin" \
        ".fonts" \
        ".themes"
    do
        linkFiles "$PWD/$file" "$HOME/$file"
    done

    # btsync ne suit pas les symlinks...
    if ln -f "$PWD/.btsync/btsync.conf" "$HOME/.btsync/btsync.conf"; then
        success "Hardlink pour btsync"
    else
        fail "Hardlink pour btsync"
    fi

    # Création des fichiers privés s'ils n'existent pas
    for file in ".extra" ".gitconfig_private"
    do
        if [ ! -f "$HOME/$file" ]; then
            cp $file $HOME
            info "Create $file in home $HOME"
        fi
    done
}

cd "$(dirname "${BASH_SOURCE}")"

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi

unset doIt

