" --------------- Vundle ---------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Provide easy code formatting in Vim by integrating existing code formatters.
Plugin 'Chiel92/vim-autoformat'
" Syntax checking hacks for vim
Plugin 'vim-syntastic/syntastic'
" surround.vim: quoting/parenthesizing made simple
Plugin 'tpope/vim-surround'
" commentary.vim: comment stuff out
Plugin 'tpope/vim-commentary'
" Highlights trailing whitespace in red and provides :FixWhitespace to fix it.
Plugin 'bronson/vim-trailing-whitespace'
" A tree explorer plugin for vim.
" Plugin 'scrooloose/nerdtree'
" lean & mean status/tabline for vim that's light as air
Plugin 'vim-airline/vim-airline'
" A dark Vim/Neovim color scheme inspired by Atom's One Dark syntax theme.
Plugin 'joshdick/onedark.vim'
" A solid language pack for Vim
Plugin 'sheerun/vim-polyglot'
" Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder.
Plugin 'ctrlpvim/ctrlp.vim'
" " Miscellaneous auto-load Vim scripts
" " DF: Is only needed for the vim-lua-inspect
" Plugin 'xolox/vim-misc'
" " Semantic highlighting for Lua in Vim
" " DF: Works great, but not particulary good for editing awesome
" " because of an awesome's context it does not know about
" Plugin 'xolox/vim-lua-inspect'
" Lua IDE for Vim/gVim/Neovim.
Plugin 'wolfgangmehner/lua-support'
" Vim motions on speed!
Plugin 'easymotion/vim-easymotion'
" An ack.vim alternative mimics Ctrl-Shift-F on Sublime Text 2
Plugin 'dyng/ctrlsf.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" --------------- Vundle ---------------

" Misc
set encoding=UTF-8
syntax on
" Tab settings
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab
" Consider shell script to be a Bash script by default
let g:is_bash=1
" Highligh search. Highlight words during search
set hlsearch
" Incremental search. Highligh words during typing for a search.
set incsearch
" Line numbers
set number
highlight LineNr ctermfg=grey
" Enable mouse
set mouse=a
" Make copy/paste go through the + register
set clipboard=unnamedplus
" Remove the menubar
set guioptions-=m
" Remove the toolbar
set guioptions-=T
" Remove scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
" Theme
let g:onedark_color_overrides = {
\ "black": {"gui": "#090a0c", "cterm": "232", "cterm16": "0" },
\}
set background=dark
colorscheme onedark
" Nerd tree
let NERDTreeShowHidden=1
map <C-n> :NERDTreeToggle<CR>
" CtrlP
let g:ctrlp_show_hidden=1
let g:ctrlp_cmd = 'CtrlPMRU'
" Automatically remove trailing whitespace on save
autocmd BufWritePost * FixWhitespace
" 
nmap <C-F> <Plug>CtrlSFPrompt
