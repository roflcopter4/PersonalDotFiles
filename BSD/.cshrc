# $FreeBSD: head/share/skel/dot.cshrc 278616 2015-02-12 05:35:00Z cperciva $
#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
#

setenv CLICOLOR_FORCE 1
#setenv CC	/usr/local/bin/gcc8
#setenv CXX	/usr/local/bin/g++8
#setenv CPP	/usr/local/bin/cpp8
setenv CCVER	gcc8

alias h		"history 25"
alias j		"jobs -l"

if ( ( `uname` == 'Linux' ) || ( { command -v gls } ) ) then
    if ( `uname` == 'Linux' ) then
	alias ls	"ls -h --color=always --group-directories-first"
    else
	alias ls	"gls -h --color=always --group-directories-first"
    endif
	alias ll	"ls -go"
	alias la	"ls -A"
	alias lla	"ls -goA"
	alias lls	"ls -go  | less -r"
	alias las	"ls -goA | less -r"
else
	alias ls	"ls -FG"
	alias la	"ls -A"
	alias ll	"ls -l"
	alias lla	"ls -lA"
	alias lls	"ll  | less -r"
	alias las	"lla | less -r"
endif

# These are normally set through /etc/login.conf.  You may override them here
# if wanted.
#set path = (/usr/local/CC /usr/local/llvm-devel/bin $HOME/bin /usr/local/sbin /usr/local/bin /usr/pkg/sbin /usr/pkg/bin /usr/sbin /usr/bin /sbin /bin) 
set path = (/usr/local/llvm-devel/bin $HOME/bin /usr/local/sbin /usr/local/bin /usr/pkg/sbin /usr/pkg/bin /usr/sbin /usr/bin /sbin /bin) 
# setenv	BLOCKSIZE	K
# A righteous umask
# umask 22

setenv	EDITOR	vi
setenv	PAGER	less

# If sh is ever switched to, this tells it where to look for its rc file.
setenv	ENV	~/.shrc

if ($?prompt) then
	# An interactive shell -- set some stuff up
	set prompt = "%N@%m %~ %# "
	set promptchars = "%#"

	set filec
	set history = 10000
	set savehist = (10000 merge)
	set autolist = ambiguous
	# Use history to aid expansion
	set autoexpand
	set autorehash
	set mail = (/var/mail/$USER)
	if ( $?tcsh ) then
		bindkey "^W" backward-delete-word
		bindkey -k up history-search-backward
		bindkey -k down history-search-forward
	endif

endif

alias use_clang_FORCE 'setenv CC /usr/local/bin/clang-devel; setenv CXX /usr/local/bin/clang++-devel; setenv CPP /usr/local/bin/clang-cpp-devel; setenv CCVER clangnext'
alias use_gcc_FORCE 'setenv CC /usr/local/bin/gcc8; setenv CXX /usr/local/bin/g++8; setenv CPP /usr/local/bin/cpp8; setenv CCVER gcc8'

alias use_clang 'setenv CCVER clangnext'
alias use_gcc   'setenv CCVER gcc8'

alias mk_clang	'echo "CCVER=clangnext" > /etc/make.conf'
alias mk_gcc	'echo "CCVER=gcc8" > /etc/make.conf'

