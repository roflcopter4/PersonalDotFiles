#!/bin/sh

##########################################################################################

ShowUsage() {
    cat <<__EOF__
Usage: ${THIS} [option]... [<file>]

Options:
    -h, --help      Show this help
    -l, --language  Explicitly specify the source language for highlight(1)
    -s, --syntax    Alias for --language
    -n, --nonumber  Disable line numbering
__EOF__
    exit "$1"
}

##########################################################################################

OPTSTRING='hs:l:n'
LONGOPTS='help,language=,syntax=,nonumber'
THIS=$(basename "$0")

[ "$LESSCOLORIZER" ] || {
    echo "LESSCOLORIZER not defined." >&2;
    exit 100
}

# Dumb linters are dumb.
# shellcheck disable=2086
command -v $LESSCOLORIZER >/dev/null 2>&1 || {
    echo "Command specified in LESSCOLORIZER not found." >&2
    exit 127
}

if [ $# -eq 0 ]; then
    echo "No arguments supplied - try again." >&2
    ShowUsage 1
fi

##########################################################################################
# Process Options

GnuGetoptCMD='' language=''
GnuGetopt=false
NoNumber=false

# Look everywhere for GNU getopt(1).
for TST in 'getopt' '/usr/bin/getopt' '/usr/local/bin/getopt'; do
    ${TST} -T >/dev/null 2>&1
    if [ $? -eq 4 ]; then
        GnuGetopt=true
        GnuGetoptCMD="$TST"
        break
    fi
done

if $GnuGetopt; then
    TEMP=$($GnuGetoptCMD -n "$THIS" -o "$OPTSTRING" \
           --longoptions "$LONGOPTS" -- "$@") || ShowUsage 2
    eval set -- "$TEMP"
else
    # It seems only ordinary getopt(1) is installed, so we're stuck using the
    # shell builtin 'getopts' instead.
    # Nonetheless, we should handle at least a few attempts at long options.
    case "$1" in
        --help)
            ShowUsage 0  # Exits
            ;;
    esac
fi

while
    if $GnuGetopt; then
        ARG="$1"; OPTARG="$2"; true  # Make the loop infinite.
    else
        getopts "${OPTSTRING}" ARG
    fi
do 
    case "$ARG" in
        --)
            $GnuGetopt && shift 1
            break
            ;;
        h|-h|--help)
            ShowUsage 0  # Exits
            ;;
        l|-l|--language|s|-s|--syntax)
            language="$OPTARG"
            $GnuGetopt && shift 2
            ;;
        n|-n|--nonumber)
            NoNumber=true
            $GnuGetopt && shift 1
            ;;
        *)
            ShowUsage 3  # Exits
            ;;
    esac
done
$GnuGetopt || shift "$(expr $OPTIND '-' 1)"

##########################################################################################
# Main

unset HIGHLIGHT_OPTIONS
_LESSCOLORIZER_="$LESSCOLORIZER"

if [ "$language" ]; then
    _LESSCOLORIZER_="${_LESSCOLORIZER_} --syntax=${language}"
fi
if $NoNumber; then
    _LESSCOLORIZER_="$(echo "${_LESSCOLORIZER_}" | sed 's/-l//')"
fi

if [ $# -eq 0 ]; then
    cat | $_LESSCOLORIZER_ | less && exit 0
elif [ $# -eq 1 ]; then
    LESSH="YES"
    export LESSH
    export _LESSCOLORIZER_
    exec less "$1"
else
    echo 'Only one filename may be supplied.' >&2
    ShowUsage 4
fi


# elif [ $# -eq 1 ]; then
#     cat | $LESSCOLORIZER --syntax="$1" | less && exit
# elif [ $# -eq 2 ]; then
#     export LESSH="YES"
#     _LESSCOLORIZER_="${LESSCOLORIZER} --syntax=${1}" less "$2"
# fi

exit 16
