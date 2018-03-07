#!/bin/sh

# This was formerly a shell function, which partially explains the slightly
# awkward nature of it. My ineptitude in general explains part, and the fact
# that I wrote it at 4 am after having been awake for well past 48 hours and
# was hearing voices might well explain even more.

VER='mktar v0.9.0'

Out_File=
Top_Dir=
Echo_Dir=
CMD=
L=
Prefered_Tar=
TimeStamp="$(date +%s)"
CWD="$PWD"
CompType='xz'
UsedTempDir=false
Use7z=false
v7z=' -bso0 -bsp0'

ShowUsage() {
    THIS="$(basename "$0")"
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


Make_Top_Dir() {
    cd /tmp || exit 1
    TMP="$(basename "$(mktemp -d)")"

    if [ "$Out_File" ]; then
        cd "$TMP" && mkdir "$Out_File"
        Top_Dir="$Out_File"

    else
        Top_Dir="${TMP}"
    fi

    echo "Hardlinking/copying (on fail) all files to a temporary top directory."

    for f in "$@"; do
        [ -e "${f}" ] || f="${CWD}/${f}"
        [ -e "./${f}" ] && f="${CWD}/${f}"
        if ! ($CP -la "${f}" "${Top_Dir}/" >/dev/null 2>&1); then
            $CP -na "${f}" "${Top_Dir}/" >/dev/null 2>&1
        fi
    done

    #cd "$Top_Dir" || exit 1
    UsedTempDir=true
}


case "$1" in
    '--help')
        ShowUsage 0  # Exits
        ;;
    '--version')
        echo "${VER}" && exit 0
        ;;
esac


[ "$#" -eq 0 ] && ShowUsage 1
while getopts 'hV7bgt:o:l:' ARG; do
    case "$ARG" in
        h)
            ShowUsage 0  # Exits
            ;;
        V)
            echo "${VER}" && exit 0
            ;;
        7)
            Use7z=true
            ;;
        b)
            Prefered_Tar='bsdtar'
            ;;
        g)
            Prefered_Tar='gtar'
            ;;
        o)
            Out_File="$OPTARG"
            ;;
        t)
            CompType="$OPTARG"
            ;;
        l)
            L="$OPTARG"
            ;;
        *)
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))


if command -v 'nproc' >/dev/null 2>&1; then
    UseCores="$(nproc --all)"
elif command -v 'gnproc' >/dev/null 2>&1; then
    UseCores="$(gnproc --all)"
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

if [ "x$Prefered_Tar" = 'xbsdtar' ] && command -v bsdtar >/dev/null 2>&1 ; then
    TAR='bsdtar'
elif [ "x$Prefered_Tar" = 'xgtar' ] && command -v gtar >/dev/null 2>&1 ; then
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
    Out_File="${Out_File:-"$1"}"

    #if [ -d "$1" ]; then 
        #Top_Dir="$1"
    #else
        #Make_Top_Dir "$@"
    #fi

else
    Out_File="${Out_File:-"${TimeStamp}"}"
    #Make_Top_Dir "$@"
fi

Make_Top_Dir "$@"
Out_Name="${Out_File}.tar.${CompType}"
Echo_Name="${Echo_Dir}${Out_Name}"
Echo_tmp_Dir="/tmp/${TMP}/${Top_Dir}"


if $Use7z; then
    echo "${TAR} -cf - '${Echo_tmp_Dir}' | ${CMD} '${Echo_Name}'"
    $TAR -cf - "$Top_Dir" | $CMD "${Out_Dir}/${Out_Name}"

else
    case "$CompType" in
        zpaq)
            Out_Name="${Out_File}.${CompType}"
            Echo_Name="${Echo_Dir}${Out_Name}"
            echo "zpaq a '${Echo_Name}'  '${Echo_tmp_Dir}' -m${Lm5} -t${UseCores}"
            zpaq a "${Out_Dir}/${Out_Name}"  "$Top_Dir" -m${Lm5} -t${UseCores} >/dev/null
            ;;
        tzpaq)
            echo 'WARNING: zpaq cannot read from the standard input; a temporary file is required.' >&2
            echo '         Ensure sufficient disk space is available.' >&2
            echo >&2
            Out_Name="${Out_File}.tar.zpaq"
            Echo_Name="${Echo_Dir}${Out_Name}"
            tmptar="$(mktemp -u).tar"

            echo "${TAR} -cf '${tmptar}'  '${Echo_tmp_Dir}'"
            ${TAR} -cf "${tmptar}" "${Top_Dir}"

            echo "zpaq a '${Echo_Name}'  '${tmptar}' -m${Lm5} -t${UseCores}"
            zpaq a "${Out_Dir}/${Out_Name}" "${tmptar}" -m${Lm5} -t${UseCores} >/dev/null
            rm -f "${tmptar}"
            ;;
        *)
            echo "${TAR} -cf - '${Echo_tmp_Dir}' | ${CMD} > '${Echo_Name}'"
            $TAR -cf - "$Top_Dir" | $CMD > "${Out_Dir}/${Out_Name}"
            ;;
    esac
fi


if "$UsedTempDir"; then
    cd /tmp
    rm -rf "$TMP"
fi
