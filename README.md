# Dotfiles

## Debian requirements

[Powerline](https://powerline.readthedocs.org/en/latest/installation.html) fonts are required

```bash
apt install git sudo rsync numlockx screenfetch zsh vim \
arandr gtk2-engines-murrine murrine-themes dmz-cursor-theme \
unzip gtk-redshift geoclue hddtemp light-locker kodi \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity openjdk-8-jre \
ttf-mscorefonts-installer msttcorefonts network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld ntp youtube-dl htop gvfs-backends p7zip cryptkeeper homebank \
smartmontools msmtp mailutils smart-notifier gsmartcontrol handbrake transmission \
apt-file hardinfo psensor catfish xarchiver zip simple-scan backintime-gnome \
shutter phatch gparted gtk3-engines-xfce gtk3-engines-xfce httpie php5 \
gdm3 gnome-screen-saver

sudo apt-get remove --purge xscreensaver
```

## How to install:

```bash
git clone
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
