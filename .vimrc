" Modeline and Notes " vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker 

" FORMERLY SPF13 Now totally changed. Little remains. It is very sad. Or something.
" let g:spf13_bundle_groups=['general', 'writing', 'neocomplete', 'programming',
"                          \ 'php', 'ruby', 'python', 'javascript', 'html', 'misc',]

" ======================================================================================================
" Environment

" Identify platform
silent function! OSX()
    return has('macunix')
endfunction
silent function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! WINDOWS()
    return  (has('win16') || has('win32') || has('win64'))
endfunction
silent function! CYGWIN()
    return has('win32unix')
endfunction
silent function! WIN_OR_CYG()
    return WINDOWS() || CYGWIN()
endfunction

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


if !($TERM ==# 'linux' || $TERM ==# 'screen' || ($CONEMUPID && !$NVIM_QT) || $SYSID ==# 'FreeBSD') && !has('nvim')
    set encoding=utf-8
    setglobal fileencoding=utf-8
endif


let g:mapleader=' '

if ! has('nvim')
    let &runtimepath = expand('~/.local/share/nvim/site').','.expand('~/.local/share/nvim/site/after').','.&runtimepath
endif

" ======================================================================================================
" Set some general configuration options for what little remains of spf13

let g:spf13_bundle_groups=['general', 'programming', 'misc', 'writing']
let g:spf13_keep_trailing_whitespace = 1
"let g:spf13_no_omni_complete = 1
"let g:spf13_no_easyWindows = 0
let g:spf13_no_fastTabs = 1
let g:spf13_no_restore_cursor = 1


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


" ======================================================================================================
" Some colorscheme setup that must come before the plugin is loaded.

"let g:myMolokai_BG = 'darker'
let g:myMolokai_BG = 'custom'
" Monokai_Brown
"let g:myMolokai_CustomBG = '#272822'
" BLACK_
"let g:myMolokai_CustomBG = '#000000'
" NEAR_BLACK
let g:myMolokai_CustomBG = '#080808'

"let g:myMolokai_FG = 'other'
"let g:myMolokai_FG = 'custom'
"let g:myMolokai_CustomFG =

let g:myMolokaiComment = 'custom'
"let g:myMolokaiComment = 'shiny'
"let g:myMolokaiComment = 'comment_grey'
"let g:myMolokaiComment_Custom = '#70F0F0'
let g:myMolokaiComment_Custom ='#5F87AF'

let g:myNova_BG = '#1B1D1E'


" ======================================================================================================
" Whitelisted filetypes for operator highlighting.

" Set the following to avoid loading the plugin
"let g:loaded_operator_highlight = 1
let g:ophigh_filetypes = [ 'c', 'cpp', 'rust', 'lua', 'go']

let g:ophigh_highlight_link_group = 'Operator'
"let g:ophigh_color_gui = '#d33682'
"let g:ophigh_color_gui = '#42A5F5'  ' Lightish-blue

"let g:negchar_highlight_link_group = 'NegationChar'
"let g:negchar_color_gui = '#66BB6A'
let g:negchar_color_gui = '#f92672'
"let g:negchar_color_gui = '#d33682'

"let g:structderef_highlight_link_group = 'Operator'
let g:structderef_color_gui = '#42A5F5'



" ######################################################################################################
" ######################################################################################################
" ######################################################################################################
" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" Plugin Setup

let g:plugin_manager = 'dein'
"let g:dein#install_max_processes = 12
filetype off

function! AddPlugin(name,...)
    if exists('a:1')
        call dein#add(a:name, a:1)
    else
        call dein#add(a:name)
    endif
endfunction

function! IsSourced(name)
    return dein#is_sourced(a:name)
endfunction

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
    call AddPlugin(expand(g:dein_path))
    call AddPlugin('haya14busa/dein-command.vim')

    if executable('ag') || executable('ack-grep') || executable('ack')
        call AddPlugin('mileszs/ack.vim')
    endif

    " My own stuff should be first!
    call AddPlugin('roflcopter4/PersonalVimStuff', {'merged': 0})
     
    " General ---------
    call AddPlugin('MarcWeber/vim-addon-mw-utils')
    call AddPlugin('ctrlpvim/ctrlp.vim')
    call AddPlugin('easymotion/vim-easymotion')
    call AddPlugin('gcmt/wildfire.vim')
    call AddPlugin('huawenyu/neogdb.vim')
    call AddPlugin('jiangmiao/auto-pairs')
    call AddPlugin('jistr/vim-nerdtree-tabs')
    call AddPlugin('kana/vim-textobj-indent')
    call AddPlugin('kana/vim-textobj-user')
    call AddPlugin('mbbill/undotree')
    call AddPlugin('osyo-manga/vim-over')
    call AddPlugin('powerline/fonts')
    call AddPlugin('rhysd/conflict-marker.vim')
    call AddPlugin('scrooloose/nerdtree')
    call AddPlugin('tacahiroy/ctrlp-funky')
    call AddPlugin('terryma/vim-multiple-cursors')
    call AddPlugin('tomtom/tlib_vim')
    call AddPlugin('tpope/vim-abolish.git')
    call AddPlugin('tpope/vim-repeat')
    call AddPlugin('tpope/vim-surround')
    call AddPlugin('vim-scripts/matchit.zip')
    call AddPlugin('vim-scripts/restore_view.vim')
    call AddPlugin('vim-scripts/sessionman.vim')
      
    " Writing -----
    call AddPlugin('reedes/vim-litecorrect')
    call AddPlugin('reedes/vim-textobj-sentence')
    call AddPlugin('reedes/vim-textobj-quote')
    call AddPlugin('reedes/vim-wordy')
      
    " General Programming -----
    call AddPlugin('tpope/vim-fugitive')
    call AddPlugin('mattn/webapi-vim')
    call AddPlugin('mattn/gist-vim')
    call AddPlugin('scrooloose/nerdcommenter')
    call AddPlugin('godlygeek/tabular')
    call AddPlugin('luochen1990/rainbow')
    call AddPlugin('junegunn/vim-easy-align')
    if executable('ctags')
        call AddPlugin('majutsushi/tagbar')
    endif
          
    " PHP --------
    call AddPlugin('spf13/PIV')
    call AddPlugin('arnaud-lb/vim-php-namespace')
    call AddPlugin('beyondwords/vim-twig')
     
    " Python ---------
    call AddPlugin('klen/python-mode')
    call AddPlugin('yssource/python.vim')
    call AddPlugin('vim-scripts/python_match.vim')
    call AddPlugin('vim-scripts/pythoncomplete')
      
    " Javascript ----------
    call AddPlugin('elzr/vim-json')
    call AddPlugin('groenewege/vim-less')
    call AddPlugin('pangloss/vim-javascript')
    call AddPlugin('briancollins/vim-jst')
    call AddPlugin('kchmck/vim-coffee-script')
    
    " Scala ---------
    call AddPlugin('derekwyatt/vim-scala')
    call AddPlugin('derekwyatt/vim-sbt')
    call AddPlugin('vim-scripts/xptemplate')
    
    " Haskell ----------
    call AddPlugin('Twinside/vim-haskellConceal')
    call AddPlugin('Twinside/vim-haskellFold')
    call AddPlugin('adinapoli/cumino')
    call AddPlugin('bitc/vim-hdevtools')
    call AddPlugin('dag/vim2hs')
    call AddPlugin('eagletmt/ghcmod-vim')
    call AddPlugin('eagletmt/neco-ghc')
    call AddPlugin('lukerandall/haskellmode-vim')
    call AddPlugin('travitch/hasksyn')
    
    " HTML ---------
    call AddPlugin('hail2u/vim-css3-syntax')
    call AddPlugin('gorodinskiy/vim-coloresque')
    call AddPlugin('tpope/vim-haml')
    "call AddPlugin('amirh/HTML-AutoCloseTag')

    " Markdown
    call AddPlugin('vim-pandoc/vim-pandoc')
    call AddPlugin('vim-pandoc/vim-pandoc-syntax')

    " Moar Languages ------
    call AddPlugin('rsmenon/vim-mathematica')
    call AddPlugin('dag/vim-fish')
    call AddPlugin('fsharp/vim-fsharp')
    call AddPlugin('chaimleib/vim-renpy')
    call AddPlugin('gentoo/gentoo-syntax')
    call AddPlugin('rust-lang/rust.vim')

    " Misc ----------
    call AddPlugin('Chiel92/vim-autoformat')
    call AddPlugin('PProvost/vim-ps1')
    call AddPlugin('carlosgaldino/elixir-snippets')
    call AddPlugin('cespare/vim-toml')
    call AddPlugin('chrisbra/Colorizer')
    call AddPlugin('elixir-lang/vim-elixir')
    call AddPlugin('equalsraf/neovim-gui-shim')
    call AddPlugin('idanarye/vim-vebugger')
    call AddPlugin('junegunn/fzf.vim')
    call AddPlugin('mattreduce/vim-mix')
    call AddPlugin('quentindecock/vim-cucumber-align-pipes')
    call AddPlugin('rodjek/vim-puppet')
    call AddPlugin('saltstack/salt-vim')
    call AddPlugin('tpope/vim-cucumber')
    call AddPlugin('tpope/vim-markdown')
    call AddPlugin('vim-scripts/Vimball')
    call AddPlugin('xolox/vim-easytags')
    call AddPlugin('xolox/vim-misc')
    call AddPlugin('xolox/vim-shell')

    call AddPlugin('Shougo/vimproc.vim', {'merged': 0, 'build': 'make'})
    call AddPlugin('vim-perl/vim-perl',  {'merged': 0, 'build': 'make -k contrib_syntax carp heredoc-sql try-tiny heredoc-sql-mason'
                                                              \.' dancer js-css-in-mason method-signatures moose test-more'})

    "call AddPlugin('Blackrush/vim-gocode')
    "call AddPlugin('fatih/vim-go')
    "call AddPlugin('dzhou121/gonvim-fuzzy')
    "call dein#add('app-vim/searchcomplete')
    "call AddPlugin('nathanaelkane/vim-indent-guides')
    "call AddPlugin('maralla/validator.vim')
    "call AddPlugin('neomake/neomake')
    "call AddPlugin('c0r73x/neotags.nvim')

    if !exists('g:ONI')
        call AddPlugin('Yggdroot/indentLine')
    endif

    if has('nvim') && g:use_ale == 1
        call AddPlugin('w0rp/ale')
        call AddPlugin('Shougo/deoplete.nvim')
        call AddPlugin('zchee/deoplete-jedi')
        call AddPlugin('Shougo/neco-vim')
        call AddPlugin('artur-shaik/vim-javacomplete2')
    else
        if has('python3') || has('nvim')
            call AddPlugin('Valloric/YouCompleteMe', {'merged': 0, 'build': 'python3 install.py --all'})
            call AddPlugin('rdnetto/YCM-Generator')
        elseif has('python')
            call AddPlugin('Valloric/YouCompleteMe', {'merged': 0, 'build': 'python2 install.py --all'})
            call AddPlugin('rdnetto/YCM-Generator')
        endif
    endif

    if (has('nvim') || !s:VimUsesPowerline) && !exists('g:ONI')
        call AddPlugin('vim-airline/vim-airline')
        call AddPlugin('vim-airline/vim-airline-themes')
    endif
    call AddPlugin('https://anongit.gentoo.org/git/proj/eselect-syntax.git')
     
      
    " Colour Schemes ----------------
    call AddPlugin('MaxSt/FlatColor')
    call AddPlugin('mhinz/vim-janah')
    call AddPlugin('iCyMind/NeoSolarized')
    call AddPlugin('joshdick/onedark.vim')
    call AddPlugin('reewr/vim-monokai-phoenix')
    call AddPlugin('KeitaNakamura/neodark.vim')
    call AddPlugin('dunckr/vim-monokai-soda')
    call AddPlugin('tyrannicaltoucan/vim-quantum')
    call AddPlugin('zanglg/nova.vim')
    call AddPlugin('crater2150/vim-theme-chroma')
    call AddPlugin('muellan/am-colors')
    call AddPlugin('jaromero/vim-monokai-refined')
    call AddPlugin('vim-scripts/darkspectrum')
    call AddPlugin('lanox/lanox-vim-theme')
    call AddPlugin('benjaminwhite/Benokai')
    call AddPlugin('Valloric/vim-valloric-colorscheme')
    call AddPlugin('petelewis/vim-evolution')
    call AddPlugin('ratazzi/blackboard.vim')
    call AddPlugin('nielsmadan/harlequin')
    call AddPlugin('morhetz/gruvbox')
    call AddPlugin('mhartington/oceanic-next')
    call AddPlugin('xolox/vim-colorscheme-switcher')

    call dein#local(expand('~/.vim/bundles/findent'))
     

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


" ######################################################################################################
" ######################################################################################################
" ######################################################################################################
" ======================================================================================================
" ======================================================================================================
" ======================================================================================================
" Plugin Config


" PIV
if IsSourced('tabular')
    let g:DisableAutoPHPFolding = 0
    let g:PIVAutoClose = 0
endif


" Misc
if IsSourced('matchit.zip')
    let b:match_ignorecase = 1
endif


" AutoCloseTag
if IsSourced('HTML-AutoCloseTag')
    " Make it so AutoCloseTag works for xml and xhtml files as well
    augroup HTML_CloseTag
        autocmd FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
    augroup END
    nmap <Leader>ac <Plug>ToggleAutoCloseMappings
endif


" Ack-vim
if IsSourced('ack.vim')
    if executable('ag')
        let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
    elseif executable('ack-grep')
        let g:ackprg='ack-grep -H --nocolor --nogroup --column'
        call AddPlugin('mileszs/ack.vim')
    elseif executable('ack')
        call AddPlugin('mileszs/ack.vim')
    endif
endif


" NerdTree
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


" Tabularize
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


" Session List
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
if IsSourced('sessionman.vim')
    nmap <leader>sl :SessionList<CR>
    nmap <leader>ss :SessionSave<CR>
    nmap <leader>sc :SessionClose<CR>
endif


" JSON
nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
let g:vim_json_syntax_conceal = 0


" PyMode
" Disable if python support not present
if !has('python') && !has('python3')
    let g:pymode = 0
endif
if IsSourced('python-mode')
    let g:pymode_options = 1
    let g:pymode_lint = 0
    let g:pymode_lint_checkers = ['flake8', 'pep8', 'pyflakes']
    "let g:pymode_lint_checkers = ['flake8','pyflakes']
    "let g:pymode_lint_on_fly = 1

    let g:pymode_indent = 1
    let g:pymode_options_colorcolumn = 0
    let g:pymode_python = 'python3'
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


" ctrlp
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
endif


" TagBar
if IsSourced('tagbar')
    nnoremap <silent> <leader>tt :TagbarToggle<CR>
endif


"Rainbow
if IsSourced('rainbow')
    let g:rainbow_active = 1
    " God, what a horrific mess.
        "\    'guifgs': ['DodgerBlue1', 'darkorange1', 'green2', 'firebrick1'],
    let g:rainbow_conf = {
        \    'guifgs': ['DodgerBlue1', 'chartreuse3', 'darkorange1',  'firebrick1', 'orchid2'],
        \    'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
        \    'operators': '_,_',
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
        \        'css': 0,
        \    }
    \}
