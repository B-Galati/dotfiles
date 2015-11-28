#!/usr/bin/env bash
# Credits : 
#   https://github.com/willdurand/dotfiles/blob/master/bin/install
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
    
    linkFiles "$PWD/.gitconfig" "$HOME/.gitconfig"
    linkFiles "$PWD/.bashrc" "$HOME/.bashrc"
    linkFiles "$PWD/.bash_aliases" "$HOME/.bash_aliases"
    linkFiles "$PWD/.bash_logout" "$HOME/.bash_logout"
    linkFiles "$PWD/.exports" "$HOME/.exports"
    linkFiles "$PWD/.functions" "$HOME/.functions"
    linkFiles "$PWD/.gitignore_global" "$HOME/.gitignore_global"
    linkFiles "$PWD/.inputrc" "$HOME/.inputrc"
    linkFiles "$PWD/.profile" "$HOME/.profile"
    linkFiles "$PWD/.tmux.conf" "$HOME/.tmux.conf"
    linkFiles "$PWD/.vimrc" "$HOME/.vimrc"
    linkFiles "$PWD/.xsessionrc" "$HOME/.xsessionrc"
    linkFiles "$PWD/.composer/config.json" "$HOME/.composer/config.json"
    linkFiles "$PWD/.btsync/btsync.conf" "$HOME/.btsync/btsync.conf"
    linkFiles "$PWD/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    linkFiles "$PWD/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    linkFiles "$PWD/.config/htop/htoprc" "$HOME/.config/htop/htoprc"
    linkFiles "$PWD/.config/nautilus/accels" "$HOME/.config/nautilus/accels"
    linkFiles "$PWD/.config/xfce4/terminal/terminalrc" "$HOME/.config/xfce4/terminal/terminalrc"
    linkFiles "$PWD/.config/xfce4/terminal/accels.scm" "$HOME/.config/xfce4/terminal/accels.scm"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
    linkFiles "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
    linkFiles "$PWD/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap" "$HOME/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
    linkFiles "$PWD/.config/sublime-text-3/Packages/User/Evernote.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Evernote.sublime-settings"
    linkFiles "$PWD/.config/sublime-text-3/Packages/User/Markdown.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Markdown.sublime-settings"
    linkFiles "$PWD/.config/sublime-text-3/Packages/User/Package Control.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings"
    linkFiles "$PWD/.config/sublime-text-3/Packages/User/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
    linkFiles "$PWD/.WebIde90/config/codestyles/Default _1_.xml" "$HOME/.WebIde90/config/codestyles/Default _1_.xml"
    linkFiles "$PWD/.WebIde90/config/keymaps/Default copy.xml" "$HOME/.WebIde90/config/keymaps/Default copy.xml"
    linkFiles "$PWD/.WebIde90/config/keymaps/Default for GNOME copy.xml" "$HOME/.WebIde90/config/keymaps/Default for GNOME copy.xml"
    linkFiles "$PWD/.WebIde90/config/tools/External Tools.xml" "$HOME/.WebIde90/config/tools/External Tools.xml"
    linkFiles "$PWD/supervisor.conf" "$HOME/supervisor.conf"
    linkFiles "$PWD/bin" "$HOME/bin"
    linkFiles "$PWD/.fonts" "$HOME/.fonts"
    linkFiles "$PWD/.themes" "$HOME/.themes"

    if [ ! -f "extra" ]; then
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

