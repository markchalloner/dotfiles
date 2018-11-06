# Import other bash global startup files
[ -f ~/.bashrc ] && . ~/.bashrc

# Import local bash profile
[ -f ~/.bash_profile_local ] && . ~/.bash_profile_local

export PATH="$HOME/.poetry/bin:$PATH"
