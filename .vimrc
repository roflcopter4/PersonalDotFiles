" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker 

" ======================================================================================================
" Environment

" Identify platform
sil fu! OSX()
    return has('macunix')
endf
sil fu! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endf
sil fu! WINDOWS()
    return  (has('win16') || has('win32') || has('win64'))
endf
sil fu! CYGWIN()
    return has('win32unix')
endf
sil fu! WIN_OR_CYG()
    return WINDOWS() || CYGWIN()
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
let g:spf13_no_omni_complete = 1
let g:spf13_no_fastTabs = 1
let g:spf13_no_restore_cursor = 1
let g:spf13_no_autochdir = 1
"let g:spf13_no_easyWindows = 0


" ======================================================================================================
" ======================================================================================================
" Some general config stuff

if CYGWIN()
    let s:VimUsesPowerline = 0
    let s:NeVimUsesPowerline = 0
else
    let s:VimUsesPowerline = 0
    let s:NeoVimUsesPowerline = 0
endif

if (!has('nvim') && s:VimUsesPowerline == 1) || (has('nvim') && s:NeoVimUsesPowerline == 1)
    let s:UsePowerline = 1
endif

let g:use_ale = 1
let g:use_deoplete = 1
let s:vim_ale = 1

let g:mapleader = ' '


" ======================================================================================================
" Some colorscheme setup that must come before the plugin is loaded.

let g:myMolokai_BG = 'darker'
" let g:myMolokai_BG = 'custom'

" ## Monokai_Brown
" let g:myMolokai_CustomBG = '#272822'
" ## BLACK_
" let g:myMolokai_CustomBG = '#000000'
" ## NEAR_BLACK
" let g:myMolokai_CustomBG = '#080808'

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
let g:ophigh_filetypes = [ 'c', 'cpp', 'rust', 'lua', 'go' ]

"let g:ophigh_highlight_link_group = 'Operator'
let g:ophigh_highlight_link_group = 'OperatorChars'
"let g:ophigh_color_gui = '#d33682'
"let g:ophigh_color_gui = '#42A5F5'  ' Lightish-blue

"let g:negchar_highlight_link_group = 'NegationChar'
"let g:negchar_color_gui = '#66BB6A'
let g:negchar_color_gui = '#f92672'
"let g:negchar_color_gui = '#d33682'

"let g:structderef_highlight_link_group = 'Operator'
let g:structderef_color_gui = '#42A5F5'



" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" Plugin Setup


"if has('nvim')
    "let &runtimepath = expand('/usr/share/vim/vimfiles') . ',' . &runtimepath
    "    \ . ',' . expand('/usr/share/vim/vimfiles/after')
    "let &runtimepath = expand('/usr/share/vim/vimfiles') . ',' . expand('/usr/share/vim/vimfiles/after') . ',' . &runtimepath
"else
    "let &runtimepath = expand('~/.local/share/nvim/site') . ',' . &runtimepath
    "    \ . ',' . expand('~/.local/share/nvim/site/after')
"endif


let g:plugin_manager = 'dein'
"let g:dein#install_max_processes = 12
filetype off

" fu! dein#add(name,...)
"     if exists('a:1')
"         call dein#add(a:name, a:1)
"     else
"         call dein#add(a:name)
"     endif
" endf

fu! IsSourced(name)
    return dein#is_sourced(a:name)
endf

if LINUX() || CYGWIN()
    let g:load_path=expand('~/.vim/dein')
    let g:dein_path=expand('~/.vim/dein/repos/github.com/Shougo/dein.vim')
    let &runtimepath = &runtimepath.','. g:dein_path
elseif WINDOWS()
    let g:load_path='C:/vim/dein'
    let g:dein_path='C:/Vim/dein/repos/github.com/Shougo/dein.vim'
    let &runtimepath = &runtimepath.','. g:dein_path
    if exists('g:ONI')
        let g:dein#cache_directory = g:load_path .'/ONI/'
    end
endif


