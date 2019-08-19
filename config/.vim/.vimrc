" turn 	on line numbering+
set number
" turn on ruler at bottom of window
set ruler

set mouse=a
set autoindent
set showcmd

" hitting <F8> highlights all instances of the word currently under the cursor
" noremap <F8> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

syntax on

" Use color scheme from ~/.vim/colors/myColors.vim
colors koehler


" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=300
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction


"Auto-Complete Window
set wildmenu
set wildignore=*.o,*~


" allows for partial matching in search
set is
" ignore case while searching
set ic
" highlights search matches
set hls
" press escape to remove highlights from search



"allows for cursor to wrap left and right from line to line
set whichwrap+=<,>,h,l,[,]


"Should handle backspace problems

"set backspace+=start

"other backspace stuff
set backspace=indent,eol,start

"vim as manpage viewer
let $PAGER=''


" taglist shit
"let Tlist_Ctags_Cmd = "/usr/bin/ctags"
"let Tlist_WinWidth = 50
"map <F4> :TlistToggle<cr>
"map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>





" AUTOMATIC BACKUPS =====================================================
"enable backup
set backup
"
"Create a backup folder, I like to have it in $HOME/vimbackup/date/
let day = strftime("%Y.%m.%d")
let backupdir = $HOME."/vimbackup/".day
silent! let xyz = mkdir(backupdir, "p")

"Set the backup folder
let cmd = "set backupdir=".backupdir
execute cmd
"
"Create an extention for backup file, useful when you are modifying the
"same file multiple times in a day. I like to have an extention with
"time hour.min.sec
let time = strftime(".%H.%M.%S")
let cmd = "set backupext=". time
execute cmd
"
"test.cpp is going to be backed up as HOME/vimbackup/date/test.cpp.hour.min.sec
" ===================================================== AUTOMATIC BACKUPS

"set autoindent

" set apropriate settings for filetype
filetype plugin on
filetype indent on

" allow mapleader declaration"{{{
let mapleader=","
let g:mapleader=","
""}}}

" increase timeout length
set timeout timeoutlen=1500



" start scrolling up/down when 7 lines from top/bottom"{{{
set so=7"}}}


" set command line bar height "{{{
"set cmdheight=2"}}}

nmap <leader>w :w!<cr>

" move between windws with cntrl+hjkl"{{{
"map <C-k> <C-w>k
"map <C-j> <C-w>j
"map <C-h> <C-w>h
"map <C-l> <C-w>l
""}}}


" moving down/up moves one visible line up/down not document line up/down"{{{
map j gj
map k gk
""}}}



" 0 moves cursor to first non-blank character in a line rather"{{{
" map 0 ^
""}}}

" fold settings "{{{
nmap <space> zo
nmap <C-f> zc
vmap <C-f> zf
""}}}

"nmap html :set tabstop=3


" Toggle background
" Last Change:  April 7, 2011
" Maintainer:   Ethan Schoonover
" License:      OSI approved MIT license

if exists("g:loaded_togglebg")
    finish
endif
let g:loaded_togglebg = 1

" noremap is a bit misleading here if you are unused to vim mapping.
" in fact, there is remapping, but only of script locally defined remaps, in
" this case <SID>TogBG. The <script> argument modifies the noremap scope in
" this regard (and the noremenu below).
nnoremap <unique> <script> <Plug>ToggleBackground <SID>TogBG
inoremap <unique> <script> <Plug>ToggleBackground <ESC><SID>TogBG<ESC>a
vnoremap <unique> <script> <Plug>ToggleBackground <ESC><SID>TogBG<ESC>gv
nnoremenu <script> Window.Toggle\ Background <SID>TogBG
inoremenu <script> Window.Toggle\ Background <ESC><SID>TogBG<ESC>a
vnoremenu <script> Window.Toggle\ Background <ESC><SID>TogBG<ESC>gv
noremap <SID>TogBG  :call <SID>TogBG()<CR>

function! s:TogBG()
   let &background = ( &background == "dark"? "light" : "dark" ) | exe "colorscheme " . g:colors_name
endfunction

if !exists(":ToggleBG")
   command ToggleBG :call s:TogBG()
endif

function! ToggleBackground()
    echo "Please update your ToggleBackground mapping. ':help togglebg' for information."
endfunction

function! Togglebgmap(mapActivation)
    try
        exe "silent! nmap <unique> ".a:mapActivation." <Plug>ToggleBackground"
        exe "silent! imap <unique> ".a:mapActivation." <Plug>ToggleBackground"
        exe "silent! vmap <unique> ".a:mapActivation." <Plug>ToggleBackground"
    finally
        return 0
    endtry
endfunction

if !exists("no_plugin_maps") && !hasmapto('<Plug>ToggleBackground')
    call Togglebgmap("<F5>")
endif


" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
 filetype plugin on
"
" " IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" " can be called correctly.
" set shellslash
"
" " IMPORTANT: grep will sometimes skip displaying the file name if you
" " search in a singe file. This will confuse Latex-Suite. Set your grep
" " program to always generate a file-name.
 set grepprg=grep\ -nH\ $*
"
" " OPTIONAL: This enables automatic indentation as you type.
 filetype indent on

" " OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" " 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" " The following changes the default filetype back to 'tex':
" let g:tex_flavor='latex'


" this is mostly a matter of taste. but LaTeX looks good with just a bit
" " of indentation.
"set sw=2
" " TIP: if you write your \label's as \label{fig:something}, then if you
" " type in \ref{fig: and press <C-n> you will automatically cycle through
" " all the figure labels. Very useful!
set iskeyword+=:
set tabstop=2
set shiftwidth=2
set expandtab

" Copy pasta
set clipboard=unnamedplus
autocmd VimLeave * call system("xclip -o | xclip -selection c")

"""""""""""""""
"" ROS STUFF --
"""""""""""""""
autocmd BufNewFile,BufRead *.launch set syntax=xml
autocmd BufNewFile,BufRead *.launch set filetype=xml

""""""""""""""""""""
"" Nerdcommenter ---
""""""""""""""""""""
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

"""""""""""""""
"" PACKAGES ---
"""""""""""""""

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdcommenter'

call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""
"" CursorLine --
""""""""""""""""

hi CursorLine   cterm=NONE ctermbg=darkgray guibg=darkred
hi CursorColumn cterm=NONE ctermbg=darkgray guibg=darkred
" set cursorline
" set cursorcolumn


""""""""""""""""
"" Vim hist   --
""""""""""""""""
" Let's save undo info!
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "", 0770)
endif
if !isdirectory($HOME."/.vim/undo-dir")
    call mkdir($HOME."/.vim/undo-dir", "", 0700)
endif
set undodir=~/.vim/undo-dir
set undofile

"""""""""""""""""""""""""""""""
"" trim whitespace on save   --
"""""""""""""""""""""""""""""""
autocmd BufWritePre * %s/\s\+$//e
