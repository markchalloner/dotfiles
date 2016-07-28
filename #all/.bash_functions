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

# Change directory to a dotfiles repo
func_dotcd() {
  local path="${1:-${HOME}/dotfiles}"
  if [ -d "${path}/.git" ] && (builtin cd "${path}" && git remote -v | grep "origin" | grep "push" | grep -q "markchalloner/dotfiles")
  then
    builtin cd "${path}"
    return 0
  fi
  func_warning "Path is not a dotfiles repository"
  return 1
}

# Diff a dotfiles repo
func_dotdiff() {
  local path="${1:-${HOME}/dotfiles}"
  (func_dotcd "${path}" && git diff)
}

# Pull a dotfiles repo
func_dotpull() {
  local path="${1:-${HOME}/dotfiles}"
  (func_dotcd "${path}" && func_gitst && git pull && func_gitst pop)
}

# Push a dotfiles repo
func_dotpush() {
  local path="${1:-${HOME}/dotfiles}"
  local hostname="${2:-$(hostname)}"
  (func_dotcd "${path}" && func_dotpull "${path}" && git add -A && git commit -m "Autocommit on ${hostname}" && git push origin master)
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
  echo "${@}"
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

# Commit optionaly adding the branch if it exactly matches ${1}
func_gitcm() {
  local match="${1}"
  local message="${2}"
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  local prefix=""
  if [ "${message}" == "-m" ]
  then
    message="${3}"
  fi
  if [ "${match}" != "" ] && [ "${branch#${match}}" == "" ]
  then
    prefix="${branch} "
  fi
  git commit -m "${prefix}${message#${prefix}}"
}

# If hub is installed open a pull-request (optionally adding the branch if it exactly matches ${1})
func_gitpr() {
  local prefix=""
  local url=""
  local match="${1}"
  local base="${2}"
  local branch=$(git rev-parse --abbrev-ref HEAD)
  local log=$(gitll)
  log="${log#${branch}}"
  if [ "${match}" != "" ] && [ "${branch#${match}}" == "" ]
  then
    prefix="${branch} "
  fi
  if type hub > /dev/null 2>&1
  then
    url="$(git push -u origin "${branch}" && hub pull-request -m "${prefix}${log}" -b "${base}")"
    echo "${url}"
    if [ -n "${prefix}" ]
    then
      func_prcache "${branch}" "${url}"
    fi
  else
    echo "Hub is not installed"
  fi
}

# Git stash with gpgsign disabled
func_gitst() {
  local gpgsign="$(git config --list | grep "commit.gpgsign" | tail -n +2 | tail -n 1  | sed 's/.*=//')"
  gpgsign="${gpgsign% }"
  git config commit.gpgsign false
  git stash ${@}
  case "${gpgsign}" in
    true)
      git config commit.gpgsign true
      ;;
    "")
      git config --unset commit.gpgsign
      ;;
   esac
}

# Use hub rather than git if installed
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

# Navigate (cd) to a shortcut
func_nv() {
  # TODO
  :
}

# Do nothing if we are already in the directory
func_pushd() {
  if [ "${PWD}" != "${1}" ]
  then
    builtin pushd "${1}"
  fi
}

# Add a branch to pr url mapping to the prs file
func_prcache() {
  local personal="${HOME}/.personal"
  local prs="${personal}/prs.txt"
  local ticket="${1}"
  local url="${2}"
  mkdir -p "${personal}"
  if [ -f "${prs}" ] && ! $(grep -q "^${ticket}" "${prs}") && ! $(grep -q "${url}$" "${prs}")
  then
    echo "${ticket}=${url}" >> "${personal}/prs.txt"
  fi
}

# Print a reminder
func_remind() {
  local msg="${1}"
  func_warning "Did you mean \`${msg}\`?"
}

# Install dotfiles on vagrant box
func_vdot() {
  vagrant ssh -- -A <<-EOF
    #cat <<EOF
    HOST_IP=\$(netstat -rn | grep '192\.168' | awk '{ gsub("[.]0\$",".1",\$1); print \$1 }')
    DIR=\${HOME}/dotfiles
    mkdir -p \${DIR}
    sudo mount \${HOST_IP}:${HOME}/dotfiles \${DIR} > /dev/null 2>&1
    curl -LsS link-files.markc.net | bash > /dev/null
    # Link
    if [ ! -x "\${HOME}/.link-files" ]
    then
      ln -s "\${DIR}" "\${HOME}/.link-files"
    fi 
    link-files -o -i
EOF
}

# Start vagrant box if not running and attempt to run tmux when connecting
func_vssh() {
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

# Print a warning
func_warning() {
  local msg="${1}"
  local dsh="$(echo ${msg} | sed 's/./-/g')"
  echo
  echo "    ------${dsh}--"
  echo "    | /!\ ${msg} |"
  echo "    ------${dsh}--"
  echo
}

# Xdebug
func_xdb() {
  local idekey="${1:-1}"
  local server_name="${2}"
  shift
  shift
  local command="${@}"
  local envs='XDEBUG_CONFIG="idekey='${idekey}'" PHP_IDE_CONFIG="serverName='${server_name}'"'
  (
    export XDEBUG_CONFIG="idekey=${idekey}"
    export PHP_IDE_CONFIG="serverName=${server_name}"
    eval ${command}
  )
}

