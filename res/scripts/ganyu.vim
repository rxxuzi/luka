" ganyu.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="ganyu"

hi Normal          guifg=#fdf5ef guibg=#3b2a34
hi Comment         guifg=#4a4d67
hi Cursor          guifg=#3b2a34 guibg=#fdf5ef
hi iCursor         guifg=#3b2a34 guibg=#fdf5ef
hi CursorLine                    guibg=#503645
hi CursorLineNr    guifg=#d8daf1               gui=none
hi CursorColumn                  guibg=#503645
hi ColorColumn                   guibg=#3b2a34
hi LineNr          guifg=#dc2f28 guibg=#3b2a34
hi NonText         guifg=#dc2f28
hi SpecialKey      guifg=#dc2f28

" Custom color definitions based on ganyu palette
hi Boolean         guifg=#d4e2f7
hi Character       guifg=#9cbfe7
hi Number          guifg=#d4e2f7
hi String          guifg=#9cbfe7
hi Conditional     guifg=#9aa9e9               gui=bold
hi Constant        guifg=#d4e2f7               gui=bold

hi Debug           guifg=#6f87ca              gui=bold
hi Define          guifg=#4a5499
hi Delimiter       guifg=#9aa9e9
hi DiffAdd                       guibg=#d4e2f7
hi DiffChange      guifg=#9cbfe7  guibg=#503645
hi DiffDelete      guifg=#dc2f28 guibg=#503645
hi DiffText                       guibg=#503645 gui=italic,bold

hi Directory       guifg=#6f87ca               gui=bold
hi Error           guifg=#9cbfe7 guibg=#503645
hi ErrorMsg        guifg=#9aa9e9 guibg=#3b2a34 gui=bold
hi Exception       guifg=#6f87ca               gui=bold
hi Float           guifg=#d4e2f7
hi FoldColumn      guifg=#dc2f28 guibg=#3b2a34
hi Folded          guifg=#dc2f28 guibg=#3b2a34
hi Function        guifg=#6f87ca
hi Identifier      guifg=#d8daf1
hi Ignore          guifg=#686fa1 guibg=bg
hi IncSearch       guifg=#29caea guibg=#3b2a34

hi Keyword         guifg=#9aa9e9               gui=bold
hi Label           guifg=#9cbfe7               gui=none
hi Macro           guifg=#29caea               gui=italic
hi SpecialKey      guifg=#4a5499               gui=italic

hi MatchParen      guifg=#3b2a34 guibg=#d8daf1 gui=bold
hi ModeMsg         guifg=#9cbfe7
hi MoreMsg         guifg=#9cbfe7
hi Operator        guifg=#9aa9e9

" complete menu
hi Pmenu           guifg=#4a5499 guibg=#3b2a34
hi PmenuSel                      guibg=#686fa1
hi PmenuSbar                     guibg=#503645
hi PmenuThumb      guifg=#4a5499

hi PreCondit       guifg=#6f87ca               gui=bold
hi PreProc         guifg=#6f87ca
hi Question        guifg=#4a5499
hi Repeat          guifg=#9aa9e9               gui=bold
hi Search          guifg=#3b2a34
" marks
hi SignColumn      guifg=#6f87ca guibg=#3b2a34
hi SpecialChar     guifg=#9aa9e9               gui=bold
hi SpecialKey      guifg=#9aa9e9 gui=bold
hi SpecialComment  guifg=#3a3d57               gui=bold
hi Special         guifg=#4a5499 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#9aa9e9               gui=bold
hi StatusLine      guifg=#dc2f28 guibg=fg
hi StatusLineNC    guifg=#686fa1 guibg=#503645
hi StorageClass    guifg=#d8daf1               gui=italic
hi Structure       guifg=#4a5499
hi Tag             guifg=#9aa9e9               gui=italic
hi Title           guifg=#d8daf1
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#4a5499
hi Type            guifg=#4a5499               gui=none
hi Underlined      guifg=#686fa1               gui=underline

hi VertSplit       guifg=#686fa1 guibg=#503645 gui=bold
hi VisualNOS                     guibg=#3b2a34
hi Visual                        guibg=#3b2a34
hi WarningMsg      guifg=#fdf5ef guibg=#503645 gui=bold
hi WildMenu        guifg=#4a5499 guibg=#3b2a34

hi TabLineFill     guifg=#3b2a34 guibg=#3b2a34
hi TabLine         guibg=#3b2a34 guifg=#686fa1 gui=none

" Special Setting
hi MethodMember     guifg=#7ebce7 guibg=NONE
hi CustomFunc       guifg=#6f87ca guibg=NONE

set background=dark