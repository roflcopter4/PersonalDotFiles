#!/bin/sh

showUsage(){
    echo "USAGE: $(basename "$0") [clang or gcc]"
    exit 1
}

if [ "$#" -eq 0 ] || [ "$1" = '-h' -o "$1" = '--help' ]; then
    showUsage
fi

if [ $(id -u) -ne 0 ]; then
    echo "This command must be run as root."
    exit 2
fi

case "$1" in
    'clang')
        ln -sf /usr/local/bin/clang     /usr/local/bin/cc
        ln -sf /usr/local/bin/clang++   /usr/local/bin/c++
        ln -sf /usr/local/bin/clang-cpp /usr/local/bin/cpp
        ln -sf /usr/local/bin/llvm-ar   /usr/local/bin/ar
        perl -pi -e 's|export CC.*|export CC=/usr/local/bin/clang|' /home/bml/.localconfig.zsh
        perl -pi -e 's|export CXX.*|export CXX=/usr/local/bin/clang++|' /home/bml/.localconfig.zsh
        ;;

    'gcc')
        ln -sf /usr/local/bin/gcc     /usr/local/bin/cc
        ln -sf /usr/local/bin/g++     /usr/local/bin/c++
        ln -sf /usr/local/bin/gcc-cpp /usr/local/bin/cpp
        ln -sf /usr/local/bin/gcc-ar  /usr/local/bin/ar
        perl -pi -e 's|export CC.*|export CC=/usr/local/bin/gcc|' /home/bml/.localconfig.zsh
        perl -pi -e 's|export CXX.*|export CXX=/usr/local/bin/g++|' /home/bml/.localconfig.zsh
        ;;

    *)
        echo 'Invalid argument.'
        showUsage
esac
