#!/bin/sh

if [ $# -eq 0 ]; then
    echo 'USAGE: TYPE SOME FUCKING FLAGS YOU MORON'
    exit 1
fi

args='-c'
first=true
for flag in $@; do
    case "$flag" in
        '-c'|'-p'|'-cp'|'-pc')
            args="${args} ${flag}"
            continue
            ;;
        '--help')
            exec euses -c --help
            ;;
    esac
    flag="$(echo "$flag" | perl -pe 's/^-(.*)/$1/')"
    if $first; then
        printf -- "[1m[33m-----    ${flag}\t-----[0m\n\n"
        first=false
    else
        printf -- "\n\n[1m[33m-----    ${flag}\t-----[0m\n\n"
    fi
    echo "$flag"
    euses $args "$flag" | perl -pe 's/^([^:]+?) - /$1:[1m[32m [0m - /' \
                        | perl -pe 's/^(\S+?):/$1\\/' | column -t -s '\' -o ' : ' \
                        | perl -pe 's/ - / \\/'       | column -t -s '\' -o ' -  '
done