" PLUGINS
if dein#load_state(expand(g:load_path))
    call dein#begin(expand(g:load_path))
    call dein#add(expand(g:dein_path))
    call dein#add('haya14busa/dein-command.vim')

    if executable('ag') || executable('ack-grep') || executable('ack')
        call dein#add('mileszs/ack.vim')
    endif

    " My own stuff should be first!
    call dein#add('roflcopter4/PersonalVimStuff', {'merged': 0})
     
    " General ---------
    call dein#add('MarcWeber/vim-addon-mw-utils')
    call dein#add('ctrlpvim/ctrlp.vim')
    call dein#add('easymotion/vim-easymotion')
    call dein#add('gcmt/wildfire.vim')
    call dein#add('huawenyu/neogdb.vim')
    call dein#add('jiangmiao/auto-pairs')
    call dein#add('jistr/vim-nerdtree-tabs')
    call dein#add('kana/vim-textobj-indent')
    call dein#add('kana/vim-textobj-user')
    call dein#add('mbbill/undotree')
    call dein#add('osyo-manga/vim-over')
    call dein#add('powerline/fonts')
    call dein#add('rhysd/conflict-marker.vim')
    call dein#add('scrooloose/nerdtree')
    call dein#add('tacahiroy/ctrlp-funky')
    call dein#add('terryma/vim-multiple-cursors')
    call dein#add('tomtom/tlib_vim')
    call dein#add('tpope/vim-abolish.git')
    call dein#add('tpope/vim-repeat')
    call dein#add('tpope/vim-surround')
    call dein#add('vim-scripts/matchit.zip')
    call dein#add('vim-scripts/restore_view.vim')
    call dein#add('vim-scripts/sessionman.vim')
      
    " Writing -----
    call dein#add('reedes/vim-litecorrect')
    call dein#add('reedes/vim-textobj-sentence')
    call dein#add('reedes/vim-textobj-quote')
    call dein#add('reedes/vim-wordy')
      
    " General Programming -----
    call dein#add('tpope/vim-fugitive')
    "call dein#add("bling/vim-bufferline")
    call dein#add('mattn/webapi-vim')
    call dein#add('mattn/gist-vim')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('godlygeek/tabular')
    " call dein#add('luochen1990/rainbow')
    call dein#add('junegunn/vim-easy-align')
    if executable('ctags')
        call dein#add('majutsushi/tagbar')
    endif
          
    " PHP --------
    call dein#add('spf13/PIV')
    call dein#add('arnaud-lb/vim-php-namespace')
    call dein#add('beyondwords/vim-twig')
     
    " Python ---------
    call dein#add('klen/python-mode')
    call dein#add('yssource/python.vim')
    call dein#add('vim-scripts/python_match.vim')
    call dein#add('vim-scripts/pythoncomplete')
      
    " Javascript ----------
    call dein#add('elzr/vim-json')
    call dein#add('groenewege/vim-less')
    call dein#add('pangloss/vim-javascript')
    call dein#add('briancollins/vim-jst')
    call dein#add('kchmck/vim-coffee-script')
    
    " Scala ---------
    call dein#add('derekwyatt/vim-scala')
    call dein#add('derekwyatt/vim-sbt')
    call dein#add('vim-scripts/xptemplate')
    
    " Haskell ----------
    call dein#add('Twinside/vim-haskellConceal')
    call dein#add('Twinside/vim-haskellFold')
    call dein#add('adinapoli/cumino')
    call dein#add('bitc/vim-hdevtools')
    call dein#add('dag/vim2hs')
    call dein#add('eagletmt/ghcmod-vim')
    call dein#add('eagletmt/neco-ghc')
    call dein#add('lukerandall/haskellmode-vim')
    call dein#add('travitch/hasksyn')
    
    " HTML ---------
    call dein#add('hail2u/vim-css3-syntax')
    call dein#add('gorodinskiy/vim-coloresque')
    call dein#add('tpope/vim-haml')
    "call dein#add('amirh/HTML-AutoCloseTag')

    " Markdown
    call dein#add('vim-pandoc/vim-pandoc')
    call dein#add('vim-pandoc/vim-pandoc-syntax')

    " Moar Languages ------
    call dein#add('rsmenon/vim-mathematica')
    call dein#add('dag/vim-fish')
    call dein#add('fsharp/vim-fsharp')
    call dein#add('chaimleib/vim-renpy')
    call dein#add('gentoo/gentoo-syntax')
    call dein#add('rust-lang/rust.vim')

    " Misc ----------
    call dein#add('Chiel92/vim-autoformat')
    call dein#add('PProvost/vim-ps1')
    call dein#add('carlosgaldino/elixir-snippets')
    call dein#add('cespare/vim-toml')
    call dein#add('chrisbra/Colorizer')
    call dein#add('elixir-lang/vim-elixir')
    call dein#add('equalsraf/neovim-gui-shim')
    call dein#add('idanarye/vim-vebugger')
    call dein#add('junegunn/fzf.vim')
    call dein#add('mattreduce/vim-mix')
    call dein#add('quentindecock/vim-cucumber-align-pipes')
    call dein#add('rodjek/vim-puppet')
    call dein#add('saltstack/salt-vim')
    call dein#add('tpope/vim-cucumber')
    call dein#add('tpope/vim-markdown')
    call dein#add('vim-scripts/Vimball')
    " call dein#add('octol/vim-cpp-enhanced-highlight')

    "call dein#add('xolox/vim-easytags', {'merged': 0})
    "call dein#add('Chilledheart/vim-clangd')

    if !WINDOWS()
        call dein#add('autozimu/LanguageClient-neovim', {'merged': 0, 'build': 'make release'})
    endif
    if has('nvim')
        " call dein#add('c0r73x/neotags.nvim', {'merged': 0})
        call dein#add('roflcopter4/neotags.nvim', {'merged': 0})
    endif
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')

    call dein#add('xolox/vim-misc')
    call dein#add('xolox/vim-shell')

    call dein#add('Shougo/vimproc.vim', {'merged': 0, 'build': 'make'})
    call dein#add('vim-perl/vim-perl',  {'merged': 0, 'build': 'make -k contrib_syntax carp try-tiny '
                                                              \.'method-signatures moose test-more'})

    "call dein#add('Blackrush/vim-gocode')
    "call dein#add('fatih/vim-go')
    "call dein#add('dzhou121/gonvim-fuzzy')
    "call dein#add('app-vim/searchcomplete')
    "call dein#add('nathanaelkane/vim-indent-guides')
    "call dein#add('maralla/validator.vim')

    if !exists('g:ONI')
        call dein#add('Yggdroot/indentLine')
    endif

    if has('nvim')
        if g:use_ale == 1
            call dein#add('w0rp/ale', {'merged': 0})
        else
            call dein#add('neomake/neomake', {'merged': 0})
        endif
        if g:use_deoplete == 1
            call dein#add('Shougo/deoplete.nvim')
            call dein#add('zchee/deoplete-jedi')
            call dein#add('Shougo/neco-vim')
            call dein#add('artur-shaik/vim-javacomplete2')
            call dein#add('zchee/deoplete-clang')
        else
            call dein#add('Valloric/YouCompleteMe', {'merged': 0, 'build': 'python3 install.py --all'})
            call dein#add('rdnetto/YCM-Generator')
        endif
    else
        if s:vim_ale == 1
            call dein#add('w0rp/ale')
            call dein#add('Shougo/neco-vim')
            call dein#add('artur-shaik/vim-javacomplete2')
        endif

        if has('python3') || has('nvim')
            call dein#add('Valloric/YouCompleteMe', {'merged': 0, 'build': 'python3 install.py --all'})
            call dein#add('rdnetto/YCM-Generator')
        elseif has('python')
            call dein#add('Valloric/YouCompleteMe', {'merged': 0, 'build': 'python2 install.py --all'})
            call dein#add('rdnetto/YCM-Generator')
        endif
    endif

    if (has('nvim') || !s:VimUsesPowerline) && !exists('g:ONI')
        call dein#add('vim-airline/vim-airline')
        call dein#add('vim-airline/vim-airline-themes')
    endif
    call dein#add('https://anongit.gentoo.org/git/proj/eselect-syntax.git')

    call dein#add('Shougo/denite.vim')
     
      
    " Colour Schemes ----------------
    call dein#add('MaxSt/FlatColor')
    call dein#add('mhinz/vim-janah')
    call dein#add('iCyMind/NeoSolarized')
    call dein#add('joshdick/onedark.vim')
    call dein#add('reewr/vim-monokai-phoenix')
    call dein#add('KeitaNakamura/neodark.vim')
    call dein#add('dunckr/vim-monokai-soda')
    call dein#add('tyrannicaltoucan/vim-quantum')
    call dein#add('zanglg/nova.vim')
    call dein#add('crater2150/vim-theme-chroma')
    call dein#add('muellan/am-colors')
    call dein#add('jaromero/vim-monokai-refined')
    call dein#add('vim-scripts/darkspectrum')
    call dein#add('lanox/lanox-vim-theme')
    call dein#add('benjaminwhite/Benokai')
    call dein#add('Valloric/vim-valloric-colorscheme')
    call dein#add('petelewis/vim-evolution')
    call dein#add('ratazzi/blackboard.vim')
    call dein#add('nielsmadan/harlequin')
    call dein#add('morhetz/gruvbox')
    call dein#add('mhartington/oceanic-next')
    call dein#add('dracula/vim')
    call dein#add('nanotech/jellybeans.vim')
    call dein#add('xolox/vim-colorscheme-switcher')

    call dein#local(expand('~/.vim/bundles/findent'))

    "if has('nvim')
    "    call dein#local(expand('/usr/share/vim/vimfiles'))
    "endif
     

    call dein#end()
    call dein#save_state()
