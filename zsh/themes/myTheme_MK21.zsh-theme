
# precmd() { }
# setprompt () { }

# export fpath=( "${HOME}/personaldotfiles/zsh/themes/autoload" $fpath )
autoload -R "${HOME}/personaldotfiles/zsh/themes/autoload/precmd"
autoload -R "${HOME}/personaldotfiles/zsh/themes/autoload/setprompt"
setprompt
