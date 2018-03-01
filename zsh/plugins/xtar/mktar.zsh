
mktar() {
    if ! [ "$(basename $(ps --no-headers -o command $$))" = 'bash' ] && \
       ! [ "$(basename $(ps --no-headers -o command $$))" = 'zsh' ]; then
        Out_File=''
        Top_Dir=''
        TimeStamp="$(date +%s)"
        UsedTempDir=false
    else
        local Out_File=''
        local Top_Dir=''
        local TimeStamp="$(date +%s)"
        local UsedTempDir=false
    fi

    if [ "$#" -eq 0 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
        echo "USAGE:  "$0" [-o Output Filename] [FILES...]"
        echo "Will create a top level dir for a list of files if none exists."
        echo "Supplying an explicit name is also optional, one can be simply generated."
        return 1
    fi
    
    if [ "$1" = '-o' ]; then
        if [ "$#" -lt 2 ]; then
            echo "ERROR: Switch '-o' too short, no file specified."
            return 4
        fi
        Out_File="$2"
        shift
        shift
    fi

    if [ "$#" -eq 0 ]; then
        echo "ERROR: No files or directories given to archive!"
        return 3
    fi

    for file in "$@"; do
        if ! [ -e "$file" ]; then
            echo File "$file" does not exist. Aborting command.
            return 2
        fi
    done

    if [ "$#" -eq 1 ]; then
        Top_Dir="$1"
        if ! [ -d "$1" ]; then
            mkdir -p ".MKTAR-TEMP/"$Top_Dir""
            cp -rla "$1" ".MKTAR-TEMP/"$Top_Dir"/"
            cd ".MKTAR-TEMP/"
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
        
        mkdir -p ".MKTAR-TEMP/"$Top_Dir""
        cp -rla "$@" ".MKTAR-TEMP/"$Top_Dir"/"
        cd ".MKTAR-TEMP/"
        UsedTempDir=true
    fi

    if [ "$Out_File" = '' ]; then
        Out_File="$TimeStamp"
    fi

    if "$UsedTempDir"; then
        Out_File=""../"$Out_File"
    fi

    tar -cf - "$Top_Dir" | 7z a -mx=9 -mfb=256 -md=128m -ms=on -m0=lzma2 -si "$Out_File".tar.7z

    if "$UsedTempDir"; then
        cd ..
        rm -rf ".MKTAR-TEMP"
    fi
}

