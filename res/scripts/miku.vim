" miku.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="miku"

hi Normal          guifg=#fdf5ef guibg=#0e0e0e
hi Comment         guifg=#373b3e
hi Cursor          guifg=#0e0e0e guibg=#fdf5ef
hi iCursor         guifg=#0e0e0e guibg=#fdf5ef
hi CursorLine                    guibg=NONE
hi CursorLineNr    guifg=#00b8ff               gui=none
hi CursorColumn                  guibg=NONE
hi ColorColumn                   guibg=#0e0e0e
hi LineNr          guifg=#a40ca8 guibg=#0e0e0e
hi NonText         guifg=#a40ca8
hi SpecialKey      guifg=#a40ca8

" Custom color definitions based on miku palette
hi Boolean         guifg=#86cecb
hi Character       guifg=#137a7f
hi Number          guifg=#86cecb
hi String          guifg=#137a7f
hi Conditional     guifg=#52c7ad               gui=bold
hi Constant        guifg=#86cecb               gui=bold

hi Debug           guifg=#e12885              gui=bold
hi Define          guifg=#47dfd3
hi Delimiter       guifg=#52c7ad
hi DiffAdd                       guibg=#86cecb
hi DiffChange      guifg=#137a7f  guibg=NONE
hi DiffDelete      guifg=#a40ca8 guibg=NONE
hi DiffText                       guibg=NONE gui=italic,bold

hi Directory       guifg=#e12885               gui=bold
hi Error           guifg=#137a7f guibg=NONE
hi ErrorMsg        guifg=#52c7ad guibg=#0e0e0e gui=bold
hi Exception       guifg=#e12885               gui=bold
hi Float           guifg=#86cecb
hi FoldColumn      guifg=#a40ca8 guibg=#0e0e0e
hi Folded          guifg=#a40ca8 guibg=#0e0e0e
hi Function        guifg=#e12885
hi Identifier      guifg=#00b8ff
hi Ignore          guifg=#00ff85 guibg=bg
hi IncSearch       guifg=#31e6f0 guibg=#0e0e0e

hi Keyword         guifg=#52c7ad               gui=bold
hi Label           guifg=#137a7f               gui=none
hi Macro           guifg=#31e6f0               gui=italic
hi SpecialKey      guifg=#47dfd3               gui=italic

hi MatchParen      guifg=#0e0e0e guibg=#00b8ff gui=bold
hi ModeMsg         guifg=#137a7f
hi MoreMsg         guifg=#137a7f
hi Operator        guifg=#52c7ad

" complete menu
hi Pmenu           guifg=#47dfd3 guibg=#0e0e0e
hi PmenuSel                      guibg=#00ff85
hi PmenuSbar                     guibg=NONE
hi PmenuThumb      guifg=#47dfd3

hi PreCondit       guifg=#e12885               gui=bold
hi PreProc         guifg=#e12885
hi Question        guifg=#47dfd3
hi Repeat          guifg=#52c7ad               gui=bold
hi Search          guifg=#0e0e0e
" marks
hi SignColumn      guifg=#e12885 guibg=#0e0e0e
hi SpecialChar     guifg=#52c7ad               gui=bold
hi SpecialKey      guifg=#52c7ad gui=bold
hi SpecialComment  guifg=#373b3e               gui=bold
hi Special         guifg=#47dfd3 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#52c7ad               gui=bold
hi StatusLine      guifg=#a40ca8 guibg=fg
hi StatusLineNC    guifg=#00ff85 guibg=NONE
hi StorageClass    guifg=#00b8ff               gui=italic
hi Structure       guifg=#47dfd3
hi Tag             guifg=#52c7ad               gui=italic
hi Title           guifg=#00b8ff
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#47dfd3
hi Type            guifg=#47dfd3               gui=none
hi Underlined      guifg=#00ff85               gui=underline

hi VertSplit       guifg=#00ff85 guibg=NONE gui=bold
hi VisualNOS                     guibg=#0e0e0e
hi Visual                        guibg=#0e0e0e
hi WarningMsg      guifg=#fdf5ef guibg=NONE gui=bold
hi WildMenu        guifg=#47dfd3 guibg=#0e0e0e

hi TabLineFill     guifg=#0e0e0e guibg=#0e0e0e
hi TabLine         guibg=#0e0e0e guifg=#00ff85 gui=none

" Special Setting
hi MethodMember     guifg=#00ff85 guibg=NONE
hi CustomFunc       guifg=#e12885 guibg=NONE

set background=dark