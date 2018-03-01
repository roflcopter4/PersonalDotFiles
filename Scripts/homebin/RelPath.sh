#!/bin/sh

ShowUsage() {
    [ "$1" ] && out=2 || out=1
    echo "Usage: $0 -[ha] <source> <target>" >&$out
    [ $out -eq 1 ] && echo "-a prepends the source to the output for testing."
    exit ${1:-0}
}
[ $# -eq 0 ] && ShowUsage 1

pre=
while getopts 'ha' ARG; do
    case "$ARG" in
        'h') ShowUsage ;;
        'a') pre='YES' ;;
        '?') echo 'Invalid argument' >&2 && ShowUsage 1 ;;
    esac
done
shift $(( $OPTIND -1 ))
[ $# -ne 2 ] && echo "Exactly 2 paramaters expected." >&2 && ShowUsage 1

# =============================================================================

this="$(realpath "$1")"
target="$(realpath "$2")"
pre="${pre:+${this}/}"
rpath=

[ "${this}" = "${target}" ] && echo "${pre}." && exit

while appendix="${target#"${this}/"}" 
      [ "${this}"     != '/'         ] &&
      [ "${appendix}"  = "${target}" ] &&
      [ "${appendix}" != "${this}"   ]
do
    this="${this%/*}" 
    rpath="${rpath}${rpath:+/}.." 
done

# Unnecessary '#/' to make 100% sure that there is never a leading '/'.
if [ "${this}" = "${appendix}" ]; then
    echo "${pre}${rpath#/}"
else
    rpath="${rpath}${rpath:+${appendix:+/}}${appendix}" 
    echo "${pre}${rpath#/}"
fi
