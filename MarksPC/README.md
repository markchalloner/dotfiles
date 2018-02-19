# Manual install steps

## Install Choclatey in CMD (Admin)

```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
```

## Install tools

### Via choco in CMD (Admin)

```
choco install -y curl
choco install -y cygwin
choco install -y gpg4win
choco install -y node
```

### Via cygwin in Cygwin Terminal

```
curl -sSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o /usr/share/bash-completion/completions/git
curl -sSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o /usr/share/git-core/git-prompt.sh
curl -kLsS https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg > /bin/apt-cyg && chmod a+x /bin/apt-cyg
apt-cyg install wget
apt-cyg install git make python python-pip python-setuptools ssh-pageant vim
pip install awscli
```

## Set path and refresh environment

```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "[Environment]::SetEnvironmentVariable('path',\"C:\Program Files (x86)\GNU\GnuPG;$([Environment]::GetEnvironmentVariable('path','Machine'))\",'Machine');"
refreshenv
```
