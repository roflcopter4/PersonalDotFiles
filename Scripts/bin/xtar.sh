#!/bin/sh

[ "$ZSH_VERSION" ] && set -o shwordsplit >/dev/null 2>&1

# Only shows long usage info if either called with no paramaters or with 0.
# Exits after showing info with either the number or with 0.
ShowUsage() {
    THIS="$(basename "$0")"
    [ "$1" ] && [ "$1" -ne 0 ] && out=2 || out=1
    echo "Usage: ${THIS} -[${OPTSTRING}] archive(s)..." >&$out
    [ "$out" -eq 2 ] && exit "$1"
    echo; cat << 'EOF'
Extract an archive safely to a unique directory, ensuring no irritating
single sub-directories or lots of loose files are created. See the manual for
more detailed information.

--- OPTIONS ---
-h        Show this usage information.
-V        Show version.
-v        Verbose mode. Display progress information if possible.
-o [dir]  Explicitly specify output directory. If it already exists, time_t will
            be appended to it. When used with multiple archives it will function
            as a top directory with each archive extracted to sub-directories,
            unless -c is supplied, whereupon all archives are combined into it.
-c        Combine multiple archives. When -o is not supplied, a directory name
            is generated from the name of the first supplied archive.

-- TAR --
-b    Use bsdtar over 'tar' if it exists, otherwise fall back to tar. [default]
-g    Use gtar if it exists, otherwise fall back to tar.
-t    Use 'tar' by default.

-- EXTRACTION --
-7    Use 7zip for extractions if it is installed. Tar archives are subsequently
        piped to tar because 7zip cannot properly handle UN*X file permissions.
-T    Simply rely on 'tar -xf' to handle the extraction. Will fail if tar fails
        to identify the archive.
-A    If the archive contains only one file that is a directory, use it as the
        top directory for the output even if it has a name like 'usr'.
-f    Force: try to extract an unknown archive by sheer trial and error.
EOF
    exit 0
}


# =================================================================================================
# Subroutines


# If the shell doesn't support 'command -v' (wtf) then try a stupid hack as a
# fallback for testing whether commands exist. For the types of commands being
# tested (generally filters) this _should_ be safe, but for anything like emacs
# for example this function would launch the editor - not what you want. There
# may be a better way but the best solution is not to use such an awful shell.
# 'command -v' is of course used if possible, which is safe.
cmd_exists() {
    if [ -z "$awful_shell" ]; then
        command -v ls >/dev/null 2>&1 && awful_shell=false || awful_shell=true
        $awful_shell && echo 'Your shell is bad and you should feel bad.' >&2
    fi

    if $awful_shell; then
        command "$1" >/dev/null 2>&1 0>&1
        [ $? -eq 127 ] && return 1 || return 0
    else
        command -v "$1" >/dev/null 2>&1
        return $?
    fi
}


# NOTE: 'is_tar' is also true for cpio files - tar can deal with both.
# EXPORTS: bpath fname bname ext bext is_tar
get_ext() {
    bpath="$(realpath "$(dirname "${Archive}")")"
    ext="$(echo "${fname}" | grep -o '\.tar\..*')"
    [ "${ext}" ] || ext="$(echo "${fname}" | grep -o '\.cpio\..*')"
    if [ "${ext}" ]; then
        ext="${ext#.}"
        bext="${ext#*.}"
        bname="${fname%*.tar.*}"
        is_tar=true
    else
        ext="${fname##*.}"
        bname="${fname%.*}"
        check_short_tar "$ext"  # assigns is_tar
    fi
}


# Simple check whether the extension is a stupid DOS style short form.
# EXPORTS: is_tar
check_short_tar() {
    case "$1" in
        tgz)
            bext='gz'
            is_tar=true
            ;;
        tbz|tb2|tbz2)
            bext='bz2'
            is_tar=true
            ;;
        txz)
            bext='xz'
            is_tar=true
            ;;
        tZ|taz|taZ)
            bext='Z'
            is_tar=true
            ;;
        tlz)
            bext='lzma'
            is_tar=true
            ;;
        *)
            is_tar=false
            ;;
    esac
}


