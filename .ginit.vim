" NOTE: This file is ignored by gonvim!

if exists('g:GtkGuiLoaded')
    call rpcnotify(1, 'Gui', 'Font', 'dina ttf 8')
    call rpcnotify(1, 'Gui', 'Linespace', '1')
    call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
    " call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
    " call rpcnotify(1, 'Gui', 'Option', 'Cmdline', 0)
else
    if WINDOWS()
        GuiFont Dina:h8
    else
        " GuiFont DinaPowerline:h8
        " GuiFont Droid\ Sans\ Mono:h10
        GuiFont Dina:h7
        GuiLinespace 1
    endif
endif


" GuiLinespace 2
"augroup GuiSettings
    "autocmd BufEnter GuiLinespace 1
"augroup END

"let g:nvim_qt = 1
"let g:airline_left_sep='›'  " Slightly fancier than '>'
"let g:airline_right_sep='‹' " Slightly fancier than '<'
"let g:airline_section_z = "%p%%%{g:airline_symbols.linenr}%3l/%L :%v"
