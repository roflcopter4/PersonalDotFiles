#!/bin/sh


# =================================================================================================
# Functions

ShowUsage() {
    THIS="$(basename "$0")"
    #printf "%s\n" "\
    cat << EOF
Normal Usage     : ${THIS} [-q] ARCHIVE [OUTPUT_DIRECTORY]
Multi-Mode Usage : ${THIS} -m [-q] [-o COMBINED_OUT_DIR] ARCHIVES

Extracts an archive with 7zip and passes the output to be extracted by tar.
Displays output info from 7zip, and output progress from tar for large files.
Prevents tarbombs by always extracting into a top directory, which is deleted
if there is only one file in it after extraction. If a directory name is
given explicitly, it will not be deleted. The automatically generated dir will
always have the current Unix time appended to it to avoid conflicts.

--- OPTIONS ---
Output Dir : When in standard or quiet mode the third parameter is taken as
             a top level directory name into which contents are extracted.
-q         : Quiet mode. Does not display progress information.
-m         : Multi mode. Extracts multiple tarballs in one command. All
             parameters after any options are taken as archive names. Takes
             -q and -o as options. Must be in that order!
-mq/-qm    : Alias for -m -q. Can take -o as an option.
-o         : In multi mode, supplies a top level directory into which the
             contents of ALL archives are placed.
EOF
}


POSIXHAX_CheckArray() {
    Comparator="$1"
    shift
    for arg in $@; do
        [ "$Comparator" = "$arg" ] && return 1
    done
    return 0
}


cmd_bsdtar() {
echo "Using bsdtar"
    [ "$(command -v bsdtar)" ] && TAR='bsdtar' || TAR='tar'

    if [ "$Extension" ]; then
        mkdir -p "$Out_Dir"
        cd "$Out_Dir"
        if [ "$(command -v 7z)" ] && ! [ "$Extension" = '.tar' ]; then
            7z x -so "${Verb_7z}" "${BasePath}/${Archive}" | $TAR xpf -
        else
            $TAR xpf "${BasePath}/${Archive}"
        fi
        cd "$BasePath"

    elif [ "$(command -v 7z)" ]; then
        echo 'I have no idea what this is, using 7zip only to extract'
        7z x "${Verb_7z}" "$Archive" -o"${Out_Dir}"
    else
        echo "I have no idea what this is and 7zip isn't installed. PANIC!!"
        exit 2
    fi
}


cmd_tar() {
    echo "Using gnu_tar"
    if [ "$Extension" ]; then
        if [ "$(command -v 7z)" ] && ! [ "$Extension" = '.tar' ]; then
            7z x -so "$Verb_7z" "$Archive" | tar "$Verb_Tar" xpf - --one-top-level="$Out_Dir"
        else
            tar "$Verb_Tar" xpf "$Archive" --one-top-level="$Out_Dir"
        fi

    elif [ "$(command -v 7z)" ]; then
        echo 'I have no idea what this is, using 7zip only to extract'
        7z x "${Verb_7z}" "$Archive" -o"${Out_Dir}"
    else
        echo "I have no idea what this is and 7zip isn't installed. PANIC!!"
        exit 2
    fi
}



