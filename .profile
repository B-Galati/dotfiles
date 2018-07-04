# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

PATH="$PATH:/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin"
PATH="$PATH:$HOME/.local/bin"
PATH="$PATH:/snap/bin"
PATH="$PATH:$HOME/.platformsh/bin"
PATH="$PATH:$HOME/.sensiocloud/bin"
PATH="$PATH:$HOME/.composer/vendor/bin"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# cf. bug https://bugzilla.redhat.com/show_bug.cgi?id=889690
#export NO_AT_BRIDGE=1
