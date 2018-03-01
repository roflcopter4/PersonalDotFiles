#!/bin/sh

if ! [ -d "${HOME}/.local/share/omf" ]; then
    git clone 'https://github.com/oh-my-fish/oh-my-fish' --depth 1 "${HOME}/.tmp"
    cd "${HOME}/.tmp"
    bin/install --offline --noninteractive
    cd "${HOME}/"
    rm -rf "${HOME}/.tmp"
fi

mkdir -p "${HOME}/.local/config/fish"
cp -r "${HOME}/personaldotfiles/dotconfig/fish/"* "${HOME}/.config/fish/"
