## Setup

Prepare and install dotfiles :

```bash
git clone --recursive
./bootstrap
```

- If needed, install [Powerline patched fonts](https://github.com/powerline/fonts).
    - see [Unicode table](http://unicode-table.com/)
- L2TP https://github.com/nm-l2tp/network-manager-l2tp/wiki/Prebuilt-Packages#ubuntu
- See [this article](http://ajclarkson.co.uk/blog/auto-mount-webdav-raspberry-pi/) to mount a webdav folder locally

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

## Credits

- [olivierdelort](https://blog.delort.email/embellir-sa-debian-et-xfce/)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [jfrazelle](https://github.com/jfrazelle/dotfiles)
- [jubianchi](https://github.com/jubianchi/dotfiles)
- [willdurand](https://github.com/willdurand/dotfiles)
- [lyrixx](https://github.com/lyrixx/dotfiles)
