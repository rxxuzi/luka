" base.vim
hi clear

if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="akari"

" ※ 以下、cterm/GUI 両方書く形に変更
"   ctermfg={ct_x_0} → {ct_x_0} が Python スクリプトによって xterm256 の数字に置換される
"   guifg={gui_x_0} → {gui_x_0} が Python スクリプトによって #RRGGBB のカラーコードに置換される

hi Normal         ctermfg={ct_x_0}  ctermbg={ct_z_0}  guifg={gui_x_0}  guibg={gui_z_0}
hi Comment        ctermfg={ct_x_1}                      guifg={gui_x_1}
hi Cursor         ctermfg={ct_z_0}  ctermbg={ct_x_0}  guifg={gui_z_0}  guibg={gui_x_0}
hi iCursor        ctermfg={ct_z_0}  ctermbg={ct_x_0}  guifg={gui_z_0}  guibg={gui_x_0}
hi CursorLine     ctermbg={ct_z_1}                      guibg={gui_z_1}
hi CursorLineNr   ctermfg={ct_c_5}                      guifg={gui_c_5} gui=none
hi CursorColumn   ctermbg={ct_z_1}                      guibg={gui_z_1}
hi ColorColumn    ctermbg={ct_z_0}                      guibg={gui_z_0}
hi LineNr         ctermfg={ct_a_0}  ctermbg={ct_z_0}  guifg={gui_a_0}  guibg={gui_z_0}
hi NonText        ctermfg={ct_a_0}                      guifg={gui_a_0}
hi SpecialKey     ctermfg={ct_a_0}                      guifg={gui_a_0}

hi Boolean        ctermfg={ct_c_0}                      guifg={gui_c_0}
hi Character      ctermfg={ct_c_1}                      guifg={gui_c_1}
hi Number         ctermfg={ct_c_0}                      guifg={gui_c_0}
hi String         ctermfg={ct_c_1}                      guifg={gui_c_1}
hi Conditional    ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi Constant       ctermfg={ct_c_0}                      guifg={gui_c_0} gui=bold

hi Debug          ctermfg={ct_c_3}                      guifg={gui_c_3} gui=bold
hi Define         ctermfg={ct_c_4}                      guifg={gui_c_4}
hi Delimiter      ctermfg={ct_a_2}                      guifg={gui_a_2}
hi DiffAdd                          ctermbg={ct_c_0}                    guibg={gui_c_0}
hi DiffChange     ctermfg={ct_c_1}  ctermbg={ct_z_1}  guifg={gui_c_1}  guibg={gui_z_1}
hi DiffDelete     ctermfg={ct_a_0}  ctermbg={ct_z_1}  guifg={gui_a_0}  guibg={gui_z_1}
hi DiffText                          ctermbg={ct_z_1}                    guibg={gui_z_1} gui=italic,bold

hi Directory      ctermfg={ct_c_3}                      guifg={gui_c_3} gui=bold
hi Error          ctermfg={ct_c_1}  ctermbg={ct_z_1}  guifg={gui_c_1}  guibg={gui_z_1}
hi ErrorMsg       ctermfg={ct_c_2}  ctermbg={ct_z_0}  guifg={gui_c_2}  guibg={gui_z_0} gui=bold
hi Exception      ctermfg={ct_c_3}                      guifg={gui_c_3} gui=bold
hi Float          ctermfg={ct_c_0}                      guifg={gui_c_0}
hi FoldColumn     ctermfg={ct_a_0}  ctermbg={ct_z_0}  guifg={gui_a_0}  guibg={gui_z_0}
hi Folded         ctermfg={ct_a_0}  ctermbg={ct_z_0}  guifg={gui_a_0}  guibg={gui_z_0}
hi Function       ctermfg={ct_c_3}                      guifg={gui_c_3}
hi Identifier     ctermfg={ct_c_5}                      guifg={gui_c_5}
hi Ignore         ctermfg={ct_c_7}  ctermbg=NONE       guifg={gui_c_7}
hi IncSearch      ctermfg={ct_c_6}  ctermbg={ct_z_0}  guifg={gui_c_6}  guibg={gui_z_0}