endif


"Fugitive
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


" Snippets
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


" UndoTree
if IsSourced('undotree')
    nnoremap <Leader>u :UndotreeToggle<CR>
    " If undotree is opened, it is likely one wants to interact with it.
    let g:undotree_SetFocusWhenToggle=1
endif


" indent_guides
if IsSourced('vim-indent-guides')
    let g:indent_guides_start_level = 1
    let g:indent_guides_guide_size = 0
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_auto_colors = 1
    let g:indent_guides_color_change_percent = 30
    "autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#808080
    "autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#465457
endif


" Wildfire
if IsSourced('wildfire.vim')
    let g:wildfire_objects = {
                \ '*' : ["i'", 'i"', 'i)', 'i]', 'i}', 'ip'],
                \ 'html,xml' : ['at'],
                \ }
endif


" vim-airline
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
    let g:airline#extensions#whitespace#checks = [ 'trailing', 'indent', 'long', 'mixed-indent-file' ]
    nnoremap <silent> <leader>al :AirlineRefresh<CR>
    if IsSourced('vim-airline-themes') && $TERM !=# 'linux'
        "let g:airline_theme = 'molokai'
        let g:airline_theme = 'papercolor'
    endif

    augroup Airline
        autocmd!
        autocmd BufNew,BufAdd * call airline#update_statusline()
        "autocmd BufRead,BufEnter * :AirlineRefresh
        autocmd BufEnter * call airline#update_statusline()
        autocmd BufReadPost * call airline#update_statusline()
        autocmd BufWinEnter * call airline#update_statusline()
        autocmd BufHidden * call airline#update_statusline()
    augroup END

    nnoremap <silent> <leader>bn :bp<CR>:call airline#update_statusline()<CR>
    nnoremap <silent> <leader>bm :bn<CR>:call airline#update_statusline()<CR>

