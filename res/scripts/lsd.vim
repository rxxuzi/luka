" lsd.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="lsd"

hi Normal          guifg=#FEFEFE guibg=#000000
hi Comment         guifg=#444444
hi Cursor          guifg=#000000 guibg=#FEFEFE
hi iCursor         guifg=#000000 guibg=#FEFEFE
hi CursorLine                    guibg=#222222
hi CursorLineNr    guifg=#02e2fd               gui=none
hi CursorColumn                  guibg=#222222
hi ColorColumn                   guibg=#000000
hi LineNr          guifg=#FFFFFF guibg=#000000
hi NonText         guifg=#FFFFFF
hi SpecialKey      guifg=#FFFFFF

" Custom color definitions based on lsd palette
hi Boolean         guifg=#e51eff
hi Character       guifg=#049cf6
hi Number          guifg=#e51eff
hi String          guifg=#049cf6
hi Conditional     guifg=#ff38ff               gui=bold
hi Constant        guifg=#e51eff               gui=bold

hi Debug           guifg=#01b4ff              gui=bold
hi Define          guifg=#ff87ff
hi Delimiter       guifg=#ff38ff
hi DiffAdd                       guibg=#e51eff
hi DiffChange      guifg=#049cf6  guibg=#222222
hi DiffDelete      guifg=#FFFFFF guibg=#222222
hi DiffText                       guibg=#222222 gui=italic,bold

hi Directory       guifg=#01b4ff               gui=bold
hi Error           guifg=#049cf6 guibg=#222222
hi ErrorMsg        guifg=#ff38ff guibg=#000000 gui=bold
hi Exception       guifg=#01b4ff               gui=bold
hi Float           guifg=#e51eff
hi FoldColumn      guifg=#FFFFFF guibg=#000000
hi Folded          guifg=#FFFFFF guibg=#000000
hi Function        guifg=#01b4ff
hi Identifier      guifg=#02e2fd
hi Ignore          guifg=#00feff guibg=bg
hi IncSearch       guifg=#ff9efe guibg=#000000

hi Keyword         guifg=#ff38ff               gui=bold
hi Label           guifg=#049cf6               gui=none
hi Macro           guifg=#ff9efe               gui=italic
hi SpecialKey      guifg=#ff87ff               gui=italic

hi MatchParen      guifg=#000000 guibg=#02e2fd gui=bold
hi ModeMsg         guifg=#049cf6
hi MoreMsg         guifg=#049cf6
hi Operator        guifg=#ff38ff

" complete menu
hi Pmenu           guifg=#ff87ff guibg=#000000
hi PmenuSel                      guibg=#00feff
hi PmenuSbar                     guibg=NONE
hi PmenuThumb      guifg=#ff87ff

hi PreCondit       guifg=#01b4ff               gui=bold
hi PreProc         guifg=#01b4ff
hi Question        guifg=#ff87ff
hi Repeat          guifg=#ff38ff               gui=bold
hi Search          guifg=#000000
" marks
hi SignColumn      guifg=#01b4ff guibg=#000000
hi SpecialChar     guifg=#ff38ff               gui=bold
hi SpecialKey      guifg=#ff38ff gui=bold
hi SpecialComment  guifg=#444444               gui=bold
hi Special         guifg=#ff87ff guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#FEFEFE   gui=undercurl
endif
hi Statement       guifg=#ff38ff               gui=bold
hi StatusLine      guifg=#FFFFFF guibg=fg
hi StatusLineNC    guifg=#00feff guibg=NONE
hi StorageClass    guifg=#02e2fd               gui=italic
hi Structure       guifg=#ff87ff
hi Tag             guifg=#ff38ff               gui=italic
hi Title           guifg=#02e2fd
hi Todo            guifg=#FEFEFE guibg=bg      gui=bold

hi Typedef         guifg=#ff87ff
hi Type            guifg=#ff87ff               gui=none
hi Underlined      guifg=#00feff               gui=underline

hi VertSplit       guifg=#00feff guibg=NONE gui=bold
hi VisualNOS                     guibg=#000000
hi Visual                        guibg=#000000
hi WarningMsg      guifg=#FEFEFE guibg=#222222 gui=bold
hi WildMenu        guifg=#ff87ff guibg=#000000

hi TabLineFill     guifg=#000000 guibg=#000000
hi TabLine         guibg=#000000 guifg=#00feff gui=none

" Special Setting
hi MethodMember     guifg=#40eeff guibg=NONE
hi CustomFunc       guifg=#01b4ff guibg=NONE

set background=dark