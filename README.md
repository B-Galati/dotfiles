# Dotfiles

## How to install on Debian Stretch

Packages used :

```bash
sudo apt install git sudo rsync numlockx screenfetch zsh vim \
arandr dmz-cursor-theme \
unzip gtk-redshift geoclue-2.0 hddtemp gimp \
ntfs-3g apt-listbugs apt-listchanges alacarte zenity \
ttf-mscorefonts-installer network-manager-openvpn-gnome \
filezilla apt-transport-https ca-certificates curl python-pip vim-nox \
meld ntp youtube-dl htop gvfs-backends p7zip cryptkeeper homebank \
smartmontools msmtp mailutils smart-notifier gsmartcontrol handbrake transmission \
apt-file hardinfo psensor catfish xarchiver zip simple-scan backintime-gnome \
shutter phatch gparted httpie gnome-screensaver libnss3-tools \
multitail tig dos2unix gnome-calculator evince \
colordiff autossh gettext software-properties-common pkg-config libgtk-3-dev \
automake autoconf sshpass strace powerline tmux \
ttf-dejavu ttf-dejavu-core ttf-dejavu-extra ttf-freefont ttf-liberation \
gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress gnome-shell-pomodoro \
xdotool wmctrl arc-theme shellcheck ansible davfs2 gpick krita sshuttle

sudo apt-get remove --purge xscreensaver light-locker

pip install --user ansible-lint passlib # -> ~/.local/bin/

sudo apt install <intel-microcode|amd64-microcode>
```

Prepare and install dotfiles :

```bash
git clone --recursive
./bootstrap
```

- If needed, install [Powerline patched fonts](https://github.com/powerline/fonts).
    - see [Unicode table](http://unicode-table.com/)
- L2TP https://github.com/nm-l2tp/network-manager-l2tp/wiki/Prebuilt-Packages#ubuntu
- See [this article](http://ajclarkson.co.uk/blog/auto-mount-webdav-raspberry-pi/) to mount a webdav folder locally

## Powerline

[Segments list](http://powerline.readthedocs.io/en/master/configuration/segments.html#segments)

```bash
powerline-lint # Verifying settings
powerline-daemon --replace # Force config reloading
```

## BTSync

Install btsync here `/usr/local/bin/btsync`

```bash
sudo systemctl enable btsync@benoit
sudo systemctl start btsync@benoit
```

## Gnome Pomodoro

Actions to add :

```
# On resume and enable (close pomodoro window)
bash -c "xdotool search --sync --name 'Pomodoro Timer' | xargs -I{} -n 1 wmctrl -i -c {}"

# On break complete (display pomodoro window)
gnome-pomodoro
```

## Atom

```bash
 # Save
apm list --installed --bare > package-list.txt

 # Restore
apm install --packages-file package-list.txt
```

## Bépo and keyboard configuration

[source](https://bepo.fr/wiki/Console_GNU/Linux#Configuration_avanc.C3.A9e)
[Keyboard Wiki Debian](https://wiki.debian.org/fr/Keyboard)
[ArchLinux Wiki](https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg)

Switch keyboard manually

```bash
setxkbmap fr bepo
```

To re-configure the keyboard :

```bash
sudo dpkg-reconfigure keyboard-configuration
```

Update file `/etc/default/keyboard` :

```
XKBMODEL="tm2030USB-102"
XKBLAYOUT="fr,fr"
XKBVARIANT="bepo,"
XKBOPTIONS="grp:alt_caps_toggle"
```

## HiDPI

https://wiki.archlinux.org/index.php/HiDPI


## Dropbox

Tray icon is not showing [fixed](https://askubuntu.com/questions/732967/dropbox-icon-is-not-working-xubuntu-14-04-lts-64) by runnig `dropbox stop && dbus-launch dropbox start -i`.

## Firefox

[source](https://support.mozilla.org/en-US/questions/814083)

edit `~/.mozilla/firefox/{profile_name}.default/chrome/userContent.css`

```css
input, textarea, select {
    color:#000 !important;
    background-color:#fff !important;
    -moz-appearance: none !important;
}
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
