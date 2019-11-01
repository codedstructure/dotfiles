" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" disable beep
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Make backspace behave in a sane manner.
set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on
set ruler
set laststatus=2
set matchpairs+=<:>
set updatetime=250

" when searching, keep some context
set scrolloff=4

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

inoremap jj <Esc>

set gfn=Monospace\ 8
"set t_Co=256

set wildmode=longest,list,full
set wildmenu

set nobackup
set nowritebackup
set noswapfile

:nnoremap <F5> :buffers<CR>:buffer<Space>
:nnoremap <F6> :bd<CR>

set expandtab
set tabstop=4
set shiftwidth=4
set colorcolumn=79
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
"au BufWritePost *.py !flake8 --ignore=E501,E121,E122,E123,E124,E125,E126,E127,E128 --max-complexity=10 %
autocmd BufWritePost *.xml,*.html !xmlwf % | grep -v 'undefined entity'
autocmd BufWritePost *.py call Flake8()
au BufWritePost *.js !jshint %
au BufWritePost *.json !python3 -m json.tool % /dev/null

" immediately source .vimrc after writing it
au! BufWritePost .vimrc source %

" folding support
set foldmethod=syntax
set fdn=5
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf
nnoremap <F10> zR
nnoremap <F11> zM
set foldlevelstart=20

"Pathogen
call pathogen#infect()
call pathogen#helptags()

"solarized support
" first disable CSApprox
let g:CSApprox_loaded = 1
set background=dark
"let g:solarized_termcolors=16
colorscheme solarized
:nnoremap <F5> :let &background = ( &background == "dark"? "light" : "dark" )<CR>

set display=lastline

" from https://superuser.com/a/423744/86211
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

function! Softwrap()
  set formatoptions=1
  set linebreak
  set wrap
  set nolist
  "set breakat=\ |@-+;:,./?^I
  nnoremap j gj
  nnoremap <Down> gj
  nnoremap k gk
  nnoremap <Up> gk
  inoremap <Down> <C-o>gj
  inoremap <Up> <C-o>gk
  vnoremap j gj
  vnoremap <Down> gj
  vnoremap k gk
  vnoremap <Up> gk
  set foldcolumn=7
  set nonumber
  set colorcolumn=0
  set textwidth=0
  set wrapmargin=0
endfunction

"au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rst set wrap linebreak nolist textwidth=0 wrapmargin=0 colorcolumn=0
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rst,*.otl call Softwrap()

nnoremap <silent> <F12> :TlistUpdate<CR>:TlistToggle<CR>
