func_warning() {
  local msg="${1}"
  local dsh="$(echo ${msg} | sed 's/./-/g')"
  echo
  echo "    -------------------${dsh}---"
  echo "    | /!\ Did you mean ${msg}? |"
  echo "    -------------------${dsh}---"
  echo
}

func_cd() {
  local pwd=$(pwd)
  func_warning "pushd/popd"
  #if [ -d ${1} ]
  #then
  #  pushd ${pwd} > /dev/null
  #fi
  builtin cd "${1}"
  dirs
}

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
    func_warning "ls -l"
    /bin/ls -l "${@}"
  else
    /bin/ls "${@}"
  fi
}

func_vagrant_ssh() {
  if [ -n "$1" ]
  then
    builtin cd "$1"
  fi
  vagrant status | grep -q "running (virtualbox)"
  if [ $? -ne 0 ]
  then
    vagrant up
  fi
  vagrant ssh -- -A -t 'if tmux has > /dev/null 2>&1; then tmux attach; else tmux new; fi'
}
