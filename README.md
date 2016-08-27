# Dotfiles

## How to install on Debian Jessie

Edit your `/apt/apt/sources.list` with :

```
deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free

# jessie-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free

deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free
```

Install those packages

```bash
sudo apt install git sudo rsync numlockx screenfetch zsh vim \
arandr gtk2-engines-murrine murrine-themes dmz-cursor-theme \
unzip gtk-redshift geoclue hddtemp kodi \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity openjdk-8-jre \
ttf-mscorefonts-installer network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld ntp youtube-dl htop gvfs-backends p7zip cryptkeeper homebank \
smartmontools msmtp mailutils smart-notifier gsmartcontrol handbrake transmission \
apt-file hardinfo psensor catfish xarchiver zip simple-scan backintime-gnome \
shutter phatch gparted gtk3-engines-xfce httpie php5 \
gdm3 gnome-screensaver libnss3-tools tmux

sudo apt-get remove --purge xscreensaver
sudo apt-get install -t jessie-backports powerline
```

Prepare and install dotfiles :

```bash
git clone # This repository
git submodule update --init --recursive
./bootstrap
```

You can try to intall gtk3-engines-unico

## Icon themes

- [numix](https://github.com/numixproject/)
- [numix-colmaris](https://labo.olivierdelort.net/colmaris/numix-colmaris.git)

## Credits :

- [olivierdelort](https://blog.olivierdelort.net/?p=1790)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [jfrazelle](https://github.com/jfrazelle/dotfiles)
- [jubianchi](https://github.com/jubianchi/dotfiles)
- [willdurand](https://github.com/willdurand/dotfiles)
