function precmd {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 2 ))

    ###
    # Truncate the path if it's too long.
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}
    
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
	    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
	#PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
	PR_FILLBAR="\${(l.${TERMWIDTH}..${PR_HBAR}.)}"
    fi

    ###
    # Get APM info.

    if which ibam > /dev/null; then
	PR_APM_RESULT=`ibam --percentbattery`
    elif which apm > /dev/null; then
	PR_APM_RESULT=`apm`
    fi
    PR_CHAR="%(!.#.$)"
}


setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
	local CMD=${1[(wr)^(*=*|sudo|-*)]}
	echo -n "\ek$CMD\e\\"
    fi
}


setprompt () {
    ###
    # Need this so the prompt will work.
    setopt prompt_subst

    ###
    # See if we can use colors.
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
    fi
    #for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	#eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	#eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	#(( count = $count + 1 ))
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval SET_B_$color='%{$fg_bold[${(L)color}]%}'
        eval SET_$color='%{$fg_no_bold[${(L)color}]%}'
    done
    #done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"


    ###
    # See if we can use extended characters to look nicer.
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    
    ###
    # Decide if we need to set titlebar text.
    case $TERM in
	xterm*)
	    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	screen)
	    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac
    
    
    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
	PR_STITLE=$'%{\ekzsh\e\\%}'
    else
	PR_STITLE=''
    fi
    
    
    ###
    # APM detection
    if which ibam > /dev/null; then
	PR_APM='$PR_RED${${PR_APM_RESULT[(f)1]}[(w)-2]}%%(${${PR_APM_RESULT[(f)3]}[(w)-1]})$PR_LIGHT_BLUE:'
    elif which apm > /dev/null; then
	PR_APM='$PR_RED${PR_APM_RESULT[(w)5,(w)6]/\% /%%}$PR_LIGHT_BLUE:'
    else
	PR_APM=''
    fi
    
    
    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$SET_B_BLUE$PR_SHIFT_IN\
$PR_ULCORNER${(e)PR_FILLBAR}$PR_URCORNER$PR_SHIFT_OUT\

$SET_B_BLUE$PR_SHIFT_IN$PR_LLCORNER$PR_SHIFT_OUT(\
%(?..$SET_RED%?$SET_B_BLUE:)\
$SET_GREEN%(!.%SROOT%s.%n$SET_WHITE:\
$SET_MAGENTA%$PR_PWDLEN<...<%~%<<)$SET_B_BLUE)\
%(!.$SET_B_RED.$SET_WHITE)$PR_SHIFT_OUT $PR_CHAR$PR_NO_COLOUR '


    PS2='$SET_B_BLUE($SET_GREEN%_$SET_B_BLUE)$PR_NO_COLOUR > '
}

setprompt
