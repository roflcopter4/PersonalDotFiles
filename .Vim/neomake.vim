scriptencoding utf-8
let s:neomake_automake_events = {}
"if get(g:, 'spacevim_lint_on_save', 0)
let s:neomake_automake_events['BufWritePost'] = {'delay': 0}
"endif

"if get(g:, 'spacevim_lint_on_the_fly', 0)
let s:neomake_automake_events['TextChanged'] = {'delay': 750}
let s:neomake_automake_events['TextChangedI'] = {'delay': 750}
"endif

if !empty(s:neomake_automake_events)
  try
    call neomake#configure#automake(s:neomake_automake_events)
  catch /^Vim\%((\a\+)\)\=:E117/
  endtry
endif
" 1 open list and move cursor 2 open list without move cursor
let g:neomake_open_list = 2
let g:neomake_verbose = 1
let g:neomake_java_javac_delete_output = 0
let g:neomake_error_sign =  {
      \ 'text': '✖',
      \ }
      "\ 'texthl': (g:spacevim_colorscheme ==# 'gruvbox' ? 'GruvboxRedSign' : 'error'),
let g:neomake_warning_sign = {
      \ 'text': '➤',
      \ }
      "\ 'texthl': (g:spacevim_colorscheme ==# 'gruvbox' ? 'GruvboxYellowSign' : 'todo'),
let g:neomake_info_sign = {
      \ 'text': '~',
      \ }
      "\ 'texthl': (g:spacevim_colorscheme ==# 'gruvbox' ? 'GruvboxYellowSign' : 'todo'),
" vim:set et sw=2:


let g:neomake_c_newgcc_maker = {
        \'errorformat': '%-G%f:%s:,%-G%f:%l: %#error: %#(Each undeclared identifier is reported only%.%#,%-G%f:%l:'
                     \. ' %#error: %#for each function it appears%.%#,%-GIn file included%.%#,%-G %#from %f:%l\,,%f:%l:%c: %trror: %m,%f:%l:%c: %tarning:'
                     \. ' %m,%I%f:%l:%c: note: %m,%f:%l:%c: %m,%f:%l: %trror: %m,%f:%l: %tarning: %m,%I%f:%l: note: %m,%f:%l: %m',
        \ 'args': ['-fsyntax-only', '-Wall', '-Wextra', '-I./', '-I..', '-Iinc', '-Iinclude', ],
        \ 'exe': 'gcc'
\ }

let g:neomake_c_enabled_makers = ['clangtidy', 'cppcheck', 'newgcc']
