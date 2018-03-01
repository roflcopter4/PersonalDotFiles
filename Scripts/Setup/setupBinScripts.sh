#!/bin/sh

mkdir -p "$HOME/.local/bin"
"$HOME/personaldotfiles/Scripts/misc/ln_sh_scripts.sh" "$HOME/personaldotfiles/Scripts/homebin" "$HOME/.local/bin"

# Neovim-QT
if [ "$(uname)" = 'Cygwin' -o "$(uname)" = 'Msys' ]; then
    ln -sf "$HOME/personaldotfiles/Scripts/viRelated/run-win_nvim_qt.sh" "$HOME/.local/bin/vi"
else
    ln -sf "$HOME/personaldotfiles/Scripts/viRelated/run_vi.sh" "$HOME/.local/bin/gvi"
fi

if [ "$(uname)" = 'Linux' ]; then
    "$HOME/personaldotfiles/Scripts/misc/ln_sh_scripts.sh" "$HOME/personaldotfiles/Scripts/localbin" "/usr/local/bin"
fi
