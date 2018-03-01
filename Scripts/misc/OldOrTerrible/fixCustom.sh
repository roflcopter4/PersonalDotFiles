#!/bin/sh

ThisPath="$(realpath "$(dirname "$0")")"
cd "$ThisPath"/..

if ! [ -L oh-my-zsh/custom ]; then
    if [ -d oh-my-zsh/custom ]; then
        rm -rf oh-my-zsh/custom
    fi
    cd oh-my-zsh
    ln -sf ../custom ./
fi
