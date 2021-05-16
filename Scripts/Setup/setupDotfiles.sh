#!/bin/sh

[ "$1" = 'omz' ] && OMZ='.omz'

ln -sf "${HOME}/personaldotfiles/.zshrc"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.zshenv"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.zshrc.local${OMZ}"	"${HOME}/.zshrc.local"
ln -sf "${HOME}/personaldotfiles/.zshrc.pre${OMZ}"	"${HOME}/.zshrc.pre"
ln -sf "${HOME}/personaldotfiles/.keephack"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.spacemacs"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.aliases"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.nexrc"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.nexrc"		"${HOME}/"
ln -sf "${HOME}/personaldotfiles/.clang-format"		"${HOME}/"

[ -d "${HOME}/.emacs.d" ] || git clone 'https://github.com/syl20bnr/spacemacs' "${HOME}/.emacs.d"
[ -d "${HOME}/.zplug" ]   || git clone 'https://github.com/zplug/zplug'        "${HOME}/.zplug"

# vim: nolist
