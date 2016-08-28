syntax on
colorscheme default

" powerline config cf. /usr/share/doc/powerline/README.Debian pour les instructions
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
set laststatus=2 " Always show statusline
set t_Co=256 " Use 256 colours (Use this setting only if your terminal supports 256 colours)

set number
set encoding=utf-8
set fileencodings=utf-8

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Display some invisibles characters
set listchars=tab:>-,trail:~,extends:>,precedes:<,nbsp:-
set list

" Keymap in insert mode
inoremap <C-A> <Home>
inoremap <C-E> <End>
