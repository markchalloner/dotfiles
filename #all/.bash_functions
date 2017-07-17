# Read an alias
func_aliasr()
{
  local cmd="$(type "${1}" | grep "is aliased" | sed 's/.* is aliased to [`]\(.*\)'"'"'/\1/g')"
  if type pbcopy > /dev/null 2>&1
  then
    echo "${cmd}"| pbcopy
  fi
  echo "${cmd}"
}

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
  local no_auth="${2}"  
  if [ "${no_auth}" != "no-auth" ]
  then
    func_yubipiv
  fi
  (func_dotcd "${path}" && func_gitst && git pull && func_gitst pop)
}

# Push a dotfiles repo
func_dotpush() {
  local path="${1:-${HOME}/dotfiles}"
  local hostname="${2:-$(hostname)}"
  # Test GPG will start
  func_pivstop && \
  func_gpgrestart && \
  func_yubipiv && \
  (func_dotcd "${path}" && func_dotpull "${path}" "no-auth" && git add -A && func_yubigpg && git commit -S -m "Autocommit on ${hostname}" && func_yubipiv && git push origin master)
}

func_dotreadme() {
  if [ "${1}" == "-g" ] || [ "${1}" == "--global" ]
  then
    (func_dotcd && vi README.md)
  else
    vi ${HOME}/README.md
  fi
}

# Reload profile
func_dotreload() {
  source "${HOME}/.bash_profile"
}

# Manage private variables
func_dotvar() {
  local name="${1}"
  local value="${2}"
  local private_file="${HOME}/.bashrc_private"
  if [ -z "${name}" ]
  then
    cat "${private_file}"
    return
  fi
  local line="export ${name}=\"${value}\""
  if  [ -f "${private_file}" ] && grep -q "^export ${name}=" "${private_file}"
  then
    if [ -z "${value}" ]
    then
      echo "Removing variable ${name}"
      sed -i.bak "/^export ${name}=/d" "${private_file}"
    else
      echo "Updating variable ${name}"
      sed -i.bak "s/^export ${name}=.*/${line}/g" "${private_file}"
    fi
    rm "${private_file}.bak"
  else
    if [ -z "${value}" ]
    then
      echo "Not present, doing nothing"
    else
      echo "Adding variable ${name}"
      echo "${line}" >> "${private_file}"
    fi
  fi
  func_dotreload
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
  local hooks
  if echo "${2}" | grep -i -q '^y\(es\)\?$'
  then
    hooks=" "
  elif echo "${2}" | grep -i -q '^no\?$'
  then
    hooks=" -n"
  else
    echo "Second parameter must enable/disable hooks with y or n."
    return 1
  fi
  local message="$(echo -e -n "${3}")"
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  local prefix=""
  if [ "${message}" == "-m" ]
  then
    message="$(echo -e -n "${4}")"
  fi
  if [ -n "${match}" ] && echo "${branch}" | grep -q "${match}"
  then
    prefix="${branch} "
  fi
  echo -n "Stopping PIV and starting GPG... "
  if func_yubigpg
  then
    echo "OK."
  else
    echo "Failed."
    return 1
  fi
  git commit${hooks} -S -m "${prefix}${message#${prefix}}"
  echo -n "Stopping GPG. "
  func_yubinul
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
  if [ -n "${match}" ] && echo "${branch}" | grep -q "${match}"
  then
    prefix="${branch} "
  fi
  if type hub > /dev/null 2>&1
  then
    func_yubipiv
    git push -u origin "${branch}"
    url="$(hub pull-request -m "${prefix}${log}" -b "${base}")"
    echo "${url}"
    if [ -n "${prefix}" ]
    then
      func_prcache "${branch}" "${url}"
    fi
  else
    echo "Hub is not installed"
  fi
}

func_gitmg() {
  local branch="${1}"
  if [ -z "${branch}" ]
  then
    echo "Error no branch argument passed."
    return 1
  fi
  yubigpg && git merge -n -S "${branch}"
}

# Git merge reminder
func_gitmt() {
  cat <<'EOF'
Merge Tool usage:
    
    Ctrl+W [arrow] - move window
    :diffu         - update diff
    :diffg B       - use BASE
    :diffg L       - use LOCAL
    :diffg R       - use REMOTE
    :wa            - save all
    :xa            - save all and exit

EOF
  read -n 1 -s -p "Press any key to start..."
  echo ""
  git mergetool
}

