execute pathogen#infect()
syntax on
filetype plugin indent on "was on

"set number
set nobackup
set nomodeline
set novisualbell

set tabstop=4 shiftwidth=4 softtabstop=4 expandtab
"set smartindent
"set smarttab
" удалить лишние пробелы в конце строки перед сохранением
autocmd BufWritePre * :%s/\s\+$//e

" не заменять 'tab' на 'space' в Makefile-ах
autocmd FileType make   set noexpandtab

autocmd FileType ruby   set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType yaml   set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType python set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

au! BufRead,BufNewFile *.json set filetype=json
autocmd FileType json   set tabstop=2 shiftwidth=2 softtabstop=2 expandtab

au! BufRead,BufNewFile *.tf set filetype=tf
autocmd FileType tf     set tabstop=2 shiftwidth=2 softtabstop=2 expandtab

au! BufRead,BufNewFile *.j2 set filetype=jinja
" -- show rule on right
set colorcolumn=80
set ruler

" ----- theme's customization -----
syntax on
"colorscheme desert
"colorscheme darkblue
"highlight Comment font= cterm=NONE      ctermfg=darkgrey
"highlight Todo    font= cterm=underline ctermfg=red ctermbg=yellow

"-- folding
"set foldcolumn=2
"set foldmethod=syntax
"set iskeyword=@,48-57,_,192-255

" ----- Mapping ------
" автоскобки
"imap {<CR> {<CR>}<Esc>O
"imap [ []<LEFT>
"imap ( ()<LEFT>

" ----- Search -----
set showmatch
set incsearch
set smartcase "Игнорировать регистр при поиске, если в искомом выражении нет символов верхнего регистра

" автодополнение по Tab
function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

" == vimdiff ==
"if &diff
"    " ignore spaces (does not work :( )
"    set diffopt+=iwhite
"endif

" сокращения
"ab <AB> <ABREVIATURE>

" skeletons
au BufNewFile *.py 0r ~/.vim/python.skel
au BufNewFile *.sh 0r ~/.vim/shell.skel
au BufNewFile *.rb 0r ~/.vim/ruby.skel
" au BufNewFile *.xml 0r ~/.vim/xml.skel | let IndentStyle = "xml"
" au BufNewFile *.html 0r ~/.vim/html.skel | let IndentStyle = "html"

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
"set viminfo='10,\"100,:20,%,n~/.viminfo

" This tip is an improved version of the example given for :help last-position-jump.
" It fixes a problem where the cursor position will not be restored if the file only has a single line.
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END