else
    augroup Airline
        au!
    augroup END

    nnoremap <silent> <leader>bn :bp<CR>
    nnoremap <silent> <leader>bm :bn<CR>
endif


" ### NEOMAKE ###
if IsSourced('neomake')
    let g:neomake_c_lint_maker = {
        \ 'exe': 'lint',
        \ 'args': ['--option', 'x'],
        \ 'errorformat': '%f:%l:%c: %m',
        \ }
    let g:neomake_error_sign = {
                \ 'text': '>>',
                \ 'texthl': 'ErrorMsg',
                \ }
    hi MyWarningMsg ctermbg=3 ctermfg=0
    let g:neomake_warning_sign = {
                \ 'text': '>>',
                \ 'texthl': 'MyWarningMsg',
                \ }
    "Disable inherited syntastic
    let g:syntastic_mode_map = {
        \ 'mode': 'passive',
        \ 'active_filetypes': [],
        \ 'passive_filetypes': []
        \ }
         
    let g:neomake_serialize = 1
    let g:neomake_serialize_abort_on_error = 1
    let g:neomake_highlight_lines = 1
    let g:neomake_place_signs=0
    let g:neomake_verbose=2
    let g:neomake_echo_current_error=1
    let g:neomake_open_list=0
    let g:neomake_c_enabled_makers=['gcc']
    let g:neomake_c_enabled_makers=['clangcheck']
    let g:neomake_make_maker = {
        \ 'exe': 'make',
        \ 'args': ['--build'],
        \ 'errorformat': '%f:%l:%c: %m',
        \ }
    
    augroup my_neomake_highlights
        au!
        autocmd ColorScheme *
          \ hi link NeomakeError SpellBad |
          \ hi link NeomakeWarning SpellCap
    augroup END
    
    autocmd! BufReadPost,BufWritePost * Neomake
