{
    __get_first_component_only() {
        echo "$1"
    }
    ps_cmd=$(ps --no-headers -ocmd -p$$)
    cmdnam=$(__get_first_component_only $ps_cmd)

    if { [ "$cmdnam" = 'dash' ] || \
         [ "$cmdnam" = 'sh' ]; }
    then
        if [ -e "${HOME}/.aliases" ]; then
            . "${HOME}/.aliases"
        fi
        set -E
    fi
    unset ps_cmd cmdnam
}

export PATH="$HOME/.cargo/bin:$PATH"
