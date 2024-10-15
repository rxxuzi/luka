" akari.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="akari"

hi Normal          guifg=#ffffff guibg=#000000
hi Comment         guifg=#4a374a
hi Cursor          guifg=#000000 guibg=#ffffff
hi iCursor         guifg=#000000 guibg=#ffffff
hi CursorLine                    guibg=#222222
hi CursorLineNr    guifg=#feac8c               gui=none
hi CursorColumn                  guibg=#222222
hi ColorColumn                   guibg=#000000
hi LineNr          guifg=#b10fa4 guibg=#000000
hi NonText         guifg=#b10fa4
hi SpecialKey      guifg=#b10fa4

" Custom color definitions based on akari palette
hi Boolean         guifg=#fe92df
hi Character       guifg=#fdfe96
hi Number          guifg=#fe92df
hi String          guifg=#fdfe96
hi Conditional     guifg=#99f398               gui=bold
hi Constant        guifg=#fe92df               gui=bold

hi Debug           guifg=#7cdffe              gui=bold
hi Define          guifg=#a971f4
hi Delimiter       guifg=#99f398
hi DiffAdd                       guibg=#fe92df
hi DiffChange      guifg=#fdfe96  guibg=#222222
hi DiffDelete      guifg=#b10fa4 guibg=#222222
hi DiffText                       guibg=#222222 gui=italic,bold

hi Directory       guifg=#7cdffe               gui=bold
hi Error           guifg=#fdfe96 guibg=#222222
hi ErrorMsg        guifg=#99f398 guibg=#000000 gui=bold
hi Exception       guifg=#7cdffe               gui=bold
hi Float           guifg=#fe92df
hi FoldColumn      guifg=#b10fa4 guibg=#000000
hi Folded          guifg=#b10fa4 guibg=#000000
hi Function        guifg=#7cdffe
hi Identifier      guifg=#feac8c
hi Ignore          guifg=#9af8d8 guibg=bg
hi IncSearch       guifg=#cb6eca guibg=#000000

hi Keyword         guifg=#99f398               gui=bold
hi Label           guifg=#fdfe96               gui=none
hi Macro           guifg=#cb6eca               gui=italic
hi SpecialKey      guifg=#a971f4               gui=italic

hi MatchParen      guifg=#000000 guibg=#feac8c gui=bold
hi ModeMsg         guifg=#fdfe96
hi MoreMsg         guifg=#fdfe96
hi Operator        guifg=#99f398

" complete menu
hi Pmenu           guifg=#a971f4 guibg=#000000
hi PmenuSel                      guibg=#9af8d8
hi PmenuSbar                     guibg=#222222
hi PmenuThumb      guifg=#a971f4

hi PreCondit       guifg=#7cdffe               gui=bold
hi PreProc         guifg=#7cdffe
hi Question        guifg=#a971f4
hi Repeat          guifg=#99f398               gui=bold
hi Search          guifg=#000000
" marks
hi SignColumn      guifg=#7cdffe guibg=#000000
hi SpecialChar     guifg=#99f398               gui=bold
hi SpecialKey      guifg=#99f398 gui=bold
hi SpecialComment  guifg=#4a374a               gui=bold
hi Special         guifg=#a971f4 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#ffffff   gui=undercurl
endif
hi Statement       guifg=#99f398               gui=bold
hi StatusLine      guifg=#b10fa4 guibg=fg
hi StatusLineNC    guifg=#9af8d8 guibg=#222222
hi StorageClass    guifg=#feac8c               gui=italic
hi Structure       guifg=#a971f4
hi Tag             guifg=#99f398               gui=italic
hi Title           guifg=#feac8c
hi Todo            guifg=#ffffff guibg=bg      gui=bold

hi Typedef         guifg=#a971f4
hi Type            guifg=#a971f4               gui=none
hi Underlined      guifg=#9af8d8               gui=underline

hi VertSplit       guifg=#9af8d8 guibg=#222222 gui=bold
hi VisualNOS                     guibg=#000000
hi Visual                        guibg=#000000
hi WarningMsg      guifg=#ffffff guibg=#222222 gui=bold
hi WildMenu        guifg=#a971f4 guibg=#000000

hi TabLineFill     guifg=#000000 guibg=#000000
hi TabLine         guibg=#000000 guifg=#9af8d8 gui=none

" Special Setting
hi MethodMember     guifg=#feaeff guibg=NONE
hi CustomFunc       guifg=#7cdffe guibg=NONE

set background=dark