# Personal dotfiles

## Usage

Install [link-files]:

```
(
INSTALLER_DIR="${HOME}/Software/Scripts/link-files"
mkdir -p "${INSTALLER_DIR}"
cd "${INSTALLER_DIR}"
git clone https://github.com/markchalloner/link-files.git .
sudo make install
)
```

Install dotfiles:

```
git clone git@github.com:markchalloner/dotfiles.git "${HOME}/dotfiles"
ln -s "${HOME}/dotfiles" "${HOME}/.link-files"
link-files -i
. ~/bash_profile
```

[link-files]: https://github.com/markchalloner/link-files
