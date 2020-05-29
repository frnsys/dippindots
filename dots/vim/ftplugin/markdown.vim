" colorscheme light
set nocursorcolumn
setlocal spell
set complete+=kspell

let g:vimfootnotelinebreak = 0
" let g:markdown_fenced_languages = ['css', 'javascript', 'js=javascript', 'json=javascript', 'sass', 'xml', 'html', 'python']


" open markdown syntax urls
" open local images with feh
" open local gifs with gifview
function! OpenUrlUnderCursor()
    let l:lnum = line('.')
    let l:line = getline(l:lnum)
    let l:coln = col('.')

    let l:lcol = l:coln
    while l:line[l:lcol] != '(' && l:line[l:lcol] != '<' && l:lcol >= 0
        let l:lcol -= 1
    endwhile

    let l:rcol = l:coln
    while l:line[l:rcol] != ')' && l:line[l:rcol] != '>' && l:rcol <= col("$")-1
        let l:rcol += 1
    endwhile

    let l:obj = l:line[l:lcol + 1: l:rcol - 1]
    let l:url = matchstr(l:obj, '\(http\|https\):\/\/[^ >,;]*')
    let l:img = matchstr(l:obj, '[^<>()]\+\.\(jpg\|jpeg\|png\|gif\)')
    if l:url != ''
        call netrw#BrowseX(l:url, 0)
    elseif l:img != ''
        if matchend(l:img, 'gif') >= 0
            silent exec "!gifview -a '".l:img."'" | redraw!
        else
            silent exec "!feh --scale-down '".l:img."'" | redraw!
        endif
    else
        echomsg 'The cursor is not on a link.'
    endif
endfunction
nnoremap gx :call OpenUrlUnderCursor()<cr>

" easily paste html clipboard content as quoted markdown
nnoremap <leader>c :r !nom clip<cr>

" easily paste pdf clipboard content as quoted markdown
nnoremap <leader>d :r !pdfpaste<cr>

" screenshot, move to assets folder, paste in markdown
nnoremap <leader>s "=system("fpath=$(shot region <bar> tail -n 1); fname=$(basename $fpath); mv $fpath assets/$fname; echo '![](assets/'$fname')'")<CR>P

" use J/K to move up/down visual (wrapped) lines
map J gj
map K gk

" assuming inline annotations are demarcated
" by {...}, this highlights those annotations
map <leader>h /{.\+}<CR>

" make footnote from selected text
vnoremap <C-f> y:! cite "<C-r>0" \| xsel -b<cr>
