#!/usr/bin/dash

if [ $# -gt 0 ]; then
    ArgPathString=''
    for ARG in "$@"; do
        if [ "$ArgPathString" = '' ]; then
            Spacer=''
        else
            Spacer=' '
        fi

        if [ -f $ARG ]; then
            ArgPath=$(realpath "$ARG")
            ArgPathString="$ArgPathString""$Spacer"`cygpath -w "$ArgPath"`
        else
            ArgPathString="$ArgPathString""$Spacer""$ARG"
        fi
    done
fi

export NVIM_QT=1
echo "$ArgPathString"


if [ $(echo "$ORIGINAL_PATH" | grep -c 'cygdrive') ]; then
    PATH="$(echo "$ORIGINAL_PATH" | perl -pe 's|/cygdrive/|/|g')"
else
    PATH="$ORIGINAL_PATH"
fi

if [ "$ArgPathString" = '' ]; then
    nvim-qt -qwindowgeometry 900x750
else
    nvim-qt -qwindowgeometry 900x750 "$ArgPathString"
fi

#for file in *; do
    #if ! [ $(echo "$file" | grep -i '\.exe\|\.sh\|\.zsh\|\.dll') ]; then
        #chmod -x "$file"
    #fi
#done
