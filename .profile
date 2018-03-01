
if [ "$(basename $(ps -o comm= $$))" = 'dash' ] || \
   [ "$(basename $(ps -o comm= $$))" = 'sh' ]; then
    if [ -f ""$HOME"/.aliases" ]; then
        . ""$HOME"/.aliases"
    fi
fi
