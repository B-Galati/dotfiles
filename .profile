# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

PATH="$PATH:$HOME/npm-global/bin"
PATH="$PATH:./vendor/bin"
PATH="$PATH:./bin"
PATH="$PATH:usr/games"
PATH="$PATH:/usr/local/games"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# cf. bug https://bugzilla.redhat.com/show_bug.cgi?id=889690
export NO_AT_BRIDGE=1
