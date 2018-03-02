#!/bin/sh

printf -- '-----  Setting up Vim.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupVim.sh"

printf -- '\n-----  Linking all dotfiles.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupDotfiles.sh" "$1"

printf -- '\n-----  Linking bin scripts.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupBinScripts.sh" "$1"

if [ "$(command -v fish)" ]; then
    printf -- '\n-----  Setting up fish -----\n\n'
    "$HOME/personaldotfiles/Scripts/Setup/setupFish.sh"
fi

if grep -q -Er '^\s*compinit (-[^C])+ [^-]' "${HOME}/.zplug/"*; then
    grep -Er -lZ '^\s*compinit (-[^C])+ [^-]' "${HOME}/.zplug/"* | \
        xargs -0 perl -pi -e 's/^(\s*compinit(?: -[^C])*)(?!-[C])( [^- ])/$1 -C$2/'
fi

mkdir -p "${HOME}/.config/terminator"
ln -sf "${HOME}/personaldotfiles/dotconfig/terminator/config" "${HOME}/.config/terminator/"

mkdir -p "${HOME}/.config/xfce4/terminal"
ln -sf "${HOME}/personaldotfiles/dotconfig/xfce4/terminal/"* "${HOME}/.config/xfce4/terminal/"

command -v 'git' >/dev/null 2>&1 && git clone 'https://github.com/roflcopter4/random' "${HOME}/random"
