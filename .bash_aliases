alias svnrev="svn info ${SVN_ROOT} | awk '/Revision:/ {print $2}'"
alias svndiff="svn diff --diff-cmd svnmeld"
alias svnlog="svn up; svn log --stop-on-copy"
alias svnlogdiff="svndiff -r \$(svn log --stop-on-copy --xml | xpath -q -e '//log/logentry[last()]/@revision' | cut -d '\"' -f 2):HEAD"
alias webserve="python -m SimpleHTTPServer"
alias sf="find . ! \( -name .svn -prune \) -a -type f -print0 | xargs -0 grep -Hn --color"
alias sn="find . ! \( -name .svn -prune \) -a -type f -name"
alias http_head="curl -I"
alias cdtemp='td=$(mktemp -d); pushd $td; bash; popd;'  # TODO: add a trap to remove on exit
alias pp="egrep '^\s*(def|class) '"

en () {
  MY_EDITOR=$VISUAL
  if [[ -z $MY_EDITOR ]] ; then
    MY_EDITOR=$EDITOR
  fi
  if [[ -z $MY_EDITOR ]] ; then
    MY_EDITOR=/usr/bin/vim
  fi
  find . ! \( -name .svn -prune \) -a -type f -name $1 | xargs $EDITOR
}

map () { prog=$1; shift; for arg in $@; do eval $prog $arg; done }

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

# ttmux to be equivalent of screen -R
alias ttmux="tmux a -d || tmux"