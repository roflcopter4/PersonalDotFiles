#!/bin/sh

# This was formerly a shell function, which partially explains the slightly
# awkward nature of it. My ineptitude in general explains part, and the fact
# that I wrote it at 4 am after having been awake for well past 48 hours and
# was hearing voices might well explain even more.

Out_File=
Top_Dir=
TimeStamp="$(date +%s)"
CompType='xz'
UsedTempDir=false
Prefer_bsdtar=false
Use7z=false

ShowUsage() {
    THIS="$(basename "$0")"
    cat << EOF
USAGE: ${THIS} -[h7] -o[Output Filename] -t[xz,bz2,gz,7z,zpaq] FILE(S)...

Will create a top level dir for a list of files if none exists. A filename will
be generated if none is supplied. Will create the archive in the tar.xz format,
by default. All types except 'xz' use 7zip as the formatter.
EOF
    exit "${1:-1}"
}

[ "$#" -eq 0 ] && ShowUsage 1
while getopts 'h7t:o:' ARG; do
    case "$ARG" in
        h)
            ShowUsage 0
            ;;
        7)
            Use7z=true
            ;;
        o)
            Out_File="$OPTARG"
            ;;
        t)
            CompType="$OPTARG"
            ;;
        *)
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

case "$CompType" in
    xz|zpaq|Z)
        ;;
    gz|gzip)
        CompType='gz'
        ;;
    bz|bz2|bzip)
        CompType='bz2'
        ;;
    7z|7zip)
        CompType='7z'
        ;;
    *)
        echo "Error: Filetype not recognized."
        exit 1
        ;;
esac


if [ $# -eq 0 ]; then
    echo "ERROR: No files or directories given to archive!"
    exit 3
fi


for file in "$@"; do
    if ! [ -e "$file" ]; then
        echo File "$file" does not exist. Aborting command.
        exit 2
    fi
done


[ "$(uname -o)" = 'FreeBSD' ] && CP='gcp' || CP='cp'


if [ $# -eq 1 ]; then
    Top_Dir="$1"
    if ! [ -d "$1" ]; then
        mkdir -p ".MKTAR-TEMP/${Top_Dir}"
        $CP -rla "$1" ".MKTAR-TEMP/${Top_Dir}/"
        cd ".MKTAR-TEMP/" || exit 1
        UsedTempDir=true
    fi

    if [ "$Out_File" = '' ]; then
        Out_File="$1"
    fi

else
    if [ "$Out_File" = '' ]; then
        Top_Dir="$TimeStamp"
    else
        Top_Dir="$Out_File"
    fi
    
    mkdir -p ".MKTAR-TEMP/${Top_Dir}"
    $CP -rla "$@" ".MKTAR-TEMP/${Top_Dir}/"
    cd ".MKTAR-TEMP/" || exit 1
    UsedTempDir=true
fi


[ "$Out_File" = '' ] && Out_File="$TimeStamp"
$UsedTempDir && Out_File="../${Out_File}"


if command -v 'nproc' >/dev/null 2>&1; then
    UseCores="$(nproc --all)"
elif command -v 'gnproc' >/dev/null 2>&1; then
    UseCores="$(gnproc --all)"
else
    UseCores=4
fi


# Prefer bsdtar if it's available, since it's better.
if command -v bsdtar >/dev/null 2>&1 && "$Prefer_bsdtar"; then
    TAR='bsdtar'
else
    TAR='tar'
fi

OutName="${Out_File}.tar.${CompType}"

if $Use7z; then
    if [ "$CompType" = 'xz' ]; then
        #echo "making xz, with 7zip"
        echo "${TAR} -cf - ${Top_Dir} | 7z a -md=512m -mfb=256 -m0=lzma2 -txz -mmt=${UseCores} -mx=9 -si ${OutName}"
        $TAR -cf - "$Top_Dir" | 7z a -md=512m -mfb=256 -m0=lzma2 -txz -mmt="$UseCores" -mx=9 -si "$OutName"

    else
        #echo "making ${CompType} archive, with 7zip"
        echo "${TAR} -cf - ${Top_Dir} | 7z a -mmt=${UseCores} -si ${OutName}"
        $TAR -cf - "$Top_Dir" | 7z a -mmt="$UseCores" -si "$OutName"

    fi

else
    case "$CompType" in
        7z)
            #echo "making 7zip"
            echo "${TAR} -cf - ${Top_Dir} | 7z a -ms=on -md=512m -mfb=256 -m0=lzma2 -mmt=${UseCores} -mx=9 -si ${OutName}"
            $TAR -cf - "$Top_Dir" | 7z a -ms=on -md=512m -mfb=256 -m0=lzma2 -mmt="$UseCores" -mx=9 -si "$OutName"
            ;;
        xz)
            #echo "making xz"
            echo "${TAR} -cf - ${Top_Dir} | xz -T${UseCores} -9 > ${OutName}"
            $TAR -cf - "$Top_Dir" | xz -T"${UseCores}" -9 > "$OutName"
            ;;
        gz)
            echo "${TAR} -cf - ${Top_Dir} | gzip -9 -c > ${OutName}"
            $TAR -cf - "$Top_Dir" | gzip -9 -c > "$OutName"
            ;;
        bz2)
            echo "${TAR} -cf - ${Top_Dir} | bzip2 -9 -c > ${OutName}"
            $TAR -cf - "$Top_Dir" | bzip2 -9 -c > "$OutName"
            ;;
        Z)
            echo "${TAR} -cf - ${Top_Dir} | compress -c > ${OutName}"
            $TAR -cf - "$Top_Dir" | compress -c > "$OutName"
            ;;
        zpaq)
            echo "making ${CompType} archive"
            echo 'WARNING: zpaq cannot read from the standard input; a temporary file is required.'
            echo '         Ensure sufficient disk space is available.'
            tmp=".$(basename "$(mktemp -u)").tar"
            ${TAR} -cf "${tmp}" "${Top_Dir}"
            zpaq a "${OutName}" "${tmp}" -m5 -t"${UseCores}"
            rm -f "${tmp}"
            ;;
        *)
            echo "ERROR ERROR ERROR ERROR"
            ;;
    esac
fi

# The actual command!

if "$UsedTempDir"; then
    cd ..
    rm -rf ".MKTAR-TEMP"
fi