endif


if exists('s:UsePowerline')
    let g:powerline_pycmd='py3'
    python from powerline.vim import setup as powerline_setup
    python powerline_setup()
    python del powerline_setup
    set laststatus=2    " Always display the statusline in all windows
    set showtabline=2   " Always display the tabline, even if there is only one tab
    set noshowmode      " Hide the default mode text (e.g. -- INSERT -- below the statusline)
endif

filetype plugin indent on
syntax enable


" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" Plugin Config


if IsSourced('tabular')
    let g:DisableAutoPHPFolding = 0
    let g:PIVAutoClose = 0
endif


if IsSourced('matchit.zip')
    let b:match_ignorecase = 1
endif


if IsSourced('HTML-AutoCloseTag')
    " Make it so AutoCloseTag works for xml and xhtml files as well
    augroup HTML_CloseTag
        autocmd FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
    augroup END
    nmap <Leader>ac <Plug>ToggleAutoCloseMappings
endif


if IsSourced('ack.vim')
    if executable('ag')
        let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
    elseif executable('ack-grep')
        let g:ackprg='ack-grep -H --nocolor --nogroup --column'
        call dein#add('mileszs/ack.vim')
    elseif executable('ack')
        call dein#add('mileszs/ack.vim')
    endif
endif


if IsSourced('nerdtree')
    noremap <leader>ee :NERDTreeTabsToggle<CR>
    "noremap <leader>e :NERDTreeFind<CR>
    noremap <leader>ef :NERDTreeFind<CR>
     
    let g:NERDTreeShowBookmarks=1
    let g:NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
    let g:NERDTreeChDirMode=0
    let g:NERDTreeQuitOnOpen=1
    let g:NERDTreeMouseMode=2
    let g:NERDTreeShowHidden=1
    let g:NERDTreeKeepTreeInNewTab=1
    let g:NERDShutUp=1
    let g:nerdtree_tabs_open_on_gui_startup=0
endif


if IsSourced('tabular')
    nmap <Leader>a& :Tabularize /&<CR>
    vmap <Leader>a& :Tabularize /&<CR>
    nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
    vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
    nmap <Leader>a=> :Tabularize /=><CR>
    vmap <Leader>a=> :Tabularize /=><CR>
    nmap <Leader>a: :Tabularize /:<CR>
    vmap <Leader>a: :Tabularize /:<CR>
    nmap <Leader>a:: :Tabularize /:\zs<CR>
    vmap <Leader>a:: :Tabularize /:\zs<CR>
    nmap <Leader>a, :Tabularize /,<CR>
    vmap <Leader>a, :Tabularize /,<CR>
    nmap <Leader>a,, :Tabularize /,\zs<CR>
    vmap <Leader>a,, :Tabularize /,\zs<CR>
    nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
endif


set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
if IsSourced('sessionman.vim')
    nmap <leader>sl :SessionList<CR>
    nmap <leader>ss :SessionSave<CR>
    nmap <leader>sc :SessionClose<CR>
endif


nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
let g:vim_json_syntax_conceal = 0


if !has('python') && !has('python3')
    let g:pymode = 0
endif
if IsSourced('python-mode')
    let g:pymode_options = 1
    let g:pymode_lint = 0
    let g:pymode_lint_checkers = ['flake8', 'pep8', 'pyflakes']
    "let g:pymode_lint_on_fly = 1

    let g:pymode_indent = 1
    let g:pymode_options_colorcolumn = 0
    let g:pymode_python = 'python'
    let g:pymode_doc = 1
    let g:pymode_doc_bind = 'K'

    let g:pymode_run = 1
    let g:pymode_run_bind = '<leader>r'
    let g:pymode_breakpoint = 1
    let g:pymode_breakpoint_bind = '<leader>b'

    let g:pymode_options_max_line_length = 79

    let g:pymode_trim_whitespaces = 0
    let g:pymode_rope = 0

    let g:pymode_syntax = 1
    let g:pymode_syntax_all = 1
    let g:pymode_syntax_docstrings = g:pymode_syntax_all
    let g:pymode_syntax_highlight_exceptions = g:pymode_syntax_all
endif


if IsSourced('ctrlp.vim')
    let g:ctrlp_working_path_mode = 'ra'
    nnoremap <silent> <D-t> :CtrlP<CR>
    nnoremap <silent> <D-r> :CtrlPMRU<CR>
    let g:ctrlp_custom_ignore = {
                \ 'dir':  '\.git$\|\.hg$\|\.svn$',
                \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }
                 
    if executable('ag')
        let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
    elseif executable('ack-grep')
        let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
    elseif executable('ack')
        let s:ctrlp_fallback = 'ack %s --nocolor -f'
        " On Windows use "dir" as fallback command.
    elseif WINDOWS()
        let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
    else
        let s:ctrlp_fallback = 'find %s -type f'
    endif
    if exists('g:ctrlp_user_command')
        unlet g:ctrlp_user_command
    endif
    let g:ctrlp_user_command = {
                \ 'types': {
                \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
                \ 2: ['.hg', 'hg --cwd %s locate -I .'],
                \ },
                \ 'fallback': s:ctrlp_fallback
                \ }
                 
    if IsSourced('ctrlp-funky')
        " CtrlP extensions
        let g:ctrlp_extensions = ['funky']
         
        "funky
        nnoremap <Leader>fu :CtrlPFunky<Cr>
    endif

    if filereadable(expand('~/personaldotfiles/.Vim/ctrlp.vim'))
        :source ~/personaldotfiles/.Vim/ctrlp.vim
    endif
endif


if IsSourced('tagbar')
    nnoremap <silent> <leader>tt :TagbarToggle<CR>
endif


