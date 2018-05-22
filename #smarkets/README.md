# Manual install steps

## Install via apt

### Install curl

```
sudo apt-get install curl
```


### Add keys and repositories

```
curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo add-apt-repository ppa:nixnote/nixnote2-daily
sudo apt-add-repository ppa:yubico/stable
```

### Update

```
sudo apt-get update
```

### Install

```
sudo apt-get install -y alltray clipit compizconfig-settings-manager gcolor2 google-chrome-stable libldap2-dev libpam-pkcs11 libsasl2-dev libssl-dev monkeysphere nixnote2 opensc-pkcs11 pinentry-tty python-dev python-pip scdaemon signal-desktop tmux vim virtualenv ykneomgr yubikey-personalization yubikey-personalization-gui yubico-piv-tool yubikey-manager yubioath-desktop
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


## Install via pip

```
pip install awscli --upgrade --user
```

## Install via snap

```
sudo snap install slack --classic
```

## Hardware

Fix touchpad issues:

```
sudo tee -a /etc/modprobe.d/blacklist.conf <<< $'\n'"# Touchpad disconnection issues"$'\n'"blacklist i2c_hid"
```

## System config

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

## Bluetooth

Set idle timeout to 60 minutes:
```
sudo sed -i.bak 's/^#IdleTimeout=30/IdleTimeout=3600/g' /etc/bluetooth/input.conf 
sudo service bluetooth restart
```
