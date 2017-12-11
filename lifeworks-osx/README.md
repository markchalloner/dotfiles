# Manual install steps

## Add SSH key to keychain (share with vagrant)

```
ssh-add -K
```

## Install [homebrew]

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Install tools

### Via Brew

```
brew tap caskroom/cask
brew tap homebrew/homebrew-php
brew install awscli bash-completion git jq php56 php56-intl php-code-sniffer phpmd tmux 
brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
brew install --devel hub
brew install --HEAD opensc
brew install Caskroom/cask/gpg-suite Caskroom/cask/virtualbox Caskroom/cask/virtualbox-extension-pack Caskroom/cask/vagrant Caskroom/cask/vagrant-manager
.reload
```

### Manually

#### Yubikeylockd

```
(
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/shtirlic/yubikeylockd.git
cd yubikeylockd
make clean && make
)
rm -rf ~/tmp/yubikeylockd
```

## Give vagrant mount permissions

```
sudo bash -c 'mkdir -p /etc/private/sudoers.d && cat <<EOF > /etc/private/sudoers.d/vagrant
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE
EOF'
```

## Add dotfiles to NFS export

```
sudo bash -c 'cat <<EOF >> /etc/exports
"${HOME}/dotfiles"
EOF'
sudo /sbin/nfsd restart
```

[homebrew]: http://brew.sh

