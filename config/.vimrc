call pathogen#infect()

set nocompatible

set number
set wildmenu
set wildmode=list:longest,full
set wildignore=*.o,*~,*.pyc
set ruler
set backspace=eol,start,indent

set smartcase
set hlsearch
set incsearch
set magic
set showmatch

syntax enable
set encoding=utf8

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
highlight colorcolumn ctermbg=235 guibg=#2c2d27
set colorcolumn=80

set autoindent
set smartindent
set nowrap

set listchars=tab:!·,trail:·
set list

autocmd FileType python
    \ setlocal softtabstop=4 |
    \ setlocal tabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal smarttab |
    \ setlocal expandtab |
    \ setlocal colorcolumn=72,80,100

autocmd FileType make
    \ setlocal softtabstop=4 |
    \ setlocal tabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal smarttab |
    \ setlocal noexpandtab