# Determine the output directory name.
# EXPORTS: odir
get_odir() {
    local modpath
    if [ "${odir_param}" ]; then
        modpath="${bpath}/${odir_param}"
        if [ "${num_archives}" -eq 1 ] || [ "${combine}" ]; then 
            odir="${modpath}"
            oname="${odir_param}"
        else
            odir="${modpath}/${bname}"
            oname="${bname}"
        fi
    else
        modpath="${bpath}"
        odir="${modpath}/${bname}"
        oname="${bname}"
    fi
    [ -e "$odir" ] && odir="$(handle_conflict "$modpath" "$oname")"
}


handle_conflict() {
    local _bpath="$1"
    local _oname="$2"
    local res_count=1
    local newdir="${_bpath}/${_oname}-${TimeStamp}"
    while [ -e "$newdir" ]; do
        newdir="${_bpath}/${_oname}-${TimeStamp}-${res_count}"
        res_count=$(( res_count + 1 ))
    done
    echo "$newdir"
}


# =================================================================================================


do_extract() {
    local modpath tmp odir2 oname BOMB
    mkdir -p "$odir" && cd "$odir" || exit 20

    A="${bpath}/${fname}"
    B="$(rel_path "${odir}" "${A}")"
    echo "mkdir && cd -> $(basename "$odir")"

    if $is_tar; then extract_tar; else extract_else; fi
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "$ret"
        handle_failure && printf '\nSuccess!\n' >&2 || return $?
    fi

    if [ -z "$combine" ] && [ "$(command ls -1 -A -- "$odir" | wc -l)" -eq 1 ]; then
        lonefile="$(command ls -1 -A -- "$odir")"
        if (echo "$lonefile" | grep -q '^\.'); then
            mv -- "${odir}/${lonefile}" "${odir}/${lonefile#.}" 

        elif [ "$lonefile" = "$bname" ]; then
            tmp="$(handle_conflict "$bpath" "$bname")"
            mv -- "${odir}/${lonefile}" "$tmp"
            cd -- "$bpath" && rmdir "$odir"
            mv -- "$tmp" "$odir"

        else
            if [ -z "$SetUsUpTheBomb" ] && [ -d "${odir}/${lonefile}" ]; then
                for d in 'usr' 'bin' 'share' 'lib' 'lib64' 'lib32'; do
                    [ "${d}" = "$lonefile" ] && BOMB='YES' && break
                done
            fi
            
            if [ -z "$BOMB" ]; then
                if [ "$num_archives" -eq 1 ]; then
                    oname="${odir_param:-${lonefile}}"
                    odir2="${bpath}/${oname}"
                    [ -e "$odir2" ] && odir2="$(handle_conflict "$bpath" "$oname")"
                else
                    modpath="${bpath}${odir_param:+/}${odir_param}"
                    odir2="${modpath}/${lonefile}"
                    [ -e "$odir2" ] && odir2="$(handle_conflict "$modpath" "$lonefile")"
                fi
                mv -- "${odir}/${lonefile}" "$odir2"
                rmdir -- "$odir"
            fi
        fi
        
    fi
    echo "Extracted to:  $(relpath "${bpath}" "${odir2:-${odir}}")"
    cd "$bpath" || exit 20
}


# Extract a .tar.* archive.
extract_tar() {
    dcmd=
    dcmdT1=
    dcmdT2=
    if [ "x${using}" = 'xtar' ]; then
        dcmd="${TAR} -xf"
        echo "${dcmd} ${B}"
        ${dcmd} "${A}"
    else
        [ "x${using}" = 'x7zip' ] && bext='7z'
        determine_decompressor "$bext" || return $?
        if [ "$dcmdT1" = 'SPECIAL' ]; then
            handle_special_cases "$bext"
        else
            echo "${dcmd}${dcmdT1} '${B}'${dcmdT2} | ${TAR} -xf -"
            ${dcmd}${dcmdT1} "${A}"${dcmdT2} | ${TAR} -xf -
        fi
    fi
}


# Extract anything else.
extract_else() {
    dcmd=
    dcmdE1=
    dcmdE2=
    [ "x${using}" = 'x7zip' ] && ext='7z'
    determine_decompressor "$ext" || return $?

    if [ "$vredir" ]; then
        echo "${dcmd}${dcmdE1} '${B}'${dcmdE2} >/dev/null 2>&1"
        ${dcmd}${dcmdE1} "${A}"${dcmdE2} >/dev/null 2>&1
    else
        echo "${dcmd}${dcmdE1} '${B}'${dcmdE2}"
        ${dcmd}${dcmdE1} "${A}"${dcmdE2}
    fi
}


