#!/bin/bash

DIR_SELF="$(dirname ${0})"
DIR_DEPS="${DIR_SELF}/deps"
FILE_DEPS="${DIR_SELF}/deps.conf"

if [ ! -f "${FILE_DEPS}" ]
then
  echo "Error: Dependencies file \"${FILE_DEPS}\" does not exist."
  exit 1
fi

mkdir -p "${DIR_DEPS}"
while IFS='' read -r dep  || [ -n "${dep}" ]
do
  name="${dep%%=*}"
  source="${dep#*=}"
  if [ -z "${name}" ] || [ -z "${source}" ]
  then
    exit
  fi
  dir_dep="${DIR_DEPS}/${name}"
  mkdir -p "${dir_dep}"
  (
    cd ${dir_dep}
    if [ -d ".git" ]
    then
      echo "Updating ${name}"
      git pull
    else
      echo "Installing ${name}"
      git clone "${source}" .
    fi
  )
done < "${FILE_DEPS}"

