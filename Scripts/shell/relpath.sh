#!/bin/sh
# shellcheck shell=sh

symlinks=false
linkmode=false
makelink=false
dryrun=false
OPTIND=0

output() {
    target="$1"
    rpath="$2"

    if $makelink; then
        echo ln -s "'${rpath}'" "'${target}'"
        if ! $dryrun; then
            ln -s "${rpath}" "${target}"
        fi
    elif $linkmode; then
        echo "${rpath}" "${target}"
    else
        echo "${rpath}"
    fi
}

showhelp() {
    location=$(basename "$0")
    cat <<EOF
USAGE ${location} [OPTIONS] <FILE> <RELATIVE-FROM-DIR>
The behavior is the same as with \`ln(1)' The only options are \`-s' to disable
resolving symlinks and -l that will print both the target and the source in a
manner that could be used with \`ln(1)'.
EOF
    exit "${1:-1}"
}


while getopts 'hslnL' arg "$@"; do
    case "$arg" in
    h) showhelp 0    ;;
    l) linkmode=true ;;
    n) dryrun=true   ;;
    L) linkmode=true makelink=true ;;
    s) { $symlinks && symlinks=false; } || symlinks=true ;;
    *) 
        echo "Invalid option '${arg}'" >&2
        showhelp 1
        ;;
    esac
done
[ $OPTIND -gt 0 ] && shift $((OPTIND - 1))


if [ $# -lt 2 ]; then
    echo "Insufficient paramaters." >&2
    showhelp 2
fi

{ $symlinks && symlinks=''; } || symlinks='-s'

rpath=''
target=$(realpath ${symlinks} "$1")
location=$(realpath ${symlinks} "$2")
orig_location="${location}"

if ! [ -e "${target}" ]; then
    echo "File ${1} does not exist." >&2
    exit 1
fi

if ! $linkmode; then
    if ! [ -e "${location}" ]; then
        echo "File ${2} does not exist." >&2
        exit 1
    fi
fi

[ -d "${location}" ] || location="${location%/*}"

if [ "${location}" = "${target}" ]; then
    rpath='.'
else
    while
        appendix="${target#"${location}/"}"
        [ "${location}"     != '/' ] &&
        [ "${appendix}"  = "${target}" ] &&
        [ "${appendix}" != "${location}" ]
    do
        location="${location%/*}"
        rpath="${rpath}${rpath:+/}.."
    done
fi

# Unnecessary '#/' to make 100% sure that there is never a leading '/'.
if [ "${location}" = "${appendix}" ]; then
    output "${orig_location}" "${rpath#/}"
else
    rpath="${rpath}${rpath:+${appendix:+/}}${appendix}"
    output "${orig_location}" "${rpath#/}"
fi
