# Personal dotfiles

## Usage

Install [link-files]:

```
cd ${HOME}
git clone https://github.com/markchalloner/link-files.git
( cd link-files && make install )
```

Install dotfiles:

```
git clone https://github.com/markchalloner/dotfiles.git
ln -s "${HOME}/dotfiles" "${HOME}/.link-files"
link-files -i
```

[link-files]: https://github.com/markchalloner/link-files