endif


" ### ALE ###
if IsSourced('ale')
    let g:airline#extensions#ale#enabled = 1
    let g:ale_lint_on_text_changed = 1 
    let g:ale_sign_column_always = 1
    let g:ale_lint_on_insert_leave = 0
    let g:ale_linters_explicit = 0
    let g:ale_sh_shell_default_shell = 'sh'

    " C, C++, C# {
        let g:ale_c_gcc_options   = '-Wall -Iinc -Wpedantic -Wextra'
        let g:ale_c_clang_options = '-Wall -Wpedantic -Wextra -Iinc'

        let g:ale_c_clangtidy_checks = ['*', '-*-braces-around-statements', '-android*',
                                      \ '-llvm-header-guard']

        let b:ale_linters_c_group = ['gcc', 'clangtidy', 'cppcheck']
        let b:ale_linters_c = {'c':      b:ale_linters_c_group,
                             \ 'cpp':    b:ale_linters_c_group,
                             \ 'csharp': b:ale_linters_c_group}
    "}

    " Python {
        let b:ale_linters_py = {'python': ['flake8', 'pyflakes']}
        let g:ale_python_pylint_executable = '/dev/null'   " FUCK PYLINT
        let g:ale_python_flake8_options = '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,E501' 
    "}

    " Perl {
        "let b:ale_linters_perl = {'perl': ['perl', 'perlcritic']}
        let b:ale_linters_perl = {'perl': ['perl']}
        let g:ale_perl_perlcritic_options = '-4'
    "}

    let g:ale_linters =  {}
    call extend(g:ale_linters, b:ale_linters_c)
    call extend(g:ale_linters, b:ale_linters_py)
    call extend(g:ale_linters, b:ale_linters_perl)


    "let g:ale_linter_aliases = { 'zsh': 'sh',
    "                           \ 'csh': 'sh'
    "                           \}

    ca ale ALE
