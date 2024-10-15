" Metro .vimrc
" Basic settings"
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Ex settings"
set incsearch
set hlsearch
set ignorecase
set smartcase
set scrolloff=8     
set sidescrolloff=8 
set showmatch       
set mouse=a         
set t_Co=256

"Syntax highlighting"
syntax enable

" Enable true color support
if has('termguicolors')
  set termguicolors
endif

hi clear
if exists("syntax_on")
  syntax reset
endif

" Background and basic UI colors
hi Normal guifg=#FFFFFF guibg=#111111
hi LineNr guifg=#777777 guibg=NONE
hi Cursor guifg=#111111 guibg=NONE
hi CursorLine guibg=#222222

syntax match CustomFunc /\<\h\w*\>\s*(/me=e-1
syntax match Operator /[+\-*/%=<>!&|^~]/
syntax match SpecialKey /[*&]/
syntax match MethodMember /\.\h\w*\>/
syntax match MethodMember /->\h\w*\>/
syntax match MethodMember /\<\h\w*\>::/
syntax match MethodMember /\<lambda\>/
syntax match ClassName /\<[A-Z]\w*\>/

augroup SyntaxSettings
    autocmd!
    autocmd FileType * syntax match CustomFunc /\<\h\w*\>\s*(/me=e-1
    autocmd FileType * syntax match Operator /[+\-*/%=<>!&|^~]/
    autocmd FileType * syntax match SpecialKey /[*&]/
    autocmd FileType * syntax match MethodMember /\.\h\w*\>/
    autocmd FileType * syntax match MethodMember /->\h\w*\>/
    autocmd FileType * syntax match MethodMember /\<\h\w*\>::/
    autocmd FileType * syntax match MethodMember /\<lambda\>/
    autocmd FileType * syntax match ClassName /\<[A-Z]\w*\>/
    autocmd FileType * syntax match Comment /\/\/.*$/
    autocmd FileType * syntax region Comment start="/\*" end="\*/"
augroup END

autocmd BufEnter * syntax sync fromstart

"Status Line"
set laststatus=1
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}


function! s:AutoClosePair(char_open, char_close)
    if getline('.')[col('.') - 1] == a:char_close
        return "\<Right>"
    else
        return a:char_open . a:char_close . "\<Left>"
    endif
endfunction

inoremap ( <C-R>=<SID>AutoClosePair('(', ')')<CR>
inoremap [ <C-R>=<SID>AutoClosePair('[', ']')<CR>
inoremap { <C-R>=<SID>AutoClosePair('{', '}')<CR>
inoremap " <C-R>=<SID>AutoClosePair('"', '"')<CR>
inoremap ' <C-R>=<SID>AutoClosePair("'", "'")<CR>


" Enable backspace and delete keys
set backspace=indent,eol,start

" Allow moving to the next/previous line with right/left arrow keys"
set whichwrap+=<,>,[,]

" Enable cursor to move to the next/previous line with h and l keys"
set whichwrap+=h,l

function! ToggleComment()
    let l:line = getline('.')
    if l:line =~ '^\s*//'
        let l:line = substitute(l:line, '^\(\s*\)//\s*', '\1', '')
    else
        let l:line = substitute(l:line, '^\(\s*\)', '\1// ', '')
    endif
    call setline('.', l:line)
endfunction

inoremap <C-/> <Esc>:call ToggleComment()<CR>i
nnoremap <C-Z> <Nop>
inoremap <C-Z> <Nop>
vnoremap <C-Z> <Nop>

nnoremap <C-Z> u
inoremap <C-Z> <C-O>u
vnoremap <C-Z> <Esc>u<gv>

nnoremap <C-Y> <C-R>
inoremap <C-Y> <C-O><C-R>
vnoremap <C-Y> <Esc><C-R><gv>

set pastetoggle=<F2>

nnoremap <C-V> :set paste!<CR>i
inoremap <C-V> <Esc>:set paste!<CR>gi

set foldmethod=indent
set foldlevel=99

nnoremap <C-Space> za
inoremap <C-Space> <C-O>za

function! s:ClosingTagAndPosition()
    let line = getline('.')
    let col = col('.')
    let tagname = matchstr(line[0:col-2], '<\zs\w\+\ze')
    if tagname != ''
        return '</'.tagname.'>' . repeat("\<Left>", len(tagname) + 3)
    else
        return '>'
    endif
endfunction

