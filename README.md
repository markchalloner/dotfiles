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

Ensure that dependencies are installed:

```
sudo apt-get install -y \
git-core \
gpg \
make \
python \
```

```
(
INSTALLER_DIR="${HOME}/dotfiles"
mkdir -p "${INSTALLER_DIR}"
cd "${INSTALLER_DIR}"
git clone https://github.com/markchalloner/dotfiles.git .
ln -s "${INSTALLER_DIR}" "${HOME}/.link-files"
./deps-download.sh
cd deps/link-files
sudo make install
link-files -i -o
)
. ~/.bash_profile
gpg --fetch-keys https://keybase.io/markchalloner/key.asc
gpg --card-status
yubigpg
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
