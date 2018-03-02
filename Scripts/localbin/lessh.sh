#!/bin/sh

[ "$LESSCOLORIZER" ] || { echo "LESSCOLORIZER not defined." >&2; exit 100; }
command -v $LESSCOLORIZER >/dev/null 2>&1 || { echo "Command specified in LESSCOLORIZER not found." >&2; exit 127; }

if [ $# -eq 0 ]; then
    echo "No arguments supplied - try again." >&2
elif [ $# -eq 1 ]; then
    cat | $LESSCOLORIZER --syntax="$1" | less && exit
elif [ $# -eq 2 ]; then
    export LESSH="YES"
    _LESSCOLORIZER_="${LESSCOLORIZER} --syntax=${1}" less "$2"
fi

exit 2
