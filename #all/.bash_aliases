# Alias management
alias aliasr="func_aliasr "\${1}""

# Dotfile editing
alias viag="vi ~/.bash_aliases && unalias -a && .reload"
alias vial="vi ~/.bash_aliases_local && unalias -a && .reload"
alias vieg="vi ~/.bash_envvars && .reload"
alias viel="vi ~/.bash_envvars_local && .reload"
alias vifg="vi ~/.bash_functions && .reload"
alias vifl="vi ~/.bash_functions_local && .reload"
alias viig="vi ~/.inputrc && .reload"
alias viog="vi ~/.bash_prompt && .reload"
alias vipg="vi ~/.bash_profile && .reload"
alias vipl="vi ~/.bash_profile_local && .reload"
alias virg="vi ~/.bashrc && .reload"
alias virl="vi ~/.bashrc_local && .reload"
alias virp="vi ~/.bashrc_private && .reload"

# Dotfile management
alias .cd="func_dotcd"
alias .diff="func_dotdiff"
alias .hub="(.cd && hub browse)"
alias .pull="func_dotpull; .reload"
alias .push="func_dotpush"
alias .readme="func_dotreadme"
alias .reload="func_dotreload"
alias .var="func_dotvar"

# Execution
alias _="func_exec"

# Git
alias gitad="git add -A && git diff --cached"
alias gitah="git config user.name \"Mark Challoner\" && git config user.email \"mark.a.r.challoner@gmail.com\""
alias gitaw="git config user.name \"Mark Challoner\" && git config user.email \"mark.challoner@lifeworks.com\""
alias gitb="git rev-parse --abbrev-ref HEAD"
alias gitbs="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo -n "\$i": && gitb); fi; done"
alias gitdf="git diff"
alias gitll="git log -1 --oneline | cut -f 2- -d ' '"
alias gitcl="gitclr && gitcll"
alias gitcll="git branch --merged | grep -v \"develop\|master\|qa\|release\|staging\|test\|^\*\" | xargs -n 1 git branch -d"
alias gitclr="yubipiv && git remote prune origin"
alias gitco="git checkout"
alias gitdf="git diff"
alias gitgr="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias gitmg="func_gitmg"
alias gitmt="func_gitmt"
alias gitpl="yubipiv && git pull"
alias gitps="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo "\$i:" && git pull); fi; done"
alias gitpu="yubipiv && git push origin \$(gitb)"
alias gitsa="git status"
alias gitst="func_gitst"

# Github
alias ghauth="func_ghauth"

# GPG
alias gpgrestart="func_gpgrestart"
alias gpgstart="func_gpgstart"
alias gpgstatus="func_gpgstatus"
alias gpgstop="func_gpgstop"

# Hosts
alias vihosts="sudo vi /etc/hosts"

# Hub
alias git="func_hub"
alias gitpr="func_gitpr """

# Less
alias less="less -R"

# Navigation
#alias cd="func_cd"
#alias cd_="builtin cd"
#alias cd~="builtin cd ${HOME}/"
#alias cd..="builtin cd ../"
alias cdtmp="mkdir -p ${HOME}/Temp && builtin cd ${HOME}/Temp"
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
#alias ls="func_ls"
alias nv="func_nv"

# Network
alias nsports="sudo netstat -plnt"

# NFS
alias nfsr="ls -alR > /dev/null"

# Permissions
alias chx="chmod +x"

# PIV
alias pivrestart="func_pivrestart"
alias pivstart="func_pivstart"
alias pivstatus="func_pivstatus"
alias pivstop="func_pivstop" 

# PR cache
alias prls="[ -f \"${HOME}/.personal/prs.txt\" ] && cat ${HOME}/.personal/prs.txt"
alias prca="func_prcache"
alias vipr="vi ${HOME}/.personal/prs.txt"

# SSH
alias ssh="func_ssh"
alias sshp="func_sshp"
alias sshunpin="func_sshunpin"

# Sudo
alias sudom="sudo bash -c"

# Tee
alias tee="stripcolors | tee"

# Terminal
alias stripcolors="sed 's/'$'\E''\[[0-9;]*[A-Za-z]//g'"

# Tmux
alias tmuxs="[ -z "\$TMUX" ] && tmux -V > /dev/null 2>&1 && { tmux has -t init > /dev/null 2>&1 && tmux attach -t init || tmux new -s init ; }"
alias tmuxd="tmux detach"

# Vagrant
alias vdot="func_vdot"
alias vhalt="vagrant halt"
alias vpro="vagrant reload --provision"
alias vre="vagrant reload"
alias vreset="vagrant destroy -f && vagrant box update && vagrant up"
alias vssh="func_vssh"
alias vup="vagrant up"

# Watch
alias watchmem="func_watchmem"

# Xdebug
alias xdb="func_xdb PHPSTORM"

# YAML
alias yamlp="func_yamlparse"

# Yubikey
alias yubigpg="func_yubigpg"
alias yubinul="func_yubinul"
alias yubipiv="func_yubipiv"
alias yubitotp="func_yubitotp"
