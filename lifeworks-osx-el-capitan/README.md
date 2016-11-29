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

```
brew tap homebrew/homebrew-php
brew install awscli bash-completion git php70 php-code-sniffer phpmd tmux 
.reload
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

[homebrew]: http://brew.sh