endif


if IsSourced('vim-vebugger')
    let g:vebugger_leader='<Leader>d'
endif


" ### EASYTAGS ###
if IsSourced('vim-easytags')
    let g:easytags_python_enabled = 1
    "let g:easytags_dynamic_files = 1
    "if LINUX() || ( IsSourced('vim-shell') && IsSourced('vim-misc') )
    "    let g:easytags_async = 1
    "endif
    nnoremap <leader>tag :UpdateTags<CR>
    if $IS_CYGWIN && !CYGWIN()
        "set tags=expand("$USERPROFILE/_vimtags"),expand("$USERPROFILE/_vimtags")
        let s:vimtags_file = expand('$USERPROFILE/_vimtags')
        let &tags = s:vimtags_file . ',' . &tags
    endif

    "let g:easytags_autorecurse = 1
    let g:easytags_include_members = 1
    let g:easytags_async = 1
    let g:easytags_always_enabled = 1


    let g:easytags_languages = {
    \   'c': {
    \       'args': ['--fields=+l', '--c-kinds=*']
    \   }
    \}

    "highlight link cMember 
    highlight def link shFunctionTag Type
endif


" ### DEOCOMPLETE ###
if IsSourced('deoplete.nvim')
    let g:deoplete#enable_at_startup = 1
    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif
    " let g:deoplete#disable_auto_complete = 1
    " deoplete tab-complete
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
    "inoremap <expr><CR> pumvisible() ? "\<c-y>" : "\<CR>"
    augroup DeocompleteSetup
        autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
        " tern
        autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
    augroup END