# Shamefully exploiting global scope of all variables.
DoEverything() {
    Archive="$1"
    Mode="$2"
    BasePath="$(realpath "$(dirname "$Archive")")"

    # Try to get the file extension. If it's not .tar.*, .tgz, or .txz, just give up.
    Extension="$(echo "$Archive" | grep -o -E '\.tar.*')"
    [ "$Extension" ] || Extension="$(echo "$Archive" | grep -o -E '\.tgz')"
    [ "$Extension" ] || Extension="$(echo "$Archive" | grep -o -E '\.txz')"
    [ "$Extension" ] || Extension="$(echo "$Archive" | grep -o -E '\.tbz2')"
    [ "$Extension" ] || Extension="$(echo "$Archive" | grep -o -E '\.tar')"

    if [ "$Out_Dir_Given" = '' ]; then
        Out_Dir="${BasePath}/$(basename "${Archive}" "${Extension}")-${TimeStamp}"
    elif [ "$Mode" = 's' ]; then
        Out_Dir="${BasePath}/${Out_Dir_Given}-${TimeStamp}"
    else
        Out_Dir="${BasePath}/${Out_Dir_Given}/$(basename "${Archive}" "${Extension}")-${TimeStamp}"
    fi


    [ "$prefer_bsdtar" ] && cmd_bsdtar || cmd_tar


    # If there is only one file in the output directory, check to see if 
    #   1) The file is a directory named 'usr' or similar, meaning it is a hidden tarbomb.
    #   2) The directory already exists in the basepath of the tarball, meaning stick a timestamp on it.
    #   3) The user supplied an output directory. Also check for conflicts as above.
    #   4) Otherwise assume a tarbomb and leave it in its "temp" directory.
    if [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
        Extr_Dir="$(\ls -1 "$Out_Dir")"

        # If the only file in the archive is a directory we don't need to make a top one,
        # unless that directory already exists in the base dir or is something useless like usr/
        if [ -d "${Out_Dir}/${Extr_Dir}" ] ; then

            # If that one directory IS named something like usr then we put it in a top directory
            ProscribedDir_Fix="$(basename "$Archive" "$Extension")"
            POSIXHAX_CheckArray "$Extr_Dir" 'usr' 'bin' 'share' 'lib' 'etc' 'lib64' 'lib32'
            retval=$?
            if [ $retval -eq 1 ] && ! [ "$Extr_Dir" = "$ProscribedDir_Fix" ]; then
                mkdir "${Out_Dir}/${ProscribedDir_Fix}"
                mv "${Out_Dir}/${Extr_Dir}" "${Out_Dir}/${ProscribedDir_Fix}/"
                Extr_Dir="$ProscribedDir_Fix"
            fi


            if ! [ "$Out_Dir_Given" ]; then
                Extr_Dir_Up="${BasePath}/${Extr_Dir}"
            elif [ "$Mode" = 's' ]; then
                Extr_Dir_Up="${BasePath}/${Out_Dir_Given}"
            else
                Extr_Dir_Up="${BasePath}/${Out_Dir_Given}/${Extr_Dir}"
            fi

            # If the directory already exists, make a new one with the time stamped on the end
            # instead of clobbering it.
            if [ -d "$Extr_Dir_Up" ]; then
                ConflictExtDir="${Extr_Dir_Up}-${TimeStamp}"
                if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                    cp -rla "${Out_Dir}/${Extr_Dir}/"* "${Out_Dir}/"

                    if [ $(\ls -A "${Out_Dir}/${Extr_Dir}" | \grep -E '^\.') ]; then
                        cp -rla "${Out_Dir}/${Extr_Dir}/".* "${Out_Dir}/"
                    fi

                    rm -rf "${Out_Dir}/${Extr_Dir}"
                else
                    mv "${Out_Dir}/${Extr_Dir}" "${ConflictExtDir}"
                    rmdir "${Out_Dir}"
                fi
            else
                if [ "$Out_Dir_Given" = '' ]; then
                    mv "${Out_Dir}/${Extr_Dir}" "${BasePath}/"
                else
                    mv "${Out_Dir}/${Extr_Dir}" "${BasePath}/${Out_Dir_Given}/"
                fi
                rmdir "$Out_Dir"
            fi
        fi
    fi
}



# =================================================================================================
# Main Code


Exit_Status=0
tarCP=1000
Verb_7z='-bso2'
Verb_Tar="--checkpoint=$tarCP"
TimeStamp="$(date +%s)"
Out_Dir=''
Out_Dir_Given=''
Extr_Dir=''
DidSomething=false
prefer_bsdtar='true'


# If run without arugments or with the help flag, just show usage and exit.
if [ $# -lt 1 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    ShowUsage
    exit 5
fi

# Multi-Mode
if [ "$1" = '-m' ] || [ "$1" = '-mq' ] || [ "$1" = '-qm' ]; then
    NextParamIsDir=false
    FirstFile=true
    # Laziest way for this to work is to only disable showing usage when we actually do something.
    for Param in $@; do
        Out_Dir=''
        case "$Param" in
            '-m')
                continue
                ;;
            '-o')
                NextParamIsDir=true 
                ;;
            '-q' | '-mq' | '-qm')
                Verb_7z=''
                Verb_Tar=''
                ;;
            *)
                if "$NextParamIsDir"; then
                    Out_Dir_Given="$Param"
                    NextParamIsDir=false
                else
                    # We actually did something, so don't show usage info.
                    DidSomething=true
                    if ! "$FirstFile" && [ "$Verb_7z" ]; then
                        echo "\n-------------------------------------------------------------------------------\n"
                    fi
                    echo "----- Extracting ${Param} -----"

                    if ! [ -f "$Param" ]; then
                        echo 'File either does not exist or is a directory. Skipping...'
                        Exit_Status=4
                    else
                        # !!! DO EVERYTHING !!!
                        DoEverything "$Param" 'm'
                    fi
                fi 
                ;;
        esac
        FirstFile=false
    done
    if ! "$DidSomething"; then
        echo "Insufficient parameters."
        ShowUsage
        exit 1
    fi

# Normal-Mode
elif [ $# -lt 3 ] || ([ "$1" = '-q' ] && [ $# -lt 4 ]); then
    # If run with quiet flag, suppress output flags.
    if [ "$1" = '-q' ]; then
        Verb_7z=''
        Verb_Tar=''
        if [ $# -eq 3 ]; then 
            Out_Dir_Given="$3"
        fi
        Max_Len=3
        Archive="$2"
    else
        if [ $# -eq 2 ]; then 
            Out_Dir_Given="$2"
        fi
        Max_Len=2
        Archive="$1"
    fi

    if [ $# -gt $Max_Len ]; then
        echo "Too many paramaters."
        ShowUsage
        exit 2
    elif ! [ -f "$Archive" ]; then
        echo "File \"$Archive\" either does not exist or is a directory. Aborting."
        exit 3
    else
        # !!! DO EVERYTHING !!!
        DidSomething=true
        DoEverything "$Archive" "s"
    fi

else
    echo "Insufficient parameters."
    ShowUsage
    exit 1
fi

if ! "$DidSomething"; then
    ShowUsage
    Exit_Status=$(( $Exit_Status + 10 ))
fi

exit "$Exit_Status"