if IsSourced('rainbow') || 1
    let g:rainbow_active = 1
    " God, what a horrific mess.

        "\    'guifgs': ['DodgerBlue1', 'chartreuse3', 'darkorange1',  'firebrick1', 'orchid2'],
        "\    'guifgs': ['DodgerBlue1', 'darkorange1', 'green2', 'firebrick1'],
        "\    'operators': '_,_',
        "\        'c': {
        "\            'guifgs': ['chartreuse3', 'DeepSkyBlue2', 'firebrick1', 'orchid2', 'gold1'],
        "\        },
    let g:rainbow_conf = {
        \    'guifgs': ['chartreuse3', 'DeepSkyBlue2', 'darkorange1', 'firebrick1', 'orchid2'],
        \    'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
        \    'operators': '',
        \    'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
        \    'separately': {
        \        '*': {},
        \        'tex': {
        \            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
        \        },
        \        'lisp': {
        \            'guifgs': ['DeepSkyBlue2', 'chartreuse3', 'darkorange1',  'firebrick1', 'orchid2', 'gold1', 'cyan1'],
        \        },
        \        'vim': {
        \            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold',
                                   \ 'start=/(/ end=/)/ containedin=vimFuncBody',
                                   \ 'start=/\[/ end=/\]/ containedin=vimFuncBody',
                                   \ 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
        \        },
        \        'html': {
        \            'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem'.
                                   \ '|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'.
                                   \ "'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
        \        },
        \        'perl': {
        \            'guifgs': ['chartreuse3', 'DeepSkyBlue2', 'firebrick1', 'orchid2'],
        \        },
        \        'c': {
        \            'guifgs': ['chartreuse3', 'DeepSkyBlue2', 'darkorange1', 'gold1', 'orchid2'],
        \        },
        \        'css': 0
        \    }
    \}

    nnoremap <leader>rnt :RainbowToggle<CR>
    nnoremap <leader>rnr :RainbowToggle<CR> :RainbowToggle<CR>
endif


if IsSourced('vim-fugitive')
    nnoremap <silent> <leader>gs :Gstatus<CR>count(g:spf13_bundle_groups, 'neocomplcache')
    nnoremap <silent> <leader>gd :Gdiff<CR>
    nnoremap <silent> <leader>gc :Gcommit<CR>
    nnoremap <silent> <leader>gb :Gblame<CR>
    nnoremap <silent> <leader>gl :Glog<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gr :Gread<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>
    nnoremap <silent> <leader>ge :Gedit<CR>
    " Mnemonic _i_nteractive
    nnoremap <silent> <leader>gi :Git add -p %<CR>
    nnoremap <silent> <leader>gg :SignifyToggle<CR>
endif


if IsSourced('neocomplcache') || IsSourced('neocomplete')
    " Use honza's snippets.
    let g:neosnippet#snippets_directory='C:Vim/dein/repos/github.com/vim-snippets/snippets'
    " Enable neosnippet snipmate compatibility mode
    let g:neosnippet#enable_snipmate_compatibility = 1
    " For snippet_complete marker.
    if !exists('g:spf13_no_conceal')
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif
    endif
    " Enable neosnippets when using go
    let g:go_snippet_engine = 'neosnippet'
    set completeopt-=preview
endif


if IsSourced('undotree')
    nnoremap <Leader>u :UndotreeToggle<CR>
    " If undotree is opened, it is likely one wants to interact with it.
    let g:undotree_SetFocusWhenToggle=1
endif


if IsSourced('vim-indent-guides')
    let g:indent_guides_start_level = 1
    let g:indent_guides_guide_size = 0
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_auto_colors = 1
    let g:indent_guides_color_change_percent = 30
    "autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#808080
    "autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#465457
endif


if IsSourced('wildfire.vim')
    let g:wildfire_objects = {
                \ '*' : ["i'", 'i"', 'i)', 'i]', 'i}', 'ip'],
                \ 'html,xml' : ['at'],
                \ }
endif


if IsSourced('vim-airline') 
    if CYGWIN() || WINDOWS()
        let g:airline_powerline_fonts = 0
    else
        let g:airline_powerline_fonts = 1
    endif

    let g:airline_section_z = '%p%%%{g:airline_symbols.maxlinenr}%3l/%L :%v'
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tagbar#enabled = 1
    let g:airline#extensions#tabline#buffer_nr_show = 1
    let g:airline#extensions#whitespace#enabled = 0
    "let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    let g:airline#extensions#whitespace#checks = [ 'trailing', 'indent', 'long', 'mixed-indent-file' ]

    nnoremap <silent> <leader>al :AirlineRefresh<CR>
    if IsSourced('vim-airline-themes') && $TERM !=# 'linux'
        "let g:airline_theme = 'molokai'
        let g:airline_theme = 'papercolor'
    endif

    nnoremap <silent> <leader>bn :bp<CR>:call airline#update_statusline()<CR>
    nnoremap <silent> <leader>bm :bn<CR>:call airline#update_statusline()<CR>

else
    augroup Airline
        au!
    augroup END

    nnoremap <silent> <leader>bn :bp<CR>
    nnoremap <silent> <leader>bm :bn<CR>
endif


if IsSourced('neomake')
    " let g:neomake_c_lint_maker = {
    "     \ 'exe': 'lint',
    "     \ 'args': ['--option', 'x'],
    "     \ 'errorformat': '%f:%l:%c: %m',
    "     \ }
    " let g:neomake_error_sign = {
    "             \ 'text': '>>',
    "             \ 'texthl': 'ErrorMsg',
    "             \ }
    " hi MyWarningMsg ctermbg=3 ctermfg=0
    " let g:neomake_warning_sign = {
    "             \ 'text': '>>',
    "             \ 'texthl': 'MyWarningMsg',
    "             \ }
    " Disable inherited syntastic
    " let g:syntastic_mode_map = {
    "     \ 'mode': 'passive',
    "     \ 'active_filetypes': [],
    "     \ 'passive_filetypes': []
    "     \ }
    " 
    " let g:neomake_serialize = 1
    " let g:neomake_serialize_abort_on_error = 1
    " let g:neomake_highlight_lines = 1
    " let g:neomake_place_signs=0
    " let g:neomake_verbose=2
    " let g:neomake_echo_current_error=1
    " let g:neomake_open_list=0
    let g:neomake_c_enabled_makers=['gcc', 'clangcheck', 'clangtidy']
    " let g:neomake_c_enabled_makers=['clangcheck']
    " let g:neomake_c_enabled_makers=['clangtidy']
    " let g:neomake_make_maker = {
    "     \ 'exe': 'make',
    "     \ 'args': ['--build'],
    "     \ 'errorformat': '%f:%l:%c: %m',
    "     \ }
    " 
    " augroup my_neomake_highlights
    "     au!
    "     autocmd ColorScheme *
    "       \ hi link NeomakeError SpellBad |
    "       \ hi link NeomakeWarning SpellCap
    " augroup END
    " 
    " autocmd! BufReadPost,BufWritePost * Neomake

    if filereadable(expand('~/personaldotfiles/.Vim/neomake.vim'))
        :source ~/personaldotfiles/.Vim/neomake.vim
    endif