endif


" ### YouCompleteMe ###
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


" ### Indent Line ###
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


" ### Autoformat Config ###
if IsSourced('vim-autoformat')
    augroup c_formatting
        autocmd FileType c,c++,cs setlocal cindent sw=8
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
            let g:formatdef_clangformat = "'clang-format -i'.&shiftwidth.' -l'.ZeroIsOneThousand().' -- -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\"'"
        else
            let g:formatdef_clangformat = "'clang-format -- -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" -style=\"{BasedOnStyle: WebKit,".
                                            \" AlignTrailingComments: true, '.(&textwidth ? 'ColumnLimit: '.&textwidth.', ' : '').(&expandtab ? 'UseTab: Never,".
                                            \" IndentWidth: '.shiftwidth() : 'UseTab: Always').'}\"'"
        endif
    "}
    
    "--------------------------------------------------------------------------------------

    "### C {
        let g:formatdef_astyle_c    = g:_Astyle_Allman_ . g:_Astyle_c_
        let g:formatdef_astyle_c_KR = g:_Astyle_KR_     . g:_Astyle_c_
        let g:formatters_c          = ['clangformat', 'astyle_c_KR', 'astyle_c']
    "}

    "### C++ {
        let g:formatdef_astyle_cpp    = g:_Astyle_Allman_ . g:_Astyle_cpp_
        let g:formatdef_astyle_cpp_KR = g:_Astyle_KR_     . g:_Astyle_cpp_
        let g:formatters_cpp          = ['clangformat', 'astyle_cpp_KR', 'astyle_cpp']
    "}

    "### C-sharp {
        let g:formatdef_astyle_cs    = g:_Astyle_Allman_ . g:_Astyle_cs_
        let g:formatdef_astyle_cs_KR = g:_Astyle_KR_     . g:_Astyle_cs_
        let g:formatters_cs          = ['clangformat', 'astyle_cs_KR', 'astyle_cs']
    "}


    "### Some generic options
    let g:autoformat_autoindent = 0
    let g:autoformat_retab = 0
    let g:autoformat_remove_trailing_spaces = 0
    let g:autoformat_verbosemode = 1
endif


" ### Line numbering ###
if IsSourced('numbers.vim') || IsSourced('PersonalVimStuff')
    nnoremap <F3> :NumbersToggle<CR>
    let g:enable_numbers = 0
    "let g:numbers_default_norelative = 1
endif


" ### NEOTAGS ###
if IsSourced('neotags.nvim')
    let g:neotags_enabled = 1
    let g:neotags_highlight = 1
    let g:neotags_run_ctags = 1
    let g:neotags_verbose = 1

    let g:neotags#cpp#order = 'ced'
    let g:neotags#c#order = 'ced'
    highlight link cTypeTag Special
    highlight link cppTypeTag Special
    highlight link cEnumTag Identifier
    highlight link cppEnumTag Identifier
    highlight link cPreProcTag PreProc
    highlight link cppPreProcTag PreProc
    let g:neotags#cpp#order = 'cedfm'
    let g:neotags#c#order = 'cedfm'
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



" ######################################################################################################
" ######################################################################################################
" ######################################################################################################
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
    %s/\s\+$//e
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


"if !has('gui')
    "set term=$TERM          " Make arrow and other keys work
"endif

if count(g:spf13_bundle_groups, 'writing')
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
    " 
    "hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
    "hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
    "hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE
     
    " Some convenient mappings
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
if !exists('g:spf13_no_omni_complete')
    " Enable omni-completion.
    augroup spf13_omni_complete
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
    augroup END
