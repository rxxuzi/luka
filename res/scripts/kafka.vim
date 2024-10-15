" kafka.vim
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="kafka"

hi Normal          guifg=#fdf5ef guibg=#0e1119
hi Comment         guifg=#3d3337
hi Cursor          guifg=#0e1119 guibg=#fdf5ef
hi iCursor         guifg=#0e1119 guibg=#fdf5ef
hi CursorLine                    guibg=#1e2129
hi CursorLineNr    guifg=#d9d6e7               gui=none
hi CursorColumn                  guibg=#1e2129
hi ColorColumn                   guibg=#0e1119
hi LineNr          guifg=#e9c092 guibg=#0e1119
hi NonText         guifg=#e9c092
hi SpecialKey      guifg=#e9c092

" Custom color definitions based on kafka palette
hi Boolean         guifg=#902f5e
hi Character       guifg=#ac4e7f
hi Number          guifg=#902f5e
hi String          guifg=#ac4e7f
hi Conditional     guifg=#bd90c1               gui=bold
hi Constant        guifg=#902f5e               gui=bold

hi Debug           guifg=#9f4d74              gui=bold
hi Define          guifg=#7e3a5f
hi Delimiter       guifg=#bd90c1
hi DiffAdd                       guibg=#902f5e
hi DiffChange      guifg=#ac4e7f  guibg=#1e2129
hi DiffDelete      guifg=#e9c092 guibg=#1e2129
hi DiffText                       guibg=#1e2129 gui=italic,bold

hi Directory       guifg=#9f4d74               gui=bold
hi Error           guifg=#ac4e7f guibg=#1e2129
hi ErrorMsg        guifg=#bd90c1 guibg=#0e1119 gui=bold
hi Exception       guifg=#9f4d74               gui=bold
hi Float           guifg=#902f5e
hi FoldColumn      guifg=#e9c092 guibg=#0e1119
hi Folded          guifg=#e9c092 guibg=#0e1119
hi Function        guifg=#9f4d74
hi Identifier      guifg=#d9d6e7
hi Ignore          guifg=#6d456f guibg=bg
hi IncSearch       guifg=#884c69 guibg=#0e1119

hi Keyword         guifg=#bd90c1               gui=bold
hi Label           guifg=#ac4e7f               gui=none
hi Macro           guifg=#884c69               gui=italic
hi SpecialKey      guifg=#7e3a5f               gui=italic

hi MatchParen      guifg=#0e1119 guibg=#d9d6e7 gui=bold
hi ModeMsg         guifg=#ac4e7f
hi MoreMsg         guifg=#ac4e7f
hi Operator        guifg=#bd90c1

" complete menu
hi Pmenu           guifg=#7e3a5f guibg=#0e1119
hi PmenuSel                      guibg=#6d456f
hi PmenuSbar                     guibg=#1e2129
hi PmenuThumb      guifg=#7e3a5f

hi PreCondit       guifg=#9f4d74               gui=bold
hi PreProc         guifg=#9f4d74
hi Question        guifg=#7e3a5f
hi Repeat          guifg=#bd90c1               gui=bold
hi Search          guifg=#0e1119
" marks
hi SignColumn      guifg=#9f4d74 guibg=#0e1119
hi SpecialChar     guifg=#bd90c1               gui=bold
hi SpecialKey      guifg=#bd90c1 gui=bold
hi SpecialComment  guifg=#3d3337               gui=bold
hi Special         guifg=#7e3a5f guibg=bg      gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#fdf5ef   gui=undercurl
endif
hi Statement       guifg=#bd90c1               gui=bold
hi StatusLine      guifg=#e9c092 guibg=fg
hi StatusLineNC    guifg=#6d456f guibg=#1e2129
hi StorageClass    guifg=#d9d6e7               gui=italic
hi Structure       guifg=#7e3a5f
hi Tag             guifg=#bd90c1               gui=italic
hi Title           guifg=#d9d6e7
hi Todo            guifg=#fdf5ef guibg=bg      gui=bold

hi Typedef         guifg=#7e3a5f
hi Type            guifg=#7e3a5f               gui=none
hi Underlined      guifg=#6d456f               gui=underline

hi VertSplit       guifg=#6d456f guibg=#1e2129 gui=bold
hi VisualNOS                     guibg=#0e1119
hi Visual                        guibg=#0e1119
hi WarningMsg      guifg=#fdf5ef guibg=#1e2129 gui=bold
hi WildMenu        guifg=#7e3a5f guibg=#0e1119

hi TabLineFill     guifg=#0e1119 guibg=#0e1119
hi TabLine         guibg=#0e1119 guifg=#6d456f gui=none

" Special Setting
hi MethodMember     guifg=#eb3a6c guibg=NONE
hi CustomFunc       guifg=#9f4d74 guibg=NONE

set background=dark