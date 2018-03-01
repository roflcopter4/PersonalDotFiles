
# Intended for use with Cygwin!!!

export PATH=$(echo "$PATH" | sed s,/cygdrive,,g)

#horrific hack
exec zsh


if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi
