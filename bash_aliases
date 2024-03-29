####
#### Initialisation
####

# Make GNU xargs behave like BSD xargs - only run the command if there are some files
# to run it against. Note recent MacOS supports the arg as a no-op for compatibility.
alias _xargs="xargs -r"

# Many of these aliases require rg to be installed; print warning if not found.
if ! command -v rg > /dev/null ; then
  echo "BASH ALIASES: rg not found!" >&2
fi

if ! command -v watchexec > /dev/null ; then
  # brew install watchexec
  # apt install watchexec
  # cargo (b)install watchexec-cli
  echo "BASH ALIASES: watchexec not found!" >&2
fi

####
#### 'find and edit' aliases and functions
####

# sfl - list non-VCS files below current point
alias sfl="rg --hidden -g '!.git/' --files"

# sf - search within files matching given content below PWD
alias sf="rg --hidden -g '!.git/'"

# sn/snw - search for files matching given name below PWD
# Needs to be a function so can be used in _findedit
function snw() {
  sfl | grep "$@"
}

function sn() {
  if [[ "$@" =~ / ]] ; then
    # if we give a (partial) path rather than filename, do a wholename search.
    snw "$@"
  else
    sfl | grep -E "^$@\$|/$@$"
  fi
}

# sd - search for directories matching given name below PWD
# Needs to be a function so can be used in _findedit
function sd() {
  sfl -0 | _xargs -0 dirname | sort -u | grep "$@"
}

# sfn - search for files matching given content below PWD; display name only
# Needs to be a function so can be used in _findedit
function sfn() {
  sf -l "$@"
}

cdn() {
  local TARGET="$1"
  if [[ -z ${TARGET} ]] ; then
    return
  fi
  local TARGET_FILE=$(sn "${TARGET}" | head -n 1)
  if [[ -f ${TARGET_FILE} ]] ; then
    local TARGET_DIR=$(dirname ${TARGET_FILE})
    if [[ -d "${TARGET_DIR}" ]] ; then
      echo ">> ${TARGET_DIR}"
      cd ${TARGET_DIR}
    fi
  fi
}

onchange() {
  CF=$1
  shift
  watchexec -w "$CF" -- "$@"
}

_findedit () {
  PATH_FIND_PROG="$1"
  shift

  PATHS=""
  while [[ -n "$1" ]]; do
    # Note quoting here needs to be only of $1
    PATHS=$(${PATH_FIND_PROG} "$1")\\n${PATHS}
    shift
  done

  echo -e "$PATHS"
  _multiedit "$PATHS"
}

_multiedit () {
  MY_EDITOR="$VISUAL"
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR="$EDITOR"
  fi
  if [[ -z "$MY_EDITOR" ]] ; then
    MY_EDITOR=vim
  fi

  export MY_EDITOR
  # see http://stackoverflow.com/questions/3852616/xargs-with-command-that-open-editor-leaves-shell-in-weird-state
  echo -e "$@" | _xargs sh -c '${MY_EDITOR} $@ < /dev/tty' "${MY_EDITOR}"
}

# en/enw - launch an editor to edit file(s) matching given name.
# Analogous to sn/snw
enw () {
  _findedit snw "$@"
}

en () {
  if [[ "$@" =~ / ]] ; then
    enw "$@"
  else
    _findedit sn "$@"
  fi
}

# efn - launch an editor to edit file(s) matching given content. Analogous to sfn.
efn () {
  # TODO: can't pass e.g. `-i` flag to efn, while it works fine with sfn
  _findedit sfn "$@"
}


####
#### git related aliases and functions
####

alias gum="(git checkout main || git checkout master ; git pull --all --prune ; git checkout -)"
# sng - list git-modified files
function sng () {
    git status -s | awk '/^.M / {print $2}'
}
# sngbase - list git-modified-since-branch files
function sngbase () {
    DEFAULT=main
    from=${1-$DEFAULT}
    git diff --name-only $(git merge-base $from HEAD)
}

# edit git-modified files
eng () {
    _multiedit $(git status -s | awk '/^.M / {print $2}')
}

# edit git files modified since branching
engbase () {
    DEFAULT=main
    from=${1-$DEFAULT}
    _multiedit $(git diff --name-only $(git merge-base $from HEAD))
}

####
#### Search & replace across files
####

_sfr () {
  local SED_OPTS="-i~"
  if [[ $1 == "nobackup" ]] ; then

    if [[ $(uname) == 'Linux' ]] ; then
       # GNU sed requires -i without any 'extension'
       SED_OPTS="-i"
    elif [[ $(uname) == 'Darwin' ]] ; then
       # BSD sed requires an empty argument
       SED_OPTS="-i ''"
    fi

    shift
  fi
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
  for FILE in $(sfl -0 | _xargs -0 grep -Il "$1") ; do
    sed ${SED_OPTS} -e "s${DELIM}$1${DELIM}$2${DELIM}g" "$FILE"
  done
}

# sfr - search & replace leaving backup files
sfr () {
   _sfr "$1" "$2"
}

# sfrn - search & replace without backup
sfrn () {
   _sfr nobackup "$@"
}

# sfd - recursively delete lines matching the given regex
_sfd () {
  local SED_OPTS="-i~"
  if [[ $1 == "nobackup" ]] ; then

    if [[ $(uname) == 'Linux' ]] ; then
       # GNU sed requires -i without any 'extension'
       SED_OPTS="-i"
    elif [[ $(uname) == 'Darwin' ]] ; then
       # BSD sed requires an empty argument
       SED_OPTS="-i ''"
    fi

    shift
  fi
  if [[ $# != 1 ]] ; then
    echo "Usage: sfd [pattern]"
    return 1
  fi
  for DELIM in / : \# \~; do
    if ! [[ "$1" =~ ${DELIM} ]] ; then
      break
    fi
  done
  for FILE in $(sfl -0 | _xargs -0 grep -Il "$1") ; do
    sed ${SED_OPTS} -e "${DELIM}$1${DELIM}d" "$FILE"
  done
}

sfd () {
   _sfd "$@"
}

sfdn () {
   _sfd nobackup "$@"
}

####
#### Various functional aliases
####

# map - apply each of params $2..$n to the program given as $1
# Example usage: 'map open file1.txt file2.txt file3.txt'
map () { prog="$1"; shift; for arg in "$@"; do eval "$prog" '"$arg"'; done }
# fold - apply binary operation to first two args, shift, repeat.
# Example usage: 'echo "hello" > a; fold cp a b c d e f g'
fold () { prog="$1"; shift; while true; do [[ -z "$2" ]] && break; eval "$prog" '"$1"' '"$2"'; shift; done }
# Do the specified actions $1 times sequentially
repeat () { count="$1"; shift; for _ in $(seq $count); do eval "$@" ; done }

####
#### Miscellaneous
####

alias http_head="curl -I"
alias cdtemp='td=$(mktemp -d -t cdtemp.XXXXX); pushd $td; bash -c "trap \"rm -rf ${td}\" EXIT; bash"; popd;'

# Output all symbolic links below this point
rlinks() {
  find -type l -print0 -exec bash -c 'echo " -> $(readlink {})"' \; | tr '\0' ' '
}

# mcd - make and change to directory
# mcd is part of mtools by default (change MSDOS directory)
mcd () {
  mkdir -p "$1" && cd "$1"
}

# sumcol - sum given column of csv input
sumcol () {
  awk -F, "{s += \$$1} END {print s}"
}

# sl - select line. e.g. '$ seq 10 20 | sl 4' => 13
sl () {
 sed -n "$1p"
}

if [[ $(uname) = 'Darwin' ]] ; then
    alias aplay="sox -r 8000 -b 8 -c 1 -t raw -e unsigned-integer - -d"

    ia() {
       for FILE in "$@"; do
          if [ ! -e "$FILE" ]; then
            touch "$FILE"
          fi
       done
       open -a "iA Writer" "$@"
    }
fi

# http://superuser.com/questions/38984/linux-equivalent-command-for-open-command-on-mac-windows
case $OSTYPE in
    linux*)
        # overwrite the original name for openvt
        alias open="xdg-open"
esac

function opencopy {
  if [[ $# != 1 ]] ; then
      echo "should have one argument"
      exit 1
  fi
  td=$(mktemp -d -t opencopy.XXXXX)
  cp "$1" "$td"
  pushd "$td"
  if [[ $OSTYPE =~ linux.* ]] ; then
      xdg-open "$td/$1"
  else
      open "$td/$1"
  fi
  popd
  (echo "waiting..."; sleep 2; echo "deleting..." ; rm "$td/$1" && rmdir "$td"; echo $?) &
}

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

function mkblank {
    dd if=/dev/zero of=blank.dd count=$1 bs=1M
}

# tmux setup
function ttmux {
    NAME=${1:-dev}
    if ! tmux has-session -t "${NAME}"; then
        tmux new-session -s "${NAME}" -d
        tmux split-window -h -t "${NAME}"
        tmux split-window -t "${NAME}"
        tmux split-window -t "${NAME}"
        tmux split-window -h -p 33 -t "${NAME}"
        tmux clock-mode
        tmux new-window -t "${NAME}"
        tmux select-window -t "${NAME}":1
    fi
    tmux attach -t "${NAME}"
}

function tmux_tty_command {
    # Use for demo captures, e.g. with `peek`
    delay=0.1
    echo -ne "$@" | sed -e 's/\(.\)/\1\n/g' | while IFS="" read c ; do
        sleep $delay
        if [[ "$c" == $(echo -e "\n") ]] ; then
            delay=0.4
            tmux send-keys Enter
            continue
        elif [[ "$c" == " " ]] ; then
            delay=0.3
        elif [[ "$c" == $(echo -e "\a") ]] ; then
            # '\a' injects a 0.5s delay
            delay=0.5
            continue
        else
            if [[ $(($RANDOM % 2)) == 0 ]] ; then
                delay=0.1
            else
                delay=0.2
            fi
        fi
        tmux send-keys "$c"
    done
    sleep 0.4
    tmux send-keys Enter
}

####
#### Delegate to other files...
####

if [[ -e ${HOME}/.bash_aliases_work ]] ; then
    . ${HOME}/.bash_aliases_work
fi
