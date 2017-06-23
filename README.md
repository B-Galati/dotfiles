# Dotfiles

## How to install on Debian Stretch

Packages used :

```bash
sudo apt install git sudo rsync numlockx screenfetch zsh vim \
arandr gtk2-engines-murrine murrine-themes dmz-cursor-theme \
unzip gtk-redshift geoclue-2.0 hddtemp gimp \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity openjdk-8-jre \
ttf-mscorefonts-installer network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld ntp youtube-dl htop gvfs-backends p7zip cryptkeeper homebank \
smartmontools msmtp mailutils smart-notifier gsmartcontrol handbrake transmission \
apt-file hardinfo psensor catfish xarchiver zip simple-scan backintime-gnome \
shutter phatch gparted gtk3-engines-xfce httpie gnome-screensaver libnss3-tools \
multitail tig dos2unix gnome-calculator evince \
colordiff autossh gettext software-properties-common pkg-config libgtk-3-dev \
automake autoconf sshpass strace powerline kodi tmux \
ttf-dejavu ttf-dejavu-core ttf-dejavu-extra ttf-freefont ttf-liberation \
gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress gnome-shell-pomodoro

sudo apt-get remove --purge xscreensaver light-locker

pip install --user ansible-lint passlib # -> ~/.local/bin/

sudo apt install <intel-microcode|amd64-microcode>
```

Prepare and install dotfiles :

```bash
git clone --recursive
./bootstrap
```

Install [Powerline patched fonts](https://github.com/powerline/fonts).
[Unicode table](http://unicode-table.com/)

## Powerline

[Segments list](http://powerline.readthedocs.io/en/master/configuration/segments.html#segments)

```bash
powerline-lint # Verifying settings
powerline-daemon --replace # Force config reloading
```

## BTSync

```bash
sudo systemctl enable btsync@benoit
sudo systemctl start btsync@benoit
```

## GTK themes

- [Arc](https://github.com/horst3180/arc-theme)
- [Numix Frost](https://github.com/Antergos/Numix-Frost)

## Icon themes

- [numix](https://github.com/numixproject/)
- [numix-colmaris](https://labo.olivierdelort.net/colmaris/numix-colmaris.git)

## Credits

- [olivierdelort](https://blog.delort.email/embellir-sa-debian-et-xfce/)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [jfrazelle](https://github.com/jfrazelle/dotfiles)
- [jubianchi](https://github.com/jubianchi/dotfiles)
- [willdurand](https://github.com/willdurand/dotfiles)