# Git stash with gpgsign disabled
func_gitst() {
  local gpgsign="$(git config --list | grep "commit.gpgsign" | tail -n +2 | tail -n 1  | sed 's/.*=//')"
  local untracked
  gpgsign="${gpgsign% }"
  git config commit.gpgsign false
  if [ $# -eq 0 ] || [ "$1" == "save" ]
  then
    untracked=" -u"
  fi
  git stash${untracked} ${@}
  case "${gpgsign}" in
    true)
      git config --local commit.gpgsign true
      ;;
    "")
      git config --local --unset commit.gpgsign
      if ! git config --local --get-regexp '^commit.' > /dev/null 2>&1
      then
        git config --local --remove-section "commit" > /dev/null 2>&1
      fi
      ;;
   esac
}

# Authenticate with github
func_ghauth() {
  func_ssh -T git@github.com > /dev/null 2>&1
  local result=${?}
  if [ ${result} -eq 1 ]
  then
    echo "Authentication succeeded"
    return 0
  fi
  echo "Authentication failed"
  return ${result}
}

# GPG
func_gpgrestart() {
  func_gpgstop && func_gpgstart
}

func_gpgstart() {
  local gpgvars
  gpgvars=$(gpg-agent --daemon)
  local result=${?}
  if [ ${result} -eq 0 ]
  then
    eval "${gpgvars}"
    gpg --no-tty --card-status > /dev/null 2>&1
    result=${?}
    if [ ${result} -ne 0 ]
    then
      func_gpgstop
      echo "GPG card access failed, is it locked by another process?"
    fi
  fi
  return ${result}
}

func_gpgstatus() {
  local out=$(ps -A | grep "gpg-agent.\+--daemon" | grep -v "grep")
  if [ -n "${out}" ]
  then
    echo "${out}"
    return 0
  else
    return 1
  fi
}

func_gpgstop() {
  local pid=$(gpgstatus | awk '{print $1}')
  if [ -n "${pid}" ]
  then
    kill -9 "${pid}"
  fi
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

# PIV
func_pivrestart() {
  func_pivstop && func_pivstart
}

# 
func_pivstart() {
  eval $(ssh-agent) > /dev/null 2>&1 
  if [ $? -eq 0 ]
  then
    ssh-add -D > /dev/null 2>&1
    ssh-add -e /usr/local/lib/pkcs11/opensc-pkcs11.so > /dev/null 2>&1
    ssh-add -t 900 -s /usr/local/lib/pkcs11/opensc-pkcs11.so 2> /dev/null
    #ssh-add -K > /dev/null 2>&1
  fi
}

func_pivstop() {
  ssh-agent -k > /dev/null 2>&1 || pkill ssh-agent 
  return 0
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

# SSH with network user
func_ssh() {
  /usr/bin/ssh $@
  local result=${?}
  func_termcolor "default"
  return ${result}
}

# Term color
func_termcolor() {
  color="${1}"
  if [ -z "${color}" ] || [ "${color}" == "default" ]
  then
    printf '\e[0m'
    return 0
  fi
  if echo "${color}" | grep -q '[^0-9;]'
  then
    echo "Error: not an RGB value in the form RRR;GGG;BBB"
    return 1
  fi
  printf '\e[38;2;'${color}'m'
}

# TOTP
func_totpvalid() {
  local token="${1}"
  [ ${#token} -ge 6 ] && [ ${#token} -le 8 ] && [ -z "${token//[0-9]/}" ]
}

# Install dotfiles on vagrant box
func_vdot() {
  vagrant ssh -- -A <<-EOF
    HOST_IP=\$(netstat -rn | grep '192\.168' | awk '{ gsub("[.]0\$",".1",\$1); print \$1 }')
    DIR=\${HOME}/dotfiles
    mkdir -p \${DIR}
    sudo mount \${HOST_IP}:${HOME}/dotfiles \${DIR} > /dev/null 2>&1
    # Link
    if [ ! -x "\${HOME}/.link-files" ]
    then
      ln -s "\${DIR}" "\${HOME}/.link-files"
    fi
    # Install link-files
    if ! type link-files > /dev/null 2>&1 
    then
      if [ -f "\${DIR}/deps/link-files/Makefile" ]
      then
        (cd "\${DIR}/deps/link-files" && sudo make install > /dev/null)
      else
        echo "Error: Dependency \"link-files\" has not been downloaded on host."
        exit 1
      fi
    fi
    # Link
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

# Watch process memory
func_watchmem() {
  watch 'ps -e -o rss,command= | grep "^[0-9]\+ .*'"${1}"'"'
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

# Yubikey switch to GPG mode
func_yubigpg() {
  func_pivstop && func_gpgrestart
}

# Yubikey switch to no mode
func_yubinul() {
  func_gpgstop
  func_pivstop
}

# Yubikey switch to PIV mode
func_yubipiv() {
  func_gpgstop && func_pivrestart
}

