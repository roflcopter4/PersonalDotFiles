# Filename:      zshenv
# Purpose:       system-wide .zshenv file for zsh(1)
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2.
################################################################################
# This file is sourced on all invocations of the shell.
# It is the 1st file zsh reads; it's read for every shell,
# even if started with -f (setopt NO_RCS), all other
# initialization files are skipped.
#
# This file should contain commands to set the command
# search path, plus other important environment variables.
# This file should not contain commands that produce
# output or assume the shell is attached to a tty.
#
# Notice: .zshenv is the same, execpt that it's not read
# if zsh is started with -f
#
# Global Order: zshenv, zprofile, zshrc, zlogin
################################################################################

if [[ -o interactive ]]; then
    [[ -f /etc/profile ]] && source /etc/profile
    [[ -r /etc/environment ]] && source /etc/environment

    # NO FUCKING MANPATHS
    [[ -n "$MANPATH" ]] && unset MANPATH
fi

# Get global operating system ID file. If you didn't make one, then MAKE ONE.
if [[ -f /etc/SYSID ]]; then
    export SYSID=$(cat /etc/SYSID)
elif [[ -f /usr/local/etc/SYSID ]]; then
    export SYSID=$(cat /usr/local/etc/SYSID)
elif [[ -f "${HOME}/.SYSID" ]]; then
    export SYSID=$(cat "${HOME}/.SYSID")
elif [[ -o interactive ]]; then
    echo "DEFINE SYSID YOU LAZY PRICK"
fi

# set environment variables (important for autologin on tty)
export HOSTNAME=${HOSTNAME:-$(hostname)}
export PAGER='less'
export EDITOR='nvim'

# make sure /usr/bin/id is available
if [[ -x /usr/bin/id ]] ; then
    [[ -z "$USER" ]]          && export USER=$(/usr/bin/id -un)
    [[ $LOGNAME == LOGIN ]] && LOGNAME=$(/usr/bin/id -un)
fi

if [[ -o interactive ]]; then
    typeset -a lp; lp=( ${^path}/lesspipe(N) )
    if (( $#lp > 0 )) && [[ -x $lp[1] ]] ; then
        export LESSOPEN="|lesspipe %s"
    elif [[ -x /usr/bin/lesspipe.sh ]] ; then
        export LESSOPEN="|lesspipe.sh %s"
    fi
    command -v highlight &>/dev/null && export LESSCOLORIZER="highlight -t8 --out-format=truecolor --force --style=molokai"
    unset lp
    export READNULLCMD=${PAGER:-/usr/bin/pager}
    # MAKEDEV should be usable on udev as well by default:
    export WRITE_ON_UDEV=yes
fi


# if [[ "$(uname)" == 'Linux' ]]; then
#     export MALLOC_PERTURB_=$(( (RANDOM % 255) + 1 ))
# fi


case "$SYSID" in
    'slackware')
        export path=( "${HOME}"/.local/bin /usr/local/sbin /usr/sbin /sbin /usr/local/bin /usr/bin /bin /usr/games /usr/lib64/kde4/libexec /usr/lib64/qt/bin /usr/share/texmf/bin )
        ;;
    'gentoo'|'laptop-gentoo')
        local adtl_path=( )
        [[ -d '/usr/mnt/bin' ]] && adtl_path+='/usr/mnt/bin'
        [[ -d '/usr/share/perl6/site/bin' ]] && adtl_path+='/usr/share/perl6/site/bin'
        #[[ -d "${HOME}/.local/lib/node_modules/.bin" ]] && adtl_path+="${HOME}/.local/lib/node_modules/.bin"

        export path=( "${HOME}/.local/bin" /opt/bin "${adtl_path[@]}" /usr/lib/ccache/bin /usr/local/sbin /usr/local/bin /usr/x86_64-pc-linux-gnu/bin /opt/clang-bin /usr/sbin /usr/bin /sbin /bin )
        export PT=/var/tmp/portage
        export LESSOPEN="|/usr/local/sbin/lesspipe.sh %s"
        alias less2="LESSOPEN='|/usr/bin/lesspipe %s' less"
        ;;
    'FreeBSD')
        export path=( "${HOME}/.local/bin" /usr/local/libexec/ccache /opt/bin /opt/clang-bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin )
        ;;
    'DragonFly')
        export path=( "${HOME}/.local/bin" /opt/bin /opt/clang-bin /usr/local/llvm-devel/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /usr/games /sbin /bin )
        ;;
    'ArchLinux'|'Artix')
        export path=( "${HOME}/.local/bin" "/usr/local/bin" $path "${HOME}/.gem/ruby/2.4.0/bin" )
        ;;
esac

#if [[ "$(uname)" == 'FreeBSD' ]]; then
#    export path=( "${HOME}/.local/bin" /usr/local/libexec/ccache /opt/bin /opt/clang-bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin )
#elif [[ "$(uname)" == 'DragonFly' ]]; then
#    export path=( /usr/local/llvm-devel/bin /usr/local/sbin /usr/local/bin /usr/pkg/sbin /usr/pkg/bin /usr/sbin /usr/bin /usr/games /sbin /bin "${HOME}/bin" )
#elif [[ "$(uname -r)" =~ 'ARCH' ]]; then
#    export path=( "${HOME}/.local/bin" "/usr/local/bin" $path "${HOME}/.gem/ruby/2.4.0/bin" )
#fi

export GOPATH=/opt/go
export path=( $path /opt/go/bin )

setopt no_global_rcs

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
