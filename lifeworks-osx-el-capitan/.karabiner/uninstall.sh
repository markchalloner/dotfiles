#!/bin/bash

shopt -s nullglob

FILE_TO="${HOME}/Library/Application Support/Karabiner/private.xml"

if [ -L "${FILE_TO}" ]
then
    rm "${FILE_TO}"
fi
if [ ! -e "${FILE_TO}" ]
then
    for FILE_FROM in "${FILE_TO}".bak.*
        do :
    done
    if [ -n "${FILE_FROM}" ] && [ -f "${FILE_FROM}" ]
    then
        mv "${FILE_FROM}" "${FILE_TO}"
    fi
fi