hi Keyword        ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi Label          ctermfg={ct_c_1}                      guifg={gui_c_1} gui=none
hi Macro          ctermfg={ct_c_6}                      guifg={gui_c_6} gui=italic
hi SpecialKey     ctermfg={ct_c_4}                      guifg={gui_c_4} gui=italic

hi MatchParen     ctermfg={ct_z_0}  ctermbg={ct_c_5}  guifg={gui_z_0}  guibg={gui_c_5} gui=bold
hi ModeMsg        ctermfg={ct_c_1}                      guifg={gui_c_1}
hi MoreMsg        ctermfg={ct_c_1}                      guifg={gui_c_1}
hi Operator       ctermfg={ct_a_2}                      guifg={gui_a_2}

hi Pmenu          ctermfg={ct_c_4}  ctermbg={ct_z_0}  guifg={gui_c_4}  guibg={gui_z_0}
hi PmenuSel                         ctermbg={ct_c_7}                    guibg={gui_c_7}
hi PmenuSbar                        ctermbg={ct_z_1}                    guibg={gui_z_1}
hi PmenuThumb     ctermfg={ct_c_4}                      guifg={gui_c_4}

hi PreCondit      ctermfg={ct_c_3}                      guifg={gui_c_3} gui=bold
hi PreProc        ctermfg={ct_c_3}                      guifg={gui_c_3}
hi Question       ctermfg={ct_c_4}                      guifg={gui_c_4}
hi Repeat         ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi Search         ctermfg={ct_z_0}                      guifg={gui_z_0}

hi SignColumn     ctermfg={ct_c_3}  ctermbg={ct_z_0}  guifg={gui_c_3}  guibg={gui_z_0}
hi SpecialChar    ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi SpecialKey     ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi SpecialComment ctermfg={ct_x_1}                      guifg={gui_x_1} gui=bold
hi Special        ctermfg={ct_c_4}                      guifg={gui_c_4} gui=italic

if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp={gui_x_0} gui=undercurl
endif

hi Statement      ctermfg={ct_c_2}                      guifg={gui_c_2} gui=bold
hi StatusLine     ctermfg={ct_a_0}  ctermbg=NONE       guifg={gui_a_0}
hi StatusLineNC   ctermfg={ct_c_7}  ctermbg={ct_z_1}  guifg={gui_c_7}  guibg={gui_z_1}
hi StorageClass   ctermfg={ct_c_5}                      guifg={gui_c_5} gui=italic
hi Structure      ctermfg={ct_c_4}                      guifg={gui_c_4}
hi Tag            ctermfg={ct_c_2}                      guifg={gui_c_2} gui=italic
hi Title          ctermfg={ct_c_5}                      guifg={gui_c_5}
hi Todo           ctermfg={ct_x_0}                      guifg={gui_x_0} gui=bold

hi Typedef        ctermfg={ct_c_4}                      guifg={gui_c_4}
hi Type           ctermfg={ct_c_4}                      guifg={gui_c_4} gui=none
hi Underlined     ctermfg={ct_c_7}                      guifg={gui_c_7} gui=underline

hi VertSplit      ctermfg={ct_c_7}  ctermbg={ct_z_1}  guifg={gui_c_7}  guibg={gui_z_1} gui=bold
hi VisualNOS                        ctermbg={ct_z_0}                    guibg={gui_z_0}
hi Visual                           ctermbg={ct_z_0}                    guibg={gui_z_0}
hi WarningMsg     ctermfg={ct_x_0}  ctermbg={ct_z_1}  guifg={gui_x_0}  guibg={gui_z_1} gui=bold
hi WildMenu       ctermfg={ct_c_4}  ctermbg={ct_z_0}  guifg={gui_c_4}  guibg={gui_z_0}

hi TabLineFill    ctermfg={ct_z_0}  ctermbg={ct_z_0}  guifg={gui_z_0}  guibg={gui_z_0}
hi TabLine        ctermbg={ct_z_0}  ctermfg={ct_c_7}  guibg={gui_z_0}  guifg={gui_c_7} gui=none

" Special Setting
hi MethodMember   ctermfg={ct_c_8}                      guifg={gui_c_8} guibg=NONE
hi CustomFunc     ctermfg={ct_c_3}                      guifg={gui_c_3} guibg=NONE

set background=dark
