#!/bin/sh

# This was formerly a shell function, which partially explains the slightly
# awkward nature of it. My ineptitude in general explains part, and the fact
# that I wrote it at 4 am after having been awake for well past 48 hours and
# was hearing voices might well explain even more.


###############################################################################
# I like to keep ugly heredocs in their own section, even if only called once.

ShowUsage() {
    cat << EOF
USAGE: ${THIS} -[h7] -o[ArchiveName] -t[type] -l[level] FILE(S)...

Types recognized: xz, bz2, gz, 7z, Z, zpaq, zip

Will create a top level dir for a list of files if none exists. A filename will
be generated if none is supplied. Will create the archive in the tar.xz format
by default. A few aliases for the formats are recognized (eg. bz,bz2,bzip etc).
Level is passed directly to the compressor if possible and ignored otherwise.
EOF
    exit "${1:-1}"
}

ComplainAboutLousyGetoptImplementation() {
    cat <<'EOF' >&2
WARNING: GNU/BSD enhanced `getopt(1)' not found; reverting to shell builtin
         `getopts(1)'. Long options will not be understood!

Only non GNU/Linux systems ship without the GNU Version: FreeBSD users can
install a fully compatible, non GPL clone from the standard ports tree.
EOF
}


###############################################################################


Make_Top_Dir() {
    cd /tmp || exit 100
    TMP=$(basename "$(mktemp -d)")

    if [ "$Out_File" ]; then
        cd "$TMP" || exit 100
        mkdir "$Out_File"
        Top_Dir="$Out_File"
    else
        Top_Dir="$TMP"
    fi

    echo "Hardlinking/copying (on fail) all files to a temporary top directory."

    for f in "$@"; do
        f=$(relative_path "${Top_Dir}/.." "${f}")
        if ! ($CP -la "${f}" "${Top_Dir}/" >/dev/null 2>&1); then
            $CP -na "${f}" "${Top_Dir}/" >/dev/null 2>&1
        fi
    done

    UsedTempDir=true
}


relative_path() {
    local us them rp app
    us=$(realpath "$1") them=$(realpath "$2") rp=
    [ "$us" = "$them" ] && echo '.' && return
    while app="${them#"${us}/"}" 
          [ "$us" != '/' ] && [ "$app" = "$them" ] && [ "$app" != "$us" ]; do
        us="${us%/*}" 
        rp="${rp}${rp:+/}.." 
    done
    [ "$us" != "$app" ] && rp="${rp}${rp:+${app:+/}}${app}"
    echo "${rp#/}"
}


###############################################################################
# Options

THIS=$(basename "$0")
VER='mktar v0.9.0'

Out_File= Top_Dir= Echo_Dir= CMD= L= Prefered_Tar=
TimeStamp=$(date +%s)
CWD=$(pwd)
CompType='xz'
UsedTempDir=false
Use7z=false
v7z=' -bso0 -bsp0'

OPTIND=1
OPTSTRING='hV7bgt:o:l:'
LONGOPTS='help,version,use7z,tar=,type=,output=,level='


for TST in 'getopt' '/usr/bin/getopt' '/usr/local/bin/getopt'; do
    ${TST} -T >/dev/null 2>&1
    if [ $? -eq 4 ]; then
        egetopt=true
        egetopt_cmd="$TST"
        break
    fi
done

if $egetopt; then
    TEMP=$(${egetopt_cmd} -n "${THIS}" -o "${OPTSTRING}" \
            --longoptions "${LONGOPTS}" -- "$@") || ShowUsage 5
    eval set -- "$TEMP"
else
    ComplainAboutLousyGetoptImplementation
    case "$1" in  # At least support these two semi-obligatory options.
        --help) ShowUsage ;;
        --version)
            echo "${VER}"
            exit 0 ;;
    esac
fi

# This is a bit hacky but it works. When using gnu getopt, the infinate loop is
# broken at '--', whereas getopts will break when the options end.
while
    if $egetopt; then
        ARG="$1"; OPTARG="$2"; true  # Make the loop infinite.
    else
        getopts "${OPTSTRING}" ARG
    fi
do 
    case "$ARG" in
        --)
            $egetopt && shift
            break
            ;;
        h|-h|--help)
            ShowUsage 0  # Exits
            ;;
        V|-V|--version)
            echo "${VER}" && exit 0
            ;;
        7|-7|--use7z)
            Use7z=true
            $egetopt && shift
            ;;
        b|-b)
            Prefered_Tar='bsdtar'
            $egetopt && shift
            ;;
        g|-g)
            Prefered_Tar='gtar'
            $egetopt && shift
            ;;
        --tar)
            Prefered_Tar="${OPTARG}"
            $egetopt && shift 2
            ;;
        o|-o|--output)
            Out_File="$OPTARG"
            $egetopt && shift 2
            ;;
        t|-t|--type)
            CompType="$OPTARG"
            $egetopt && shift 2
            ;;
        l|-l|--level)
            L="$OPTARG"
            $egetopt && shift 2
            ;;
        *)
            exit 1
            ;;
    esac
done
$egetopt || shift $((OPTIND - 1))

