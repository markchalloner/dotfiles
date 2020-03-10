# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# Set language.
LANG=en_GB.utf8

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=999999
HISTFILESIZE=9999

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Disable terminal suspend.
stty -ixon

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support of ls and also add handy aliases/
if [ -x /usr/bin/dircolors ]
then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Show git state in the fancy prompt.
GIT_PS1_SHOWDIRTYSTATE=true

# Save terminal if in TMUX.
if [ -n "$TMUX" ] && [ -z "$SCRIPT_FILE" ]; then
  export SCRIPT_FILE=~/.script/tmux-${TMUX_PANE/\%/}.log
  mkdir -p ~/.script
  exec script -aefq "$SCRIPT_FILE"
fi

# Import other global configs.
[ -f ~/.bash_prompt ] && . ~/.bash_prompt
[ -f ~/.bash_functions ] && . ~/.bash_functions
[ -f ~/.bash_envvars ] && . ~/.bash_envvars
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# Enable programmable bash completion features.
if ! shopt -oq posix
then
  if [ -f /etc/bash_completion ]
  then
    . /etc/bash_completion
  elif [ -f /usr/share/bash-completion/bash_completion ]
  then
    . /usr/share/bash-completion/bash_completion
  elif type brew > /dev/null 2>&1 && [ -f $(brew --prefix)/etc/bash_completion ]
  then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# Import other local bash startup files.
[ -f ~/.bashrc_local ] && . ~/.bashrc_local
[ -f ~/.bashrc_private ] && . ~/.bashrc_private

# Pre and post commands.
FIRST_PROMPT=1
func_bashpre() {
  [ -z "$AT_PROMPT" ] && return
  unset AT_PROMPT
  [ -f ~/.bash_prompt_pre ] && . ~/.bash_prompt_pre
}

func_bashpost() {
  AT_PROMPT=1
  if [ -n "$FIRST_PROMPT" ]
  then
    unset FIRST_PROMPT
    return
  fi
  [ -f ~/.bash_prompt_post ] && . ~/.bash_prompt_post
}

trap "func_bashpre" DEBUG
PROMPT_COMMAND="func_bashpost"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
