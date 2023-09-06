" NOTE: This file is ignored by gonvim!

let s:linespace = 3

if exists('g:GtkGuiLoaded')
    call rpcnotify(1, 'Gui', 'Font', 'dina ttf 8')
    call rpcnotify(1, 'Gui', 'Linespace', string(s:linespace))
    call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
    call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
    call rpcnotify(1, 'Gui', 'Option', 'Cmdline', 0)
else
    " set mouse=a

    if exists(':GuiFont')
        if OSX()
        elseif WINDOWS()
            GuiFont Dina:h8
            execute 'GuiLinespace ' . s:linespace
        else
            " GuiFont Dina:h10
            GuiFont Dina:h7
            execute 'GuiLinespace ' . s:linespace
        endif
    endif
    if exists(':GuiTabline')
        GuiTabline 0
    endif
    if exists(':GuiPopupmenu')
        GuiPopupmenu 1
    endif
    if exists(':GuiScrollBar')
        GuiScrollBar 1
    endif

    try 
        GuiAdaptiveColor 1
    catch //
    endtry
    try
        GuiAdaptiveStyle 1
    catch //
    endtry

    " Right Click Context Menu (Copy-Cut-Paste)
    nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
    inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
    xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
    snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv
endif

" GuiLinespace 2
"augroup GuiSettings
    "autocmd BufEnter GuiLinespace 1
"augroup END

"let g:nvim_qt = 1
"let g:airline_left_sep='›'  " Slightly fancier than '>'
"let g:airline_right_sep='‹' " Slightly fancier than '<'
"let g:airline_section_z = "%p%%%{g:airline_symbols.linenr}%3l/%L :%v"
