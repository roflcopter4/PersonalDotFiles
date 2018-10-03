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

is_oneoff=false

# Some basic error checking
if [ $# -eq 0 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    ShowUsage 0
    
elif [ $# -eq 1 ]; then
    printf 'ERROR: No destination dir given.\n\n'
    ShowUsage 1

elif [ $# -gt 3 ]; then
    if [ "$1" = '-1' ]; then
        is_oneoff=true
    else
        printf 'ERROR: Too many paramaters.\n\n'
        ShowUsage 2
    fi
fi

srcDir=$(realpath "$1")
destDir=$(realpath "$2")
RELPATH="${HOME}/personaldotfiles/Scripts/shell/relpath.sh"

# Some more basic error checking
if ! [ -d "$srcDir" ] && ! $is_oneoff; then
    printf 'ERROR: srcdir does not exist or is not a directory.\n\n'
    ShowUsage 3

elif ! [ -d "$destDir" ]; then
    printf 'ERROR: destdir does not exist or is not a directory.\n\n'
    ShowUsage 4

elif ! [ -w "$destDir" ] && ! [ "$DryRun" ]; then
    echo "ERROR: Insufficient permissions to write to $2. Did you forget to sudo?"
    exit 5
fi


handle_file() {
    [ $# -eq 1 ] || return 1
    if   echo "$1" | grep -q '\.sh$'; then
        make_link 'sh' 'shell'
    elif echo "$1" | grep -q '\.pl$'; then
        make_link 'pl' 'perl'
    elif echo "$1" | grep -q '\.py$'; then
        make_link 'py' 'python'
    elif echo "$1" | grep -q '\.zsh$'; then
        make_link 'zsh' 'zsh'
    else
        echo "1 ${1} is not a known script type, skipping..."
    fi
}


if $is_oneoff; then
    handle_file "$2"
else
    for file in "${srcDir}/"*; do
        handle_file "$file"
    done
fi
