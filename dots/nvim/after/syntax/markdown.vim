syntax match mdHeader '^#' conceal cchar=▉
syntax match mdHeader '\(#\)\@<=#' conceal cchar=▉
syntax match mdDivider '^-\(--$\)\@=' conceal cchar=▰
syntax match mdDivider '\(--\)\@<=-$' conceal cchar=▰
syntax match mdDivider '\(-\)\@<=-\(-$\)\@=' conceal cchar=▰
highlight Conceal guifg=#6096e8
