" berry.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="berry"

hi Normal          guifg=#E0FFEF guibg=#000000
hi Comment         guifg=#444444
hi Cursor          guifg=#000000 guibg=#E0FFEF
hi iCursor         guifg=#000000 guibg=#E0FFEF
hi CursorLine                    guibg=#111111
hi CursorLineNr    guifg=#a41240               gui=none
hi CursorColumn                  guibg=#111111
hi ColorColumn                   guibg=#000000
hi LineNr          guifg=#61a55d guibg=#000000
hi NonText         guifg=#61a55d
hi SpecialKey      guifg=#61a55d

" Custom color definitions based on berry palette
hi Boolean         guifg=#db2348
hi Character       guifg=#db23a8
hi Number          guifg=#db2348
hi String          guifg=#db23a8
hi Conditional     guifg=#ec3163               gui=bold
hi Constant        guifg=#db2348               gui=bold

hi Debug           guifg=#396db9              gui=bold
hi Define          guifg=#fa86b5
hi Delimiter       guifg=#ec3163
hi DiffAdd                       guibg=#db2348
hi DiffChange      guifg=#db23a8  guibg=#111111
hi DiffDelete      guifg=#61a55d guibg=#111111
hi DiffText                       guibg=#111111 gui=italic,bold

hi Directory       guifg=#396db9               gui=bold
hi Error           guifg=#db23a8 guibg=#111111
hi ErrorMsg        guifg=#ec3163 guibg=#000000 gui=bold
hi Exception       guifg=#396db9               gui=bold
hi Float           guifg=#db2348
hi FoldColumn      guifg=#61a55d guibg=#000000
hi Folded          guifg=#61a55d guibg=#000000
hi Function        guifg=#396db9
hi Identifier      guifg=#a41240
hi Ignore          guifg=#392da9 guibg=bg
hi IncSearch       guifg=#392da9 guibg=#000000

hi Keyword         guifg=#ec3163               gui=bold
hi Label           guifg=#db23a8               gui=none
hi Macro           guifg=#392da9               gui=italic
hi SpecialKey      guifg=#fa86b5               gui=italic

hi MatchParen      guifg=#000000 guibg=#a41240 gui=bold
hi ModeMsg         guifg=#db23a8
hi MoreMsg         guifg=#db23a8
hi Operator        guifg=#ec3163

" complete menu
hi Pmenu           guifg=#fa86b5 guibg=#000000
hi PmenuSel                      guibg=#392da9
hi PmenuSbar                     guibg=#111111
hi PmenuThumb      guifg=#fa86b5

hi PreCondit       guifg=#396db9               gui=bold
hi PreProc         guifg=#396db9
hi Question        guifg=#fa86b5
hi Repeat          guifg=#ec3163               gui=bold
hi Search          guifg=#000000
" marks
hi SignColumn      guifg=#396db9 guibg=#000000
hi SpecialChar     guifg=#ec3163               gui=bold
hi SpecialKey      guifg=#ec3163 gui=bold
hi SpecialComment  guifg=#444444               gui=bold
hi Special         guifg=#fa86b5 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#E0FFEF   gui=undercurl
endif
hi Statement       guifg=#ec3163               gui=bold
hi StatusLine      guifg=#61a55d guibg=fg
hi StatusLineNC    guifg=#392da9 guibg=#111111
hi StorageClass    guifg=#a41240               gui=italic
hi Structure       guifg=#fa86b5
hi Tag             guifg=#ec3163               gui=italic
hi Title           guifg=#a41240
hi Todo            guifg=#E0FFEF guibg=bg      gui=bold

hi Typedef         guifg=#fa86b5
hi Type            guifg=#fa86b5               gui=none
hi Underlined      guifg=#392da9               gui=underline

hi VertSplit       guifg=#392da9 guibg=#111111 gui=bold
hi VisualNOS                     guibg=#000000
hi Visual                        guibg=#000000
hi WarningMsg      guifg=#E0FFEF guibg=#111111 gui=bold
hi WildMenu        guifg=#fa86b5 guibg=#000000

hi TabLineFill     guifg=#000000 guibg=#000000
hi TabLine         guibg=#000000 guifg=#392da9 gui=none

" Special Setting
hi MethodMember     guifg=#392da9 guibg=NONE
hi CustomFunc       guifg=#396db9 guibg=NONE

set background=dark