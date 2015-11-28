#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
    	  --exclude "README.md" --exclude "LICENSE-MIT.txt" --exclude ".extra" -avh --no-perms . ~;
    
    ln -snf "$PWD/.gitconfig" "$HOME/.gitconfig"
    ln -snf "$PWD/.bashrc" "$HOME/.bashrc"
    ln -snf "$PWD/.bash_aliases" "$HOME/.bash_aliases"
    ln -snf "$PWD/.bash_logout" "$HOME/.bash_logout"
    ln -snf "$PWD/.exports" "$HOME/.exports"
    ln -snf "$PWD/.functions" "$HOME/.functions"
    ln -snf "$PWD/.gitignore_global" "$HOME/.gitignore_global"
    ln -snf "$PWD/.inputrc" "$HOME/.inputrc"
    ln -snf "$PWD/.profile" "$HOME/.profile"
    ln -snf "$PWD/.tmux.conf" "$HOME/.tmux.conf"
    ln -snf "$PWD/.vimrc" "$HOME/.vimrc"
    ln -snf "$PWD/.xsessionrc" "$HOME/.xsessionrc"
    ln -snf "$PWD/.composer/config.json" "$HOME/.composer/config.json"
    ln -snf "$PWD/.btsync/btsync.conf" "$HOME/.btsync/btsync.conf"
    ln -snf "$PWD/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    ln -snf "$PWD/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    ln -snf "$PWD/.config/htop/htoprc" "$HOME/.config/htop/htoprc"
    ln -snf "$PWD/.config/nautilus/accels" "$HOME/.config/nautilus/accels"
    ln -snf "$PWD/.config/xfce4/terminal/terminalrc" "$HOME/.config/xfce4/terminal/terminalrc"
    ln -snf "$PWD/.config/xfce4/terminal/accels.scm" "$HOME/.config/xfce4/terminal/accels.scm"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
    ln -snf "$PWD/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
    ln -snf "$PWD/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap" "$HOME/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
    ln -snf "$PWD/.config/sublime-text-3/Packages/User/Evernote.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Evernote.sublime-settings"
    ln -snf "$PWD/.config/sublime-text-3/Packages/User/Markdown.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Markdown.sublime-settings"
    ln -snf "$PWD/.config/sublime-text-3/Packages/User/Package Control.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings"
    ln -snf "$PWD/.config/sublime-text-3/Packages/User/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
    ln -snf "$PWD/.WebIde90/config/codestyles/Default _1_.xml" "$HOME/.WebIde90/config/codestyles/Default _1_.xml"
    ln -snf "$PWD/.WebIde90/config/keymaps/Default copy.xml" "$HOME/.WebIde90/config/keymaps/Default copy.xml"
    ln -snf "$PWD/.WebIde90/config/keymaps/Default for GNOME copy.xml" "$HOME/.WebIde90/config/keymaps/Default for GNOME copy.xml"
    ln -snf "$PWD/.WebIde90/config/tools/External Tools.xml" "$HOME/.WebIde90/config/tools/External Tools.xml"

    if [ -d "$HOME/supervisor.conf" ]; then rm -rf "$HOME/supervisor.conf"; fi
    ln -snf "$PWD/supervisor.conf" "$HOME/supervisor.conf"

    if [ -d "$HOME/bin" ]; then rm -rf "$HOME/bin"; fi
    ln -snf "$PWD/bin" "$HOME/bin"

    if [ -d "$HOME/.fonts" ]; then rm -rf "$HOME/.fonts"; fi
    ln -snf "$PWD/.fonts" "$HOME/.fonts"

    if [ -d "$HOME/.themes" ]; then rm -rf "$HOME/.themes"; fi
    ln -snf "$PWD/.themes" "$HOME/.themes"

    if [ ! -f "extra" ]; then
        cp .extra "$HOME"
    fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt;
