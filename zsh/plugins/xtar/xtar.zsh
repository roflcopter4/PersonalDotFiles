
xtar() {
    local ShowUsage=false
    local tarCP=1000
    local Verb_7z='-bso2'
    local Verb_Tar="--checkpoint="$tarCP""
    local Out_Dir=''
    local Exit_Val=0
    local Out_Dir_Given=''
    local TimeStamp="$(date +%s)"
    local Extracted_Dir=''
    local BasePath
    local ConflictExtDir


    # If run without arugments or with the help flag, just show usage and exit.
    if   [ "$#" -lt 1 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
        ShowUsage=true
        Exit_Val=5
        
    # Multi-Mode
    elif [ "$1" = '-m' ] || [ "$1" = '-mq' ] || [ "$1" = '-qm' ]; then
        local NextParamIsDir=false
        local FirstFile=true
        # Laziest way for this to work is to only disable showing usage when we actually do something.
        ShowUsage=true
        for Param in "$@"; do
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
                        ShowUsage=false
                        if ! "$FirstFile" && ! [ "$Verb_7z" = '' ]; then
                            printf "\n-------------------------------------------------------------------------------\n\n"
                        fi
                        # For some baffling reason printf fails in bash when the first character of a string is '-'.
                        # The only way I could make it work is by passing two more paramaters to printf. Weird.
                        printf "%s  Extracting %s  %s\n" '-----' "$Param" '-----'
                        
                        if ! [ -f "$Param" ]; then
                            echo "File either does not exist or is a directory. Skipping..."
                            Exit_Val=4
                        else
                            
                            BasePath="$(realpath "$(dirname "$Param")")"
                            
                            # Try to get the file extension. If it's not .tar.*, .tgz, or .txz, just give up.
                            Extension=$(echo "$Param" | grep -o -E '\.tar.*')
                            if ! [ "$Extension" ]; then
                                Extension=$(echo "$Param" | grep -o -E '\.tgz')
                            fi
                            if ! [ "$Extension" ]; then
                                Extension=$(echo "$Param" | grep -o -E '\.txz')
                            fi
                         
                            if [ "$Out_Dir_Given" = '' ]; then
                                Out_Dir=""$BasePath"/"$(basename "$Param" "$Extension")"-"$TimeStamp""
                            else
                                Out_Dir=""$BasePath"/"$Out_Dir_Given"/"$(basename "$Param" "$Extension")"-"$TimeStamp""
                            fi
                            
                            #echo "BASEPATH: "$BasePath""
                            #echo "Param: "$Param""
                            #echo "Extension: "$Extension""
                            #echo "Out_dir: "$Out_Dir""
                            #echo "Given: "$Out_Dir_Given""
                            
                            7z x -so "$Verb_7z" "$Param" | tar "$Verb_Tar" -xf - --one-top-level="$Out_Dir"
                            
                            if [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                                if [ -d "$BasePath"/"$Extracted_Dir" ]; then
                                    ConflictExtDir=""$BasePath"/"$Extracted_Dir"-"$TimeStamp""
                                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                                        fi
                                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                                    else
                                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                                        rmdir "$Out_Dir"
                                    fi
                                else
                                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/
                                    rmdir "$Out_Dir"
                                fi
                                
                            # This is so lazy. For god's sake fix this.
                            elif ! [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                                
                                if [ -d "$BasePath"/"$Out_Dir_Given"/"$Extracted_Dir" ]; then
                                    ConflictExtDir=""$BasePath"/"$Out_Dir_Given"/"$Extracted_Dir"-"$TimeStamp""
                                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                                        fi
                                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                                    else
                                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                                        rmdir "$Out_Dir"
                                    fi
                                else
                                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/"$Out_Dir_Given"/
                                    rmdir "$Out_Dir"
                                fi
                                 
                            fi
                            
                        fi
                    fi 
                    ;;
            esac
            FirstFile=false
        done
        if "$ShowUsage"; then
            echo "Insufficient parameters."
            Exit_Val=1
        fi
        
    # Normal-Mode
    elif [ "$#" -lt 3 ] || ([ "$1" = '-q' ] && [ "$#" -lt 4 ]); then
        local Max_Len
        local Archive
        local Extension

        # If run with quiet flag, suppress output flags.
        if [ "$1" = '-q' ]; then
            Verb_7z=''
            Verb_Tar=''
            if [ "$#" -eq 3 ]; then 
                #Out_Dir="$BasePath"/"$3"
                #Out_Dir_Given="$Out_Dir"
                Out_Dir_Given="$3"
            fi
            Max_Len=3
            Archive="$2"
        else
            if [ "$#" -eq 2 ]; then 
                #Out_Dir="$BasePath"/"$2"
                #Out_Dir_Given="$Out_Dir"
                Out_Dir_Given="$2"
            fi
            Max_Len=2
            Archive="$1"
        fi
        
        if [ "$#" -gt "$Max_Len" ]; then
            echo "Too many paramaters."
            ShowUsage=true
            Exit_Val=2
        elif ! [ -f "$Archive" ]; then
            echo "File \""$Archive"\" either does not exist or is a directory. Aborting."
            Exit_Val=3
        else
            BasePath="$(realpath "$(dirname "$Archive")")"

            if ! [ "$Out_Dir_Given" = '' ]; then
                Out_Dir=""$BasePath"/"$Out_Dir_Given""
                if [ -d "$Out_Dir" ]  && [ $(\ls -1 -A "$Out_Dir" | wc -l) -gt 0 ] ; then
                    Out_Dir=""$Out_Dir"-"$TimeStamp""
                fi
            fi


            # Try to get the file extension. If it's not .tar.*, .tgz, or .txz, just give up.
            Extension=$(echo "$Archive" | grep -o -E '\.tar.*')
            if ! [ "$Extension" ]; then
                Extension=$(echo "$Archive" | grep -o -E '\.tgz')
            fi
            if ! [ "$Extension" ]; then
                Extension=$(echo "$Archive" | grep -o -E '\.txz')
            fi
            
            # Use the file name minus the extension as a directory name if none was supplied.
            if [ "$Out_Dir" = '' ]; then
                Out_Dir=""$BasePath"/"$(basename "$Archive" "$Extension")"-"$TimeStamp""
            fi
            
            7z x -so "$Verb_7z" "$Archive" | tar "$Verb_Tar" -xf - --one-top-level="$Out_Dir"
            
            if [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                if [ -d "$BasePath"/"$Extracted_Dir" ]; then
                    ConflictExtDir=""$BasePath"/"$Extracted_Dir"-"$TimeStamp""
                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                        fi
                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                    else
                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                        rmdir "$Out_Dir"
                    fi
                else
                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/
                    rmdir "$Out_Dir"
                fi
            fi
            
        fi
        
    else
        echo "Insufficient parameters."
        ShowUsage=true
        Exit_Val=1
    fi

    if "$ShowUsage"; then
        UseStr="\
Normal Usage     : "$0" [-q] [ARCHIVE] [OUTPUT_DIRECTORY]
Multi-Mode Usage : "$0" -m [-q] [-o COMBINED_OUT_DIR] [ARCHIVES]

Extracts an archive with 7zip and passes the output to be extracted by tar.
Displays output info from 7zip, and output progress from tar for large files.
Prevents tarbombs by always extracting into a top directory, which is deleted
if there is only one file in it after extraction. If a directory name is
given explicitly, it will not be deleted. The automatically generated dir will
always have the current Unix time appended to it to avoid conflicts.

OPTIONS
    Output Dir : When in standard or quiet mode the third parameter is taken as
                 a top level directory name into which contents are extracted.
    -q         : Quiet mode. Does not display progress information.
    -m         : Multi mode. Extracts multiple tarballs in one command. All
                 parameters after any options are taken as archive names. Takes
                 -q and -o as options. Must be in that order!
    -mq/-qm    : Alias for -m -q. Can take -o as an option.
    -o         : In multi mode, supplies a top level directory into which the
                 contents of ALL archives are placed."

        printf "%s\n" "$UseStr"
    fi
    return "$Exit_Val"
}


# =============================================================================================================================
# =============================================================================================================================
# =============================================================================================================================


bsdxtar(){
    local ShowUsage=false
    local tarCP=1000
    local Verb_7z='-bso2'
    local Verb_Tar="--checkpoint="$tarCP""
    local Out_Dir=''
    local Exit_Val=0
    local Out_Dir_Given=''
    local TimeStamp="$(date +%s)"
    local Extracted_Dir=''
    local BasePath
    local ConflictExtDir


    # If run without arugments or with the help flag, just show usage and exit.
    if   [ "$#" -lt 1 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
        ShowUsage=true
        Exit_Val=5
        
    # Multi-Mode
    elif [ "$1" = '-m' ] || [ "$1" = '-mq' ] || [ "$1" = '-qm' ]; then
        local NextParamIsDir=false
        local FirstFile=true
        # Laziest way for this to work is to only disable showing usage when we actually do something.
        ShowUsage=true
        for Param in "$@"; do
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
                        ShowUsage=false
                        if ! "$FirstFile" && ! [ "$Verb_7z" = '' ]; then
                            printf "\n-------------------------------------------------------------------------------\n\n"
                        fi
                        # For some baffling reason printf fails in bash when the first character of a string is '-'.
                        # The only way I could make it work is by passing two more paramaters to printf. Weird.
                        printf "%s  Extracting %s  %s\n" '-----' "$Param" '-----'
                        
                        if ! [ -f "$Param" ]; then
                            echo "File either does not exist or is a directory. Skipping..."
                            Exit_Val=4
                        else
                            
                            BasePath="$(realpath "$(dirname "$Param")")"
                            
                            # Try to get the file extension. If it's not .tar.*, .tgz, or .txz, just give up.
                            Extension=$(echo "$Param" | grep -o -E '\.tar.*')
                            if ! [ "$Extension" ]; then
                                Extension=$(echo "$Param" | grep -o -E '\.tgz')
                            fi
                            if ! [ "$Extension" ]; then
                                Extension=$(echo "$Param" | grep -o -E '\.txz')
                            fi
                         
                            if [ "$Out_Dir_Given" = '' ]; then
                                Out_Dir=""$BasePath"/"$(basename "$Param" "$Extension")"-"$TimeStamp""
                            else
                                Out_Dir=""$BasePath"/"$Out_Dir_Given"/"$(basename "$Param" "$Extension")"-"$TimeStamp""
                            fi
                            
                            #echo "BASEPATH: "$BasePath""
                            #echo "Param: "$Param""
                            #echo "Extension: "$Extension""
                            #echo "Out_dir: "$Out_Dir""
                            #echo "Given: "$Out_Dir_Given""
                            
                            7z x -so "$Verb_7z" "$Param" | bsdtar "$Verb_Tar" -xf - --one-top-level="$Out_Dir"
                            
                            if [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                                if [ -d "$BasePath"/"$Extracted_Dir" ]; then
                                    ConflictExtDir=""$BasePath"/"$Extracted_Dir"-"$TimeStamp""
                                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                                        fi
                                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                                    else
                                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                                        rmdir "$Out_Dir"
                                    fi
                                else
                                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/
                                    rmdir "$Out_Dir"
                                fi
                                
                            # This is so lazy. For god's sake fix this.
                            elif ! [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                                
                                if [ -d "$BasePath"/"$Out_Dir_Given"/"$Extracted_Dir" ]; then
                                    ConflictExtDir=""$BasePath"/"$Out_Dir_Given"/"$Extracted_Dir"-"$TimeStamp""
                                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                                        fi
                                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                                    else
                                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                                        rmdir "$Out_Dir"
                                    fi
                                else
                                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/"$Out_Dir_Given"/
                                    rmdir "$Out_Dir"
                                fi
                                 
                            fi
                            
                        fi
                    fi 
                    ;;
            esac
            FirstFile=false
        done
        if "$ShowUsage"; then
            echo "Insufficient parameters."
            Exit_Val=1
        fi
        
    # Normal-Mode
    elif [ "$#" -lt 3 ] || ([ "$1" = '-q' ] && [ "$#" -lt 4 ]); then
        local Max_Len
        local Archive
        local Extension

        # If run with quiet flag, suppress output flags.
        if [ "$1" = '-q' ]; then
            Verb_7z=''
            Verb_Tar=''
            if [ "$#" -eq 3 ]; then 
                Out_Dir="$BasePath"/"$3"
                Out_Dir_Given="$Out_Dir"
            fi
            Max_Len=3
            Archive="$2"
        else
            if [ "$#" -eq 2 ]; then 
                Out_Dir="$BasePath"/"$2"
                Out_Dir_Given="$Out_Dir"
            fi
            Max_Len=2
            Archive="$1"
        fi
        
        if [ "$#" -gt "$Max_Len" ]; then
            echo "Too many paramaters."
            ShowUsage=true
            Exit_Val=2
        elif ! [ -f "$Archive" ]; then
            echo "File \""$Archive"\" either does not exist or is a directory. Aborting."
            Exit_Val=3
        else
            BasePath="$(realpath "$(dirname "$Archive")")"

            # Try to get the file extension. If it's not .tar.*, .tgz, or .txz, just give up.
            Extension=$(echo "$Archive" | grep -o -E '\.tar.*')
            if ! [ "$Extension" ]; then
                Extension=$(echo "$Archive" | grep -o -E '\.tgz')
            fi
            if ! [ "$Extension" ]; then
                Extension=$(echo "$Archive" | grep -o -E '\.txz')
            fi
            
            # Use the file name minus the extension as a directory name if none was supplied.
            if [ "$Out_Dir" = '' ]; then
                Out_Dir=""$BasePath"/"$(basename "$Archive" "$Extension")"-"$TimeStamp""
            fi
            
            7z x -so "$Verb_7z" "$Archive" | bsdtar "$Verb_Tar" -xf - --one-top-level="$Out_Dir"
            
            if [ "$Out_Dir_Given" = '' ] && [ $(\ls -1 -A "$Out_Dir" | wc -l) -eq 1 ]; then
                Extracted_Dir="$(\ls -1 "$Out_Dir")"
                if [ -d "$BasePath"/"$Extracted_Dir" ]; then
                    ConflictExtDir=""$BasePath"/"$Extracted_Dir"-"$TimeStamp""
                    if [ "$Out_Dir" = "$ConflictExtDir" ]; then
                        cp -rla "$Out_Dir"/"$Extracted_Dir"/* "$Out_Dir"/
                        if [ $(\ls -A "$Out_Dir"/"$Extracted_Dir" | \grep -E '^\.') ]; then
                            cp -rla "$Out_Dir"/"$Extracted_Dir"/.* "$Out_Dir"/
                        fi
                        rm -rf "$Out_Dir"/"$Extracted_Dir"
                    else
                        mv "$Out_Dir"/"$Extracted_Dir" "$ConflictExtDir"
                        rmdir "$Out_Dir"
                    fi
                else
                    mv "$Out_Dir"/"$Extracted_Dir" "$BasePath"/
                    rmdir "$Out_Dir"
                fi
            fi
            
        fi
        
    else
        echo "Insufficient parameters."
        ShowUsage=true
        Exit_Val=1
    fi

    if "$ShowUsage"; then
        UseStr="\
Normal Usage     : "$0" [-q] [ARCHIVE] [OUTPUT_DIRECTORY]
Multi-Mode Usage : "$0" -m [-q] [-o COMBINED_OUT_DIR] [ARCHIVES]

Extracts an archive with 7zip and passes the output to be extracted by tar.
Displays output info from 7zip, and output progress from tar for large files.
Prevents tarbombs by always extracting into a top directory, which is deleted
if there is only one file in it after extraction. If a directory name is
given explicitly, it will not be deleted. The automatically generated dir will
always have the current Unix time appended to it to avoid conflicts.

OPTIONS
    Output Dir : When in standard or quiet mode the third parameter is taken as
                 a top level directory name into which contents are extracted.
    -q         : Quiet mode. Does not display progress information.
    -m         : Multi mode. Extracts multiple tarballs in one command. All
                 parameters after any options are taken as archive names. Takes
                 -q and -o as options. Must be in that order!
    -mq/-qm    : Alias for -m -q. Can take -o as an option.
    -o         : In multi mode, supplies a top level directory into which the
                 contents of ALL archives are placed."

        printf "%s\n" "$UseStr"
    fi
    return "$Exit_Val"
}
