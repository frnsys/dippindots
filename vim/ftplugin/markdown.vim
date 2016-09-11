set nocursorcolumn
setlocal spell
set complete+=kspell

let g:markdown_fenced_languages = ['css', 'javascript', 'js=javascript', 'json=javascript', 'sass', 'xml', 'html', 'python']


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
        call netrw#NetrwBrowseX(l:url, 0)
    elseif l:img != ''
        if matchend(l:img, 'gif') >= 0
            silent exec "!gifview -a '".l:img."'" | redraw!
        else
            silent exec "!feh '".l:img."'" | redraw!
        endif
    else
        echomsg 'The cursor is not on a link.'
    endif
endfunction
nnoremap gx :call OpenUrlUnderCursor()<cr>

" compile markdown and preview in browser
nnoremap <leader>p :!nom view -i "%"<cr>
