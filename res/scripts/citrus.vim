" citrus.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="citrus"

hi Normal          guifg=#FFFFFF guibg=#111111
hi Comment         guifg=#444444
hi Cursor          guifg=#111111 guibg=#FFFFFF
hi iCursor         guifg=#111111 guibg=#FFFFFF
hi CursorLine                    guibg=#222222
hi CursorLineNr    guifg=#9be100               gui=none
hi CursorColumn                  guibg=#222222
hi ColorColumn                   guibg=#111111
hi LineNr          guifg=#2cff3e guibg=#111111
hi NonText         guifg=#2cff3e
hi SpecialKey      guifg=#2cff3e

" Custom color definitions based on citrus palette
hi Boolean         guifg=#ff7742
hi Character       guifg=#fbd746
hi Number          guifg=#ff7742
hi String          guifg=#fbd746
hi Conditional     guifg=#fda318               gui=bold
hi Constant        guifg=#ff7742               gui=bold

hi Debug           guifg=#d8dc3e              gui=bold
hi Define          guifg=#fc777c
hi Delimiter       guifg=#fda318
hi DiffAdd                       guibg=#ff7742
hi DiffChange      guifg=#fbd746  guibg=#222222
hi DiffDelete      guifg=#2cff3e guibg=#222222
hi DiffText                       guibg=#222222 gui=italic,bold

hi Directory       guifg=#d8dc3e               gui=bold
hi Error           guifg=#fbd746 guibg=#222222
hi ErrorMsg        guifg=#fda318 guibg=#111111 gui=bold
hi Exception       guifg=#d8dc3e               gui=bold
hi Float           guifg=#ff7742
hi FoldColumn      guifg=#2cff3e guibg=#111111
hi Folded          guifg=#2cff3e guibg=#111111
hi Function        guifg=#d8dc3e
hi Identifier      guifg=#9be100
hi Ignore          guifg=#f6ee22 guibg=bg
hi IncSearch       guifg=#feec90 guibg=#111111

hi Keyword         guifg=#fda318               gui=bold
hi Label           guifg=#fbd746               gui=none
hi Macro           guifg=#feec90               gui=italic
hi SpecialKey      guifg=#fc777c               gui=italic

hi MatchParen      guifg=#111111 guibg=#9be100 gui=bold
hi ModeMsg         guifg=#fbd746
hi MoreMsg         guifg=#fbd746
hi Operator        guifg=#fda318

" complete menu
hi Pmenu           guifg=#fc777c guibg=#111111
hi PmenuSel                      guibg=#f6ee22
hi PmenuSbar                     guibg=#222222
hi PmenuThumb      guifg=#fc777c

hi PreCondit       guifg=#d8dc3e               gui=bold
hi PreProc         guifg=#d8dc3e
hi Question        guifg=#fc777c
hi Repeat          guifg=#fda318               gui=bold
hi Search          guifg=#111111
" marks
hi SignColumn      guifg=#d8dc3e guibg=#111111
hi SpecialChar     guifg=#fda318               gui=bold
hi SpecialKey      guifg=#fda318 gui=bold
hi SpecialComment  guifg=#444444               gui=bold
hi Special         guifg=#fc777c guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#FFFFFF   gui=undercurl
endif
hi Statement       guifg=#fda318               gui=bold
hi StatusLine      guifg=#2cff3e guibg=fg
hi StatusLineNC    guifg=#f6ee22 guibg=#222222
hi StorageClass    guifg=#9be100               gui=italic
hi Structure       guifg=#fc777c
hi Tag             guifg=#fda318               gui=italic
hi Title           guifg=#9be100
hi Todo            guifg=#FFFFFF guibg=bg      gui=bold

hi Typedef         guifg=#fc777c
hi Type            guifg=#fc777c               gui=none
hi Underlined      guifg=#f6ee22               gui=underline

hi VertSplit       guifg=#f6ee22 guibg=#222222 gui=bold
hi VisualNOS                     guibg=#111111
hi Visual                        guibg=#111111
hi WarningMsg      guifg=#FFFFFF guibg=#222222 gui=bold
hi WildMenu        guifg=#fc777c guibg=#111111

hi TabLineFill     guifg=#111111 guibg=#111111
hi TabLine         guibg=#111111 guifg=#f6ee22 gui=none

" Special Setting
hi MethodMember     guifg=#fcb70a guibg=NONE
hi CustomFunc       guifg=#d8dc3e guibg=NONE

set background=dark