# NOTE: No space between the additional option variables and the main command
#       to allow chaining options. If the main command lacks any a space must be
#       added to the option.
# EXPORTS: dcmd dcmdT1 dcmdT2 dcmdE1
determine_decompressor() {
    #echo $1
    cmd_exists 'uncompress' && case "$1" in
        z|Z)
            dcmd='uncompress'
            dcmdT1=' -c'
            return 0;;
    esac

    cmd_exists 'gzip' && case "$1" in 
        gz|z|Z)
            dcmd='gzip -d'
            dcmdT1='c'
            dcmdE1='k'
            return 0;;
    esac

    cmd_exists 'bzip2' && case "$1" in
        bz|bz2)
            dcmd='bzip2 -d'
            dcmdT1='c'
            dcmdE1='k'
            return 0;;
    esac

    cmd_exists 'xz' && case "$1" in
        xz|lzma|lz)
            dcmd='xz -d'
            dcmdT1='c'
            dcmdE1='k'
            return 0;;
    esac

    cmd_exists 'lz4' && case "$1" in
        lz4)
            dcmd='lz4 -d'
            dcmdT1='c'
            return 0;;
    esac

    case "$1" in  # Tar ALWAYS exists
        tar|cpio)
            dcmd="${TAR} -xf"
            dcmdT2=' -'
            return 0;;
    esac

    cmd_exists '7z' && [ -z "$no7z" ] && case "$1" in
        7z|gz|bz|bz2|xz|lzma|lz|lz4|zip|cpio|rar|\
        Z|z|jar|deb|rpm|a|ar|iso|img)
            dcmd="7z${v7z}"
            dcmdT1=' -so x'
            dcmdE1=' x'
            return 0;;
    esac

    cmd_exists 'zpaq' && case "$1" in
        zpaq)
            dcmd='zpaq x'
            dcmdT1='SPECIAL'
            $verb || vredir='YES'
            return 0;;
    esac

    cmd_exists 'zip' && case "$1" in
        zip)
            dcmd="unzip${vzip}"
            dcmdT1=' -p'
            return 0;;
    esac

    cmd_exists 'arc' && case "$1" in
        arc)
            dcmd='arc'
            dcmdT1=' p'
            dcmdE1=' x'
            return 0;;
    esac

    cmd_exists 'unace' && case "$1" in
        ace|winace)
            dcmd='unace x'
            return 0;;
    esac

    cmd_exists 'unrar' && case "$1" in
        rar)
            dcmd='unrar x'
            return 0;;
    esac
    
    if [ -z "${dcmd}" ]; then
        [ -z "${FORCE}" ] && cat << EOF >&2
ERROR: File "${fname}"
       Either format is unrecognized or no known extraction utilities were
       found. Double check whether the required program is installed and is in
       your \$PATH. If unsure, consider attempting to 'force' extract the
       archive with the '-f' flag. If that fails too then this script
       unfortunately cannot extact your file.
EOF
        return 120
    fi
}


# Handle formats whose extractor will not write to the standard output.
handle_special_cases() {
    case "$1" in
        zpaq)
            if [ "$vredir" ]; then
                echo "zpac x '${B}' >/dev/null 2>&1"
                zpaq x "${A}" >/dev/null 2>&1
            else
                echo "zpac x '${B}'"
                zpaq x "${A}"
            fi
            for f in .*; do
                if (echo "${f}" | grep -q '.tar$'); then
                    echo "tar -xf && rm -> '${f}'"
                    tar -xf "${f}"
                    rm -f "${f}"
                    break
                fi
            done
            ;;
        *)
            exit 5
            ;;
    esac
}


handle_failure() {
    # Unzip likes to return failure for no good reason.
    if [ "$ext" = 'zip' ] || [ "$bext" = 'zip' ]; then
        return 0
    elif [ "$FORCE" ]; then
        index=1
        printf '\nAttempting to force extract\n\n' >&2
        while true; do
            if cmd_exists '7z' && [ $index -eq 1 ]; then
                echo "Trying 7zip" >&2
                7z x${v7z} "${A}" && return

            elif cmd_exists 'patool' && [ $index -eq 2 ]; then
                echo "Trying patool" >&2
                patool extract "${A}" && return

            elif cmd_exists 'atool' && [ $index -eq 3 ]; then
                echo "Trying atool" >&2
                atool -x "${A}" && return

            elif cmd_exists 'zpaq' && [ $index -eq 4 ]; then
                echo 'Trying zpaq' >&2
                zpaq x "${A}" && return

            elif [ $index -eq 5 ]; then
                echo "Trying tar" >&2
                tar -xf "${A}" && return

            else
                echo 'Total failure' >&2
                break
            fi
            index=$(( index + 1 ))
            echo
        done
    fi
    cd "${bpath}" || exit 20
    [ -z "$combine" ] && rmdir "${odir}"
    return 30
}


