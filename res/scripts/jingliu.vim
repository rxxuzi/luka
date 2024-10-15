" jingliu.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="jingliu"

hi Normal          guifg=#efefff guibg=#161626
hi Comment         guifg=#38343d
hi Cursor          guifg=#161626 guibg=#efefff
hi iCursor         guifg=#161626 guibg=#efefff
hi CursorLine                    guibg=#665a5f
hi CursorLineNr    guifg=#26bdf7               gui=none
hi CursorColumn                  guibg=#665a5f
hi ColorColumn                   guibg=#161626
hi LineNr          guifg=#dc2f28 guibg=#161626
hi NonText         guifg=#dc2f28
hi SpecialKey      guifg=#dc2f28

" Custom color definitions based on jingliu palette
hi Boolean         guifg=#7ea8d9
hi Character       guifg=#96bde7
hi Number          guifg=#7ea8d9
hi String          guifg=#96bde7
hi Conditional     guifg=#1871c2               gui=bold
hi Constant        guifg=#7ea8d9               gui=bold

hi Debug           guifg=#2e297e              gui=bold
hi Define          guifg=#09aaf0
hi Delimiter       guifg=#1871c2
hi DiffAdd                       guibg=#7ea8d9
hi DiffChange      guifg=#96bde7  guibg=#665a5f
hi DiffDelete      guifg=#dc2f28 guibg=#665a5f
hi DiffText                       guibg=#665a5f gui=italic,bold

hi Directory       guifg=#2e297e               gui=bold
hi Error           guifg=#96bde7 guibg=#665a5f
hi ErrorMsg        guifg=#1871c2 guibg=#161626 gui=bold
hi Exception       guifg=#2e297e               gui=bold
hi Float           guifg=#7ea8d9
hi FoldColumn      guifg=#dc2f28 guibg=#161626
hi Folded          guifg=#dc2f28 guibg=#161626
hi Function        guifg=#2e297e
hi Identifier      guifg=#26bdf7
hi Ignore          guifg=#aed7fa guibg=bg
hi IncSearch       guifg=#2a4b94 guibg=#161626

hi Keyword         guifg=#1871c2               gui=bold
hi Label           guifg=#96bde7               gui=none
hi Macro           guifg=#2a4b94               gui=italic
hi SpecialKey      guifg=#09aaf0               gui=italic

hi MatchParen      guifg=#161626 guibg=#26bdf7 gui=bold
hi ModeMsg         guifg=#96bde7
hi MoreMsg         guifg=#96bde7
hi Operator        guifg=#1871c2

" complete menu
hi Pmenu           guifg=#09aaf0 guibg=#161626
hi PmenuSel                      guibg=#aed7fa
hi PmenuSbar                     guibg=#38343d
hi PmenuThumb      guifg=#09aaf0

hi PreCondit       guifg=#2e297e               gui=bold
hi PreProc         guifg=#2e297e
hi Question        guifg=#09aaf0
hi Repeat          guifg=#1871c2               gui=bold
hi Search          guifg=#161626
" marks
hi SignColumn      guifg=#2e297e guibg=#161626
hi SpecialChar     guifg=#1871c2               gui=bold
hi SpecialKey      guifg=#1871c2 gui=bold
hi SpecialComment  guifg=#38343d               gui=bold
hi Special         guifg=#09aaf0 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#efefff   gui=undercurl
endif
hi Statement       guifg=#1871c2               gui=bold
hi StatusLine      guifg=#dc2f28 guibg=fg
hi StatusLineNC    guifg=#aed7fa guibg=#38343d
hi StorageClass    guifg=#26bdf7               gui=italic
hi Structure       guifg=#09aaf0
hi Tag             guifg=#1871c2               gui=italic
hi Title           guifg=#26bdf7
hi Todo            guifg=#efefff guibg=bg      gui=bold

hi Typedef         guifg=#09aaf0
hi Type            guifg=#09aaf0               gui=none
hi Underlined      guifg=#aed7fa               gui=underline

hi VertSplit       guifg=#aed7fa guibg=#38343d gui=bold
hi VisualNOS                     guibg=#161626
hi Visual                        guibg=#161626
hi WarningMsg      guifg=#efefff guibg=#665a5f gui=bold
hi WildMenu        guifg=#09aaf0 guibg=#161626

hi TabLineFill     guifg=#161626 guibg=#161626
hi TabLine         guibg=#161626 guifg=#aed7fa gui=none

" Special Setting
hi MethodMember     guifg=#ddc9af guibg=NONE
hi CustomFunc       guifg=#2e297e guibg=NONE

set background=dark