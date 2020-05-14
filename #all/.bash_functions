# Alias
func_alias() {
  local alias="$1"; shift
  local completion="$1"; shift

  local name="${alias%%=*}"
  local completion_name="${name//./_}"

  # Register or deregister the completion.
  [ -n "$completion" ] && func_mapset "ALIAS" "$completion_name" "$completion" || func_mapdel "ALIAS" "$completion_name"

  # Create the alias.
  alias "$alias"

  # Set the completion function.
  complete -F func_aliascomplete "$name"
  
  # Print a warning if unable to find alias.
  if ! type _complete_alias > /dev/null 2>&1 && [ -z "$(func_mapget "COMPLETION" "warned")" ]; then
    func_mapset "COMPLETION" "warned" "true"
    echo "Unable to find _complete_alias function. Is complete-alias installed correctly?"
  fi
}

func_aliascomplete() {
  type _complete_alias > /dev/null 2>&1 || return

  local name="$1"; shift

  local completion_name="${name//./_}"
  local completion="$(func_mapget "ALIAS" "$completion_name")"
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cmd=

  if [ -n "$completion" ]
  then
    COMP_WORDS=($completion "$cur")
    COMP_LINE="$completion $cur"
    COMP_CWORD=$((${#COMP_WORDS[@]}-1))
    COMP_POINT=${#COMP_LINE}

    cmd="${COMP_WORDS[0]}"

    case "$cmd" in
      kubectl)
        source <(kubectl completion bash)
        ;;
      *)
        _set_default_completion "${COMP_WORDS[0]}"
        ;;
    esac

    _command_offset 0
    return
  fi

  _complete_alias "$name"
}

func_aliasread() {
  local name="$1"; shift
  local type
  local return
  local cmd

  type="$(type "$name" 2> /dev/null)"
  [ $? -ne 0 ] && return

  if [ "$name" != "func_aliasread" ] && grep -q "is aliased to" <<< "$type"
  then
    cmd="$(sed 's/.* is aliased to [`]\(.*\)'"'"'/\1/g' <<< "$type")"
    echo "$type"
    func_aliasread "$cmd"
  else
    echo "$type"
  fi
}

func_awsassumerole() {
  local role mfa token mfa_args output result
  role=$1; shift
  session_name=$1; shift
  mfa=$1; shift
  token=$1; shift
  mfa_args=
  if [ -n "$mfa" ] && [ -n "$token" ]; then
    mfa_args=--serial-number "$mfa" --token-code "$token"
  fi
  output="$(aws sts assume-role --role-arn "$role" --role-session-name "$session_name" --query "Credentials.[AccessKeyId, SecretAccessKey, SessionToken]" --output text $mfa_args)"
  result=$?
  AWS_ACCESS_KEY_ID="$(echo "${output}" | cut -f 1)"
  AWS_SECRET_ACCESS_KEY="$(echo "${output}" | cut -f 2)"
  AWS_SESSION_TOKEN="$(echo "${output}" | cut -f 3)"
  return $result
}

func_awsid() {
  aws sts get-caller-identity --query "[UserId, Account, Arn]" --output text
}

func_awsshell() {
  (
    local role
    role=$1
    if grep -v -q ":" <<< "$role"; then
      role="arn:aws:iam::$(func_awsid | cut -f 2):role/$role"
    fi
    func_awsassumerole "$role" "${2:-$USER}" "$3" "$4" || return 1
    echo "Starting new shell $SHELL as AWS role $role..."
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    $SHELL
  )
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

func_certremote() {
  local host="$1"; shift
  local port="${1:-443}"; shift
  if [ -z "$host" ]
  then
    echo "Error: host must be specified."
    return 1
  fi
  openssl s_client -showcerts -servername "$host" -connect "$host":"$port" <<< "" 2>/dev/null | openssl x509 -inform pem -noout -text
}

func_copytoclip() {
  local command_clip
  for command in "pbcopy -Prefer txt" "xclip -selection c" "clip"
  do
    type "${command%% *}" &> /dev/null &&
      command_clip="${command}" &&
      break
  done
  if [ -n "${command_clip}" ]
  then
    for content in "${@}"
    do
      echo -n "${content}" | ${command_clip}
      # Sleep to allow content to register in the clipboard.
      sleep 1
    done
  else
    echo "Error: pbcopy, xclip or clip must be present on the path."
  fi
}

func_dconfbackup() {
  local dir="$1"; shift
  local dir_backup="${HOME}/dotfiles/$(hostname)/.dconf"
  local file
  if [ -z "$dir" ]
  then
    echo "Error: dir must be specified."
    return 1
  fi
  dir="${dir%/}/"
  file="$dir"
  file="${file#/}"
  file="${file%/}"
  file="$dir_backup/${file//\//_}.sh"
  mkdir -p "$dir_backup"
  echo "dconf load $dir << 'EOF'" > "${file}"
  dconf dump "$dir" >> "$file"
  echo 'EOF' >> "$file"
  chmod +x "$file"
  echo "Wrote dconf restore file to $file."
}

func_dconfrestore() {
  local dir_backup="${HOME}/dotfiles/$(hostname)/.dconf"
  if [ -z "${dir_backup}//\/}" ]
  then
    echo "Error: unsafe backup dir specified: $dir_backup."
    return 1
  fi
  (
    shopt -s nullglob
    for i in $dir_backup/*
    do
      bash $i
    done
  )
  echo "Restored dconf config from $dir_backup."
}

# Debounce
func_debounce() {
  local func_name="$1"; shift
  local cache_secs="${1:-1}"; shift
  func_debouncewrite "${func_name}" "${cache_secs}"
  func_debounceread
}

func_debouncewrite() {
  local func_name="$1"; shift
  local cache_secs="${1:-10}"; shift
  local cache_dir="$HOME/.debounce"
  local cache_file="${cache_dir}/${func_name}"
  local time_now="$(date '+%s')"
  if type "$func_name" > /dev/null 2>&1; then
    if [ ! -d "${cache_dir}" ]
    then
      mkdir -p "${cache_dir}"
    fi
    time_cache="$(stat -c '%Y' ${cache_file} 2> /dev/null || echo 0)"
    if [ $((${time_now}-${time_cache})) -gt ${cache_secs} ]; then
      touch "${cache_file}"
      { result="$($func_name $@ 2> /dev/null)"; echo "$result" > "${cache_file}"; } & > /dev/null 2>&1
      disown > /dev/null 2>&1
    fi
  fi
}

func_debounceread() {
  local func_name="$1"; shift
  local cache_dir="$HOME/.debounce"
  local cache_file="${cache_dir}/${func_name}"
  if type "$func_name" > /dev/null 2>&1; then
    cat "${cache_file}" 2> /dev/null
  fi

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
  #func_pivstop && \
  #func_gpgrestart && \
  #func_yubipiv && \
  #(func_dotcd "${path}" && func_dotpull "${path}" "no-auth" && git add -A && func_yubigpg && git commit -S -m "Autocommit on ${hostname}" && func_yubipiv && git push origin master)
  # When using gnupg-pkcs11-scd GPG and PIV can work in parallel.
  func_yubigpg && \
  func_yubipiv && \
  (func_dotcd "${path}" && func_dotpull "${path}" "no-auth" && git add -A && func_yubigpg && git commit -S -m "Autocommit on ${hostname}" && git push origin master)
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
  type link-files > /dev/null 2>&1 && link-files -i -q
  source "${HOME}/.bash_profile"
  [ -f "${HOME}/.inputrc" ] && bind -f  "${HOME}/.inputrc"
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

# Echo and exec (unless $PROFILE_DEBUG is set) command
func_exec() {
  echo "${@}"
  if [ -z "${PROFILE_DEBUG}" ]
  then
    eval "${@}"
  fi
}

# Show branches with description
func_gitbr() {
  if [ ${#} -gt 0 ]
  then
    git branch ${@}
    return $?
  fi
  local branches=$(git for-each-ref --format='%(refname)' refs/heads/ | sed 's|refs/heads/||')
  for branch in $branches; do
    desc=$(git config branch.$branch.description)
    if [ $branch == $(git rev-parse --abbrev-ref HEAD) ]
    then
      branch="* \033[0;32m$branch\033[0m"
    else
       branch="  $branch"
    fi
    echo -e "$branch \033[0;36m$desc\033[0m"
  done
}

# Push branches to backup remote.
func_gitbu() {
  if ! git rev-parse --git-dir > /dev/null 2>&1
  then
    echo "Error: not a git repository."
    return 1
  fi

  if ! git remote get-url backup > /dev/null 2>&1
  then
    echo "Error: no backup remote set. Try running git remote add backup <remote>."
    return 1
  fi

  if ! git ls-remote "$(git remote get-url backup)" > /dev/null 2>&1
  then
    echo "Error: remote is invalid."
    return 1
  fi

  for i in $(git for-each-ref refs/heads/ --format '%(refname:strip=2)')
  do
    echo "Backing up branch $i."
    git push backup $i
  done
}

# Commit amending the previous commit
func_gitca() {
  local message="$(echo -e -n "${1}")"
  if [ "${message}" == "-m" ]
  then
    message="$(echo -e -n "${2}")"
  fi
  if [ -n "$message" ]
  then
    func_yubigpg && git commit -S --amend -m "$message"
  else
    func_yubigpg && git commit -S --amend --no-edit
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
    prefix="$(grep -o "${match}" <<< "${branch}") "
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
  log="${log#${branch} }"
  if [ -n "${match}" ] && echo "${branch}" | grep -q "${match}"
  then
    prefix="${branch} "
  fi
  if type hub > /dev/null 2>&1
  then
    func_yubipiv
    git push -u origin "${branch}"
    url="$(hub pull-request -m "${prefix}${log#$(grep -o "${match}" <<< "${branch}") }" -b "${base}")"
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

# Git pull with force option
func_gitpl() {
  func_yubipiv || return
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$1" == "-f" ]
  then
    git fetch --all
    git reset --hard "origin/$branch"
    return $?
  fi
  if [ -z "$1" ]
  then
    set - "origin" "$branch"
  elif [ -z "$2" ]
  then
    set - "$branch"
  fi
  git pull "$@"
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
  local gpkvars
  local gpgvars
  local result
  if type gnupg-pkcs11-scd > /dev/null 2>&1
  then
    gpkvars="$(gnupg-pkcs11-scd --daemon 2> /dev/null)"
    result=$?
    if [ $result -eq 0 ]
    then
      eval "$gpkvars"
      echo "$gpkvars" > $HOME/.gnupg-pkcs11-scd-info
      export SCDAEMON_INFO
    fi
  fi
  gpgvars=$(gpg-agent --daemon 2> /dev/null)
  local result=$?
  if [ $result -eq 0 ]
  then
    eval "$gpgvars"
    echo "$gpgvars" > $HOME/.gpg-agent-info
    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
    gpg --no-tty --card-status > /dev/null 2>&1
    result=${?}
    if [ ${result} -ne 0 ]
    then
      func_gpgstop
      echo "GPG card access failed, is it locked by another process?"
    fi
  fi
  func_gpgstatus > /dev/null 2>&1
}

func_gpgstatus() {
  local cmd="${1:-gpg-agent}"
  local out=$(ps -A | grep "${cmd:0:15}" | grep -v "grep")
  if [ -n "${out}" ]
  then
    echo "${out}"
    return 0
  else
    return 1
  fi
}

func_gpgstop() {
  local pids
  local pid
  local cmd
  for cmd in gnupg-pkcs11-scd gpg-agent
  do
    pids="$(func_gpgstatus "$cmd" | awk '{print $1}')"
    if [ -n "${pids}" ]
    then
      for pid in $pids
      do
        kill -9 "${pid}"
      done
    fi
  done
}

func_grpassign()
{
  local new="$1"; shift
  if [ -z "$new" ]
  then
    echo "Error: must specify a group"
  fi

  exec sg "$new" newgrp $(id -gn)
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

# LastPass
func_lpassf() {
  local search="$1"; shift
  local index="$1"; shift
  if [ -n "$index" ]
  then
    cmd="awk NR==$index"
  else
    cmd="cat"
  fi

  lpass show -G -x --json "$search" | jq -r '.[] | (.fullname + "'$'\t''" +.password )' | $cmd | column -t -s $'\t'
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

# Map (associative arrays)
func_mapdel() {
  local map="$1"; shift
  local name="$1"; shift
  local var="MAP_${map}_KEY_${name//-/_}"

  unset ${var}
}

func_mapget() {
  local map="$1"; shift
  local name="$1"; shift

  local var="MAP_${map}_KEY_${name//-/_}"

  if [ -n "${!var}" ]
  then
    echo ${!var}
  fi
}

func_mapset() {
  local map="$1"; shift
  local name="$1"; shift
  local value="$1"; shift

  read "MAP_${map}_KEY_${name//-/_}" <<< "$value"
}

# OATH
func_oathstop() {
  local pid="$(ps -A | grep "yubioath" | awk '{print $1}')"
  if [ -n "$pid" ]
  then
    kill -9 "$pid"
  fi
}

# Password
func_pwgen() {
  local chars="[:graph:]"
  local len=
  while [ "$#" -gt 0 ]; do
    case "$1" in
      *[!0-9]*)
        chars="$1"
        shift
        ;;
      *)
        if [ -n "$len" ]; then
          chars="$1"
        else
          len="$1"
        fi
        shift
        ;;
    esac
  done
  len="${len:-16}"
  tr -cd "$chars" < /dev/urandom | dd bs=1 count="$len" status=none
  # Output a newline unless STDOUT is a pipe.
  exec 9>&1
  case `readlink /dev/fd/9` in
    pipe:\[*\]) ;;
    *) echo ;;
  esac
}

# PATH
func_pathadd() {
  local position="${1}"; shift
  local paths="${1}"; shift
  local paths_array

  if [ -z "${paths}" ]
  then
    paths="${position}"
    position="-b"
  fi
  
  IFS=':' read -ra paths_array <<< "${paths}"
  paths=""
  for path in "${paths_array[@]}"
  do
    if [ -n "${path}" ] && grep -vq "\(^\|:\)${path}\($\|:\)" <<< "${PATH}"
    then
      if [ -n "${paths}" ]
      then
        paths="${paths}:${path}"
      else
        paths="${path}"
      fi
    fi
  done

  if [ -z "${paths}" ]
  then
    return 1
  fi

  case "${position}" in
    -a|--after)
      PATH="${PATH}:${paths}"
      ;;
    -b|--before|*)
      PATH="${paths}:${PATH}"
      ;;
   esac
   export PATH
}

# PIV
func_pivrestart() {
  func_pivstop && func_pivstart
}

func_pivstart() {
  local envfile=~/.ssh-agent-info
  local lib=
  for i in /usr/lib/opensc-pkcs11.so /usr/lib/pkcs11/opensc-pkcs11.so /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so /usr/local/lib/opensc-pkcs11.so /usr/local/lib/pkcs11/opensc-pkcs11.so
  do
    if [ -f "$i" ]
    then
      lib="$i"
      break
    fi
  done

  if [ -z "$lib" ]
  then
    echo "Error: no opensc-pkcs11.so library found."
    return 1
  fi

  { ssh-agent -P '/usr/lib/*,/usr/local/lib/*,/usr/local/Cellar/opensc/*' || ssh-agent; } 2> /dev/null > "$envfile"
  source "$envfile" > /dev/null
  if [ $? -eq 0 ]
  then
    ssh-add -D > /dev/null 2>&1
    ssh-add -e "$lib" > /dev/null 2>&1
    ssh-add -s "$lib" 2> /dev/null
  fi
}

func_pivstatus() {
  local envfile=~/.ssh-agent-info
  if ! [ -f "$envfile" ]
  then
    return 1
  fi
  local out=$(ps -A | grep "ssh-agent" | grep -v "grep")
  if [ -z "${out}" ]
  then
    return 1
  fi
  source "$envfile" > /dev/null
  # Test SSH keys are loaded.
  if ! ssh-add -l 2> /dev/null | grep -q "$lib"
  then
    return 1
  fi
  # Test signing. Shellcode extracted from https://github.com/pts/rsa/blob/master/ssh_agent_rsa_sign_example.py using binascii.
  if [ -z "$(echo -en "\x00\x00\x01\x25\x0d\x00\x00\x01\x17\x00\x00\x00\x07\x73\x73\x68\x2d\x72\x73\x61\x00\x00\x00\x03\x01\x00\x01\x00\x00\x01\x01\x00\xe4\xc7\x4a\xc3\x53\x15\x19\x77\x4c\xc2\xa9\xf6\x3b\x38\xc8\xe5\x35\x6e\x5c\xa2\x78\x61\xea\xb0\x34\xc6\x81\x5c\x46\x92\xf8\x86\x9d\x19\xe0\xe5\x6f\x4f\x19\x19\x7b\x72\xf0\xc0\x12\x8a\x7a\xd2\xa5\x4c\xb4\x04\x55\x33\xd2\x44\xad\x5c\x1d\x11\x28\xd6\x86\x9c\x40\x97\x4b\x27\xb8\x11\x7a\x03\x1a\x19\x71\x14\x36\x5c\x49\xfc\x49\xe4\x18\x10\xec\x2b\x2f\x54\x65\xc0\xc6\xf7\x0d\x95\x56\xb0\x46\x01\x2a\x8f\x57\x38\x90\x92\xd3\xa7\x03\xfb\x3a\xd9\x06\x37\x79\x8a\x46\xeb\x8a\x5e\x52\xef\x3a\x32\x6e\x14\x80\x5d\x24\xb2\xc9\xf1\xe8\x34\x86\x0c\x27\x8f\x27\xb4\x12\xab\xc3\x4a\x8e\x0a\x7f\x15\x53\xcd\xaa\x7d\x78\x44\xa9\x36\x44\xa8\x06\xe1\x80\x90\x36\x1e\x3b\xaf\x1c\x48\xe9\xe1\x7d\xf0\x46\x8f\x29\xfb\x10\xa5\x9c\xee\xa8\xc7\x9d\x1f\x1a\xbb\xc2\xe0\x1f\xcc\xea\xd6\xee\x4f\xfe\x77\x24\x1c\x76\x1f\xb4\xbd\xcb\xd9\x67\x2a\xc0\x0a\xa1\xbb\x28\x5a\x15\xd5\x73\x8f\xc5\xf8\x27\x90\xc0\x62\xca\x17\x48\x51\x88\x96\x88\x0c\xbd\x1b\x32\x7d\xc6\x50\xf4\xf7\x19\xcd\x3f\x07\x79\xad\x4c\x8d\x11\x8b\x6c\xef\xb0\x0b\x27\x00\xf5\x73\x10\xfd\x00\x00\x00\x01\x30\x00\x00\x00\x00"  | nc -w 1 -U $SSH_AUTH_SOCK | strings)" ]
  then
    return 1
  fi
  echo "${out}"
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

# Prompt
func_promptyubistatus() {
  local command=""
  for i in "lsusb" "system_profiler SPUSBDataType"
  do
    type "${i%% *}" > /dev/null 2>&1 &&
      command="${i}" &&
      break
  done
  if [ -n "${command}" ] && ${command} | grep -q "ID 1050:"
  then
    echo -n "yubikey"
    func_yubistatus > /dev/null 2>&1
    case $? in
      1) echo -n "[gpg]" ;;
      2) echo -n "[piv]" ;; 
      3) echo -n "[gpg|piv]" ;;
    esac
  else
    echo -n "nothing"
  fi
}

# Get realpath
func_realpath() {
  python -c "import os; print(os.path.realpath('$1'))"
}

# Print a reminder
func_remind() {
  local msg="${1}"
  func_warning "Did you mean \`${msg}\`?"
}

# SSH with network user
func_ssh() {
  func_yubipiv
  /usr/bin/ssh $@
  local result=${?}
  if [ -t 1 ]; then
    func_termcolor "default"
  fi
  return ${result}
}

func_sshp() {
  func_yubipiv
  func_ssh -o PreferredAuthentications=publickey $@
}

func_sshtunneldown() {
    local dir_config=$HOME/.ssh-tunnel
    local file_known_hosts=$dir_config/known_hosts
    local file_control_path=$dir_config/control_path
    local hosts=( "$@" )
    local status="$(func_sshtunnelstatus)"
    if [ -z "$status" ]
    then
      return 1
    fi
    while IFS='' read -r line || [[ -n "$line" ]]
    do
      host=${line%% *}
      port=${line#* }
      if [ ${#hosts[@]} -eq 0 ] || printf '%s\n' "${hosts[@]}" | grep -q "^$host$"
      then
        echo "Destroying existing SSH tunnel to $host on $port."
        ssh -O "exit" -S "${file_control_path}_${port}" "$host" > /dev/null 2>&1
        sed -i.bak "/^$host,$port/d" "$file_known_hosts"
      fi
    done <<< "$status"
}

func_sshtunnelstatus() {
  local dir_config=$HOME/.ssh-tunnel
  local file_known_hosts=$dir_config/known_hosts
  local file_control_path=$dir_config/control_path
  local host
  local port
  local count
  if [ -f "$file_known_hosts" ]
  then
    while IFS='' read -r line || [[ -n "$line" ]]
    do
        host=${line%%,*}
        line=${line#*,}
        port=${line%% *}
        echo $host $port
    done < "$file_known_hosts"
  fi
}

func_sshtunnelup() {
  local key="$1"; shift
  local dir_config=$HOME/.ssh-tunnel
  local file_known_hosts=$dir_config/known_hosts
  local file_control_path=$dir_config/control_path
  local hosts=( "$@" )
  local host
  local port=1079
  mkdir -p $dir_config
  while true
  do
    if [ ${#hosts[@]} -eq 0 ]
    then
      break
    fi
    port=$(($port+1))

    if [ -e "${file_control_path}_${port}" ]
    then
      for i in ${!hosts[@]}
      do
        host=${hosts[$i]}
        if grep -q "$host $port" <<< "$(func_sshtunnelstatus)"
        then
          echo "Skipped existing SSH tunnel to $host on $port."
          unset "hosts[$i]"
          hosts=( "${hosts[@]}" )
        fi
      done
      continue
    fi

    host=${hosts[0]}
    if ! grep -q "$host" <<< "$(func_sshtunnelstatus)"
    then
      echo "$host,$port $key" >> "$file_known_hosts"
    fi
    if ssh -f -N -T -D $port ec2-user@$host -o "UserKnownHostsFile=$file_known_hosts" -o "ControlMaster=yes" -o "ControlPath=${file_control_path}_${port}"
    then
      echo "Created new SSH tunnel to $host on port $port."
    fi
    hosts=("${hosts[@]:1}")
  done
}

func_sshunpin()
{
  line="${1}"
  if [ -z "${line}" ]
  then
    echo "Error: line number must be specified."
  fi
  sed -i.bak -e "${line}d" "${HOME}/.ssh/known_hosts"
}

# Read stdin
func_stdin() {
  local char
  local stdin=""
  if read -n 1 -t 1 char
  then
    if (( $? <= 128 ))
    then
       IFS= read -r -d '' stdin
       stdin="${char}${stdin}"
    fi
  fi
  RETVAL="${stdin}"
}

func_term() {
  if [ -z "$SCRIPT_DIR" ]; then
    local script_dir
    script_dir="~/.script"
    mkdir -p "$script_dir"
    export SCRIPT_FILE=$script_dir/$([ -n "$TMUX" ] && echo "tmux-$TMUX_TTY")
    script -aef $SCRIPT_FILE
  fi
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

# Time
func_timeadd() {
  local total=0
  local i
  local time
  local min=0
  local sec=0
  for i in $@
  do
    time=${i//./:}
    min=$((10#${time%:*}))
    sec=$((10#${time##*:}))
    total=$((total+(min*60)+sec))
  done
  printf "%d:%.2d\n" "$((total/60))" "$((total%60))"
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
      (
        cd "\${DIR}"
        if [ ! -d "\${DIR}/deps/link-files" ]
        then
          ./deps-download.sh
        fi
        cd "deps/link-files" && sudo make install > /dev/null
      )
    fi
    # Link
    link-files -o -i -q
EOF
}

# Start vagrant box if not running and attempt to run tmux when connecting
func_vssh() {
  local dir="${1}"
  #if [ -n "${TMUX}" ]
  #then
  #  echo "Running in a tmux session; run \"tmux detach\" first."
  #  return 1
  #fi
  (
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
  )
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

# YAML
func_yamlparse() {
  local file="${1}"; shift
  local key="${1}"; shift
  if [ -z "${file}" ]
  then
    echo 'Error: must provide a file.'
    return 1
  fi
  if ! type ruby > /dev/null 2>&1
  then
    echo 'Error: ruby must be installed.'
  fi
  key="$(<<< "${key}" sed 's/\[/.\[/g' | tr '.' $'\n' | sed 's/^\([0-9][0-9]*\)$/[\1]/g' | sed "s/^\([^[][^[]*\)/['\1']/g" | tr -d $'\n')"
  local cmd="hash = YAML.load(File.read('${file}')) ; pp hash${key}"
  echo -e "$(ruby -r pp -r yaml <<< "${cmd}")" | sed -e 's/^"//g' -e 's/"$//g'
}

# Yubikey switch to GPG mode
func_yubigpg() {
  #func_pivstop && func_gpgrestart
  # When using gnupg-pkcs11-scd GPG and PIV can work in parallel.
  func_gpgrestart
}

# Yubikey switch to no mode
func_yubinul() {
  func_gpgstop
  func_pivstop
}

# Yubikey switch to PIV mode
func_yubipiv() {
  #func_gpgstop && func_oathstop && { func_pivstatus > /dev/null || func_pivrestart ; }
  # When using gnupg-pkcs11-scd GPG and PIV can work in parallel.
  func_oathstop && { func_pivstatus > /dev/null || func_pivrestart ; }
}

func_yubistatus() {
  status=0
  if func_gpgstatus > /dev/null 2>&1
  then
    echo "gpg-mode"
    status=$((status|1))
  fi
  if func_pivstatus > /dev/null 2>&1
  then
    echo "piv-mode"
    status=$((status|2))
  fi
  return $status
}

# Yubikey TOTP
func_yubitotp() {
  local code_only="${1}"; shift
  local query="${1}"; shift
  local index="${1}"; shift
  local command
  local output
  local status
  local code
  if [ "${code_only}" != "-c" ] && [ "${code_only}" != "--code" ]; then
    index="${query}"
    query="${code_only}"
  fi
  if type ykman > /dev/null 2>&1; then
    command="ykman oath code"
  elif type yubioath > /dev/null 2>&1; then
    command="yubioath"
  else
    echo "Error: ykman or yubioath must be present on the path."
    return 1
  fi
  if [ "${code_only}" == "-c" ] || [ "${code_only}" == "--code" ]
  then
    output="$($command "${query}" | sed 's/.*  *//g')"
    status=${PIPESTATUS[0]}
  else
    output="$($command "${query}")"
    status=${PIPESTATUS[0]}
  fi
  echo "$output"
  code="$(sed 's/.*  *//g' <<< "$output" | head -n 1 | tr -d '\n')"
  func_copytoclip "${code}"
  return $status
}
