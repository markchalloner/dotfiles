# Dotfile editing
alias viag="vi ~/.bash_aliases && unalias -a && .reload"
alias vial="vi ~/.bash_aliases_local && unalias -a && .reload"
alias vieg="vi ~/.bash_envvars && .reload"
alias viel="vi ~/.bash_envvars_local && .reload"
alias vifg="vi ~/.bash_functions && .reload"
alias vifl="vi ~/.bash_functions_local && .reload"
alias vipg="vi ~/.bash_profile && .reload"
alias vipl="vi ~/.bash_profile_local && .reload"
alias virg="vi ~/.bashrc && .reload"
alias virl="vi ~/.bashrc_local && .reload"

# Dotfile management
alias .reload=". ~/.bash_profile"
alias .diff="(builtin cd ${HOME}/dotfiles && git diff)"
alias .pull="(builtin cd ${HOME}/dotfiles && git stash && git pull && git stash pop)"
alias .push="(builtin cd ${HOME}/dotfiles && .pull && { git add -A && git commit -m \"Autocommit on $(hostname)\" ; git push origin master; } )"

# Execution
alias _="func_exec"

# Git
alias gitb="git rev-parse --abbrev-ref HEAD"
alias gitbs="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo -n "\$i": && gitb); fi; done"
alias gitps="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo "\$i:" && git pull); fi; done"
alias gitll="git log -1 --oneline | cut -f 2- -d ' '"
alias gitcl="gitclr && gitcll"
alias gitcll="git branch --merged | grep -v \"develop\|master\|qa\|release\|staging\|^\*\" | xargs -n 1 git branch -d"
alias gitclr="git remote prune origin"
alias gitco="git checkout"
alias gitgr="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

# GPG
alias gpg-restart="gpg-stop; gpg-start"
alias gpg-start="eval \$(gpg-agent --daemon)"
alias gpg-status="ps -A | grep \"gpg-agent --daemon\" | grep -v \"grep\""
alias gpg-stop="PID=\$(gpg-status | awk '{print \$1}'); [ -n \"\${PID}\" ] && kill -9 \"\${PID}\""

# Hub
alias git="func_hub"
alias gitpr="func_gitpr """

# Navigation
alias cd="func_cd"
alias cd_="builtin cd"
alias cd~="builtin cd ~/"
alias cd..="builtin cd ../"
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls="func_ls"

# Permissions
chx="chmod +x"

# Tmux
alias tmuxs="[ -z "$TMUX" ] && tmux -V > /dev/null 2>&1 && { tmux has -t init > /dev/null 2>&1 && tmux attach -t init || tmux new -s init ; }"

# Vagrant
alias vssh="func_vagrant_ssh"

# Xdebug
alias xdb="func_xdb PHPSTORM"
