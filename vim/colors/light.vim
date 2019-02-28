" Futora
" Francis Tseng (@frnsys)
" ref: <http://vimdoc.sourceforge.net/htmldoc/syntax.html>
" or :h hi

hi Normal       ctermfg=232 ctermbg=254
hi Visual       ctermbg=227
hi ModeMsg      ctermfg=1
hi ErrorMsg     ctermbg=196 ctermfg=230
hi StatusLine   ctermbg=234 ctermfg=255
hi StatusLineNC ctermbg=252 ctermfg=255

hi LineNr       ctermfg=235
hi CursorLine   ctermbg=254 cterm=none
hi CursorLineNr ctermbg=254 ctermfg=235
hi CursorColumn ctermbg=237
hi ColorColumn  ctermbg=237
hi SignColumn   ctermbg=none
hi VertSplit    cterm=none
hi TabLine      ctermbg=none ctermfg=248 cterm=none
hi TabLineSel   ctermbg=none ctermfg=238
hi TabLineFill  cterm=none ctermbg=none

hi PMenu        ctermbg=229 ctermfg=235
hi PMenuSel     cterm=reverse
hi Search       ctermbg=9 ctermfg=230
hi Folded       ctermbg=3 ctermfg=8

hi DiffAdd      ctermfg=42
hi DiffDelete   ctermfg=196
hi DiffChange   ctermfg=61

hi MatchParen   ctermbg=227
hi Comment      ctermfg=245
hi Todo         ctermbg=none ctermfg=12
hi String       ctermfg=14
hi Function     ctermfg=11
hi Conditional  ctermfg=14
hi Repeat       ctermfg=14
hi Operator     ctermfg=14
hi Include      ctermfg=14
hi Constant     ctermfg=9
hi Define       ctermfg=11
hi Special      ctermfg=8
hi Statement    ctermfg=1
hi Identifier   ctermfg=9
hi Type         ctermfg=9
hi Character    ctermfg=11
hi Number       ctermfg=11
hi Boolean      ctermfg=11
hi Float        ctermfg=11
hi Keyword      ctermfg=14
hi Error        ctermbg=160 ctermfg=2

hi Title        ctermfg=1
hi PreProc      ctermfg=14
hi SpellCap     ctermfg=none ctermbg=none cterm=underline
hi SpellBad     ctermfg=none ctermbg=none cterm=underline
hi Underlined   ctermfg=4

hi Conceal      ctermfg=4 ctermbg=none
hi Structure    ctermfg=4

" TODO unsure
hi Ignore       ctermbg=33
hi WarningMsg   ctermbg=196

" markdown
" ref: <https://github.com/tpope/vim-markdown/blob/master/syntax/markdown.vim>
hi markdownCheckboxUnchecked  ctermfg=196
hi markdownCheckboxChecked    ctermfg=35
hi markdownUnchecked          ctermfg=none
hi markdownChecked            ctermfg=248
hi markdownEqnIn              ctermfg=4
hi markdownEqnDelimiter       ctermfg=42
hi markdownCode               ctermfg=4
hi markdownCodeDelimiter      ctermfg=42
hi markdownCodeBlock          ctermfg=4
hi markdownBold               ctermfg=42 ctermbg=none
hi markdownItalic             ctermfg=42 ctermbg=none
hi markdownUrl                ctermfg=2
hi markdownRule               ctermfg=27