endif


if IsSourced('ale')
    let g:airline#extensions#ale#enabled = 1
    let g:ale_lint_on_text_changed = 1 
    let g:ale_sign_column_always = 1
    let g:ale_lint_on_insert_leave = 0
    let g:ale_linters_explicit = 0
    let g:ale_open_list = 0
    let g:ale_list_window_size = 4
    let g:ale_sh_shell_default_shell = 'sh'

    function! Find_File_Cwd()
        return fnamemodify(expand('%:p'), ':h')
    endfunction

    " C, C++, C# {
        let g:ale_c_gcc_options   = '-Wall -Wpedantic -Wextra -Iinc -Iinclude -I..'
        let g:ale_c_clang_options = '-Wall -Wpedantic -Wextra -Iinc -Iinclude -i..'

        let g:ale_c_clangtidy_checks = ['*',
                                      \ '-*-braces-around-statements',
                                      \ '-android*',
                                      \ '-readability-avoid-const-params-in-decls',
                                      \ '-llvm-header-guard',
                                      \ '-hicpp-signed-bitwise',
                                      \ ]

        let g:ale_cpp_clangtidy_checks = (g:ale_c_clangtidy_checks)
        call extend(g:ale_cpp_clangtidy_checks, ['-*pointer-arithmetic*, -*fuchsia*'])
                                        
        let s:ALE_C = ['gcc', 'clangtidy', 'cppcheck', 'flawfinder']

        let b:ale_linters_c = {'c': s:ALE_C,
                             \ 'cpp': ['clang', 'gcc', 'clangtidy', 'cppcheck', 'flawfinder']
                             \ }

    " Python {
        let b:ale_linters_py = {'python': ['flake8', 'pyflakes']}
        let g:ale_python_pylint_executable = '/dev/null'   " FUCK PYLINT
        let g:ale_python_flake8_options = '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,E501' 

    " Perl {
        let b:ale_linters_perl = {'perl': ['perl']}
        let g:ale_perl_perlcritic_options = '-4'

    let g:ale_linters =  {}
    call extend(g:ale_linters, b:ale_linters_c)
    call extend(g:ale_linters, b:ale_linters_py)
    call extend(g:ale_linters, b:ale_linters_perl)

    augroup CloseLoclistWindowGroup
        autocmd!
        autocmd QuitPre * if empty(&buftype) | lclose | endif
    augroup END


    let g:ale_linter_aliases = {'csh': 'sh'}

    if filereadable(expand('~/personaldotfiles/.Vim/ale.vim'))
        :source ~/personaldotfiles/.Vim/ale.vim
    endif
endif


if IsSourced('vim-vebugger')
    let g:vebugger_leader='<Leader>d'
endif


if IsSourced('vim-easytags')
    let g:easytags_python_enabled = 0
    let g:easytags_dynamic_files = 2
    set tags=./tags;
    let &cpoptions .= 'd'
    nnoremap <leader>tag :UpdateTags<CR>
    nnoremap <leader>tah :HighlightTags<CR>
    let g:easytags_autorecurse = 1
    let g:easytags_include_members = 1
    let g:easytags_async = 1
    "let g:easytags_always_enabled = 1

    let g:easytags_languages = {
    \   'c': {
    \       'args': ['--fields=+l', '--c-kinds=*']
    \   }
    \}

    highlight def link cMember perlSpecialChar2
    highlight def link shFunctionTag Type
    highlight def link cEnumTag Enum
    highlight def link cMemberTag CMember
    highlight def link cPreProcTag PreProc
    highlight def link cFunctionTag CFuncTag
endif


if IsSourced('deoplete.nvim')
    " let g:deoplete#enable_at_startup = 1
    " if !exists('g:deoplete#omni#input_patterns')
        " let g:deoplete#omni#input_patterns = {}
    " endif
    if filereadable(expand('~/personaldotfiles/.Vim/deoplete.vim'))
        :source ~/personaldotfiles/.Vim/deoplete.vim
    endif

    " let g:deoplete#disable_auto_complete = 1

    " deoplete tab-complete
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
    "inoremap <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    "imap <expr><CR> pumvisible() ? "<c-y><CR>" : <CR>
    "inoremap <buffer> <silent> <CR> <C-R>=AutoPairsReturn()<CR>
    "inoremap <expr><CR> pumvisible() ? deoplete#smart_close_popup() : "\<CR>"
    "inoremap <expr><CR> pumvisible() ? deoplete#smart_close_popup()  "\<CR>" : "\<CR>"

    "augroup DeocompleteSetup
    "    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    "    " tern
    "    autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
    "augroup END
    " Use smartcase.
    let g:deoplete#enable_smart_case = 1

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS>  deoplete#smart_close_popup()."\<C-h>"

    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function() abort
        return deoplete#close_popup() . "\<CR>"
    endfunction
    
    if IsSourced('zchee/deoplete-clang')
        g:deoplete#sources#clang#libclang_path = '/usr/lib64/llvm/7/lib64/libclang.so'
        g:deoplete#sources#clang#clang_header = '/usr/lib64/clang/7.0.0/include'
    endif
endif


if IsSourced('YouCompleteMe')
    let g:acp_enableAtStartup = 0

    if CYGWIN()
        let g:ycm_server_python_interpreter='/c/bin/python3'
    else
        if has('nvim')
            let g:ycm_server_python_interpreter='/usr/bin/env python3'
        endif
        if executable('/usr/bin/python2') && has('python')
            let g:ycm_server_python_interpreter='/usr/bin/env python2'
        elseif executable('/usr/local/bin/python3') && has('python3')
            let g:ycm_server_python_interpreter='/usr/bin/env python3'
        endif
    endif
    " enable completion from tags
    let g:ycm_collect_identifiers_from_tags_files = 1
    " remap Ultisnips for compatibility for YCM
    let g:UltiSnipsExpandTrigger = '<C-j>'
    let g:UltiSnipsJumpForwardTrigger = '<C-j>'
    let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

    " Enable omni completion.
    augroup YcmOmniVimrc
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
    augroup END

    " Haskell post write lint and check with ghcmod
    " $ `cabal install ghcmod` if missing and ensure ~/.cabal/bin is in your $PATH.
    if !executable('ghcmod')
        augroup YcmGhcMod
            autocmd BufWritePost *.hs GhcModCheckAndLintAsync
        augroup END
    endif

    " For snippet_complete marker.
    if !exists('g:spf13_no_conceal')
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif
    endif

    let g:ycm_global_ycm_extra_conf = expand('~/.vim/ycm_extra_conf.py')

    " Disable the neosnippet preview candidate window
    " When enabled, there can be too much visual noise, especially when splits are used.
    set completeopt-=preview
