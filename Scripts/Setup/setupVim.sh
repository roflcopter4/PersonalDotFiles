#!/bin/sh

# I should really comment this mess at some point. Meh.

USAGE(){
    echo "USAGE: "$0" [unix/windows] [dein/vundle] [OPTIONS]"
    echo "OPTIONS: -cp"
}


# ----------------------------
# Setup and some basic checks

#rcPath="$(realpath "$(realpath "$(dirname "$0")")/..")"
rcPath=""$HOME"/personaldotfiles"


if ! [ -f "$rcPath"/.vimrc ] || ! [ -f "$rcPath"/.ginit.vim ]; then
    echo "ERROR: Critical files not found."
    echo "Vim files are not in path '"$rcPath"'"
    exit 2
fi

if [ "$1" = '-h' -o "$1" = '--help' ]; then
    USAGE
    exit 0
fi


# ----------------------------
# Main Script

if [ "$1" = 'unix' ] || [ "$#" -eq 0 ]; then
    if [ "$2" = 'dein' ] || [ "$#" -eq 0 ]; then
        mkdir -p ~/.vim/dein/repos/github.com/Shougo
        
        if ! [ -d ~/.vim/dein/repos/github.com/Shougo/dein.vim ]; then
            git clone --recursive https://github.com/Shougo/dein.vim ~/.vim/dein/repos/github.com/Shougo/dein.vim
        fi
        
    elif [ "$2" = 'vundle' ]; then
        mkdir -p ~/.vim/Vundle
        
        if ! [ -d ~/.vim/Vundle/Vundle.vim ]; then
            git clone https://github.com/VundleVim/Vundle.vim ~/.vim/Vundle/Vundle.vim
        fi
    fi


    mkdir -p ~/.config/nvim
    if [ "$2" = 'cp' ] || [ "$3" = 'cp' ]; then
        echo "Copying "$rcPath"/.vimrc to ~/.vimrc"
        echo "Copying ~/.vimrc to ~/.config/nvim/init.vim"
        echo "Copying "$rcPath"/.ginit.vim to ~/.config/nvim/ginit.vim"
        cp "$rcPath"/.vimrc ~/.vimrc
        cp "$rcPath"/.vimrc ~/.vimrc
        cp "$rcPath"/.ginit.vim ~/.config/nvim/ginit.vim
    else
        echo "Linking "$rcPath"/.vimrc to ~/.vimrc"
        echo "Linking ~/.vimrc to ~/.config/nvim/init.vim"
        echo "Linking "$rcPath"/.ginit.vim to ~/.config/nvim/ginit.vim"
        ln -sf "$rcPath"/.vimrc ~/.vimrc
        ln -sf ~/.vimrc ~/.config/nvim/init.vim
        ln -sf "$rcPath"/.ginit.vim ~/.config/nvim/ginit.vim
    fi



elif [ "$1" = 'windows' ]; then
    ADLocal=$(cygpath "$LOCALAPPDATA")
    echo "$ADLocal"
    if [ "$2" = 'dein' ] || [ "$#" -eq 1 ]; then
        mkdir -p /c/Vim/dein/repos/github.com/Shougo
        
        if ! [ -d /c/Vim/dein/repos/github.com/Shougo/dein.vim ]; then
            git clone https://github.com/Shougo/dein.vim /c/Vim/dein/repos/github.com/Shougo/dein.vim
        fi
        
        winln -sf .vimrc "$ADLocal/nvim/init.vim"
        winln -sf ginit.vim "$ADLocal/nvim/ginit.vim"
        
    elif [ "$2" = 'vundle' ]; then
        mkdir -p /c/Vim/Vundle
        
        if ! [ -d /c/Vim/Vundle/Vundle.vim ]; then
            git clone https://github.com/VundleVim/Vundle.vim /c/Vim/Vundle/Vundle.vim
        fi
        
        winln -sf .vimrc "$ADLocal/nvim/init.vim"
        winln -sf ginit.vim "$ADLocal/nvim/ginit.vim"
    fi

else
    USAGE
    exit 1
fi

