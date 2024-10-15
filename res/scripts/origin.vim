" origin.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="origin"

" Background and basic UI colors
hi Normal guifg=#FFFFFF guibg=#111111
hi LineNr guifg=#777777 
hi Cursor guifg=#111111 
hi iCursor         guifg=#111111 guibg=#EFEFEF
hi CursorLine guibg=#222222
hi CursorLineNr    guifg=#ffafff               gui=none
hi CursorColumn                  guibg=#333333
hi ColorColumn                   guibg=#111111
hi NonText         guifg=#feec90
hi SpecialKey      guifg=#feec90
hi Comment guifg=#444444 

" Custom color definitions based on origin palette
hi Boolean         guifg=#ff5faf
hi Character       guifg=#87ffff
hi Number          guifg=#afd7ff
hi String          guifg=#97ffff
hi Conditional     guifg=#00d7ff               gui=bold
hi Constant        guifg=#d7afff               gui=bold

hi Debug           guifg=#5fafff              gui=bold
hi Define          guifg=#af87ff
hi Delimiter       guifg=#00d7ff
hi DiffAdd                       guibg=#afd7ff
hi DiffChange      guifg=#87ffff  guibg=#333333
hi DiffDelete      guifg=#feec90 guibg=#333333
hi DiffText                       guibg=#333333 gui=italic,bold

hi Directory       guifg=#5fafff               gui=bold
hi Error           guifg=#ff323f guibg=#333333
hi ErrorMsg        guifg=#00d7ff guibg=#111111 gui=bold
hi Exception       guifg=#5fafff               gui=bold
hi Float           guifg=#afd7ff
hi FoldColumn      guifg=#feec90 guibg=#111111
hi Folded          guifg=#feec90 guibg=#111111
hi Function        guifg=#ff7fff 
hi Ignore          guifg=#808080 guibg=bg
hi IncSearch       guifg=#ff5faf guibg=#111111

hi Keyword         guifg=#ff5faf               gui=bold
hi Label           guifg=#87ffff               gui=none
hi Macro           guifg=#ff5faf               gui=italic
hi SpecialKey      guifg=#af87ff               gui=italic

hi MatchParen      guifg=#111111 guibg=#ffafff gui=bold
hi ModeMsg         guifg=#87ffff
hi MoreMsg         guifg=#87ffff
hi Operator        guifg=#ffb7ff

" complete menu
hi Pmenu           guifg=#af87ff guibg=#111111
hi PmenuSel                      guibg=#87ff00
hi PmenuSbar                     guibg=#222222
hi PmenuThumb      guifg=#af87ff

hi PreCondit       guifg=#5fafff               gui=bold
hi PreProc         guifg=#af87ff
hi Question        guifg=#af87ff
hi Repeat          guifg=#00d7ff               gui=bold
hi Search          guifg=#111111
" marks
hi SignColumn      guifg=#5fafff guibg=#111111
hi SpecialKey      guifg=#00ffff gui=bold
hi SpecialComment  guifg=#447474               gui=bold
hi Special         guifg=#af87ff guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#EFEFEF   gui=undercurl
endif
hi Statement       guifg=#ff5faf               gui=bold
hi StatusLine      guifg=#feec90 guibg=fg
hi StatusLineNC    guifg=#87ff00 guibg=#222222
hi StorageClass    guifg=#ff5fff               gui=italic
hi Structure       guifg=#af87ff
hi Tag             guifg=#00d7ff               gui=italic
hi Title           guifg=#87ff00
hi Todo            guifg=#ff38ff guibg=bg      gui=bold

hi Typedef         guifg=#af87ff
hi Type            guifg=#ff5faf               gui=none
hi Underlined      guifg=#87ff00               gui=underline

hi VertSplit       guifg=#87ff00 guibg=#222222 gui=bold
hi VisualNOS                     guibg=#111111
hi Visual                        guibg=#111111
hi WarningMsg      guifg=#EFEFEF guibg=#333333 gui=bold
hi WildMenu        guifg=#af87ff guibg=#111111

hi TabLineFill     guifg=#111111 guibg=#111111
hi TabLine         guibg=#111111 guifg=#87ff00 gui=none

" Custom color definitions based on the provided colors
hi Identifier guifg=#5fafff 
hi SpecialChar guifg=#bfffff gui=bold
hi CustomFunc guifg=#ffafff
hi MethodMember guifg=#87ff00 
hi ClassName guifg=#00d7ff

set background=dark