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
define(`RED',      `[0;31m$1'NORM)dnl
define(`GREEN',    `[0;32m$1'NORM)dnl
define(`YELLOW',   `[0;33m$1'NORM)dnl
define(`BLUE',     `[0;34m$1'NORM)dnl
define(`MAGENTA',  `[0;35m$1'NORM)dnl
define(`CYAN',     `[0;36m$1'NORM)dnl
dnl
define(`bRED',     `[1;31m$1'NORM)dnl
define(`bGREEN',   `[1;32m$1'NORM)dnl
define(`bYELLOW',  `[1;33m$1'NORM)dnl
define(`bBLUE',    `[1;34m$1'NORM)dnl
define(`bMAGENTA', `[1;35m$1'NORM)dnl
define(`bCYAN',    `[1;36m$1'NORM)dnl
changequote(`<<', `>>')
EOF
)" "$(cat "$1")" | m4 && echo

