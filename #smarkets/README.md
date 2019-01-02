# Manual install steps

## Install via apt

### Install curl

```
sudo apt-get install curl
```


### Add keys and repositories

```
curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
curl -s https://keybase.io/docs/server_security/code_signing_key.asc | sudo apt-key add -
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
echo 'deb [arch=amd64] http://prerelease.keybase.io/deb stable main' | sudo tee /etc/apt/sources.list.d/keybase.list
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo add-apt-repository ppa:musicbrainz-developers/stable
sudo apt-add-repository ppa:nixnote/nixnote2-daily
sudo apt-add-repository ppa:sebastian-stenzel/cryptomator
sudo apt-add-repository ppa:yubico/stable
```

### Update

```
sudo apt-get update
```

### Install

```
sudo apt-get install -y \
alltray \
asciidoc \
cmake \
clipit \
compizconfig-settings-manager \
devscripts \
gcolor2 \
gimp \
google-chrome-stable \
keybase \
libcurl4-openssl-dev \
libldap2-dev \
libpam-pkcs11 \
libsasl2-dev \
libssl-dev \
libxml2 \
libxml2-dev \
monkeysphere \
nfs-kernel-server \
nixnote2 \
opensc-pkcs11 \
openssl \
picard \
pinentry-curses \
pinentry-tty \
pkg-config \
python-dev \
python-pip \
renmmina \
scdaemon \
shellcheck \
signal-desktop \
tmux \
vagrant \
vim \
virtualenv \
ykneomgr \
yubico-piv-tool \
yubikey-manager \
yubikey-personalization \
yubikey-personalization-gui \
yubikey-piv-manager \
yubioath-desktop \
xclip \
xsltproc \
wmctrl \

```

## Install via pip

```
pip install awscli --upgrade --user
```

## Install via snap

```
sudo snap install slack --classic
```

## Build gnupg-pkcs11-scd from source

```
git clone https://github.com/alonbl/gnupg-pkcs11-scd.git
cd gnupg-pkcs11-scd
git checkout gnupg-pkcs11-scd-0.7.4
git clean -fd
sudo apt-get install -y autoconf automake cdbs debhelper libpkcs11-helper1-dev libgpg-error-dev libassuan-dev libgcrypt11-dev
autoreconf --install
autoconf
automake
rm -rf gnupg-pkcs11-scd
ln -s distro/debian
dpkg-buildpackage -rfakeroot
cd ../
sudo dpkg -i gnupg-pkcs11-scd_*.deb
```

## Build lastpass-cli from source

```
git clone https://github.com/lastpass/lastpass-cli
cd lastpass-cli
make
sudo make install
sudo make install-doc
```

## Build yubikey-luks from source

```
git clone https://github.com/cornelinux/yubikey-luks.git
cd yubikey-luks
make builddeb NO_SIGN=1
sudo dpkg -i DEBUILD/yubikey-luks_*.deb
sudo sed -i -e 's/CONCATENATE=.*/CONCATENATE=1/g; s/HASH=.*/HASH=1/g' /etc/ykluks.cfg
sudo update-initramfs -u
sudo yubikey-luks-enroll
```

## Run keybase

```
run_keybase
```

## Terminal

Set the terminal settings:

