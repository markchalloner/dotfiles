#!/bin/bash

DIR_FROM="$(dirname ${BASH_SOURCE[0]})"
DIR_TO="${HOME}/Library/Application Support/Karabiner"

FILE_FROM="${DIR_FROM}/private.xml"
FILE_TO="${DIR_TO}/private.xml"

mkdir -p "${DIR_TO}"
if [ -L "${FILE_TO}" ]
then
    rm "${FILE_TO}"
elif [ -e "${FILE_TO}" ]
then
    mv "${FILE_TO}" "${FILE_TO}.bak.$(date "+%Y%m%d%H%M%S")"
fi
cp "${FILE_FROM}" "${FILE_TO}"
