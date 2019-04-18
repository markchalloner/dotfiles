# Alias
func_alias aliasr='func_aliasread' 'alias'

# AWS
func_alias awssub='aws ec2 describe-subnets'
func_alias awsips='aws ec2 describe-instances --page-size 5 --filter "Name=instance-state-name,Values=running" --query '"'"'Reservations[].Instances[?PrivateIpAddress!=null][].{ip:PrivateIpAddress, name:Tags[?Key==`Name`].Value[] | [0]} | @[].[ip, name]'"'"' --output text' 'aws ec2 describe-instances'

# Keys
func_alias keybash='bind -p | less'
func_alias keytmux='tmux list-keys | less'

# Navigation
func_alias cddown='cd $HOME/Downloads'
func_alias cddev='cd $DEV_ROOT'
func_alias cdtmp='cd $HOME/Temp'

# Cert
func_alias crtr="func_certremote"

# Dotfile editing
func_alias viag='vi ~/.bash_aliases && unalias -a && .reload'
func_alias vial='vi ~/.bash_aliases_local && unalias -a && .reload'
func_alias vicg='vi ~/.bash_completion && .reload'
func_alias vicl='vi ~/.bash_completion_local && .reload'
func_alias vieg='vi ~/.bash_envvars && .reload'
func_alias viel='vi ~/.bash_envvars_local && .reload'
func_alias vifg='vi ~/.bash_functions && .reload'
func_alias vifl='vi ~/.bash_functions_local && .reload'
func_alias vihi="vi ~/.bash_history"
func_alias viig='vi ~/.inputrc && .reload'
func_alias viog='vi ~/.bash_prompt && .reload'
func_alias vipg='vi ~/.bash_profile && .reload'
func_alias vipl='vi ~/.bash_profile_local && .reload'
func_alias virg='vi ~/.bashrc && .reload'
func_alias virl='vi ~/.bashrc_local && .reload'
func_alias virp='vi ~/.bashrc_private && .reload'
func_alias vitg='vi ~/.tmux.conf'

# Dconf
func_alias dconfb='func_dconfbackup' 'dconf read'
func_alias dconfr='func_dconfrestore'

# Docker
func_alias docknuke='docker rmi -f $(docker images --all -q)'

# Dotfile management
func_alias .cd='func_dotcd'
func_alias .diff='func_dotdiff'
func_alias .hub='(.cd && hub browse)'
func_alias .link='link-files -i -o'
func_alias .pull='func_dotpull; .reload'
func_alias .push='func_dotpush'
func_alias .readme='func_dotreadme'
func_alias .reload='func_dotreload'
func_alias .var='func_dotvar'

# Execution
func_alias _='func_exec'

# Git
func_alias gitad='git add -A && git diff --cached'
func_alias gitah='git config user.name "Mark Challoner" && git config user.email "mark.a.r.challoner@gmail.com"'
func_alias gitb='git rev-parse --abbrev-ref HEAD'
func_alias gitbd='git branch --edit-description' 'git branch'
func_alias gitbr='func_gitbr' 'git branch'
func_alias gitbs='for i in *; do if [ -d "$i" ] && [ -d "$i/.git" ]; then (builtin cd "$i" && echo -n "$i": && gitb); fi; done'
func_alias gitbu='func_gitbu'
func_alias gitdf='git diff --cached'
func_alias gitfe='yubipiv && git fetch'
func_alias gitll='git log -1 --oneline | cut -f 2- -d " "'
func_alias gitca='func_gitca'
func_alias gitcl='gitclr && gitcll'
func_alias gitcll='git branch --merged master | grep -v "develop\|master\|qa\|release\|staging\|test\|^\*" | xargs -n 1 git branch -d'
func_alias gitclr='yubipiv && git remote prune origin'
func_alias gitco='git checkout' 'git checkout'
func_alias gitcm='func_gitcm "" "y"'
func_alias gitcn='func_gitcm "" "n"'
func_alias gitdf='git diff'
func_alias gitgr='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
func_alias gitmg='func_gitmg' 'git merge'
func_alias gitmt='func_gitmt'
func_alias gitpl='func_gitpl' 'git pull'
func_alias gitps='for i in *; do if [ -d "$i" ] && [ -d "$i/.git" ]; then (builtin cd "$i" && echo "$i:" && git pull); fi; done'
func_alias gitpu='yubipiv && git push' 'git push'
func_alias gitre='yubigpg && git rebase -S -i' 'git rebase'
func_alias gitrv='yubigpg && git revert -S' 'git revert'
func_alias gitsa='git status' 'git status'
func_alias gitst='func_gitst' 'git stash'

