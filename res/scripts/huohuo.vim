" huohuo.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="huohuo"

hi Normal          guifg=#fdf5ef guibg=#111310
hi Comment         guifg=#252d41
hi Cursor          guifg=#111310 guibg=#fdf5ef
hi iCursor         guifg=#111310 guibg=#fdf5ef
hi CursorLine                    guibg=#252d41
hi CursorLineNr    guifg=#52a5ac               gui=none
hi CursorColumn                  guibg=#252d41
hi ColorColumn                   guibg=#111310
hi LineNr          guifg=#83f1f3 guibg=#111310
hi NonText         guifg=#83f1f3
hi SpecialKey      guifg=#83f1f3

" Custom color definitions based on huohuo palette
hi Boolean         guifg=#c4ffd6
hi Character       guifg=#81c5ad
hi Number          guifg=#c4ffd6
hi String          guifg=#81c5ad
hi Conditional     guifg=#91e5ad               gui=bold
hi Constant        guifg=#c4ffd6               gui=bold

hi Debug           guifg=#325f65              gui=bold
hi Define          guifg=#91b995
hi Delimiter       guifg=#91e5ad
hi DiffAdd                       guibg=#c4ffd6
hi DiffChange      guifg=#81c5ad  guibg=#252d41
hi DiffDelete      guifg=#83f1f3 guibg=#252d41
hi DiffText                       guibg=#252d41 gui=italic,bold

hi Directory       guifg=#325f65               gui=bold
hi Error           guifg=#81c5ad guibg=#252d41
hi ErrorMsg        guifg=#91e5ad guibg=#111310 gui=bold
hi Exception       guifg=#325f65               gui=bold
hi Float           guifg=#c4ffd6
hi FoldColumn      guifg=#83f1f3 guibg=#111310
hi Folded          guifg=#83f1f3 guibg=#111310
hi Function        guifg=#325f65
hi Identifier      guifg=#52a5ac
hi Ignore          guifg=#eff8fe guibg=bg
hi IncSearch       guifg=#c7ffda guibg=#111310

hi Keyword         guifg=#91e5ad               gui=bold
hi Label           guifg=#81c5ad               gui=none
hi Macro           guifg=#c7ffda               gui=italic
hi SpecialKey      guifg=#91b995               gui=italic

hi MatchParen      guifg=#111310 guibg=#52a5ac gui=bold
hi ModeMsg         guifg=#81c5ad
hi MoreMsg         guifg=#81c5ad
hi Operator        guifg=#91e5ad

" complete menu
hi Pmenu           guifg=#91b995 guibg=#111310
hi PmenuSel                      guibg=#eff8fe
hi PmenuSbar                     guibg=#252d41
hi PmenuThumb      guifg=#91b995

hi PreCondit       guifg=#325f65               gui=bold
hi PreProc         guifg=#325f65
hi Question        guifg=#91b995
hi Repeat          guifg=#91e5ad               gui=bold
hi Search          guifg=#111310
" marks
hi SignColumn      guifg=#325f65 guibg=#111310
hi SpecialChar     guifg=#91e5ad               gui=bold
hi SpecialKey      guifg=#91e5ad gui=bold
hi SpecialComment  guifg=#252d41               gui=bold
hi Special         guifg=#91b995 guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#91e5ad               gui=bold
hi StatusLine      guifg=#83f1f3 guibg=fg
hi StatusLineNC    guifg=#eff8fe guibg=#252d41
hi StorageClass    guifg=#52a5ac               gui=italic
hi Structure       guifg=#91b995
hi Tag             guifg=#91e5ad               gui=italic
hi Title           guifg=#52a5ac
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#91b995
hi Type            guifg=#91b995               gui=none
hi Underlined      guifg=#eff8fe               gui=underline

hi VertSplit       guifg=#eff8fe guibg=#252d41 gui=bold
hi VisualNOS                     guibg=#111310
hi Visual                        guibg=#111310
hi WarningMsg      guifg=#fdf5ef guibg=#252d41 gui=bold
hi WildMenu        guifg=#91b995 guibg=#111310

hi TabLineFill     guifg=#111310 guibg=#111310
hi TabLine         guibg=#111310 guifg=#eff8fe gui=none

" Special Setting
hi MethodMember     guifg=#d4feff guibg=NONE
hi CustomFunc       guifg=#325f65 guibg=NONE

set background=dark