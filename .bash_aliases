alias svnrev="svn info ${SVN_ROOT} | awk '/Revision:/ {print $2}'"
alias svndiff="svn diff --diff-cmd svnmeld | filterdiff --clean"
alias svnlog="svn up; svn log --stop-on-copy"
alias svnlogdiff="svndiff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD"
alias svnlogdifft="svn diff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD"
alias svnlogstat="svn diff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD --summarize"
alias branchdiff="svn diff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD | filterdiff --clean"
alias gitdiff="git difftool -d"
alias webserve="python -m SimpleHTTPServer"

alias _findnovcs="find . ! \( -name .svn -prune -o -name .git -prune -o -name .hg -prune \) -a"
# sf - search within files matching given content below PWD
alias sf="_findnovcs -type f -print0 | xargs -0 grep -IHn --color"

# sfl - list files below current PWD
alias sfl="_findnovcs -type f"

# sn - search for files matching given name below PWD
alias sn="_findnovcs -type f -name"

# sfn - search for files matching given content below PWD; display name only
alias sfn="_findnovcs -type f -print0 | xargs -0 grep -Il"

alias http_head="curl -I"
alias cdtemp='td=$(mktemp -d); pushd $td; bash -c "trap \"rm -rf ${td}\" EXIT; bash"; popd;'

alias pp="egrep '^\s*(def|class) '"

cdn() {
  local TARGET="$1"
  if [[ -z ${TARGET} ]] ; then
    return
  fi
  local TARGET_FILE=$(_findnovcs -type f -name "${TARGET}" | head -n 1)
  if [[ -f ${TARGET_FILE} ]] ; then
    local TARGET_DIR=$(dirname ${TARGET_FILE})
    if [[ -d "${TARGET_DIR}" ]] ; then
      echo ">> ${TARGET_DIR}"
      cd ${TARGET_DIR}
    fi
  fi
}

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
  _findnovcs -type f -name $1 | xargs sh -c '${MY_EDITOR} $@ < /dev/tty' "${MY_EDITOR}"
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
  _findnovcs -type f -print0 | xargs -0 grep -Il "$1" | xargs sh -c '${MY_EDITOR} $@ < /dev/tty' "${MY_EDITOR}"
}

sfr () {
  if [[ $# != 2 ]] ; then
    echo "Usage: sfr [old] [new]"
    return 1
  fi
  for DELIM in / : \# \~; do
    if ! [[ "$1" =~ ${DELIM} ]] ; then
      break
    fi
  done
  if [[ "$1" =~ ${DELIM} ]] ; then
     echo "Old string contains delimiters"
     return 1
  fi
  for FILE in $(_findnovcs -type f -print0 | xargs -0 grep -Il "$1") ; do
    sed -i~ -e "s${DELIM}$1${DELIM}$2${DELIM}g" "$FILE"
  done
}

# map - apply each of params $2..$n to the program given as $1
# Example usage: 'map sn file1.txt file2.txt file3.txt'
map () { prog="$1"; shift; for arg in "$@"; do eval "$prog" '"$arg"'; done }
# fold - apply binary operation to first two args, shift, repeat.
# Example usage: 'echo "hello" > a; fold cp a b c d e f g'
fold () { prog="$1"; shift; while true; do [[ -z "$2" ]] && break; eval "$prog" '"$1"' '"$2"'; shift; done }

# mcd - make and change to directory
# mcd is part of mtools by default (change MSDOS directory)
mcd () {
  mkdir -p $1 && cd $1
}

# sumcol - sum given column of csv input
sumcol () {
  awk -F, "{s += \$$1} END {print s}"
}

sl () {
 # select line. e.g. '$ seq 10 20 | sl 4' => 13
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