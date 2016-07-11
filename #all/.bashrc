# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Show git state in the fancy prompt
GIT_PS1_SHOWDIRTYSTATE=true

# Bash completion
if [ -f /usr/share/bash-completion/bash_completion ]
then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]
then
	. /etc/bash_completion
elif type brew > /dev/null 2>&1 && [ -f $(brew --prefix)/etc/bash_completion ] 
then
	. $(brew --prefix)/etc/bash_completion
fi

# Import other global configs
[ -f ~/.bash_functions ] && . ~/.bash_functions
[ -f ~/.bash_envvars ]   && . ~/.bash_envvars
[ -f ~/.bash_aliases ]   && . ~/.bash_aliases

# Import other local bash startup files
[ -f ~/.bashrc_local ]   && . ~/.bashrc_local