###############################################################################


if command -v 'nproc' >/dev/null 2>&1; then
    UseCores=$(nproc --all)
elif command -v 'gnproc' >/dev/null 2>&1; then
    UseCores=$(gnproc --all)
else
    UseCores=4
fi
Lm9="${L:-9}"
Lm5="${L:-5}"


case "$CompType" in
    xz)
        CMD="xz -T${UseCores} -${Lm9}"
        ;;
    gz|gzip)
        CompType='gz'
        CMD="gzip -${Lm9} -c"
        ;;
    bz|bz2|bzip)
        CompType='bz2'
        CMD="bzip2 -${Lm9} -c"
        ;;
    z|Z)
        CompType='Z'
        CMD='compress -c'
        ;;
    zip)
        CMD="zip -${Lm9}"
        ;;
    7z|7zip)
        CompType='7z'
        Use7z=true
        CMD="7z a${v7z} -ms=on -md=512m -mfb=256 -m0=lzma2 -mmt=${UseCores} -mx=${Lm9} -si"
        ;;
    zpaq|zp)
        CompType='zpaq'
        ;;
    tzpaq|tzp)
        CompType='tzpaq'
        ;;
    *)
        echo "Error: Filetype not recognized."
        exit 1
        ;;
esac


$Use7z && case "$CompType" in
    7z) ;;
    xz)
        CMD="7z a${v7z} -md=512m -mfb=256 -m0=lzma2 -txz -mmt=${UseCores} -mx=${Lm9} -si"
        ;;
    *)
        CMD="7z a${v7z} -mmt=${UseCores} -mx=${Lm9} -si"
        ;;
esac

###############################################################################


if [ $# -eq 0 ]; then
    echo "ERROR: No files or directories given to archive!" >&2
    exit 3
fi
for file in "$@"; do
    if ! [ -e "$file" ]; then
        echo "File ${file} does not exist. Aborting command." >&2
        exit 2
    fi
done

if [ -w "$CWD" ]; then
    Out_Dir="$CWD"
else
    echo "Current directory is not writable, placing archive in your home directory." >&2
    Out_Dir="$HOME"
    Echo_Dir='~/'
fi

if [ ".$Prefered_Tar" = '.bsdtar' ] && command -v bsdtar >/dev/null 2>&1 ; then
    TAR='bsdtar'
elif [ ".$Prefered_Tar" = '.gtar' ] && command -v gtar >/dev/null 2>&1 ; then
    TAR='gtar'
else
    TAR='tar'
fi


(cp --help >/dev/null 2>&1) && CP='cp' || CP='gcp'
command -v "$CP" >/dev/null 2>&1 || {
    echo 'Sorry, this script requires GNU cp.' >&2
    exit 1
}

if [ $# -eq 1 ]; then
    Out_File="${Out_File:-"$(basename "$1")"}"
else
    Out_File="${Out_File:-"${TimeStamp}"}"
fi


###############################################################################


Make_Top_Dir "$@"
Out_Name="${Out_File}.tar.${CompType}"
Echo_Name="${Echo_Dir}${Out_Name}"
Echo_tmp_Dir="/tmp/${TMP}/${Top_Dir}"


if $Use7z; then
    echo "${TAR} -cf - '${Echo_tmp_Dir}' | ${CMD} '${Echo_Name}'"
    eval '${TAR} -cf - "$Top_Dir" | $CMD "${Out_Dir}/${Out_Name}"'

else
    case "$CompType" in
        zpaq)
            Out_Name="${Out_File}.${CompType}"
            Echo_Name="${Echo_Dir}${Out_Name}"
            echo "zpaq a '${Echo_Name}'  '${Echo_tmp_Dir}' -m${Lm5} -t${UseCores}"
            eval 'zpaq a "${Out_Dir}/${Out_Name}"  "$Top_Dir" -m${Lm5} -t${UseCores} >/dev/null'
            ;;
        tzpaq)
            echo 'WARNING: zpaq cannot read from the standard input; a temporary file is required.' >&2
            echo '         Ensure sufficient disk space is available.' >&2
            echo >&2
            Out_Name="${Out_File}.tar.zpaq"
            Echo_Name="${Echo_Dir}${Out_Name}"
            tmptar="$(mktemp -u).tar"

            echo "${TAR} -cf '${tmptar}'  '${Echo_tmp_Dir}'"
            eval '${TAR} -cf "${tmptar}" "${Top_Dir}"'

            echo "zpaq a '${Echo_Name}'  '${tmptar}' -m${Lm5} -t${UseCores}"
            eval 'zpaq a "${Out_Dir}/${Out_Name}" "${tmptar}" -m${Lm5} -t${UseCores} >/dev/null'
            rm -f "${tmptar}"
            ;;
        *)
            echo "${TAR} -cf - '${Echo_tmp_Dir}' | ${CMD} > '${Echo_Name}'"
            eval '${TAR} -cf - "$Top_Dir" | $CMD > "${Out_Dir}/${Out_Name}"'
            ;;
    esac
fi


if "$UsedTempDir"; then
    cd /tmp || exit 100
    rm -rf "$TMP"
fi
