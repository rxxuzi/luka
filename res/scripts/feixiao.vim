" feixiao.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="feixiao"

hi Normal          guifg=#fdf5ef guibg=#111111
hi Comment         guifg=#484548
hi Cursor          guifg=#111111 guibg=#fdf5ef
hi iCursor         guifg=#111111 guibg=#fdf5ef
hi CursorLine                    guibg=#242328
hi CursorLineNr    guifg=#e5f4dd               gui=none
hi CursorColumn                  guibg=#242328
hi ColorColumn                   guibg=#111111
hi LineNr          guifg=#990000 guibg=#111111
hi NonText         guifg=#990000
hi SpecialKey      guifg=#990000

" Custom color definitions based on feixiao palette
hi Boolean         guifg=#92b6c3
hi Character       guifg=#3d627a
hi Number          guifg=#92b6c3
hi String          guifg=#3d627a
hi Conditional     guifg=#8de5ea               gui=bold
hi Constant        guifg=#92b6c3               gui=bold

hi Debug           guifg=#fcfbd7              gui=bold
hi Define          guifg=#476c87
hi Delimiter       guifg=#8de5ea
hi DiffAdd                       guibg=#92b6c3
hi DiffChange      guifg=#3d627a  guibg=#242328
hi DiffDelete      guifg=#990000 guibg=#242328
hi DiffText                       guibg=#242328 gui=italic,bold

hi Directory       guifg=#fcfbd7               gui=bold
hi Error           guifg=#3d627a guibg=#242328
hi ErrorMsg        guifg=#8de5ea guibg=#111111 gui=bold
hi Exception       guifg=#fcfbd7               gui=bold
hi Float           guifg=#92b6c3
hi FoldColumn      guifg=#990000 guibg=#111111
hi Folded          guifg=#990000 guibg=#111111
hi Function        guifg=#fcfbd7
hi Identifier      guifg=#e5f4dd
hi Ignore          guifg=#1b617c guibg=bg
hi IncSearch       guifg=#5fc7d8 guibg=#111111

hi Keyword         guifg=#8de5ea               gui=bold
hi Label           guifg=#3d627a               gui=none
hi Macro           guifg=#5fc7d8               gui=italic
hi SpecialKey      guifg=#476c87               gui=italic

hi MatchParen      guifg=#111111 guibg=#e5f4dd gui=bold
hi ModeMsg         guifg=#3d627a
hi MoreMsg         guifg=#3d627a
hi Operator        guifg=#8de5ea

" complete menu
hi Pmenu           guifg=#476c87 guibg=#111111
hi PmenuSel                      guibg=#1b617c
hi PmenuSbar                     guibg=#242328
hi PmenuThumb      guifg=#476c87

hi PreCondit       guifg=#fcfbd7               gui=bold
hi PreProc         guifg=#fcfbd7
hi Question        guifg=#476c87
hi Repeat          guifg=#8de5ea               gui=bold
hi Search          guifg=#111111
" marks
hi SignColumn      guifg=#fcfbd7 guibg=#111111
hi SpecialChar     guifg=#8de5ea               gui=bold
hi SpecialKey      guifg=#8de5ea gui=bold
hi SpecialComment  guifg=#e8e5e8               gui=bold
hi Special         guifg=#476c87 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#8de5ea               gui=bold
hi StatusLine      guifg=#990000 guibg=fg
hi StatusLineNC    guifg=#1b617c guibg=#242328
hi StorageClass    guifg=#e5f4dd               gui=italic
hi Structure       guifg=#476c87
hi Tag             guifg=#8de5ea               gui=italic
hi Title           guifg=#e5f4dd
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#476c87
hi Type            guifg=#476c87               gui=none
hi Underlined      guifg=#1b617c               gui=underline

hi VertSplit       guifg=#1b617c guibg=#242328 gui=bold
hi VisualNOS                     guibg=#111111
hi Visual                        guibg=#111111
hi WarningMsg      guifg=#fdf5ef guibg=#242328 gui=bold
hi WildMenu        guifg=#476c87 guibg=#111111

hi TabLineFill     guifg=#111111 guibg=#111111
hi TabLine         guibg=#111111 guifg=#1b617c gui=none

" Special Setting
hi MethodMember     guifg=#b2cbce guibg=NONE
hi CustomFunc       guifg=#fcfbd7 guibg=NONE

set background=dark