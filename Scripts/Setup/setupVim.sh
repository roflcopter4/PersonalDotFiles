#!/bin/sh

# I should really comment this mess at some point. Meh.

USAGE(){
    echo "USAGE: ${0} [unix/windows] [dein/vundle] [OPTIONS]"
    echo 'OPTIONS: -cp'
}


# ----------------------------
# Setup and some basic checks

rcPath="${HOME}/personaldotfiles"


if ! [ -f "${rcPath}/.vimrc" ] || ! [ -f "${rcPath}/.ginit.vim" ]; then
    echo "ERROR: Critical files not found."
    echo "Vim files are not in path '${rcPath}'"
    exit 2
fi

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    USAGE
    exit 0
fi


# ----------------------------
# Main Script

if [ "$1" = 'unix' ] || [ $# -eq 0 ]; then
    if [ "$2" = 'dein' ] || [ $# -eq 0 ]; then
        mkdir -p "${HOME}/.vim/dein/repos/github.com/Shougo"
        
        if ! [ -d "${HOME}/.vim/dein/repos/github.com/Shougo/dein.vim" ]; then
            git clone --recursive 'https://github.com/Shougo/dein.vim' "${HOME}/.vim/dein/repos/github.com/Shougo/dein.vim"
        fi
        
    elif [ "$2" = 'vundle' ]; then
        mkdir -p "${HOME}/.vim/Vundle"
        
        if ! [ -d "${HOME}/.vim/Vundle/Vundle.vim" ]; then
            git clone 'https://github.com/VundleVim/Vundle.vim' "${HOME}/.vim/Vundle/Vundle.vim"
        fi
    fi


    mkdir -p "${HOME}/.config/nvim"
    if [ "$2" = 'cp' ] || [ "$3" = 'cp' ]; then
        echo "Copying ${rcPath}/.vimrc to ${HOME}/.vimrc"
        echo "Copying ${HOME}/.vimrc to ${HOME}/.config/nvim/init.vim"
        echo "Copying ${rcPath}/.ginit.vim to ${HOME}/.config/nvim/ginit.vim"
        echo "Copying ${rcPath}/.vimpluginsto ${HOME}/.vimplugins"
        cp "${rcPath}/.vimrc"      "${HOME}/.vimrc"
        cp "${rcPath}/.vimrc"      "${HOME}/.config/nvim/init.vim"
        cp "${rcPath}/.ginit.vim"  "${HOME}/.config/nvim/ginit.vim"
        cp "${rcPath}/.vimplugins" "${HOME}/.vimplugins"
    else
        echo "Linking ${rcPath}/.vimrc to ${HOME}/.vimrc"
        echo "Linking ${HOME}/.vimrc to ${HOME}/.config/nvim/init.vim"
        echo "Linking ${rcPath}/.ginit.vim to ${HOME}/.config/nvim/ginit.vim"
        echo "Linking ${rcPath}/.vimpluginsto ${HOME}/.vimplugins"
        ln -sf "${rcPath}/.vimrc"      "${HOME}/.vimrc"
        ln -sf "${HOME}/.vimrc"        "${HOME}/.config/nvim/init.vim"
        ln -sf "${rcPath}/.ginit.vim"  "${HOME}/.config/nvim/ginit.vim"
        ln -sf "${rcPath}/.vimplugins" "${HOME}/.vimplugins"
    fi



elif [ "$1" = 'windows' ]; then
    ADLocal="$(cygpath "$LOCALAPPDATA")"
    echo "$ADLocal"
    if [ "$2" = 'dein' ] || [ $# -eq 1 ]; then
        mkdir -p '/c/Vim/dein/repos/github.com/Shougo'
        
        if ! [ -d '/c/Vim/dein/repos/github.com/Shougo/dein.vim' ]; then
            git clone 'https://github.com/Shougo/dein.vim' '/c/Vim/dein/repos/github.com/Shougo/dein.vim'
        fi
        
        winln -sf '.vimrc'    "${ADLocal}/nvim/init.vim"
        winln -sf 'ginit.vim' "${ADLocal}/nvim/ginit.vim"
        
    elif [ "$2" = 'vundle' ]; then
        mkdir -p '/c/Vim/Vundle'
        
        if ! [ -d '/c/Vim/Vundle/Vundle.vim' ]; then
            git clone 'https://github.com/VundleVim/Vundle.vim' '/c/Vim/Vundle/Vundle.vim'
        fi
        
        winln -sf '.vimrc'    "${ADLocal}/nvim/init.vim"
        winln -sf 'ginit.vim' "${ADLocal}/nvim/ginit.vim"
    fi

else
    USAGE
    exit 1
fi