```
(
BGCOLOR="#33322f"
FGCOLOR="#C5C8C6"
FGCOLOR="#f1ebeb"
BOLDCOLOR="$FGCOLOR"
BLACK_NORM="#48483e"
RED_NORM="#dc2566"
GREEN_NORM="#8fc029"
YELLOW_NORM="#d4c96e"
BLUE_NORM="#55aace"
MAGENTA_NORM="#9358fe"
CYAN_NORM="#56b7a5"
WHITE_NORM="#acada1"
BLACK_BOLD="#76715e"
RED_BOLD="#ff2874"
GREEN_BOLD="#bcff34"
YELLOW_BOLD="#ffe400"
BLUE_BOLD="#00b9fe"
MAGENTA_BOLD="#ae82ff"
CYAN_BOLD="#56ffdf"
WHITE_BOLD="#feffee"
PROFILE="custom"
COLORS="'$BLACK_NORM:$RED_NORM:$GREEN_NORM:$YELLOW_NORM:$BLUE_NORM:$MAGENTA_NORM:$CYAN_NORM:$WHITE_NORM:$BLACK_BOLD:$RED_BOLD:$GREEN_BOLD:$YELLOW_BOLD:$BLUE_BOLD:$MAGENTA_BOLD:$CYAN_BOLD:$WHITE_BOLD'"
dconf reset -f /org/mate/terminal/global/profile-list
dconf reset -f /org/mate/terminal/profiles
dconf write /org/mate/terminal/global/profile-list "['default', '$PROFILE']"
dconf write /org/mate/terminal/profiles/$PROFILE/use-theme-colors false
dconf write /org/mate/terminal/profiles/$PROFILE/palette "$COLORS"
dconf write /org/mate/terminal/profiles/$PROFILE/bold-color-same-as-fg false
dconf write /org/mate/terminal/profiles/$PROFILE/background-color "'$BGCOLOR'"
dconf write /org/mate/terminal/profiles/$PROFILE/foreground-color "'$FGCOLOR'"
dconf write /org/mate/terminal/profiles/$PROFILE/bold-color "'$BOLDCOLOR'"
dconf write /org/mate/terminal/profiles/$PROFILE/visible-name "'$PROFILE'"
dconf write /org/mate/terminal/profiles/$PROFILE/custom-command "'/bin/bash -i -c \"tmuxs\"'"
dconf write /org/mate/terminal/profiles/$PROFILE/use-custom-command true
dconf write /org/mate/terminal/profiles/$PROFILE/exit-action "'close'"
dconf write /org/mate/terminal/profiles/$PROFILE/falsecopy-selection false
)

```

## Editor

```
sudo update-alternatives --config editor
```

## Disable gnome-keyring and ssh-agent

```
gsettings set org.mate.session gnome-compat-startup "['smproxy']"
sudo sed -i 's/use-ssh-agent/#\0/' /etc/X11/Xsession.options
```

Untick Secret Storage Service

```
mate-session-properties
```

## Hardware

Disable Upower battery polling (for Apple Trackpad issues):

```
sudo sed -i 's/NoPollBatteries=false/NoPollBatteries=true/g' /etc/UPower/UPower.conf
sudo service upower restart
```

Disable bluetooth idle timeout (for Apple Trackpad issues):

```
sudo sed -i.bak 's/^#IdleTimeout=30/IdleTimeout=0/g' /etc/bluetooth/input.conf
sudo service bluetooth restart
```

Disable autosuspend for device on startup (for Apple Trackpad issues):

```
sudo sed -i 's#exit 0#'$HOME'/bin/apple-trackpad-autosuspend-disable\n\n&#' /etc/rc.local
```

## Screen rotation

Set console rotation:

````
sudo sed -i 's/GRUB_CMDLINE_LINUX="([^"])"/GRUB_CMDLINE_LINUX="\1 fbcon=rotate:1"/g' /etc/default/grub
update-grub
```

Set lightdm rotation:
```
sudo tee /etc/lightdm/lightdm.conf.d/80-display-setup.conf <<< '[SeatDefaults]'$'\n''display-setup-script=xrandr -o right'
```


## System config

Enable rc.local

```
sudo systemctl enable rc-local.service
```

Set `fs.inotify.max_user_watches` higher for IDEs.

```
sudo bash -c 'echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/fs.inotify.conf'
sudo sysctl -p --system
```

## Sudo

Give admins vagrant mount permissions:

```
sudo bash -c 'mkdir -p /etc/sudoers.d && cat <<EOF > /etc/sudoers.d/vagrant
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
%adm ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE
EOF'
```

Give admins bluetooth service restart permissions:

```
sudo bash -c 'mkdir -p /etc/sudoers.d && cat <<EOF > /etc/sudoers.d/service
Cmnd_Alias SERVICE_BLUETOOTH = /usr/sbin/service bluetooth restart
%adm ALL=(root) NOPASSWD: SERVICE_BLUETOOTH
EOF'
```

