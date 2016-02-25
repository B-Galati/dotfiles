# Dotfiles

## Debian requirements

apt install git sudo rsync numlockx screenfetch zsh vim \
arandr gtk2-engines-murrine murrine-themes dmz-cursor-theme \
unzip gtk-redshift geoclue hddtemp light-locker kodi \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity openjdk-8-jre \
ttf-mscorefonts-installer msttcorefonts network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld

sudo apt-get remove --purge xscreensaver



fichier de confs modifiés:

   10  vi /etc/.zsh
   24  screenfetch
   40  sudo vi /etc/apt/sources.list
   59  git fetch --all
  110  sudo mkdir /etc/lightdm/lightdm.d
  111  vi /etc/lightdm/lightdm.d/
  112  sudo vi /etc/lightdm/lightdm.d/01_malightdm.conf
  113  sudo vi /etc/lightdm/lightdm-gtk-greeter.conf
  114  sudo cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
  115  sudo vi /etc/lightdm/lightdm-gtk-greeter.conf
  133  sudo vi /etc/lightdm/lightdm-gtk-greeter.conf
  134  sudo vi /etc/lightdm/lightdm.conf
  135  sudo vi /etc/lightdm/lightdm.d/01_malightdm.conf
  150  sudo vi /etc/lightdm/lightdm.d/01_malightdm.conf
  170  sudo vi /etc/fstab
  186  cat /etc/apt/sources.list
  187  sudo vi /etc/sudoers
  189  cat /etc/sudoers
  190  sudo cat /etc/sudoers
  192  sudo vi /etc/default/grub
  194  sudo vi /etc/default/grub
  196  cat /etc/default/grub
  197  sudo vi /etc/sysctl.d/local.conf
  198  sudo vi /etc/default/tmpfs
  236  sudo vi /etc/sysctl.conf
  237  sudo vi /etc/sysctl.d/local.conf

## How to install:

```bash
git clone
git submodule update --init --recursive
./bootstrap
```

## icons themes

- [numix](https://github.com/numixproject/)
- [numix-colmaris](https://labo.olivierdelort.net/colmaris/numix-colmaris.git)

## Crédits :

- [olivierdelort](https://blog.olivierdelort.net/?p=1790)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [jfrazelle](https://github.com/jfrazelle/dotfiles)
- [jubianchi](https://github.com/jubianchi/dotfiles)
- [willdurand](https://github.com/willdurand/dotfiles)