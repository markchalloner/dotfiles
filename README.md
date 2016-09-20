# Personal dotfiles

## Usage

### Set hostname:

#### Linux

```
sudo bash -c 'echo "<hostname>" > /etc/hostname'
```

#### OSX

```
(
HOSTNAME="<hostname>"
sudo scutil --set HostName ${HOSTNAME}
sudo scutil --set LocalHostName ${HOSTNAME}
)
```

### Install [link-files]

```
(
INSTALLER_DIR="${HOME}/Software/Scripts/link-files"
mkdir -p "${INSTALLER_DIR}"
cd "${INSTALLER_DIR}"
git clone https://github.com/markchalloner/link-files.git .
sudo make install
)
```

### Install dotfiles

```
(
INSTALLER_DIR="${HOME}/dotfiles"
mkdir -p "${INSTALLER_DIR}"
cd "${INSTALLER_DIR}"
git clone https://github.com/markchalloner/dotfiles.git .
ln -s "${INSTALLER_DIR}" "${HOME}/.link-files"
link-files -i -o
)
. ~/.bash_profile
gpg-restart
```

### Convert dotfiles to ssh

```
(
.cd
git remote set-url origin git@github.com:markchalloner/dotfiles.git
)

```
[link-files]: https://github.com/markchalloner/link-files
