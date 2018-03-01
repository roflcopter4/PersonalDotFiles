#!/bin/sh

[ "$LESSCOLORIZER" ] || { echo "LESSCOLORIZER not defined." > /dev/stderr; exit 100; }

if [ $# -eq 0 ]; then
    echo "No arguments supplied - try again." > /dev/stderr
elif [ $# -eq 1 ]; then
    cat | $LESSCOLORIZER --syntax="$1" | less && exit
elif [ $# -eq 2 ]; then
    #$LESSCOLORIZER "$1" --syntax="$2" | less && exit
    LESSCOLORIZER="${LESSCOLORIZER} --syntax=${2}" less "$1" && exit
    less "$1" && exit 1
fi

exit 2
