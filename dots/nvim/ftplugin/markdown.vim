set nocursorcolumn
setlocal spell
set complete+=kspell
setlocal linebreak

let g:vimfootnotelinebreak = 0

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
    let l:img = matchstr(l:obj, '[^<>()]\+\.\(jpg\|jpeg\|png\|gif\|mp4\|webm\)')
    if l:url != ''
        call netrw#BrowseX(l:url, 0)
    elseif l:img != ''
        if matchend(l:img, 'gif') >= 0
            call jobstart("gifview -a '".expand('%:p:h')."/".l:img."'")
        elseif matchend(l:img, 'mp4') >= 0 || matchend(l:img, 'webm') >= 0
            call jobstart("mpv '".expand('%:p:h')."/".l:img."'")
        else
            call jobstart("feh --scale-down '".expand('%:p:h')."/".l:img."'")
        endif
    else
        echomsg 'The cursor is not on a link.'
    endif
endfunction
nnoremap gx :call OpenUrlUnderCursor()<cr>


" download the file at the specified to the "assets/"
" folder, then add markdown reference
" optionally specify filename as second argument
function! DownloadUrlToAssets(url, ...)
    " Get remote filename (removing any query params)
    let l:remotename = split(split(a:url, "/")[-1], "?")[0]

    " Get specified filename, defaulting to remote name if none
    let l:filename = get(a:, 1, l:remotename)

    " If the filename is a directory (i.e. if it ends with '/')
    " then use the remote filename and save to that directory
    if l:filename =~ '/$'
        let l:filename = l:filename.l:remotename
    endif

    " Remove parentheses
    let l:filename = substitute(l:filename, '[()]', '', 'g')

    " Download the file
    silent exec "!wget \"".a:url."\" -O \"assets/".l:filename."\""

    " Insert the image markdown
    call append(line('.'), "![](assets/".l:filename.")")

    " Go to insert the caption
    execute "normal! j0f[l"
    startinsert
endfunction

" download a video from a url using youtube-dl
" then convert to gif and insert image markdown
function! DownloadUrlToAssetsGif(url, ...)
    " Get remote filename (removing any query params)
    let l:remotename = split(split(a:url, "/")[-1], "?")[0]

    " Get specified directory
    let l:dir = "assets/".get(a:, 1, "")

    " Download the file
    echo "Downloading..."
    silent exec "!cd ".l:dir."; youtube-dl \"".a:url."\""
    let l:filename = system("youtube-dl --get-filename \"".a:url."\"")
    let l:filename = substitute(l:filename, '\n$', '', '')

    " Create the gif
    echo "Creating gif..."
    let l:gifname = substitute(l:filename, '.[A-Za-z0-9]\+$', '.gif', '')
    let l:gifname = substitute(l:gifname, '[()]', '', 'g') " Remove parentheses
    silent exec "!cd ".l:dir."; vid2gif -f 12 \"".l:filename."\" \"".l:gifname."\""
    silent exec "!cd ".l:dir."; rm \"".l:filename."\""

    " Insert the image markdown
    call append(line('.'), "![](".l:dir.l:gifname.")")

    " Go to insert the caption
    execute "normal! j0f[l"
    startinsert
endfunction


" easily paste html clipboard content as quoted markdown
nnoremap <leader>c :r !nom clip <bar> sed 's/^/> /'<cr>

" easily paste pdf clipboard content as quoted markdown
nnoremap <leader>d :r !pdfpaste <bar> sed 's/^/> /'<cr>

" screenshot, move to assets folder, paste in markdown
nnoremap <leader>s "=system("fpath=$(shot region <bar> tail -n 1); [ ! -z $fpath ] && (fname=$(basename $fpath); [ -f $fpath ] && (mv $fpath ".expand('%:p:h')."/assets/$fname; echo '![](assets/'$fname')'))")<CR>P

" use J/K to move up/down visual (wrapped) lines
map J gj
map K gk

" quickly fix the closest previous spelling error.
imap <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <c-f> [s1z=``

" assuming inline annotations are demarcated
" by {...}, this highlights those annotations
map <leader>h /{.\+}<CR>

" make footnote from selected text
vnoremap <silent> <C-f> y:! cite "<C-r>0" \| xsel -b<cr>

" compile and open in browser
nnoremap <leader>v :call jobstart('nom view -w '.expand('%:p'))<cr>

" for inline mathjax
imap <leader>b ¦¦<esc>i

" writing mode
" <https://stackoverflow.com/a/59955784>
function! ToggleWriteMode()
  let l:name = '_writeroom_'
  if bufwinnr(l:name) > 0
    colorscheme dark
    :bwipeout _writeroom_
  else
    colorscheme light

    " hide vertical split
    hi VertSplit ctermfg=bg ctermbg=NONE cterm=NONE

    " auto-close writeroom buffers when the text buffer closes
    autocmd QuitPre <buffer> :bwipeout _writeroom_

    " target column width
    let l:target = 90
    let l:width = (&columns - l:target) / 2
    silent! execute 'topleft' l:width . 'vsplit +setlocal\ nobuflisted' l:name | wincmd p
    silent! execute 'botright' l:width . 'vsplit +setlocal\ nobuflisted' l:name | wincmd p
    endif
endfunction
" nnoremap <silent> <leader>w :call ToggleWriteMode()<cr>

" easily paste in current datetime
nnoremap <leader>t "=strftime("%m.%d.%Y %H:%M")<CR>p