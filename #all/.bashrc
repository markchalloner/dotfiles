# Variables
GIT_PS1_SHOWDIRTYSTATE=true

# Bash completion
[ -f /etc/bash_completion ] && . /etc/bash_completion
type brew > /dev/null 2&>1 && [ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion

# Import other global configs
[ -f ~/.bash_functions ] && . ~/.bash_functions
[ -f ~/.bash_envvars ]   && . ~/.bash_envvars
[ -f ~/.bash_aliases ]   && . ~/.bash_aliases

