#!/bin/sh

ShowUsage() {
    $quiet && exit "$1"
    cat <<__EOF__
Usage: ${THIS} [options] [python version] [script]

Python version correspond to an installed version of python. The script should
reside in "\$PATH". If the version specified is not found in the list below, an
attempt is made to find an exactly matching executable of that name, otherwise
the script exits.

The following options are recognized:
  -h --help        Show this help and exit.
  -V --version     Show version and exit.
  -b --backup=     Specify a fallback version if the main version fails. The
                   same formatting rules as below apply.
  -N --not-python  If abusing the script to run a non-python script in path
                   with a specific executable (eg. ruby, shell scripts...),
                   this option suppresses the normal shortcuts for python. The
                   executable must therefore match exactly.
  -v --verbose     Print the specific executable used in execution to stdout.
  -q --quiet       Don't even print error messages.

The following shortcuts for the python version are recognized:
   2, 2.7, 2_7, 27    - python2
   3                  - Any version of python 3
   3.6, 3_6, 37       - python3.6
   3.5, 3_5, 35       - python3.5
   3.4, 3_5, 34       - python3.4
   pypy, pypy2 y, y2  - pypy (python 2 compatible)
   pypy3, y3          - pypy (python 3 compatible)
__EOF__
    exit "$1"
}


###############################################################################


# Requires: 1 paramater (string)
# Exports: EXE
id_exe() {
    if $is_python; then
        case "$1" in
            pypy|pypy2|y|y2)
                EXE='pypy'
                ;;
            pypy3|y3)
                EXE='pypy3'
                ;;
            *2)
                EXE='python2'
                ;;
            *2.7|*2_7|*27)
                EXE='python2.7'
                ;;
            *3)
                EXE='python3'
                ;;
            *3.6|*3_6|*36)
                EXE='python3.6'
                ;;
            *3.5|*3_5|*35)
                EXE='python3.5'
                ;;
        esac
    else
        EXE="$1"
    fi
}


Exists() {
    if [ -z "$ExistChecker" ]; then
        FindExistChecker
    fi
    case "$ExistChecker" in
        'command')
            command -v "$1" >/dev/null 2>&1
            return $?
            ;;
        'type')
            type "$1" >/dev/null 2>&1
            return $?
            ;;
        'shell')
            $ExistCheckerSh -c "command -v $1 >/dev/null 2>&1" >/dev/null 2>&1
            return $?
            ;;
        'csh')
            csh -c "which $1 >& /dev/null" >/dev/null 2>&1
            return $?
            ;;
        'which')
            which "$1" >/dev/null 2>&1
            return $?
            ;;
    esac

    return 255
}

# Yes, all of the redirections are actually necessary. Most shells don't need
# them, but the most ancient and terrible of shells will insist on echoing
# errors unless you put the command in a subshell and redirect that too.
FindExistChecker() {
    if (command -v ls >/dev/null 2>&1) >/dev/null 2>&1; then
        ExistChecker='command'
    elif (type ls >/dev/null 2>&1) >/dev/null 2>&1; then
        ExistChecker='type'
    else
        for shell in 'sh' 'bash' 'dash' 'ksh' 'mksh' 'pdksh' 'ash' 'busybox ash' 'zsh'; do
            if ($shell -c 'command -v ls >/dev/null 2>&1' >/dev/null 2>&1) >/dev/null 2>&1; then
                ExistChecker='shell'
                ExistCheckerSh="$shell"
                break
            fi
        done
    fi
    if [ -z "$ExistChecker" ]; then
        if (csh -c 'which ls >& /dev/null' >/dev/null 2>&1) >/dev/null 2>&1; then
            ExistChecker='csh'
        elif (which ls >/dev/null 2>&1) >/dev/null 2>&1; then
            ExistChecker='which'
        fi
    fi

    if [ -z "$ExistChecker" ]; then
        $quiet || cat <<__EOF__
Your shell does not support "command -v", you do not have 'which' installed,
and you have no other shells installed (in a sane location) that support any
equivalent. Amazing. I could try to revert to something like testing whether
'cmd --version' succeeds, but instead, out of spite, this is a fatal error.
__EOF__
        exit 255
    fi

    $debug && echo "Using ${ExistChecker}" >&2
    $debug && [ -n "$ExistCheckerSh" ] && echo "Shell = ${ExistCheckerSh}" >&2
}


###############################################################################

OPTSTRING='hVb:NvqD'
LONGOPTS='help,version,backup=,not-python,verbose,quiet,debug'
THIS=`basename "$0"`
VER="${THIS} v0.1.0"

TEMP= GnuGetoptCMD= fallback= EXE= ExistChecker= CheckerSh=
GnuGetopt=false 
is_python=true
verbose=false
quiet=false
debug=false

[ $# -eq 0 ] && ShowUsage 1


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
    TEMP=`$GnuGetoptCMD -n "$THIS" -o "$OPTSTRING" \
            --longoptions "$LONGOPTS" -- "$@"` || ShowUsage 5
    eval set -- "$TEMP"
else
    # It seems only ordinary getopt(1) is installed, so we're stuck using the
    # shell builtin 'getopts' instead.
    # Nonetheless, we should handle at least a few attempts at long options.
    case "$1" in
        --help)
            ShowUsage 0  # Exits
            ;;
        --version)
            echo "${VER}" && exit 0
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
        V|-V|--version)
            echo "${VER}" && exit 0
            $GnuGetopt && shift 1
            ;;
        b|-b|--backup)
            fallback="$OPTARG"
            $GnuGetopt && shift 2
            ;;
        N|-N|--not-python)
            is_python=false
            $GnuGetopt && shift 1
            ;;
        v|-v|--verbose)
            verbose=true
            quiet=false
            $GnuGetopt && shift 1
            ;;
        q|-q|--quiet)
            verbose=false
            quiet=true
            $GnuGetopt && shift 1
            ;;
        D|-D|--debug)
            debug=true
            verbose=true
            quiet=false
            $GnuGetopt && shift 1
            ;;
        *)
            ShowUsage 2  # Exits
            ;;
    esac
done
$GnuGetopt || shift `expr $OPTIND '-' 1`

[ $# -ge 2 ] || { printf 'ERROR: Wrong number of paramaters.\n\n' >&2; ShowUsage 2; }


id_exe "$1"
Exists "$EXE"
retval=$?
if [ -z "$EXE" ] || [ $retval -ne 0 ]; then
    $quiet || echo "Executable '${EXE}' not found." >&2
    if [ -n "$fallback" ]; then
        id_exe "$fallback"
        if [ -n "$EXE" ] && Exists "$EXE"; then
            $quiet || echo "Using fallback executable '${EXE}'." >&2
        else
            $quiet || echo "Fallback executable '${EXE}' not found. Aborting." >&2
            exit 128
        fi
    else
        $quiet || echo "Aborting." >&2
        exit 127
    fi
elif $debug; then
    echo "Using executable '${EXE}'." >&2
fi

if echo "$2" | grep -q '^\.\{0,2\}/'; then
    file="$2"
elif [ -x "/usr/bin/${2}" ]; then
    file="/usr/bin/${2}"
elif [ -x "/usr/local/bin/${2}" ]; then
    file="/usr/local/bin/${2}"
else
    file=`command -v "${2}"`
fi
shift 2

# The command
$verbose && echo "Executing: \"${EXE} '${file}' $*\""
eval '"$EXE" "$file" "$@"'
