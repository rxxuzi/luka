" elysia.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="elysia"

hi Normal          guifg=#f2e3f0 guibg=#251d1c
hi Comment         guifg=#4b383d
hi Cursor          guifg=#251d1c guibg=#f2e3f0
hi iCursor         guifg=#251d1c guibg=#f2e3f0
hi CursorLine                    guibg=#251d1c
hi CursorLineNr    guifg=#ecebee               gui=none
hi CursorColumn                  guibg=#251d1c
hi ColorColumn                   guibg=#251d1c
hi LineNr          guifg=#5edff0 guibg=#251d1c
hi NonText         guifg=#5edff0
hi SpecialKey      guifg=#5edff0

" Custom color definitions based on elysia palette
hi Boolean         guifg=#e4a3d8
hi Character       guifg=#f09cc2
hi Number          guifg=#e4a3d8
hi String          guifg=#f09cc2
hi Conditional     guifg=#ab6ce5               gui=bold
hi Constant        guifg=#e4a3d8               gui=bold

hi Debug           guifg=#c759be              gui=bold
hi Define          guifg=#dc9bdd
hi Delimiter       guifg=#ab6ce5
hi DiffAdd                       guibg=#e4a3d8
hi DiffChange      guifg=#f09cc2  guibg=#251d1c
hi DiffDelete      guifg=#5edff0 guibg=#251d1c
hi DiffText                       guibg=#251d1c gui=italic,bold

hi Directory       guifg=#c759be               gui=bold
hi Error           guifg=#f09cc2 guibg=#251d1c
hi ErrorMsg        guifg=#ab6ce5 guibg=#251d1c gui=bold
hi Exception       guifg=#c759be               gui=bold
hi Float           guifg=#e4a3d8
hi FoldColumn      guifg=#5edff0 guibg=#251d1c
hi Folded          guifg=#5edff0 guibg=#251d1c
hi Function        guifg=#c759be
hi Identifier      guifg=#ecebee
hi Ignore          guifg=#ab87d6 guibg=bg
hi IncSearch       guifg=#7f6297 guibg=#251d1c

hi Keyword         guifg=#ab6ce5               gui=bold
hi Label           guifg=#f09cc2               gui=none
hi Macro           guifg=#7f6297               gui=italic
hi SpecialKey      guifg=#dc9bdd               gui=italic

hi MatchParen      guifg=#251d1c guibg=#ecebee gui=bold
hi ModeMsg         guifg=#f09cc2
hi MoreMsg         guifg=#f09cc2
hi Operator        guifg=#ab6ce5

" complete menu
hi Pmenu           guifg=#dc9bdd guibg=#251d1c
hi PmenuSel                      guibg=#ab87d6
hi PmenuSbar                     guibg=#251d1c
hi PmenuThumb      guifg=#dc9bdd

hi PreCondit       guifg=#c759be               gui=bold
hi PreProc         guifg=#c759be
hi Question        guifg=#dc9bdd
hi Repeat          guifg=#ab6ce5               gui=bold
hi Search          guifg=#251d1c
" marks
hi SignColumn      guifg=#c759be guibg=#251d1c
hi SpecialChar     guifg=#ab6ce5               gui=bold
hi SpecialKey      guifg=#ab6ce5 gui=bold
hi SpecialComment  guifg=#3b282d               gui=bold
hi Special         guifg=#dc9bdd guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#f2e3f0   gui=undercurl
endif
hi Statement       guifg=#ab6ce5               gui=bold
hi StatusLine      guifg=#5edff0 guibg=fg
hi StatusLineNC    guifg=#ab87d6 guibg=#251d1c
hi StorageClass    guifg=#ecebee               gui=italic
hi Structure       guifg=#dc9bdd
hi Tag             guifg=#ab6ce5               gui=italic
hi Title           guifg=#ecebee
hi Todo            guifg=#f2e3f0 guibg=bg      gui=bold

hi Typedef         guifg=#dc9bdd
hi Type            guifg=#dc9bdd               gui=none
hi Underlined      guifg=#ab87d6               gui=underline

hi VertSplit       guifg=#ab87d6 guibg=#251d1c gui=bold
hi VisualNOS                     guibg=#251d1c
hi Visual                        guibg=#251d1c
hi WarningMsg      guifg=#f2e3f0 guibg=#251d1c gui=bold
hi WildMenu        guifg=#dc9bdd guibg=#251d1c

hi TabLineFill     guifg=#251d1c guibg=#251d1c
hi TabLine         guibg=#251d1c guifg=#ab87d6 gui=none

" Special Setting
hi MethodMember     guifg=#b86a8c guibg=NONE
hi CustomFunc       guifg=#c759be guibg=NONE

set background=dark