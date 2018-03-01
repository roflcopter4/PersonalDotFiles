
###############################################################################

### PROMPT ###

function precmd {
    #TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
    # Truncate the path if it's too long.
    PR_FILLBAR=""
    PR_PWDLEN=""
    promptsize=${#${(%):---(%n)-----}}
    pwdsize=${#${(%):-%~}}
    if [[ "$promptsize + $pwdsize" -gt ($TERMWIDTH/2) ]]; then
          ((PR_PWDLEN=(($TERMWIDTH - $promptsize)/2) ))
    fi
    PR_FILLBAR="\${(l.(($TERMWIDTH - 5))..${PR_HBAR}.)}"
    PR_CHAR="%(!.#.$)"
}


setprompt () {
    # Need this so the prompt will work.
    setopt prompt_subst
    # See if we can use colors.
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
        colors
    fi

    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval SET_B_$color='%{$fg_bold[${(L)color}]%}'
        eval SET_$color='%{$fg_no_bold[${(L)color}]%}'
    done


    PR_NO_COLOUR="%{$terminfo[sgr0]%}"
    # See if we can use extended characters to look nicer.
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    #PR_SHIFT_IN="%{%"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    #if [[ $TTY == *'tty'* ]] ; then
        #PR_HBAR=${altchar[]:--}
    #else
        PR_HBAR='─'
    #fi
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_URCORNER=${altchar[k]:--}
    if [ "$IsCmderStr" = 'ConEmu found!'$'\r' ]; then
        Extra_HBAR="$PR_HBAR""$PR_HBAR"
        #echo yes
    else
        Extra_HBAR="$PR_HBAR""$PR_HBAR""$PR_HBAR"
        #echo no
    fi

    # Finally, the prompt.
    PROMPT='$SET_B_BLUE$PR_SHIFT_IN$PR_ULCORNER$PR_SHIFT_OUT\
$Extra_HBAR${(e)PR_FILLBAR}$PR_HBAR$PR_SHIFT_IN$PR_URCORNER$PR_SHIFT_OUT
$PR_SHIFT_IN$PR_LLCORNER$PR_SHIFT_OUT\
(%(?..$SET_RED%?$SET_B_BLUE:)\
$SET_GREEN%(!.%SROOT%s.%n$SET_WHITE:\
$SET_MAGENTA%$PR_PWDLEN<...<%~%<<)$SET_B_BLUE)\
%(!.$SET_B_RED.$SET_WHITE)$PR_SHIFT_OUT $PR_CHAR\
$PR_NO_COLOUR '

    PS2='$SET_B_BLUE($SET_GREEN%_$SET_B_BLUE)$PR_NO_COLOUR > '
}
setprompt

## PROMPT ##

###############################################################################
