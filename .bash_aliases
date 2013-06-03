alias svnrev="svn info ${SVN_ROOT} | awk '/Revision:/ {print $2}'"
alias svndiff="svn diff --diff-cmd svnmeld | filterdiff --clean"
alias svnlog="svn up; svn log --stop-on-copy"
alias svnlogdiff="svndiff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD"
alias branchdiff="svn diff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD | filterdiff --clean"
alias webserve="python -m SimpleHTTPServer"

# sf - search within files matching given content below PWD
alias sf="find . ! \( -name .svn -prune \) -a -type f -print0 | xargs -0 grep -Hn --color"

# sfl - list files below current PWD
alias sfl="find . ! \( -name .svn -prune \) -a -type f"

# sn - search for files matching given name below PWD
alias sn="find . ! \( -name .svn -prune \) -a -type f -name"

# sfn - search for files matching given content below PWD; display name only
alias sfn="find . ! \( -name .svn -prune \) -a -type f -print0 | xargs -0 grep -l"

alias http_head="curl -I"
alias cdtemp='td=$(mktemp -d); pushd $td; bash -c "trap \"rm -rf ${td}\" EXIT; bash"; popd;'

alias pp="egrep '^\s*(def|class) '"


# en - launch an editor to edit file(s) matching given name. Analogous to sn.
en () {
  MY_EDITOR="$VISUAL"
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR="$EDITOR"
  fi
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR=/usr/bin/vim
  fi
  # see http://stackoverflow.com/questions/3852616/xargs-with-command-that-open-editor-leaves-shell-in-weird-state
  export MY_EDITOR
  find . ! \( -name .svn -prune \) -a -type f -name $1 | xargs sh -c '${MY_EDITOR} $@ < /dev/tty' "${MY_EDITOR}"
}

# efn - launch an editor to edit file(s) matching given content. Analogous to sfn.
efn () {
  MY_EDITOR="$VISUAL"
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR="$EDITOR"
  fi
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR=/usr/bin/vim
  fi
  # see http://stackoverflow.com/questions/3852616/xargs-with-command-that-open-editor-leaves-shell-in-weird-state
  export MY_EDITOR
  find . ! \( -name .svn -prune \) -a -type f -print0 | xargs -0 grep -l "$1" | xargs sh -c '${MY_EDITOR} $@ < /dev/tty' "${MY_EDITOR}"
}

# map - apply each of params $2..$n to the program given as $1
# Example usage: 'map sn file1.txt file2.txt file3.txt'
map () { prog="$1"; shift; for arg in $@; do eval "$prog" "$arg"; done }

# mcd - make and change to directory
# mcd is part of mtools by default (change MSDOS directory)
mcd () {
  mkdir -p $1 && cd $1
}

sl () {
 sed -n "$1p"
}

if [[ $(uname) = 'Darwin' ]] ; then
    alias gvim=mvim
    alias vim='mvim -v'
    alias aplay="sox -r 8000 -b 8 -c 1 -t raw -e unsigned-integer - -d"
fi

# http://superuser.com/questions/38984/linux-equivalent-command-for-open-command-on-mac-windows
case $OSTYPE in
    linux*)
        # overwrite the original name for openvt
        alias open="xdg-open"
esac

# 'column-number' - filter to extract the relevant column
function cn {
  awk "{print \$$1;}"
}

# rmake - run a 'top-level' make from within a lower directory
function rmake {
  pushd . > /dev/null
  while true ; do
    if [[ -e Makefile ]]; then
      make $@
      break
    fi
    if [[ $PWD = '/' ]] ; then
      break
    fi
    cd ..
  done
  popd > /dev/null
}

# tmux setup
function ttmux {
    if ! tmux has-session -t dev; then
        tmux new-session -s dev -d
        tmux split-window -h -t dev
        tmux split-window -t dev
        tmux split-window -t dev
        tmux split-window -h -p 33 -t dev
        tmux clock-mode
        tmux new-window -t dev
        tmux select-window -t dev:1
    fi
    tmux attach -t dev
}