endif


if IsSourced('indentLine')
    if exists('g:ONI')
        let g:indentLine_loaded = 0
    endif
    if WINDOWS() && !$NVIM_QT
        let g:indentLine_char = '│'
    else
        let g:indentLine_char = '│'
    endif

    let g:indentLine_enabled = 0

    "let g:indentLine_setColors = 0
    let g:indentLine_color_gui = '#7E8E91'
    "let g:indentLine_enabled = 1
    nmap <silent> <leader>il :IndentLinesToggle<CR>
endif


if IsSourced('vim-autoformat')
    augroup c_formatting
        autocmd FileType c,cpp,cs,c++ setlocal cindent sw=8 sts=8
    augroup END
    let g:__c__shiftwidth = 8

    " ### astyle {
        let g:_Astyle_Main_ = ''
            \ . ' --indent=spaces=' . g:__c__shiftwidth
            \ . ' --pad-oper'
            \ . ' --preserve-date'
            \ . ' --pad-header'
            \ . ' --max-code-length=180'
            \ . ' --break-one-line-headers'
            \ . ' --remove-braces'

        let g:_Astyle_KR_     = '"astyle --style=kr'     . g:_Astyle_Main_
        let g:_Astyle_Allman_ = '"astyle --style=allman' . g:_Astyle_Main_

        let g:_Astyle_c_      = ' --mode=c"'
        let g:_Astyle_cpp_    = ' --mode=c --indent-namespaces"'
        let g:_Astyle_cs_     = ' --mode=cs --indent-namespaces"'
    "}

    "### clang-format {
        if len(findfile('.clang-format', expand('%:p:h').';'))
            let s:ClangFile = findfile('.clang-format', expand('%:p:h').';')
        elseif len(findfile('_clang-format', expand('%:p:h').';'))
            let s:ClangFile = findfile('_clang-format', expand('%:p:h').';')
        elseif filereadable(expand('~/.clang-format'))
            let s:ClangFile = expand('~/.clang-format')
        endif

        function! g:ZeroIsOneThousand()
            if &textwidth ==# 0
                return 1000
            else
                return &textwidth
            endif
        endfunction

        if exists('s:ClangFile') 
            let g:formatdef_clangformat = "'clang-format -i'.&shiftwidth.' -l'.ZeroIsOneThousand().' -- "
                                      \ . "-lines='.a:firstline.':'.a:lastline.' "
                                      \ . "--assume-filename=\"'.expand('%:p').'\"'"
        endif
    "}

    "--------------------------------------------------------------------------------------

    "### C {
        let g:formatdef_astyle_c    = g:_Astyle_Allman_ . g:_Astyle_c_
        let g:formatdef_astyle_c_KR = g:_Astyle_KR_     . g:_Astyle_c_
        let g:formatters_c          = ['clangformat', 'astyle_c_KR', 'astyle_c']
    "### }

    "### C++ {
        let g:formatdef_astyle_cpp    = g:_Astyle_Allman_ . g:_Astyle_cpp_
        let g:formatdef_astyle_cpp_KR = g:_Astyle_KR_     . g:_Astyle_cpp_
        let g:formatters_cpp          = ['clangformat', 'astyle_cpp_KR', 'astyle_cpp']
    "### }

    "### C-sharp {
        let g:formatdef_astyle_cs    = g:_Astyle_Allman_ . g:_Astyle_cs_
        let g:formatdef_astyle_cs_KR = g:_Astyle_KR_     . g:_Astyle_cs_
        let g:formatters_cs          = ['clangformat', 'astyle_cs_KR', 'astyle_cs']
    "### }


    "### Some generic options
    let g:autoformat_autoindent = 0
    let g:autoformat_retab = 0
    let g:autoformat_remove_trailing_spaces = 0
    let g:autoformat_verbosemode = 1
endif


if IsSourced('numbers.vim') || IsSourced('PersonalVimStuff')
    nnoremap <F3> :NumbersToggle<CR>
    let g:enable_numbers = 0
    "let g:numbers_default_norelative = 1
endif


if IsSourced('neotags.nvim')
    let g:neotags_enabled = 1
    let g:neotags_highlight = 1
    let g:neotags_run_ctags = 1
    let g:neotags_verbose = 0
    let g:neotags_recursive = 1
    let g:neotags_no_autoconf = 1
    " let g:neotags_find_tool = 'ag -g ""'

    " let g:neotags#c#order = 'cgstuedfpm'
    " let g:neotags#cpp#order = 'cgstuedfpm'
    let g:neotags#c#order = 'cgstuedfm'
    let g:neotags#cpp#order = 'cgstuedfm'

    " C
    highlight def link cEnumTag Enum
    highlight def link cMemberTag CMember
    highlight def link cPreProcTag PreProc
    highlight def link cFunctionTag CFuncTag

    " C++
    highlight def link cppEnumTag Enum
    highlight def link cppMemberTag CMember
    highlight def link cppPreProcTag PreProc
    highlight def link cppFunctionTag CFuncTag

    " Sh
    highlight def link shFunctionTag CFuncTag
    highlight def link shAliasTag Constant

    " Perl
    highlight def link perlFunctionTag CFuncTag

    set tags=./tags;
    let &cpoptions .= 'd'

    let g:neotags_norecurse_dirs = [$HOME, '/', '/include', '/usr/include', '/usr/share', '/usr/local/include', '/usr/local/share',
                                  \ expand('~/personaldotfiles'), expand('~/random'), expand('~/random/Code'), expand('~/random/school')]
    " let g:neotags_ctags_args = [
    "     \ '--fields=+l',
    "     \ '--c-kinds=+p',
    "     \ '--c++-kinds=+p',
    "     \ '--sort=yes',
    "     \ '--extras=+q',
    "     \ '--links=no',
    "     \ "--languages='-json'",
    "     \ "--exclude='*config.log' --exclude='*config.guess' --exclude='*configure' --exclude='*Makefile.in'",
    "     \ "--exclude='*missing' --exclude='*depcomp' --exclude='*aclocal.m4' --exclude='*install-sh'",
    "     \ "--exclude='*config.status' --exclude='*config.h.in' --exclude='*Makefile'"
    "     \ ]

    let g:neotags_ignored_tags = ['NULL', 'restrict', 'const', 'BUFSIZ', 'true', 'false']

    nmap <leader>tag :NeotagsToggle<CR>
