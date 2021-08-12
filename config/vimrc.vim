syntax on

colorscheme murphy

set autoindent smartindent
set autoread
set background=dark
set backspace=indent,eol,start
set cmdheight=2
set display+=lastline
set encoding=utf-8 fileencoding=utf-8
set hidden
set history=100
set ignorecase incsearch
set laststatus=2
set lazyredraw
set linebreak
set list
set listchars=tab:→\ ,trail:█
set mouse=
set noautowrite
set nobackup
set confirm
set nocompatible
set noerrorbells
set nofoldenable
set nohlsearch
set noignorecase
set nomodeline
set nospell
set noswapfile
set noundofile
set nowrap
set nowritebackup
set number relativenumber
set pastetoggle=<F12>
set path+=**
set ruler
set scrolloff=8
set shiftround
set shiftwidth=4
set showcmd
set showmode
set showmatch
set smarttab expandtab tabstop=4 softtabstop=4
set textwidth=0
set title
set ttyfast
set wildmenu

hi Normal guibg=NONE ctermbg=NONE

" Remap Ctrl+A/E to Home/End
noremap <C-a> <Home>
noremap <C-e> <End>

" Make Y yank to end of line
nnoremap Y y$

" Insert blank lines
nnoremap <C-k> O<Esc>j
nnoremap <C-j> o<Esc>k

inoremap <C-a> <Home>
inoremap <C-e> <End>

cnoremap <C-A> <Home>
cnoremap <C-E> <End>
