# Manual install steps

## Install basic software

```
sudo apt-get install -y \
curl \
tmux \
vim
```

### Add keys and repositories

```
curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
curl -s https://keybase.io/docs/server_security/code_signing_key.asc | sudo apt-key add -
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
echo 'deb [arch=amd64] http://prerelease.keybase.io/deb stable main' | sudo tee /etc/apt/sources.list.d/keybase.list
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-add-repository -y ppa:nixnote/nixnote2-daily
sudo add-apt-repository -y ppa:phoerious/keepassxc
sudo apt-add-repository -y ppa:yubico/stable
```

### Update

```
sudo apt-get update
```

### Install

```
sudo apt-get install -y \
asciidoc \
cifs-utils \
chrome-gnome-shell \
cmake \
clipit \
devscripts \
font-manager \
gimp \
gnome-tweaks \
google-chrome-stable \
jq \
keybase \
keypassxc \
libcurl4-openssl-dev \
libldap2-dev \
libpam-pkcs11 \
libsasl2-dev \
libssl-dev \
libxml2 \
libxml2-dev \
monkeysphere \
network-manager-openvpn \
network-manager-openvpn-gnome \
nfs-kernel-server \
nixnote2 \
opensc-pkcs11 \
openssl \
picard \
pinentry-curses \
pinentry-tty \
postgres-client \
pkg-config \
python-dev \
python-pip \
scdaemon \
shellcheck \
texinfo \
tmux \
tshark \
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
xsltproc
```

## Install via pip

```
pip3 install awscli --upgrade --user
pip3 install python-gitlab --upgrade --user
pip3 install pipenv --upgrade --user
```

## Install via snap

```
sudo snap install slack --classic
```

## Install nodejs

```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Install gnome extensions

* [Put Windows](https://extensions.gnome.org/extension/39/put-windows/)


## Build lastpass-cli from source

```
(
cd /tmp
git clone https://github.com/lastpass/lastpass-cli
cd lastpass-cli
make
sudo make install
sudo make install-doc
)
```

## Build yubikey-luks from source

```
(
cd /tmp
git clone https://github.com/cornelinux/yubikey-luks.git
cd yubikey-luks
make builddeb NO_SIGN=1
sudo dpkg -i DEBUILD/yubikey-luks_*.deb
)
sudo sed -i -e 's/CONCATENATE=.*/CONCATENATE=1/g; s/HASH=.*/HASH=1/g' /etc/ykluks.cfg
sudo update-initramfs -u
sudo yubikey-luks-enroll
```

## Set /bin/sh to /bin/bash

Required for `bash` support in `/usr/bin/at`.

```
sudo ln -f -s /bin/bash /bin/sh
```

## Install yubikey-lock udev rules

```
# Install rules.
sudo tee /etc/udev/rules.d/85-yubikey.rules <<EOF
ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0116", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/run/user/1000/gdm/Xauthority", RUN+="/home/mark/bin/yubikey-lock lock"
ACTION=="add", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0116", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/run/user/1000/gdm/Xauthority", RUN+="/home/mark/bin/yubikey-lock wake"
EOF
# Reload rules.
sudo udevadm control --reload-rules
```

## Install trackpad udev rules

```
# Get input details.
udevadm info -a -p $(udevadm info -q path -n /dev/input/mouse3)
# Install rules.
sudo tee /etc/udev/rules.d/86-apple-trackpad.rules <<EOF
ACTION=="add", KERNEL=="input[0-9]*", SUBSYSTEM=="input", ATTRS{uniq}=="84:fc:fe:dd:49:a4", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/run/user/1000/gdm/Xauthority", RUN+="/usr/bin/at -M -f /home/mark/bin/apple-trackpad-rotate.sh now"
EOF
# Test rules.
udevadm test $(udevadm info -q path -n /dev/input/mouse3)
# Reload rules.
sudo udevadm control --reload-rules
```

## Run keybase

```
run_keybase
```

## Configure tshark

```
sudo dpkg-reconfigure wireshark-common
sudo adduser $USER wireshark
grpassign wireshark
```

## Editor

```
sudo update-alternatives --config editor
```

## Screen rotation

Set console rotation:

````
sudo sed -i 's/GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="$1 fbcon=rotate:1"/g' /etc/default/grub
update-grub
```

Set lightdm rotation:

```
sudo tee /etc/lightdm/lightdm.conf.d/80-display-setup.conf <<< '[SeatDefaults]'$'\n''display-setup-script=xrandr -o right'
```

## Fix trackpad

```
sudo tee /sys/module/bluetooth/parameters/disable_esco <<< "1"
sudo /etc/init.d/bluetooth restart
sudo tee /etc/modprobe.d/bluetooth-tweaks.conf <<< "options bluetooth disable_esco=1"
# Disable SNIFF mode
sudo hcitool lp 84:FC:FE:DD:49:A4 RSWITCH
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

## Shortcuts

* Maximise to monitors, Ctrl+Super+Home, /home/mark/bin/gnome-resize-to-monitors.sh