endif


if IsSourced('octol/vim-cpp-enhanced-highlight')
    let g:cpp_class_scope_highlight = 1
    let g:cpp_class_decl_highlight = 1
    let g:cpp_member_variable_highlight = 1
    let g:cpp_experimental_simple_template_highlight = 1
    " let g:cpp_experimental_template_highlight = 1
    let g:cpp_concepts_highlight = 1
    let g:cpp_no_function_highlight = 1
endif


if IsSourced('auto-pairs')
    let g:AutoPairsFlyMode = 1
endif


if IsSourced('vim-over')
    " Bring up over command line with substitute and very magic mode already typed
    nnoremap <silent> <leader>os :OverCommandLine<CR>%s/\v
    nnoremap <silent> <leader>oo :OverCommandLine<CR>
endif


if IsSourced('vim-easymotion')
    map , <Plug>(easymotion-prefix)
endif


if IsSourced('vim-pandoc')
    "let g:NOPNOPNOPNOP = ''
endif


if IsSourced('LanguageClient-neovim')
    let g:LanguageClient_serverCommands = {
        \ 'cpp': ['cquery', '--log-file=/tmp/cq.log'],
        \ 'c': ['cquery', '--log-file=/tmp/cq.log'],
        \ } 
    "let g:LanguageClient_serverCommands = {
        "\ 'cpp': ['cquery', '--log-file=/tmp/cq.log'],
        "\ 'c': ['clangd']
        "\ } 
    let g:LanguageClient_diagnosticsEnable = 0

    let g:LanguageClient_autoStart = 1
    let g:LanguageClient_trace = 'verbose'

    let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings 
    let g:LanguageClient_settingsPath = expand('~/.config/nvim/settings.json')
    "set completefunc=LanguageClient#complete
    "set formatexpr=LanguageClient_textDocument_rangeFormatting()

    nnoremap <silent> <leader>h :call LanguageClient_textDocument_hover()<CR>

    nnoremap <silent> <leader>gh :call LanguageClient_textDocument_hover()<CR>
    nnoremap <silent> <leader>gd :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> <leader>gr :call LanguageClient_textDocument_references()<CR>
    nnoremap <silent> <leader>gs :call LanguageClient_textDocument_documentSymbol()<CR>
    nnoremap <silent> <leader><F2> :call LanguageClient_textDocument_rename()<CR>

    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly', 'rls']
endif


if IsSourced('unite.vim')
    if filereadable(expand('~/personaldotfiles/.Vim/unite.vim'))
        :source ~/personaldotfiles/.Vim/unite.vim
    endif
endif


if IsSourced('nerdcommenter')
    let g:NERDCompactSexyComs = 1
    let g:NERDCommentEmptyLines = 1
    let g:NERDSpaceDelims = 1
    let g:NERDRemoveExtraSpaces = 1
    imap <C-c> <plug>NERDCommenterInsert
    nmap <leader>ci <plug>NERDCommenterInsert
    nmap <leader>ce <plug>NERDCommenterAppend
    map <leader>cd <plug>NERDCommenterInvert

    let g:NERDCustomDelimiters = {
                \ 'perl': { 'left': '#', 'rightAlt': '*/', 'leftAlt': '/*' }
                \ }

    function! FixNerdSpaces()
        if &filetype ==# 'python'
            let g:NERDSpaceDelims = 0
        else
            let g:NERDSpaceDelims = 1
        endif
    endfunction

    augroup NerdCommentSpaces
        autocmd BufEnter * call FixNerdSpaces()
    augroup END
endif


" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" Functions & Commands


" Initialize directories
function! InitializeDirectories()
    let l:parent = $HOME
    let l:prefix = 'vim'
    let l:dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }
                 
    if has('persistent_undo')
        let l:dir_list['undo'] = 'undodir'
    endif
     
    " Specify a different directory in which to place the vimbackup vimviews, vimundo, and vimswap
    " with:  let g:spf13_consolidated_directory = <full path to desired directory>
    if exists('g:spf13_consolidated_directory')
        let l:common_dir = g:spf13_consolidated_directory . l:prefix
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
            exec 'set ' . l:settingname . '=' . l:directory
        endif
    endfor
endfunction
call InitializeDirectories()

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

" OmniComplete
if !exists('g:spf13_no_omni_complete')
    if has('autocmd') && exists('+omnifunc')
        autocmd Filetype *
                    \if &omnifunc == "" |
                    \setlocal omnifunc=syntaxcomplete#Complete |
                    \endif
    endif
     
    " # Some convenient mappings
    "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
    "inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
    inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
    inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
     
    " Automatically open and close the popup menu / preview window
    au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
    set completeopt=menu,preview,longest
endif

" Normal Vim omni-completion
"if !exists('g:spf13_no_omni_complete')
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
"endif

" Automatically switch to the current file directory when a new buffer is opened.
augroup spf13_autchdir
    " autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    autocmd VimEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
augroup END

" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
augroup no_revertcursor_git
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
augroup END

