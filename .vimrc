" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Make backspace behave in a sane manner.
set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on

" Enable file type detection and do language-dependent indenting.
filetype plugin indent on

" from http://ianrolfe.livejournal.com/39474.html
" For some reason home and end keys are not mapping properly
" Home key
imap <esc>OH <esc>0i
cmap <esc>OH <home>
nmap <esc>OH 0
" End key
nmap <esc>OF $
imap <esc>OF <esc>$a
cmap <esc>OF <end>

set gfn=Monospace\ 8
set t_Co=256

set wildmode=longest,list,full
set wildmenu

set nobackup
set nowritebackup
set noswapfile
set lines=40
set columns=80

set expandtab
set tabstop=4
set shiftwidth=4
:map <C-Up> :bn<Return>
:map <C-Down> :bp<Return>
filetype plugin indent on
augroup mkd
    autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>
augroup END
set incsearch
set showmatch
set ignorecase
set smartcase
autocmd FileType python set omnifunc=pythoncomplete#Complete
set complete-=i
:nnoremap <Tab> :bnext<CR>
:nnoremap <S-Tab> :bprevious<CR>
:map <End> <End>
:map <Home> <Home>
set list listchars=trail:_
highlight SpecialKey ctermfg=DarkGray ctermbg=yellow
set hidden
set backspace=2
set ruler
"set smartindent
"set autoindent
set spelllang=en_gb
set guioptions-=T

" line numbering
set number
set numberwidth=4

" Informative status line
set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\ [%l/%L\ (%p%%)]

" various post-write hooks for quality checking
au BufWritePost *.py !flake8 --ignore=E501 %
au BufWritePost *.js !jshint %

" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()
filetype plugin indent on
syntax on
