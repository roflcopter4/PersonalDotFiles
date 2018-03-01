zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _oldlist _expand _complete _ignored _match _correct _approximate _prefix
#zstyle ':completion:*' completions 1
#zstyle ':completion:*' format 'Completing %d'
#zstyle ':completion:*' glob 1
#zstyle ':completion:*' group-name ''
#zstyle ':completion:*' insert-unambiguous false
#zstyle ':completion:*' list-colors ''
#zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*' match-original both
zstyle ':completion:*' max-errors 2 numeric
#zstyle ':completion:*' menu select=1
zstyle ':completion:*' preserve-prefix '//[^/]##/'
#zstyle ':completion:*' prompt '$$'
#zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
#zstyle ':completion:*' substitute 1
#zstyle ':completion:*' verbose true
#zstyle :compinstall filename '/home/bml/.zshrc'
#autoload -Uz compinit
#compinit

setopt appendhistory autocd extendedglob notify
