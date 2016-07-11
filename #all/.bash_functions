# Remind user to use pushd/popd
func_cd() {
  local pwd=$(pwd)
  func_remind "pushd/popd"
  #if [ -d ${1} ]
  #then
  #  pushd ${pwd} > /dev/null
  #fi
  #builtin cd "${1}"
  dirs
}

# Convert dev names to github usernames
# Requires DEV variable e.g.:
#   DEV="dev1nick1,dev1nick2,...:dev1gh;dev2nick1,...:dev2gh"
func_dev2gh() {
  local dev="$(echo "${1}" | tr '[:upper:]' '[:lower:]')"
  local devs=
  local names=
  local git=
  local gitl=
  local out=
  IFS=';' read -a devs <<< "${DEVS}"
  for i in ${devs[@]}
  do
    names="$(echo ",${i%%:*}," | tr '[:upper:]' '[:lower:]')"
    git="${i##*:}"
    gitl="$(echo "${git}" | tr '[:upper:]' '[:lower:]')"
    if [ "${dev}" == "${gitl}" ] || [ "${names//,${dev},/}" != "${names}" ]
    then
      out="${git}"
    fi
  done <<< "${DEVS}"
  echo "${out}"
}

# Append to env variable, takes a variable name, string and optional separator (defaults to :)
func_envvar_append() {
  local envvar="${1}"
  local string="${2}"
  local separator="${3:-:}"
  if [[ "${separator}${!envvar}${separator}" != *"${separator}${string}${separator}"* ]]
  then
    export ${envvar}="${!envvar:+"${!envvar}${separator}"}${string}"
  fi
}

# Echo and exec (unless $PROFILE_DEBUG is set) command
func_exec() {
  echo "$@"
  if [ -z "${PROFILE_DEBUG}" ]
  then
    eval "${@}"
  fi
}

# Prepend to env variable, takes a variable name, string and optional separator (defaults to :)
func_envvar_prepend() {
  local envvar="${1}"
  local string="${2}"
  local separator="${3:-:}"
  if [[ "${separator}${!envvar}${separator}" != *"${separator}${string}${separator}"* ]]
  then
    export ${envvar}="${string}${!envvar:+"${separator}${!envvar}"}"
  fi
}

# If hub is installed open a pull-request (optionally adding the branch if it exactly matches ${1})
func_gitpr() {
  local match="${1}"
  local base="${2}"
  local branch=$(git rev-parse --abbrev-ref HEAD)
  local prefix=""
  if [ "${match}" != "" ] && [ "${branch#${match}}" == "" ]
  then
    prefix="${branch} "
  fi
  if type hub > /dev/null 2>&1
  then
    git push -u origin "${branch}" && hub pull-request -m "${prefix}$(gitll)" -b "${base}"
  else
    echo "Hub is not installed"
  fi
}

func_hub() { 
  if type hub > /dev/null 2>&1
  then
    func_native hub "${@}"
  else
    func_native git "${@}"
  fi
}

# Remind user to use -l argument
func_ls() {
  local ok=
  for arg in "${@}"
  do
    case "$arg" in
      -*l)
        ok=1
        ;;
    esac
  done
  if [ -z "${ok}" ]
  then
    func_remind "ls -l"
    #/bin/ls -l "${@}"
  else
    /bin/ls "${@}"
  fi
}

# Execute native version of command
func_native() {
  local cmd=$(type -P "${1}")
  if [ $? -eq 0 ]
  then
    shift
    ${cmd} "$@"
  fi
}

# Do nothing if we are already in the directory
func_pushd() {
  if [ "${PWD}" != "${1}" ]
  then
    builtin pushd "${1}"
  fi
}

# Print a reminder
func_remind() {
  local msg="${1}"
  local dsh="$(echo ${msg} | sed 's/./-/g')"
  echo
  echo "    -------------------${dsh}---"
  echo "    | /!\ Did you mean ${msg}? |"
  echo "    -------------------${dsh}---"
  echo
}

# Start vagrant box if not running and attempt to run tmux when connecting
func_vagrant_ssh() {
  local dir="${1}"
  if [ -n "${TMUX}" ]
  then
    echo "Running in a tmux session; run \"tmux detach\" first."
    return 1
  fi
  if [ -n "${dir}" ]
  then
    builtin cd "${dir}"
  fi
  vagrant status | grep -q "running (virtualbox)"
  if [ $? -ne 0 ]
  then
    vagrant up
  fi
  vagrant ssh -- -A -t 'if tmux has > /dev/null 2>&1; then tmux send-keys " source \${HOME}/.bash_profile"; tmux send-keys C-m; tmux attach; else tmux new; fi'
}

# Xdebug
func_xdb() {
  local idekey="${1:-1}"
  local server_name="${2}"
  shift
  shift
  local command=${@}
  local envs='XDEBUG_CONFIG="idekey='${idekey}'" PHP_IDE_CONFIG="serverName='${server_name}'"'
  eval ${envs} ${@}
}
