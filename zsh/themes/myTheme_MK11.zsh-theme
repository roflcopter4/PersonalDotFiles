
precmd() {
    local TERMWIDTH=0
    if [[ $(uname) == 'DragonFly' ]]; then
	(( TERMWIDTH = ${COLUMNS} - 3 ))
    else
	(( TERMWIDTH = ${COLUMNS} - 2 ))
    fi

    # Truncate the path if it's too long.
    local leadersize=${#${(%):---%n-%m--}}
    local pwdmax=0
    (( pwdmax = COLUMNS - leadersize ))
    _pwdStr="%${pwdmax}<…<%~ %<<"

    float fPromptWidth=${#${(%):---%n-%m--%~---}}
    float fTermWidth=${COLUMNS}
    float fRatio
    local FreeSpace
    (( fRatio = fPromptWidth / fTermWidth ))
    (( FreeSpace = COLUMNS - fPromptWidth ))
    
    if ! [[ $(uname) == 'FreeBSD' ]] && [[ $(uname) != 'DragonFly' ]]; then
        if [[ $fRatio -lt 0.33333 ]] && [[ $FreeSpace -gt 60 ]]; then
            _ThirdLine=''
        else
            _ThirdLine="
"
        fi
    fi

    _Char="%(!.#.$)"
    
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


MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
vi_mode_prompt_info() {
    echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
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
#    typeset -A altchar
#    set -A altchar ${(s..)terminfo[acsc]}
#    _Set_Charset="%{$terminfo[enacs]%}"
#    _ShiftIn="%{$terminfo[smacs]%}"
#    _ShiftOut="%{$terminfo[rmacs]%}"
#    _Hbar='-'
#    _ulCorner=${altchar[l]:--}
#    _llCorner=${altchar[m]:--}
#    _lrCorner=${altchar[j]:--}
#    _urCorner=${altchar[k]:--}
    _ulCorner='/'
    _urCorner='\'
    _llCorner='\'
    _Hbar='-'
    
    PROMPT='\
${_Set_bBlue}${_ulCorner}${(e)_Fillbar}${_urCorner}\

${_llCorner}(%(?..${_Set_Red}%?${_Set_bBlue}:)\
%(!.${_Set_Red}root%s.${_Set_Green}%n)${_Set_Blue}@${_Set_Yellow}%m\
${_Set_bBlue}%) ${_Set_Magenta}${_pwdStr}\
${_ThirdLine}${_Set_White}${_Char} '

#    PROMPT='\
#$_Set_Charset$_Set_bBlue$_ShiftIn\
#$_ulCorner${(e)_Fillbar}$_urCorner$_ShiftOut\
#
#$_Set_bBlue$_ShiftIn$_llCorner($_ShiftOut\
#%(?..$_Set_Red%?$_Set_bBlue:)\
#%(!.${_Set_Red}root%s.${_Set_Green}%n)$_Set_Blue@$_Set_Yellow%m$_Set_bBlue%) \
#$_Set_Magenta$_pwdStr\
#%(!.$_NoColor.$_NoColor)$_ShiftOut$_ThirdLine\
#${_NoColor}${_Char} '

#    PS2='$_Set_bBlue($_Set_Green%_$_Set_bBlue)$_NoColor > '
    PS2=''

    #RPROMPT=""$_Set_bBlue"("$_Set_Green"%D{%K:%M %p}"$_Set_bBlue")"$_NoColor""

    RPS1='$(vi_mode_prompt_info)'

}

setprompt
