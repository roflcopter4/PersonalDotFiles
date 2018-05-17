# Executed whenever the vi mode changes.
zle-keymap-select() {
    _VI_Mode="${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
    if [[ "$KEYMAP" != "$1" ]]; then
        _Mode_Swap=1
    fi
    zle reset-prompt
}
zle -N zle-keymap-select

# This little routine forces the vi mode to be updated for every prompt
_Get_VI_Mode() {
    builtin echo -n "$_VI_Mode"
}

autoload -R "${HOME}/personaldotfiles/zsh/themes/autoload/precmd"
autoload -R "${HOME}/personaldotfiles/zsh/themes/autoload/setprompt"
setprompt
