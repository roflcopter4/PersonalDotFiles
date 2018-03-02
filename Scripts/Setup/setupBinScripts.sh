#!/bin/sh

mkdir -p "${HOME}/.local/bin"
"${HOME}/personaldotfiles/Scripts/misc/ln_sh_scripts.sh" "${HOME}/personaldotfiles/Scripts/bin" "${HOME}/.local/bin"

# Neovim-QT
if [ "$(uname)" = 'Cygwin' ] || [ "$(uname)" = 'Msys' ]; then
    ln -sf "${HOME}/personaldotfiles/Scripts/misc/viRelated/run-win_nvim_qt.sh" "${HOME}/.local/bin/vi"
else
    ln -sf "${HOME}/personaldotfiles/Scripts/misc/viRelated/run_vi.sh" "${HOME}/.local/bin/gvi"
fi

if [ "$(uname)" = 'Linux' ] && [ "$(id -u)" -eq 1 ] && [ x"$1" = x'sbin' ]; then
    for file in "${HOME}/personaldotfiles/Scripts/localbin/"*; do
        mkdir -p '/usr/local/sbin'
        cp "$(basename "$file" .sh)" '/usr/local/sbin'
    done
fi