" Restore cursor to file position in previous editing session
if !exists('g:spf13_no_restore_cursor')
    function! ResCur()
        if line("'\"") <= line('$')
            silent! normal! g`"
            return 1
        endif
    endfunction
     
    augroup resCur
        autocmd!
        autocmd BufWinEnter * call ResCur()
    augroup END
endif

" Setting up the directories
set backup                  " Backups are nice ...
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

" To disable views add the following to your .vimrc.before.local file:
if !exists('g:spf13_no_views')
    " Add exclusions to mkview and loadview
    " eg: *.*, svn-commit.tmp
    let g:skipview_files = [
                \ '\[example pattern\]'
                \ ]
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


" ================================================================================================================
" ================================================================================================================
" ================================================================================================================
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


highlight clear SignColumn    " SignColumn should match background
highlight clear LineNr        " Current line number row will have same background color in relative mode
"highlight clear CursorLineNr " Remove highlight color from current line number
filetype plugin indent on
syntax on

"# Better Unix / Windows compatibility. #
set viewoptions=folds,options,cursor,unix,slash
set backspace=indent,eol,start


set mouse=a                 " Automatically enable mouse usage
set mousehide               " Hide the mouse cursor while typing
set tabpagemax=30
set winminheight=0          " Windows can be 0 line high
set linespace=1

set shortmess+=filmnrxoOtT  " Abbrev. of messages (avoids 'hit enter')
set history=10000           " Store a ton of history (default is 20)
set hidden                  " Allow buffer switching without saving
set iskeyword-=.            " '.' is an end of word designator
set iskeyword-=#            " '#' is an end of word designator
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

set textwidth=120
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
"set ttyfast
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.

"set virtualedit=onemore        " Allow for cursor beyond last character
"set showbreak=>>>
set matchpairs+=<:>            " Match, to be used with %

"# Auto format comment blocks. #
"set comments=sl:/*,mb:*,elx:*/  

"# Highlight problematic whitespace. #
set list
set listchars=tab:›\ ,extends:#,nbsp:.
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:.


" ================================================================================================================


if !exists('g:ONI')
    set scrolloff=3
else
    command! OniConfig e C:/Users/Brendan/.oni/config.js
    command! EditOniDefaults e C:/Vim/Oni/resources/app/vim/default/bundle/oni-vim-defaults/plugin/init.vim
    " Some things imported from the official ONI defaults.
    if g:ONI_HideStatusBar
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
        set showtabline=0
    endif
endif


" ================================================================================================================
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
noremap j gj
noremap k gk


" End/Start of line motion keys act relative to row/wrap width in the
" presence of `:set wrap`, and relative to line for `:set nowrap`.
" Default vim behaviour is to act relative to text line in both cases
if !exists('g:spf13_no_wrapRelMotion') && !exists('g:ONI')
    " Same for 0, home, end, etc
    function! WrapRelativeMotion(key, ...)
        let l:vis_sel=''
        if a:0
            let l:vis_sel='gv'
        endif
        if &wrap
            execute 'normal!' l:vis_sel . 'g' . a:key
        else
            execute 'normal!' l:vis_sel . a:key
        endif
    endfunction
     
    " Map g* keys in Normal, Operator-pending, and Visual+select
    noremap $ :call WrapRelativeMotion("$")<CR>
    noremap <End> :call WrapRelativeMotion("$")<CR>
    noremap 0 :call WrapRelativeMotion("0")<CR>
    noremap <Home> :call WrapRelativeMotion("0")<CR>
    noremap ^ :call WrapRelativeMotion("^")<CR>
    " Overwrite the operator pending $/<End> mappings from above to force inclusive motion with :execute normal!
    onoremap $ v:call WrapRelativeMotion("$")<CR>
    onoremap <End> v:call WrapRelativeMotion("$")<CR>
    " Overwrite the Visual+select mode mappings from above to ensure the correct vis_sel flag is passed to function
    vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
endif

" " The following two lines conflict with moving to top and bottom of the screen.
" if !exists('g:spf13_no_fastTabs')
"     map <S-H> gT
"     map <S-L> gt
" endif
" 
" " Stupid shift key fixes
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
cmap w!! w !sudo tee % >/dev/null

" Some helpers to edit mode
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Adjust viewports to the same size
map <Leader>= <C-w>=

" Map <Leader>ff to display all lines with keyword under cursor and ask which one to jump to
nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Easier horizontal scrolling
map zl zL
map zh zH


" ================================================================================================================
" ================================================================================================================
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
        colo myMolokai3
    else
        colo chroma
        set background=dark
    endif

    if has('gui_running')
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
    autocmd BufReadPost,BufNew,BufEnter *.pl call FixPerl()
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
command -nargs=1 Sdiff execute 'w !diff -au "%" - > ' . "<args>"

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

nnoremap <leader>nl :call ToggleList()<CR>
nnoremap <leader>jj :pc<CR>

" ================================================================================================================
" Neovim Terminal Config

if has('nvim')
    " Leave insert mode by pressing esc twice
    tnoremap <esc><esc> <C-\><C-n>
    augroup TermNumberFix
        autocmd TermOpen * setlocal nonumber
    augroup END

    " This is the dumbest possible way to set the colors for the terminal but I
    " can't actually think of any better way to do it.
    if !WIN_OR_CYG()
        let s:colorlist = ['#000000', '#cd0000', '#00cd00', '#cdcd00', '#0075ff', '#cd00cd',
                         \ '#00cdcd', '#e5e5e5', '#7f7f7f', '#ff0000', '#00ff00', '#ffff00',
                         \ '#0075ff', '#ff00ff', '#00ffff', '#ffffff']

        let g:terminal_color_0  = s:colorlist[0]
        let g:terminal_color_1  = s:colorlist[1]
        let g:terminal_color_2  = s:colorlist[2]
        let g:terminal_color_3  = s:colorlist[3]
        let g:terminal_color_4  = s:colorlist[4]
        let g:terminal_color_5  = s:colorlist[5]
        let g:terminal_color_6  = s:colorlist[6]
        let g:terminal_color_7  = s:colorlist[7]
        let g:terminal_color_8  = s:colorlist[8]
        let g:terminal_color_9  = s:colorlist[9]
        let g:terminal_color_10 = s:colorlist[10]
        let g:terminal_color_11 = s:colorlist[11]
        let g:terminal_color_12 = s:colorlist[12]
        let g:terminal_color_13 = s:colorlist[13]
        let g:terminal_color_14 = s:colorlist[14]
        let g:terminal_color_15 = s:colorlist[15]
    endif

    command! Term term 'zsh'
endif

" ================================================================================================================

" This makes sure vim knows that /bin/sh is not bash.
let g:is_posix = 1
let g:is_kornshell = 1
let g:perl_sub_signatures = 1

let g:gonvim_draw_split      = 1
let g:gonvim_draw_statusline = 0
let g:gonvim_draw_lint       = 1

fu! DoIfZeroRange() range
    let l:line1 = getline(a:firstline)
    let l:line2 = getline(a:lastline)
    if (l:line1 =~# '\v^[ ]*#[ ]*if 0$') && (l:line2 =~# '\v^[ ]*#[ ]*endif$')
        :execute a:lastline.'d'
        :execute a:firstline.'d'
    else
        call append(a:lastline, '#endif')
        call append(a:firstline - 1, '#if 0')
    endif
endf

command! -range IfZeroRange <line1>,<line2>call DoIfZeroRange()
nnoremap <silent> <leader>cf :IfZeroRange<CR>
command! RecacheRunetimepath call dein#recache_runtimepath()

if has('nvim') && !WIN_OR_CYG() && executable('pypy3')
    let g:python3_host_prog = '/usr/bin/pypy3'
    let g:python_host_prog = '/usr/bin/pypy'
endif


fu! ToggleOneMore()
    if &virtualedit ==# 'onemore'
        set virtualedit=
    else
        set virtualedit=onemore
    endif
endf

nnoremap <silent> <leader>ve :call ToggleOneMore()<CR>

if has('clipboard')
    if has('unnamedplus')
        set clipboard=unnamed,unnamedplus
    else
        set clipboard=unnamed
    endif
endif
