# .bash_profile
# @codedstructure

# Configure path
export PATH="$PATH:$HOME/bin:$HOME:/.local/bin"
export CDPATH="$CDPATH:$HOME/projects/codedstructure"

# Homebrew config (Mac)
if command -v brew >/dev/null ; then
  # Set PATH, MANPATH, etc., for Homebrew.
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # setup from bash-completion@2
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# editfile completion
if command -v editfile >/dev/null ; then
  . <(editfile completion)
fi

# Rust config
[[ -r "${HOME}/.cargo/env" ]] && . "$HOME/.cargo/env"

# Set prompt
GIT_COLOUR="0;33m"
HOST_COLOUR="1;34m"
function colour_set { echo "\[\e[$1\]"; }
function colour_reset { colour_set "m"; }

export GIT_PS1_SHOWDIRTYSTATE='TRUE'
BASE_PS1="$(colour_set $HOST_COLOUR)\u@\h$(colour_reset):\w\$ "
export PS1="$(colour_set $GIT_COLOUR)"'$(__git_ps1 "%s ")'"$(colour_set $COLOUR)${BASE_PS1}$(colour_reset)"

# Bash options
shopt -s globstar  # example: 'vim src/**/thing'
shopt -s dotglob  # example: 'echo ~/*' will include .vimrc

# Delegate to other files
if [[ -r "${HOME}/.bash_aliases" ]]; then
  . ~/.bash_aliases
fi
