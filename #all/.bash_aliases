# Dot file editing
alias sourcep="source ~/.bash_profile"
alias vie="vi ~/.bash_envvars && sourcep"
alias viel="vi ~/.bash_envvars_local && sourcep"
alias vip="vi ~/.bash_profile && sourcep"
alias vipl="vi ~/.bash_profile_local && sourcep"
alias via="vi ~/.bash_aliases && unalias -a && sourcep"
alias vial="vi ~/.bash_aliases_local && unalias -a && sourcep"
alias vir="vi ~/.bashrc && sourcep"
alias virl="vi ~/.bashrc_local && sourcep"
# Navigation
alias ls="func_ls"
alias cd="func_cd"
alias cd_="builtin cd"
alias cd..="builtin cd ../"
# Permissions
chx="chmod +x"
# Vagrant
alias vssh="func_vagrant_ssh"
# Git
alias git="hub"
alias gitb="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo -n "\$i": && git rev-parse --abbrev-ref HEAD); fi; done"
alias gitp="for i in *; do if [ -d "\$i" ] && [ -d "\$i/.git" ]; then (builtin cd "\$i" && echo "\$i:" && git pull); fi; done"
alias gitll="git log -1 --pretty=%B | head -n 1"
# SSH
#alias ssh="ssh -t 'tmux list-sessions; bash -l'"
