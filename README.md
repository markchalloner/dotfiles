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

### Install dotfiles

```
(
INSTALLER_DIR="${HOME}/dotfiles"
mkdir -p "${INSTALLER_DIR}"
cd "${INSTALLER_DIR}"
git clone https://github.com/markchalloner/dotfiles.git .
ln -s "${INSTALLER_DIR}" "${HOME}/.link-files"
./deps-download.sh
make install -f deps/link-files/Makefile
link-files -i -o
)
. ~/.bash_profile
gpgrestart
```

### Convert dotfiles to ssh (for editing)

```
(.cd && git remote set-url origin git@github.com:markchalloner/dotfiles.git)
```
