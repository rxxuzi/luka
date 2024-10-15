" blackswan.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="blackswan"

hi Normal          guifg=#fdf5ef guibg=#05020e
hi Comment         guifg=#2d252f
hi Cursor          guifg=#05020e guibg=#fdf5ef
hi iCursor         guifg=#05020e guibg=#fdf5ef
hi CursorLine                    guibg=#2c2641
hi CursorLineNr    guifg=#9c7adc               gui=none
hi CursorColumn                  guibg=#2c2641
hi ColorColumn                   guibg=#05020e
hi LineNr          guifg=#fb9bfd guibg=#05020e
hi NonText         guifg=#fb9bfd
hi SpecialKey      guifg=#fb9bfd

" Custom color definitions based on blackswan palette
hi Boolean         guifg=#e7e5ff
hi Character       guifg=#c7baf8
hi Number          guifg=#e7e5ff
hi String          guifg=#c7baf8
hi Conditional     guifg=#826fd4               gui=bold
hi Constant        guifg=#e7e5ff               gui=bold

hi Debug           guifg=#b5ebf9              gui=bold
hi Define          guifg=#9d7bdb
hi Delimiter       guifg=#826fd4
hi DiffAdd                       guibg=#e7e5ff
hi DiffChange      guifg=#c7baf8  guibg=#2c2641
hi DiffDelete      guifg=#fb9bfd guibg=#2c2641
hi DiffText                       guibg=#2c2641 gui=italic,bold

hi Directory       guifg=#b5ebf9               gui=bold
hi Error           guifg=#c7baf8 guibg=#2c2641
hi ErrorMsg        guifg=#826fd4 guibg=#05020e gui=bold
hi Exception       guifg=#b5ebf9               gui=bold
hi Float           guifg=#e7e5ff
hi FoldColumn      guifg=#fb9bfd guibg=#05020e
hi Folded          guifg=#fb9bfd guibg=#05020e
hi Function        guifg=#b5ebf9
hi Identifier      guifg=#9c7adc
hi Ignore          guifg=#57516c guibg=bg
hi IncSearch       guifg=#feec90 guibg=#05020e

hi Keyword         guifg=#826fd4               gui=bold
hi Label           guifg=#c7baf8               gui=none
hi Macro           guifg=#feec90               gui=italic
hi SpecialKey      guifg=#9d7bdb               gui=italic

hi MatchParen      guifg=#05020e guibg=#9c7adc gui=bold
hi ModeMsg         guifg=#c7baf8
hi MoreMsg         guifg=#c7baf8
hi Operator        guifg=#826fd4

" complete menu
hi Pmenu           guifg=#9d7bdb guibg=#05020e
hi PmenuSel                      guibg=#57516c
hi PmenuSbar                     guibg=#15121e
hi PmenuThumb      guifg=#9d7bdb

hi PreCondit       guifg=#b5ebf9               gui=bold
hi PreProc         guifg=#b5ebf9
hi Question        guifg=#9d7bdb
hi Repeat          guifg=#826fd4               gui=bold
hi Search          guifg=#05020e
" marks
hi SignColumn      guifg=#b5ebf9 guibg=#05020e
hi SpecialChar     guifg=#826fd4               gui=bold
hi SpecialKey      guifg=#826fd4 gui=bold
hi SpecialComment  guifg=#2d252f               gui=bold
hi Special         guifg=#9d7bdb guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#826fd4               gui=bold
hi StatusLine      guifg=#fb9bfd guibg=fg
hi StatusLineNC    guifg=#57516c guibg=#15121e
hi StorageClass    guifg=#9c7adc               gui=italic
hi Structure       guifg=#9d7bdb
hi Tag             guifg=#826fd4               gui=italic
hi Title           guifg=#9c7adc
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#9d7bdb
hi Type            guifg=#9d7bdb               gui=none
hi Underlined      guifg=#57516c               gui=underline

hi VertSplit       guifg=#57516c guibg=#15121e gui=bold
hi VisualNOS                     guibg=#05020e
hi Visual                        guibg=#05020e
hi WarningMsg      guifg=#fdf5ef guibg=#2c2641 gui=bold
hi WildMenu        guifg=#9d7bdb guibg=#05020e

hi TabLineFill     guifg=#05020e guibg=#05020e
hi TabLine         guibg=#05020e guifg=#57516c gui=none

" Special Setting
hi MethodMember     guifg=#706e91 guibg=NONE
hi CustomFunc       guifg=#b5ebf9 guibg=NONE

set background=dark