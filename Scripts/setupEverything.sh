#!/bin/sh

printf -- '-----  Setting up Vim.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupVim.sh"

printf -- '\n-----  Linking all dotfiles.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupDotfiles.sh" "$1"

printf -- '\n-----  Linking bin scripts.  -----\n\n'
"$HOME/personaldotfiles/Scripts/Setup/setupBinScripts.sh" "$1"

# printf -- '\n----- Linking perl scripts -----\n\n'
# echo 'Linking mktar'
# ln -sf "${HOME}/personaldotfiles/Scripts/perl/mktar.pl"        "${HOME}/.local/bin/mktar"
# echo 'Linking clang-format'
# ln -sf "${HOME}/personaldotfiles/Scripts/perl/clang-format.pl" "${HOME}/.local/bin/clang-format"
# echo 'Linking mpip'
# ln -sf "${HOME}/personaldotfiles/Scripts/perl/my_gpip.pl.pl"   "${HOME}/.local/bin/mpip"

if [ -x '/bin/fish' ]; then
    printf -- '\n-----  Setting up fish -----\n\n'
    "$HOME/personaldotfiles/Scripts/Setup/setupFish.sh"
fi


printf -- '\n----- Some miscalaneous config --\n\n'

if grep -q -Er '^\s*compinit (-[^C])+ [^-]' "${HOME}/.zplug/"*
then
    grep -Er -lZ '^\s*compinit (-[^C])+ [^-]' "${HOME}/.zplug/"* | \
        xargs -0 perl -pi -e 's/^(\s*compinit(?: -[^C])*)(?!-[C])( [^- ])/$1 -C$2/'
fi

if ! [ -f "${HOME}/.config/terminator/config" ]; then
    mkdir -p "${HOME}/.config/terminator"
    ln -sf "${HOME}/personaldotfiles/dotconfig/terminator/config" "${HOME}/.config/terminator/"
fi

if ! [ -f "${HOME}/.config/xfce4/terminal/terminalrc" ]; then
    mkdir -p "${HOME}/.config/xfce4/terminal"
    ln -sf "${HOME}/personaldotfiles/dotconfig/xfce4/terminal/"* "${HOME}/.config/xfce4/terminal/"
fi

if ! [ -d "${HOME}/random" ]; then
    command -v 'git' >/dev/null 2>&1 && git clone 'https://github.com/roflcopter4/random' "${HOME}/random"
fi

ln -sf "${HOME}/random/code/perl/xtar/Xtar-41.pl" "${HOME}/.local/bin/xtar"