# Github
func_alias ghauth='func_ghauth'

# GPG
func_alias gpgrestart='func_gpgrestart'
func_alias gpgstart='func_gpgstart'
func_alias gpgstatus='func_gpgstatus'
func_alias gpgstop='func_gpgstop'

# Group
func_alias grpassign='func_grpassign'

# Hosts
func_alias vihosts='sudo vi /etc/hosts'

# Hub
func_alias git='func_hub'
func_alias gitpr='func_gitpr ""'

# LastPass
func_alias lpassf='func_lpassf'

# Less
func_alias less='less -R'

# Navigation
func_alias cdtmp='mkdir -p ${HOME}/Temp && builtin cd ${HOME}/Temp'
func_alias l='ls -CF'
func_alias la='ls -A'
func_alias ll='ls -alF'

# Network
func_alias nsports='sudo netstat -plnt'

# NFS
func_alias nfsr='ls -alR > /dev/null'

# Passwords
func_alias pwgen='func_pwgen'
func_alias pwgenhex='func_pwgen "a-f0-9"'

# Permissions
func_alias chx='chmod +x'

# PIV
func_alias pivrestart='func_pivrestart'
func_alias pivstart='func_pivstart'
func_alias pivstatus='func_pivstatus'
func_alias pivstop='func_pivstop'

# PR cache
func_alias prls='[ -f "${HOME}/.personal/prs.txt\" ] && cat ${HOME}/.personal/prs.txt'
func_alias prca='func_prcache'
func_alias vipr='vi ${HOME}/.personal/prs.txt'

# Python
func_alias pycd='cddev && cd python'
func_alias pyenv='pycd && pipenv install --dev && pipenv shell'
func_alias pyvi='pycd && pipenv --three && vi Pipfile && pyenv'
func_alias pypy='pycd && pipenv install --dev && pipenv run python'

# Realpath
func_alias rp="func_realpath"

# SCP
func_alias scp='yubipiv && scp'

# SSH
func_alias ssh='func_ssh'
func_alias sshp='func_sshp'
func_alias sshtd='func_sshtunneldown'
func_alias sshts='func_sshtunnelstatus'
func_alias sshtu='func_sshtunnelup'
func_alias sshu='func_sshunpin'

# Sudo
func_alias sudom='sudo bash -c'

# Tee
#func_alias tee='stripcolors | tee'

# Terminal
func_alias stripcolors='sed "s/"$'\E'"\[[0-9;]*[A-Za-z]//g"'

# Time
func_alias timeadd='func_timeadd'

# Tmux
func_alias tmuxs='[ -z "$TMUX" ] && [ -n "$TMUX_TTY" ] && tmux -V > /dev/null 2>&1 && { tmux has -t "$TMUX_TTY" > /dev/null 2>&1 && tmux attach -t "$TMUX_TTY" || tmux new -s "$TMUX_TTY" ; }'
func_alias tmuxd='tmux detach'

# Upower
func_alias battt='for i in $(upower -e | grep mouse_hid); do upower -i "$i" | awk "/model/{printf \$2\": \"}/percentage/{print \$2}"; done'

# Vagrant
func_alias vdot='func_vdot'
func_alias vhalt='vagrant halt'
func_alias vpro='vagrant reload --provision'
func_alias vre='vagrant reload'
func_alias vreset='vagrant destroy -f && vagrant box update && vagrant up'
func_alias vssh='func_vssh'
func_alias vup='vagrant up'

# Watch
func_alias watch='watch '
func_alias watchmem='func_watchmem'

# X
func_alias xclip='xclip -selection clipboard'
func_alias xkeys='xev'

# Xdebug
func_alias xdb='func_xdb PHPSTORM'

# YAML
func_alias yamlp='func_yamlparse'
func_alias yq='yq.v2'

# Yubikey
func_alias yubigpg='func_yubigpg'
func_alias yubinul='func_yubinul'
func_alias yubipiv='func_yubipiv'
func_alias yubitotp='func_yubitotp'