endif

" Automatically switch to the current file directory when a new buffer is opened.
if !exists('g:spf13_no_autochdir')
    augroup spf13_autchdir
        autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    augroup END
endif

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
set linespace=0             " No extra spaces between rows

set shortmess+=filmnrxoOtT  " Abbrev. of messages (avoids 'hit enter')
set history=10000           " Store a ton of history (default is 20)
set hidden                  " Allow buffer switching without saving
set iskeyword-=.            " '.' is an end of word designator
set iskeyword-=#            " '#' is an end of word designator
"set iskeyword-=-           " '-' is an end of word designator

set showmode                " Display the current mode
set number                  " Line numbers on
set nospell                 " Spell checking on
set showmatch               " Show matching brackets/parenthesis
set incsearch               " Find as you type search
set hlsearch                " Highlight search terms
set smartcase               " Case sensitive when uc present

set autoindent              " Indent at the same level of the previous line
set cindent
"set smartindent             " Better autoindent
set breakindent

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
set ttyfast
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.



"set virtualedit=onemore        " Allow for cursor beyond last character
"set showbreak=>>>
"set matchpairs+=<:>            " Match, to be used with %

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
cmap cwd lcd %:p:h
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


" ######################################################################################################
" ######################################################################################################
" ######################################################################################################
" ================================================================================================================
" ================================================================================================================
" ================================================================================================================
" Other


" Catch all for shitty terminals.
if $TERM ==# 'linux' || $TERM ==# 'screen' || ($CONEMUPID && !$NVIM_QT) || ($SYSID ==# 'FreeBSD' && $TERM ==# 'xterm')
    set notermguicolors
    colo default
    set background=dark
else
    scriptencoding utf-8
    set termguicolors
    if IsSourced('PersonalVimStuff')
        colo myMolokai3
    else
        colo chroma
        set background=dark
    endif

    if has('gui_running')
        set guifont=DinaPowerline\ 10
    endif
endif

" ================================================================================================================

set fileformats=unix,dos,mac

augroup MyCrap
    autocmd!
    autocmd BufRead *.py setlocal colorcolumn=0
augroup END

if has('nvim')
    augroup GuiPls
        autocmd!
        autocmd GuiEnter,BufEnter,BufAdd,BufReadpost * :GuiLinespace 0<CR>
    augroup end
endif

augroup PerlFix
    autocmd!
    autocmd BufReadPost,BufNew,BufEnter *.pl call FixPerl()
augroup END

function! FixPerl()
    setlocal indentkeys=
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


" ================================================================================================================
" ### MY MAPPINGS ###

nnoremap <leader>p "+p
nnoremap <leader>yy "+yy"*yy
vnoremap <leader>y "+y

nnoremap <leader>ww :w<CR>
nnoremap <leader>qq :q!<CR>
nnoremap <leader>QQ :qa!<CR>

nnoremap <leader>buf :buffers<CR>
command Config e $MYVIMRC

nnoremap <leader>nl :set nolist<CR>

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
endif

" ================================================================================================================

" This makes sure vim knows that /bin/sh is not bash.
let g:is_posix = 1
let g:is_kornshell = 1
let g:perl_sub_signatures = 1

let g:gonvim_draw_split      = 1
let g:gonvim_draw_statusline = 0
let g:gonvim_draw_lint       = 1

function! DoIfZeroRange() range
    let l:line1 = getline(a:firstline)
    let l:line2 = getline(a:lastline)
    if (l:line1 =~# '\v^[ ]*#[ ]*if 0$') && (l:line2 =~# '\v^[ ]*#[ ]*endif$')
        :execute a:lastline.'d'
        :execute a:firstline.'d'
    else
        call append(a:lastline, '#endif')
        call append(a:firstline - 1, '#if 0')
    endif
endfunction

command! -range IfZeroRange <line1>,<line2>call DoIfZeroRange()
noremap <silent> <leader>cf :IfZeroRange<CR>

if exists('$NVIM_QT')
    augroup NvimQt
        autocmd Bufenter,BufAdd,BufCreate,BufRead * GuiLinespace 1
    augroup END
endif

"if has('clipboard')
"if has('unnamedplus')  " When possible use + register for copy-paste
"set clipboard=unnamed,unnamedplus
"else         " On mac and Windows, use * register for copy-paste
"set clipboard=unnamed
"endif
"endif
