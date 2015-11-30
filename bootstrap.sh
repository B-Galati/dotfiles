#!/usr/bin/env bash
# Credits :
#   https://github.com/willdurand/dotfiles/blob/master/bin/install
#   https://github.com/mathiasbynens/dotfiles
#

info () {
    printf "  [ \033[00;34m..\033[0m ] %s" "$1"
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
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
    	  --exclude "README.md" --exclude "LICENSE-MIT.txt" --exclude ".extra" -avh --no-perms . ~;

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
        ".WebIde90/config/codestyles/Default _1_.xml" \
        ".WebIde90/config/keymaps/Default copy.xml" \
        ".WebIde90/config/keymaps/Default for GNOME copy.xml" \
        ".WebIde90/config/tools/External Tools.xml" \
        "supervisor.conf" \
        "bin" \
        ".fonts" \
        ".themes"
    do
        linkFiles "$PWD/$file" "$HOME/$file"
    done

    if [ ! -f "$HOME/.extra" ]; then
        cp .extra "$HOME"
        info "Create .extra in home"
    fi
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

echo ''
unset doIt

