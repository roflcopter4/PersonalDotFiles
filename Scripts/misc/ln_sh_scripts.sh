#!/bin/sh

# Obligitory usage notice.
ShowUsage() {
    echo "USAGE: $0 [-d (dry run)] [srcdir] [destdir]"
    [ $1 -eq 0 ] && printf "%s\n" "
Links all shell scipts in the given source dir to the destination dir,
removing any file extensions in the process, allowing their use as 
simple commands. Links will be full paths, not relative."
    exit $1
}

# Some basic error checking
if [ $# -eq 0 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    ShowUsage 0
    
elif [ $# -eq 1 ]; then
    printf 'ERROR: No destination dir given.\n\n'
    ShowUsage 1

elif [ $# -gt 4 ]; then
    printf 'ERROR: Too many paramaters.\n\n'
    ShowUsage 2
fi

# Set the variables
while [ $# -gt 2 ]; do
    if [ "$1" = '-d' ]; then
        DryRun='true'
    elif [ "$1" = '-H' ]; then
        HARDLINKS='true'
    else
        printf 'ERROR: Unknown paramater %s.\n\n' "$1"
        ShowUsage 50
    fi
    shift
done
srcDir="$(realpath "$1")"
destDir="$(realpath "$2")"


# Some more basic error checking
if ! [ -d "$srcDir" ]; then
    printf 'ERROR: srcdir does not exist or is not a directory.\n\n'
    ShowUsage 3

elif ! [ -d "$destDir" ]; then
    printf 'ERROR: destdir does not exist or is not a directory.\n\n'
    ShowUsage 4

elif ! [ -w "$destDir" ] && ! [ "$DryRun" ]; then
    echo "ERROR: Insufficient permissions to write to $2. Did you forget to sudo?"
    exit 5
fi


for file in "${srcDir}/"*; do
    if echo "${file}" | grep -q '\.sh$'; then
        target="${destDir}/$(basename "${file}" '.sh')"
        
        if [ "$HARDLINKS" ]; then
            if [ "$DryRun" ]; then
                echo "Would HARD link $(basename "${file}") to ${target}"
            else
                echo "HARD linking $(basename "${file}") to ${target}"
                ln -f "$file" "$target"
            fi
        else
            if [ "$DryRun" ]; then
                echo "Would link $(basename "${file}") to ${target}"
            else
                echo "Linking $(basename "${file}") to ${target}"
                ln -sf "$file" "$target"
            fi
        fi
    else
        echo "File ${file} is not a shell script, skipping..."
    fi
done

