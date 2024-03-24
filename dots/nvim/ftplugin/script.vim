" Gliss scripts
syntax on

syntax match action '^\s*\(Set\|Move\|Look\|Anim\|AddItem\|SkillCheck\):'
highlight link action Keyword

syntax match condition 'If:'
highlight link condition Exception

syntax match verse '\(> \)\=@[a-zA-Z0-9_-]\+'
highlight link verse Constant

syntax match actor '\[[a-zA-Z0-9_-]\+\]'
highlight link actor Character

syntax match branch '^\s*>'
highlight link branch Statement

syntax match operator ':'
syntax match operator '='
highlight link operator Operator

syntax match meta '\(Id\|Scene\|Tags\):.*'
highlight link meta Comment
