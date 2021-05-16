" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker

" ======================================================================================================
" Environment

" Identify platform
if has('unix') && !has('macunix') && !has('win32unix')
    let g:_platform = substitute(system('uname'), "\n", '', '')
    if g:_platform ==# 'FreeBSD' || g:_platform ==# 'DragonFly'
        let g:_platform = 'BSD'
    endif
else
    let g:_platform = 'OTHER'
endif

func! LINUX()
    return (has('unix') && !has('macunix') && g:_platform ==# 'Linux')
endf
func! WINDOWS()
    return (has('win16') || has('win32') || has('win64'))
endf
func! OSX()
    return has('macunix')
endf
func! CYGWIN()
    return has('win32unix')
endf
func! WIN_OR_CYG()
    return WINDOWS() || CYGWIN()
endf
func! BSD()
    return g:_platform ==# 'BSD'
endf

" Basics
set nocompatible
if WINDOWS()
    set shell=cmd
else
    if executable('/bin/dash')
        set shell=/bin/dash
    else
        set shell=/bin/sh
    endif
endif

if &runtimepath =~# 'oni'
    let g:ONI = 1
    let g:ONI_HideStatusBar = 1
endif
if WINDOWS()
    let g:spf13_consolidated_directory='C:/Vim/Vim_Misc_Data/'
    if exists('g:ONI')
        let g:spf13_consolidated_directory = g:spf13_consolidated_directory . 'ONI/'
    endif
endif


if !($TERM ==# 'linux' || $TERM ==# 'screen' || ($CONEMUPID && !$NVIM_QT) || $SYSID ==# 'FreeBSD')
        \ && !has('nvim')
    set encoding=utf-8
    setglobal fileencoding=utf-8
endif


" ======================================================================================================
" Set some general configuration options for what little remains of spf13

let g:spf13_writing = 1
let g:spf13_keep_trailing_whitespace = 1
" let g:spf13_no_omni_complete = 1
let g:spf13_no_fastTabs = 1
let g:spf13_no_restore_cursor = 1
let g:spf13_no_autochdir = 1
"let g:spf13_no_easyWindows = 0


" ======================================================================================================
" C/C++ Enhanced highlight. Must come before the plugin is loaded.

let g:cpp_class_scope_highlight = 1
let g:cpp_class_decl_highlight = 1
" let g:cpp_member_variable_highlight = 1
" let g:cpp_experimental_simple_template_highlight = 1
" let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1

" ======================================================================================================
" Some general config stuff

let g:mapleader = ' '


" ======================================================================================================
" Some colorscheme setup that must come before the plugin is loaded.

let g:myMolokai_BG        = 'darker'
"let g:myMolokai_BG       = 'custom'
"let g:myMolokai_CustomBG = '#272822' " ## Monokai_Brown
"let g:myMolokai_CustomBG = '#000000' " ## BLACK_
"let g:myMolokai_CustomBG = '#080808' " ## NEAR_BLACK

"let g:myMolokai_FG = 'other'
"let g:myMolokai_FG = 'custom'
"let g:myMolokai_CustomFG =

let g:myMolokaiComment         = 'custom'
"let g:myMolokaiComment        = 'shiny'
"let g:myMolokaiComment        = 'comment_grey'
"let g:myMolokaiComment_Custom = '#70F0F0'
let g:myMolokaiComment_Custom  = '#5F87AF'

let g:myNova_BG = '#1B1D1E'


" ======================================================================================================
" Whitelisted filetypes for operator highlighting.

" Set the following to avoid loading the plugin
let g:ophigh_filetypes = [ 'c', 'cpp', 'rust', 'lua', 'go', 'x4c' ]

"let g:ophigh_highlight_link_group = 'Operator'
let g:ophigh_highlight_link_group = 'OperatorChars'
"let g:ophigh_color_gui = '#d33682'
"let g:ophigh_color_gui = '#42A5F5'  " Lightish-blue

"let g:negchar_highlight_link_group = 'NegationChar'
"let g:negchar_color_gui = '#66BB6A'
let g:negchar_color_gui = '#f92672'
"let g:negchar_color_gui = '#d33682'

"let g:structderef_highlight_link_group = 'Operator'
let g:structderef_color_gui = '#42A5F5'


" ======================================================================================================
" ======================================================================================================
" =====  Plugins
" ======================================================================================================
" ======================================================================================================


execute 'source ' . fnameescape(expand('~/.vimplugins'))


" ======================================================================================================
" ======================================================================================================
" =====  Functions & Commands
" ======================================================================================================
" ======================================================================================================

" Initialize directories
function! InitializeDirectories(consolidate)
    let l:parent = $HOME
    let l:prefix = 'vim'
    let l:dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }

    if has('persistent_undo')
        let l:dir_list['undo'] = 'undodir'
    endif

    if a:consolidate !=# ''
        let l:common_dir = l:parent . '/.' . a:consolidate
        if !isdirectory(l:common_dir)
            call mkdir(l:common_dir)
        endif
        let l:common_dir .= '/'
    else
        let l:common_dir = l:parent . '/.' . l:prefix
    endif

    for [l:dirname, l:settingname] in items(l:dir_list)
        let l:directory = l:common_dir . l:dirname . '/'
        if exists('*mkdir')
            if !isdirectory(l:directory)
                call mkdir(l:directory)
            endif
        endif
        if !isdirectory(l:directory)
            echo 'Warning: Unable to create backup directory: ' . l:directory
            echo 'Try: mkdir -p ' . l:directory
        else
            let l:directory = substitute(l:directory, ' ', '\\\\ ', 'g')
            execute 'set ' . l:settingname . '=' . fnameescape(l:directory)
        endif
    endfor
endfunction

if has('nvim')
    call InitializeDirectories('nvim_cache')
else
    call InitializeDirectories('vim_cache')
endif

" Initialize NERDTree as needed
function! NERDTreeInitAsNeeded()
    redir => l:bufoutput
    buffers!
    redir END
    let l:idx = stridx(l:bufoutput, 'NERD_tree')
    if l:idx > -1
        NERDTreeMirror
        NERDTreeFind
        wincmd l
    endif
endfunction

" Strip whitespace
function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let l:_s=@/
    let l:l = line('.')
    let l:c = col('.')
    " do the business:
    call execute('%s/\s\+$//e')
    " clean up: restore previous search history, and cursor position
    let @/=l:_s
    call cursor(l:l, l:c)
endfunction

" Shell command
function! s:RunShellCommand(cmdline)
    botright new

    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nowrap
    setlocal filetype=shell
    setlocal syntax=shell

    call setline(1, a:cmdline)
    call setline(2, substitute(a:cmdline, '.', '=', 'g'))
    execute 'silent $read !' . escape(a:cmdline, '%#')
    setlocal nomodifiable
    1
endfunction
command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
" e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %


" ================================================================================================================
" ================================================================================================================
" ================================================================================================================
" General


if exists('g:spf13_writing')
    " TextObj Sentence
    augroup textobj_sentence
        autocmd!
        autocmd FileType markdown call textobj#sentence#init()
        autocmd FileType textile call textobj#sentence#init()
        autocmd FileType text call textobj#sentence#init()
    augroup END
    " TextObj Quote
    augroup textobj_quote
        autocmd!
        autocmd FileType markdown call textobj#quote#init()
        autocmd FileType textile call textobj#quote#init()
        autocmd FileType text call textobj#quote#init({'educate': 0})
    augroup END
endif

" " OmniComplete
" if !exists('g:spf13_no_omni_complete')
"     if has('autocmd') && exists('+omnifunc')
"         autocmd Filetype *
"                     \if &omnifunc == "" |
"                     \setlocal omnifunc=syntaxcomplete#Complete |
"                     \endif
"     endif
"
"     " # Some convenient mappings
"     "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
"     "inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
"     inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
"     inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
"     inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
"     inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
"
"     " Automatically open and close the popup menu / preview window
"     au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
"     set completeopt=menu,preview,longest
" endif
"
" " Normal Vim omni-completion
" if !exists('g:spf13_no_omni_complete')
"    " Enable omni-completion.
"    augroup spf13_omni_complete
"        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"        autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
"        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
"    augroup END
" endif

" Automatically switch to the current file directory when a new buffer is opened.
augroup spf13_autchdir
    autocmd BufEnter * if bufname("") !~# "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    " autocmd VimEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
augroup END

" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
" augroup no_revertcursor_git
    " au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
" augroup END

" Restore cursor to file position in previous editing session
" if !exists('g:spf13_no_restore_cursor')
"     function! ResCur()
"         if line("'\"") <= line('$')
"             silent! normal! g`"
"             return 1
"         endif
"     endfunction
"
"     augroup resCur
"         autocmd!
"         autocmd BufWinEnter * call ResCur()
"     augroup END
" endif

" Setting up the directories
set backup                  " Backups are nice ...
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

augroup misc_config
    " Remove trailing whitespaces and ^M chars
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql
                \ autocmd BufWritePre <buffer> if !exists('g:spf13_keep_trailing_whitespace')
                \ | call StripTrailingWhitespace() | endif

    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    "autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.
    autocmd BufNewFile,BufRead *.coffee set filetype=coffee
    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell
augroup END


" ----------------------------------------------------------------------------------------------------------------
" ----------------------------------------------------------------------------------------------------------------
" Vim UI

if has('cmdline_info')
    set ruler                   " Show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    " Show partial commands in status line and selected characters/lines in visual mode
    set showcmd
endif

if has('statusline') && !IsSourced('vim-airline') && !exists('g:ONI')
    set laststatus=2
    " Broken down into easily includeable segments
    set statusline=%<%f\                     " Filename
    set statusline+=\ [%{&ff}/%Y]            " Filetype
    set statusline+=\ [%{getcwd()}]          " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

" ================================================================================================================


"highlight clear SignColumn    " SignColumn should match background
"highlight clear LineNr        " Current line number row will have same background color in relative mode
"highlight clear CursorLineNr " Remove highlight color from current line number

"# Better Unix / Windows compatibility. #
set viewoptions=folds,options,cursor,unix,slash
set backspace=indent,eol,start


augroup LinterConfig
    autocmd BufEnter,BufNew,BufCreate,BufRead * setl signcolumn=yes
augroup END


set mouse=a                 " Automatically enable mouse usage
set mousehide               " Hide the mouse cursor while typing
set tabpagemax=30
set winminheight=0          " Windows can be 0 line high
set linespace=1

set shortmess+=filmnrxoOtT  " Abbrev. of messages (avoids 'hit enter')
set history=10000           " Store a ton of history (default is 20)
set hidden                  " Allow buffer switching without saving
" set iskeyword-=.            " '.' is an end of word designator
" set iskeyword-=#            " '#' is an end of word designator
"set iskeyword-=-           " '-' is an end of word designator

set showmode                " Display the current mode
set number                  " Line numbers on
set nospell
set showmatch               " Show matching brackets/parenthesis
set incsearch               " Find as you type search
set hlsearch                " Highlight search terms
set ignorecase
set smartcase               " Case sensitive when uc present

set autoindent              " Indent at the same level of the previous line
set smartindent             " Better autoindent
set cindent
set breakindent

set textwidth=80
set tabstop=8               " An indentation every four columns
set shiftwidth=4            " Use indents of 4 spaces
set softtabstop=4           " Let backspace delete indent
set expandtab               " Tabs are spaces, not tabs

set nojoinspaces            " Prevents inserting two spaces after punctuation on a join (J)
set splitright              " Puts new vsplit windows to the right of the current
set splitbelow              " Puts new split windows to the bottom of the current
set pastetoggle=<F12>       " pastetoggle (sane indentation on pastes)
set wrap
set whichwrap="b,s"
set nofoldenable            " Do not Auto fold code
set nocursorline            " Don't paint cursor line

set magic
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.

"set virtualedit=onemore        " Allow for cursor beyond last character
"set showbreak=>>>
set matchpairs+=<:>            " Match, to be used with %

"# Auto format comment blocks. #
"set comments=sl:/*,mb:*,elx:*/

"# Highlight problematic whitespace. #
set list
if &encoding ==# 'utf-8' || has('nvim')
    set listchars=tab:›\ ,extends:#,nbsp:.
    "set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
else
    set nolist
endif


set maxmempattern=2000000


" ================================================================================================================


set scrolloff=3

" if !exists('g:ONI')
"     set scrolloff=3
" else
"     command! OniConfig e C:/Users/Brendan/.oni/config.js
"     command! EditOniDefaults e C:/Vim/Oni/resources/app/vim/default/bundle/oni-vim-defaults/plugin/init.vim
"     " Some things imported from the official ONI defaults.
"     if g:ONI_HideStatusBar
"         set noshowmode
"         set noruler
"         set laststatus=0
"         set noshowcmd
"         set showtabline=0
"     endif
" endif


" ================================================================================================================
" ================================================================================================================
" Key (re)Mappings


" Easier moving in tabs and windows
" The lines conflict with the default digraph mapping of <C-K>
if !exists('g:spf13_no_easyWindows')
    nnoremap <C-J> <C-W>j
    nnoremap <C-K> <C-W>k
    nnoremap <C-L> <C-W>l
    nnoremap <C-H> <C-W>h
endif

" Wrapped lines goes down/up to next row, rather than next line in file.
" noremap j gj
" noremap k gk


" End/Start of line motion keys act relative to row/wrap width in the
" presence of `:set wrap`, and relative to line for `:set nowrap`.
" Default vim behaviour is to act relative to text line in both cases
" if !exists('g:spf13_no_wrapRelMotion') && !exists('g:ONI')
"     " Same for 0, home, end, etc
"     function! WrapRelativeMotion(key, ...)
"         let l:vis_sel=''
"         if a:0
"             let l:vis_sel='gv'
"         endif
"         if &wrap
"             execute 'normal!' l:vis_sel . 'g' . a:key
"         else
"             execute 'normal!' l:vis_sel . a:key
"         endif
"     endfunction
"
"     " Map g* keys in Normal, Operator-pending, and Visual+select
"     noremap $ :call WrapRelativeMotion("$")<CR>
"     noremap <End> :call WrapRelativeMotion("$")<CR>
"     noremap 0 :call WrapRelativeMotion("0")<CR>
"     noremap <Home> :call WrapRelativeMotion("0")<CR>
"     noremap ^ :call WrapRelativeMotion("^")<CR>
"     " Overwrite the operator pending $/<End> mappings from above to force inclusive motion with :execute normal!
"     onoremap $ v:call WrapRelativeMotion("$")<CR>
"     onoremap <End> v:call WrapRelativeMotion("$")<CR>
"     " Overwrite the Visual+select mode mappings from above to ensure the correct vis_sel flag is passed to function
"     vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
"     vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
"     vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
"     vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
"     vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
" endif

" " The following two lines conflict with moving to top and bottom of the screen.
" if !exists('g:spf13_no_fastTabs')
"     map <S-H> gT
"     map <S-L> gt
" endif
"
" Stupid shift key fixes
" if !exists('g:spf13_no_keyfixes')
"     command! -bang -nargs=* -complete=file E e<bang> <args>
"     command! -bang -nargs=* -complete=file W w<bang> <args>
"     command! -bang -nargs=* -complete=file Wq wq<bang> <args>
"     command! -bang -nargs=* -complete=file WQ wq<bang> <args>
"     command! -bang Wa wa<bang>
"     command! -bang WA wa<bang>
"     command! -bang Q q<bang>
"     command! -bang QA qa<bang>
"     command! -bang Qa qa<bang>
"     cmap Tabe tabe
" endif

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Code folding options
nmap <leader>f0 :set foldlevel=0<CR>
nmap <leader>f1 :set foldlevel=1<CR>
nmap <leader>f2 :set foldlevel=2<CR>
nmap <leader>f3 :set foldlevel=3<CR>
nmap <leader>f4 :set foldlevel=4<CR>
nmap <leader>f5 :set foldlevel=5<CR>
nmap <leader>f6 :set foldlevel=6<CR>
nmap <leader>f7 :set foldlevel=7<CR>
nmap <leader>f8 :set foldlevel=8<CR>
nmap <leader>f9 :set foldlevel=9<CR>

" Toggle highlighting of search terms with <leader>/.
nmap <silent> <leader>/ :set invhlsearch<CR>

" Find merge conflict markers
map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>


" ================================================================================================================
" Shortcuts

" Change Working Directory to that of the current file
" cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
if has('nvim') && executable('ksshaskpass')
    execute printf("cmap w!! w !SUDO_ASKPASS='%s' sudo tee %% >/dev/null", exepath('ksshaskpass'))
else
    cmap w!! w !sudo tee % >/dev/null
endif

" Some helpers to edit mode
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Adjust viewports to the same size
map <Leader>= <C-w>=

" Map <Leader>ff to display all lines with keyword under cursor and ask which one to jump to
" nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Easier horizontal scrolling
map zl zL
map zh zH


" ================================================================================================================
" ================================================================================================================
" Other

" Catch all for shitty terminals.
if $TERM ==# 'linux' || $TERM ==# 'screen' || ($CONEMUPID && !$NVIM_QT)
        \ || ($SYSID ==# 'FreeBSD' && $TERM ==# 'xterm')
    set notermguicolors
    colo default
    set background=dark
else
    if has('nvim')
        set linespace=1
    else
        scriptencoding utf-8
    endif

    set termguicolors

    if IsSourced('PersonalVimStuff')
        colo myMolokai4
    else
        colo chroma
        set background=dark
    endif

    if !has('nvim') && has('gui_running')
        set guifont=DinaPowerline\ 10
        set linespace=1
        set guioptions=agimrLt
        set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor
    endif
endif

" ================================================================================================================

set fileformats=unix,dos,mac

augroup MyCrap
    autocmd!
    autocmd BufRead *.py setlocal colorcolumn=0
    autocmd CompleteDone * pclose
augroup END

augroup PerlFix
    autocmd!
    autocmd BufEnter *.pl setlocal cindent smartindent autoindent indentexpr=
augroup END

function! FixPerl()
    setlocal nocindent
    setlocal smartindent
    setlocal autoindent
    setlocal indentexpr=
endfunction

" ================================================================================================================

"set background=dark
function! ToggleBG()
    let s:tbg = &background
    " Inversion
    if s:tbg ==# 'dark'
        set background=light
    else
        set background=dark
    endif
endfunction
noremap <leader>bg :call ToggleBG()<CR>

" Save changes to a buffer as a diff file, leaving the original file untouched.
command -nargs=1 Sdiff execute 'w !diff -au fnameescape(expand("%:p:S")) - > ' . "<args>"

function! ToggleList()
    if &list == 1
        set nolist
    else
        set list
    endif
endfunction


" ================================================================================================================
" ### MY MAPPINGS ###

nnoremap <leader>p "+p
nnoremap <leader>yy "+yy"*yy
vnoremap <leader>y "*y

nnoremap <leader>ww :w<CR>
nnoremap <leader>QA :qa!<CR>

nnoremap <leader>buf :buffers<CR>
command Config e $MYVIMRC
command Plugins :execute 'e '. fnameescape(expand("~/.vimplugins"))

nnoremap <leader>nl :call ToggleList()<CR>
nnoremap <leader>jj :pc<CR>
nnoremap <leader>k :pc<CR>

" ================================================================================================================
" Neovim Terminal Config

if has('nvim')
    " Leave insert mode by pressing esc twice
    tnoremap <esc><esc> <C-\><C-n>
    augroup TermNumberFix
        autocmd TermOpen * setlocal nonumber
    augroup END

    if !WIN_OR_CYG()
        let s:colorlist = ['#000000', '#cd0000', '#00cd00', '#cdcd00', '#0075ff', '#cd00cd',
                         \ '#00cdcd', '#e5e5e5', '#7f7f7f', '#ff0000', '#00ff00', '#ffff00',
                         \ '#0075ff', '#ff00ff', '#00ffff', '#ffffff']
        let s:i = 0
        while s:i < len(s:colorlist)
            call execute(printf('let g:terminal_color_%d = s:colorlist[%d]', s:i, s:i))
            let s:i += 1
        endwhile
    endif

    command! Term term 'zsh'
endif

" ================================================================================================================

" Some commands because I'm lazy
command! -nargs=1 -complete=help Vhelp :vert help <args>
command! -nargs=* -complete=customlist,man#complete Vman :vert Man <args>
cmap vhelp Vhelp
cmap VHelp Vhelp
cmap vman Vman
cmap VMan Vman

" ================================================================================================================

highlight link perlStringStartEnd	perlQuoteSE
" highlight link perlStatementRegexp	perlQuoteSE
" highlight link perlMatchStartEnd	perlQuoteSE
highlight link perlMatchStartEnd	perlMatchSE

" ================================================================================================================

" This makes sure vim knows that /bin/sh is not bash.
let g:is_posix = 1
let g:is_kornshell = 1
let g:perl_sub_signatures = 1
let g:c_gnu = 1

let g:gonvim_draw_split      = 1
let g:gonvim_draw_statusline = 0
let g:gonvim_draw_lint       = 1

let g:c_syntax_for_h = 1

highlight! link perlInline Exception

function! DoIfZeroRange() range
    let l:line1 = getline(a:firstline)
    let l:line2 = getline(a:lastline)
    if (l:line1 =~# '\v^[ ]*#[ ]*if 0$') && (l:line2 =~# '\v^[ ]*#[ ]*endif$')
        execute a:lastline.'d'
        execute a:firstline.'d'
    else
        call append(a:lastline, '#endif')
        call append(a:firstline - 1, '#if 0')
    endif
endfunction

command! -range IfZeroRange <line1>,<line2>call DoIfZeroRange()
noremap <silent> <leader>cf :IfZeroRange<CR>
command! RecacheRunetimepath call dein#recache_runtimepath()

nnoremap <leader>. /\v
nnoremap ,, @:
nnoremap <leader>aa :.Autoformat<CR>
nnoremap <leader>af :Autoformat<CR>
nnoremap <leader>sj <leader>ysVj{
vnoremap <leader>aa :Autoformat<CR>

nnoremap <leader>::<space> q:
nnoremap q: :

set textwidth=89

if has('nvim')
    if WINDOWS()
        let g:python_host_prog  = 'python2'
        let g:python3_host_prog = 'python3'
    else
        let g:python_host_prog  = 'python2'
        let g:python3_host_prog = 'python3.9'
    endif
    " let g:python_host_prog  = executable('pypy')  ? 'pypy'  : 'python2'
    " let g:python3_host_prog = executable('pypy3') ? 'pypy3' : 'python3'
    " let g:python_host_prog  = 'python2'
    " let g:python3_host_prog = 'python3'
    " let g:python_host_prog = 'python2'
else
        let g:python3_host_prog = 'python3'
endif


fu! ToggleOneMore()
    if &virtualedit ==# 'onemore'
        set virtualedit=
    else
        set virtualedit=onemore
    endif
endf
nnoremap <silent> <leader>ve :call ToggleOneMore()<CR>

func! BracesBeGone()
    NextFormatter
    Autoformat
    PreviousFormatter
    Autoformat
    try | execute '%s/^\s*$\n\(\s*\)else/\1else/' | catch /E486/ | endtry
endf
nnoremap <silent> <leader>ab :call BracesBeGone()<CR>

" let g:clipboard = {
"             \   'name': 'myXselWrap',
"             \   'copy': {
"             \      '+': 'xsel -i',
"             \      '*': 'xsel -i',
"             \    },
"             \   'paste': {
"             \      '+': 'xsel -o',
"             \      '*': 'xsel -o',
"             \   },
"             \   'cache_enabled': 1,
"             \ }

if has('clipboard')
    if has('unnamedplus')
        set clipboard=unnamed,unnamedplus,""
    else
        set clipboard=unnamed
    endif
endif

augroup CMakeSyntaxFix
    autocmd BufReadPost CMake* :syntax enable
augroup END
augroup AssemblySettings
    autocmd Filetype asm,nasm setlocal sw=0 sts=0 noexpandtab
augroup END

" syntax match arsehole "\%(ass\|fuck\)"
" syntax match arsehole "\v%(ass|fuck)"

let g:huge_number = (-(4294967295 * 2))
let g:nasm_ctx_outside_macro = 1
let g:nasm_loose_syntax = 1

command! -range FixClangStars <line1>,<line2>s/\v([*&]+)(\s*)(\S)/\2\1\3/g
nnoremap <silent> <leader>cls :FixClangStars<CR>
vnoremap <silent> <leader>cls :FixClangStars<CR>

let g:gonvim_draw_statusline = 0
let g:gonvim_draw_tabline = 0
let g:gonvim_draw_lint = 0

augroup CHeaderType
    autocmd BufReadPre *.h set ft=cpp
augroup END

if exists('g:gnvim') && g:gnvim == 1
    set guifont=dinaTTF:h10
    set linespace=0
    set guioptions=agimrLt
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor
else
    set guifont=Dina:h7
    set linespace=1
endif

let g:yacc_uses_golang = 1

" '<,'>sort/v(^extern .{-})@<=[a-zA-Z_]w+((.*);)@=/
