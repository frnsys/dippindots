" Gliss scripts
syntax on

syntax match ScriptKeyword '\(Set\|Move\|Look\|Anim\|AddItem\|Branch\|SkillCheck\)' contained
syntax match ScriptAction '^\s*.*:' contains=ScriptKeyword
highlight ScriptKeyword guifg=#97A0C5

syntax match ScriptCondition '^\s*If:'
highlight ScriptCondition guifg=#494949

syntax match ScriptVerse '\(> \)\=@[a-zA-Z0-9_-]\+'
highlight ScriptVerse guifg=#FA3E3E

syntax match ScriptActor '\[[a-zA-Z0-9_-]\+\]'
highlight ScriptActor guifg=#ffaf87 gui=italic

syntax match operator ':'
syntax match operator '='
highlight link operator Operator

syntax match ScriptMeta '\(Id\|Scene\|Tags\):.*'
highlight link ScriptMeta Comment
