#!/bin/sh

_numMakeProcesses=$(($(nproc --all)+1))
#_numMakeProcesses=$(nproc --all)
if [ "$#" -gt 0 ]; then
    /usr/bin/make -j "$_numMakeProcesses" "$@"
else
    /usr/bin/make -j "$_numMakeProcesses"
fi
