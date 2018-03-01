
precmd() {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 2 ))

    # Truncate the path if it's too long.
    #promptsize=${#${(%):---%n--%~}}
    #pwdsize=${#${(%):-%~}}
    local leadersize=${#${(%):---%n--}}
    local pwdmax
    (( pwdmax = COLUMNS - leadersize ))
    _pwdStr="%${pwdmax}<…<%~ %<<"

    _Char="%(!.#.$)"

    if [[ $TERM == 'linux' ]] && [[ $COLUMNS -gt 100 ]]; then
        _EndPrompt="%(!.#.$)$_NoColor "
    else
        _EndPrompt="\n%(!.#.$)$_NoColor "
    fi
    
    _Fillbar=""
    _Fillbar="\${(l.${TERMWIDTH}..${_Hbar}.)}"
}


setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -n "\ek$CMD\e\\"
    fi
}


setprompt () {
    # Need this so the prompt will work.
    setopt prompt_subst

    # See if we can use colors.
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
        colors
    fi
    for color in Red Green Yellow Blue Magenta Cyan White; do
        eval _Set_b$color='%{$fg_bold[${(L)color}]%}'
        eval _Set_$color='%{$fg_no_bold[${(L)color}]%}'
    done
    #done
    _NoColor="%{$terminfo[sgr0]%}"

    # See if we can use extended characters to look nicer.
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    _Set_Charset="%{$terminfo[enacs]%}"
    _ShiftIn="%{$terminfo[smacs]%}"
    _ShiftOut="%{$terminfo[rmacs]%}"
    _Hbar=${altchar[q]:--}
    _ulCorner=${altchar[l]:--}
    _llCorner=${altchar[m]:--}
    _lrCorner=${altchar[j]:--}
    _urCorner=${altchar[k]:--}
    
    # Decide if we need to set titlebar text.
    #case $TERM in
        #xterm*)
            #_Titlebar=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
            #;;
        #screen)
            #_Titlebar=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
            #;;
        #*)
            #_Titlebar=''
            #;;
    #esac
    
    ## Decide whether to set a screen title
    #if [[ "$TERM" == "screen" ]]; then
        #_Stitle=$'%{\ekzsh\e\\%}'
    #else
        #_Stitle=''
    #fi
    
    ###
    # Finally, the prompt.

#    PROMPT='\
#$_Set_Charset$_Set_bBlue$_ShiftIn\
#$_ulCorner${(e)_Fillbar}$_urCorner$_ShiftOut\

#$_Set_bBlue$_ShiftIn$_llCorner($_ShiftOut\
#%(?..$_Set_Red%?$_Set_bBlue:)\
#$_Set_Green%(!.%SROOT%s.%n)${_Set_Yellow}@$_Set_Green%M$_Set_bBlue%)\
#$_Set_White:$_Set_Magenta%$_Pwdlen<...<%~%<<\
#%(!.$_Set_bRed.$_Set_White)$_ShiftOut
#$_Char$_NoColor '


    PROMPT='\
$_Set_Charset$_Set_bBlue$_ShiftIn\
$_ulCorner${(e)_Fillbar}$_urCorner$_ShiftOut\

$_Set_bBlue$_ShiftIn$_llCorner($_ShiftOut\
%(?..$_Set_Red%?$_Set_bBlue:)\
$_Set_Green%(!.%SROOT%s.%n)$_Set_bBlue%) \
$_Set_Magenta$_pwdStr\
%(!.$_Set_bRed.$_NoColor)$_ShiftOut\
$_EndPrompt'

    PS2='$_Set_bBlue($_Set_Green%_$_Set_bBlue)$_NoColor > '
}

setprompt
