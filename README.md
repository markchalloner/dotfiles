# Personal dotfiles

## Usage

### Set hostname:

#### Linux

```
HOSTNAME=
sudo bash -c "echo '$HOSTNAME' > /etc/hostname"
```

#### OSX

```
HOSTNAME=
sudo bash -c "scutil --set HostName '$HOSTNAME' ; scutil --set LocalHostName '$HOSTNAME'"
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

### Set user details and origin to ssh (for editing)

```
(
.cd
git config user.name "Mark Challoner"
git config user.email "mark.a.r.challoner@gmail.com"
git remote set-url origin git@github.com:markchalloner/dotfiles.git
)
```