# =================================================================================================

# I always have this in a separate shell script somewhere in PATH, but since
# most people don't it's easy enough to include it here.
rel_path() {
    local this target rpath
    this="$(realpath "$1")"
    target="$(realpath "$2")"

    [ "${this}" = "${target}" ] && echo '.' && return

    while appendix="${target#"${this}/"}" 
          [ "${this}" != '/' ] &&
          [ "${appendix}" = "${target}" ] &&
          [ "${appendix}" != "${this}" ]
    do
        this="${this%/*}" 
        rpath="${rpath}${rpath:+/}.." 
    done

    # Unnecessary '#/' to make 100% sure that there is never a leading '/'.
    if [ "${this}" = "${appendix}" ]; then
        echo "${rpath#/}"
    else
        rpath="${rpath}${rpath:+${appendix:+/}}${appendix}" 
        echo "${rpath#/}"
    fi
}

# =================================================================================================
# Main Code

VER='xtar version 2.0'
OPTSTRING='hVvo:cbgt7TAf'
TimeStamp="$(date +%s)"
first=true
odir=
is_tar=
awful_shell=

odir_param=
combine=
prefer=
using=
SetUsUpTheBomb=
FORCE=
no7z=

# Verbiage - defaults to 'shut the hell up'.
verb=false
vredir=
v7z=' -bso0 -bsp0'
vzip=' -qq'

# Some color literals
NORMAL='\033[0m'
BOLD='\033[1m'
YELLOW='\033[33m'

[ $# -eq 0 ] && ShowUsage 1  # Exit if no paramaters

# For portability we're stuck with the POSIX builtin getopts rather than the
# superior GNU getopt command. It's still much better than BSD's getopt.
# Nonetheless, we should handle at least a few attempts at GNU style options.
case "$1" in
    '--help')
        ShowUsage 0  # Exits
        ;;
    '--version')
        echo "${VER}" && exit 0
        ;;
esac

while getopts "${OPTSTRING}N" ARG; do
    case "$ARG" in
        h)
            ShowUsage 0  # Exits
            ;;
        V)
            echo "${VER}" && exit 0
            ;;
        v)
            verb=true
            v7z=
            vzip=
            ;;
        o)
            odir_param="$OPTARG"
            ;;
        c)
            combine='YES'
            ;;
        b)
            prefer='bsdtar'
            ;;
        g)
            prefer='gtar'
            ;;
        t)
            prefer='tar'
            ;;
        7)
            using='7zip'
            ;;
        T)
            using='tar'
            ;;
        A)
            SetUsUpTheBomb='MakeYourTime'
            ;;
        f)
            FORCE='YES'
            ;;
        N)
            # UNDOCUMENTED - Avoid 7zip for testing backup commands.
            no7z='YES'
            ;;
        *)
            ShowUsage 2  # Exits
            ;;
    esac
done
shift $(( OPTIND - 1 ))

[ $# -eq 0 ] && echo 'No archive names provided.' >&2 && ShowUsage 3
num_archives=$#


case "$prefer" in
    bsdtar)
        cmd_exists bsdtar && TAR='bsdtar' || TAR='tar'
        ;;
    gtar)
        cmd_exists gtar && TAR='gtar' || TAR='tar'
        ;;
    tar|*)
        TAR='tar'
        ;;
esac


for Archive in "$@"; do
    fname="$(basename "$Archive")"
    $first && first=false || echo
    printf -- "${YELLOW}===============================================================================${NORMAL}\n"
    printf -- "${YELLOW}-----  Processing ${fname}  -----${NORMAL}\n"

    [ -f "$Archive" ] || { 
        echo "ERROR: File '${Archive}' either doesn't exist or is a directory. Skipping." >&2
        continue;
    }

    get_ext
    if ([ -n "$combine" ] && [ -z "$odir" ]) || [ -z "$combine" ]; then
        get_odir
    fi
    do_extract
done
