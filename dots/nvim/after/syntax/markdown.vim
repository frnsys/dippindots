" highlight Foobar guifg=#ff0000 guibg=NONE guisp=NONE blend=NONE gui=NONE
syntax match mdHeader '^#' conceal cchar=▉
syntax match mdHeader '\(#\)\@<=#' conceal cchar=▉
syntax match mdDivider '^-\(--\)\@=' conceal cchar=▰
syntax match mdDivider '\(--\)\@<=-' conceal cchar=▰
syntax match mdDivider '\(-\)\@<=-\(-\)\@=' conceal cchar=▰
highlight Conceal guifg=#f55151
