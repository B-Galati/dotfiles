# Dotfiles

## How to install on Debian Jessie

Edit your `/apt/apt/sources.list` with :

```
deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free
```

Packages used :

```bash
sudo apt install git sudo rsync numlockx screenfetch zsh vim \
arandr gtk2-engines-murrine murrine-themes dmz-cursor-theme \
unzip gtk-redshift geoclue hddtemp \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity openjdk-8-jre \
ttf-mscorefonts-installer network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld ntp youtube-dl htop gvfs-backends p7zip cryptkeeper homebank \
smartmontools msmtp mailutils smart-notifier gsmartcontrol handbrake transmission \
apt-file hardinfo psensor catfish xarchiver zip simple-scan backintime-gnome \
shutter phatch gparted gtk3-engines-xfce httpie php5 \
gdm3 gnome-screensaver libnss3-tools multitail tig dos2unix gnome-calculator \
colordiff autossh gettext software-properties-common pkg-config libgtk-3-dev \
automake autoconf sshpass strace

sudo apt-get remove --purge xscreensaver
sudo apt-get install -t jessie-backports powerline kodi tmux

pip install --user ansible-lint passlib # -> ~/.local/bin/
```

Prepare and install dotfiles :

```bash
git clone # This repository
git submodule update --init --recursive
./bootstrap
```

You can try to intall gtk3-engines-unico

Install [Powerline patched fonts](https://github.com/powerline/fonts).
[Unicode table](http://unicode-table.com/)

## Powerline

[Segments list](http://powerline.readthedocs.io/en/master/configuration/segments.html#segments)

```bash
powerline-lint # Vérification des fichiers de configuration
powerline-daemon --replace # Force le rechargement de la config
```

## GTK themes

- [Arc](https://github.com/horst3180/arc-theme)
- [Numix Frost](https://github.com/Antergos/Numix-Frost)

## Icon themes

- [numix](https://github.com/numixproject/)
- [numix-colmaris](https://labo.olivierdelort.net/colmaris/numix-colmaris.git)

## Credits

- [olivierdelort](https://blog.olivierdelort.net/?p=1790)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [jfrazelle](https://github.com/jfrazelle/dotfiles)
- [jubianchi](https://github.com/jubianchi/dotfiles)
- [willdurand](https://github.com/willdurand/dotfiles)
