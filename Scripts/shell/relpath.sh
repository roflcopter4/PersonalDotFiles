#!/bin/sh

output() {
    link=$1
    target=$2
    rpath=$3

    if $link; then
        echo "$target" "$rpath"
    else
        echo "$rpath"
    fi
}

symlinks=
link=false

while getopts 'hsl' arg "$@"; do
    case "$arg" in
        (h)
            THIS=$(basename "$0")
            cat <<EOF
USAGE ${THIS} [OPTIONS] <FILE> <RELATIVE-FROM-DIR>
The behavior is the same as with \`ln(1)' The only options are \`-s' to disable
resolving symlinks and -l that will print both the target and the source in a
manner that could be used with \`ln(1)'.
EOF
            exit 0
            ;;
        (s)
            symlinks='-s'
            ;;
        (l)
            link=true
            ;;
        (*)
            exit 2
            ;;
    esac
done
[ $OPTIND -gt 0 ] && shift $((OPTIND - 1))


[ $# -lt 2 ] && echo "Insufficient paramaters." >&2 && exit 1

rpath=
target=$(realpath $symlinks "$1")
this=$(realpath $symlinks "$2")

[ ".${this}" = ".${target}" ] && echo '.' && return

while appendix="${target#"${this}/"}"
      [ ".${this}" != './' ] &&
      [ ".${appendix}" = ".${target}" ] &&
      [ ".${appendix}" != ".${this}" ]
do
    this="${this%/*}"
    rpath="${rpath}${rpath:+/}.."
done

# Unnecessary '#/' to make 100% sure that there is never a leading '/'.
if [ ".${this}" = ".${appendix}" ]; then
    output "$link" "$target" "${rpath#/}"
else
    rpath="${rpath}${rpath:+${appendix:+/}}${appendix}"
    output "$link" "$target" "${rpath#/}"
fi
