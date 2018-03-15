" NOTE: This file is ignored by gonvim!

if WINDOWS()
    GuiFont Dina:h8
"elseif $QT == 'true'
else
    GuiFont DinaPowerline:h8
endif


GuiLinespace 1
"augroup GuiSettings
    "autocmd BufEnter GuiLinespace 1
"augroup END

"let g:nvim_qt = 1
"let g:airline_left_sep='›'  " Slightly fancier than '>'
"let g:airline_right_sep='‹' " Slightly fancier than '<'
"let g:airline_section_z = "%p%%%{g:airline_symbols.linenr}%3l/%L :%v"
