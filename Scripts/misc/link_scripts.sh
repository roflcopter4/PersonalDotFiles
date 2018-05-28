#!/bin/sh

# Obligitory usage notice.
ShowUsage() {
    echo "USAGE: $0 [srcdir] [destdir]"
    [ $1 -eq 0 ] && printf "%s\n" "
Links all shell scipts in the given source dir to the destination dir,
removing any file extensions in the process, allowing their use as 
simple commands. Links will be full paths, not relative."
    exit $1
}


make_link() {
    extension=$1
    script_type=$2
    target_name=$(basename "${file}" ".${extension}")
    target="${HOME}/.local/bin/${target_name}"
    #ln -srf "$file" "$target"
    echo "Linking $file to $target"
    ln -sf "$file" "$target"
}


# Some basic error checking
if [ $# -eq 0 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    ShowUsage 0
    
elif [ $# -eq 1 ]; then
    printf 'ERROR: No destination dir given.\n\n'
    ShowUsage 1

elif [ $# -gt 3 ]; then
    printf 'ERROR: Too many paramaters.\n\n'
    ShowUsage 2
fi

srcDir=$(realpath "$1")
destDir=$(realpath "$2")
RELPATH="${HOME}/personaldotfiles/Scripts/shell/relpath.sh"

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
    if   echo "$file" | grep -q '\.sh$'; then
        make_link 'sh' 'shell'
    elif echo "$file" | grep -q '\.pl$'; then
        make_link 'pl' 'perl'
    elif echo "$file" | grep -q '\.py$'; then
        make_link 'py' 'python'
    elif echo "$file" | grep -q '\.zsh$'; then
        make_link 'zsh' 'zsh'
    else
        echo "File ${file} is not a known script type, skipping..."
    fi
done

