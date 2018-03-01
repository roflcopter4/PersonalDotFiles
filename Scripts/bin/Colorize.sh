#!/bin/sh

ShowUsage() {
    echo "USAGE: $0 [file] or [-] for stdin"
    cat << 'EOF'
Simply cat`s a short m4 file containing a series of macros for adding ascii
colours to console output before a file and pipes it to m4. The macros are:
BOLD
RED
GREEN
YELLOW
BLUE
MAGENTA
CYAN
All colors have a bold variant usable by putting a 'b' in front of the colour
(ie bBLUE()). Colour sequences are automatically terminated.
EOF
}

([ $# -eq 0 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]) && ShowUsage && exit 1

[ "$1" = '-' ] || [ -f "$1" ] || { echo "File $1 does not exist"; exit 1; }
                                 

printf "%s%s" "$(cat << 'EOF'
define(`NORM',     `[0m')dnl
define(`BOLD',     `[1m$1'NORM)dnl
dnl
define(`RED',      `[0m[31m$1'NORM)dnl
define(`GREEN',    `[0m[32m$1'NORM)dnl
define(`YELLOW',   `[0m[33m$1'NORM)dnl
define(`BLUE',     `[0m[34m$1'NORM)dnl
define(`MAGENTA',  `[0m[35m$1'NORM)dnl
define(`CYAN',     `[0m[36m$1'NORM)dnl
dnl
define(`bRED',     `[1m[31m$1'NORM)dnl
define(`bGREEN',   `[1m[32m$1'NORM)dnl
define(`bYELLOW',  `[1m[33m$1'NORM)dnl
define(`bBLUE',    `[1m[34m$1'NORM)dnl
define(`bMAGENTA', `[1m[35m$1'NORM)dnl
define(`bCYAN',    `[1m[36m$1'NORM)dnl
changequote(`<<', `>>')
EOF
)" "$(cat "$1")" | m4 && echo

