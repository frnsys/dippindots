" checkbox highlighting
syn match markdownCheckboxUnchecked "^\s*\[\s\]" contained
syn match markdownCheckboxChecked "^\s*\[X\]" contained
syn match markdownUnchecked "^\s*\[\s\] .*$" contains=markdownCheckboxUnchecked
syn match markdownChecked "^\s*\[X\] .*$" contains=markdownCheckboxChecked

" mathjax highlighting
syn region markdownEqn matchgroup=markdownEqnDelimiter start="¦" end="¦" keepend oneline contains=markdownEqnIn
syn region markdownEqn matchgroup=markdownEqnDelimiter start="\$\$" end="\$\$" keepend contains=markdownEqnIn
syn match markdownEqnIn ".*" contained
hi def link markdownEqnDelimiter Comment

" yaml front matter highlighting
syntax match Comment /\%^---\_.\{-}---$/ contains=@Spell

" disable indented code syntax highlighting,
" interferes with nested list items
syn clear markdownCodeBlock

" fix for nested list items to have proper bullet highlighting
syn match markdownListMarker
    \ "\%(\t\| \+\)[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker
    \ "\%(\t\| \+\)\<\d\+\.\%(\s\+\S\)\@=" contained
