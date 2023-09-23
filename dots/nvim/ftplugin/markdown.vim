set nocursorcolumn
setlocal spell
set complete+=kspell
setlocal linebreak

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
nnoremap <buffer> gx <cmd>call OpenUrlUnderCursor()<cr>

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
nnoremap <buffer> <leader>c :r !nom clip <bar> sed 's/^/> /'<cr>

" easily paste pdf clipboard content as quoted markdown
nnoremap <buffer> <leader>d :r !pdfpaste <bar> sed 's/^/> /'<cr>

" screenshot, move to assets folder, paste in markdown
nnoremap <buffer> <leader>s "=system("fpath=$(shot region <bar> tail -n 1); [ ! -z $fpath ] && (fname=$(basename $fpath); [ -f $fpath ] && (mv $fpath ".expand('%:p:h')."/assets/$fname; echo '![](assets/'$fname')'))")<CR>P

" quickly fix the closest previous spelling error.
imap <buffer> <c-k> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <buffer> <c-k> [s1z=``

" compile and open in browser
nnoremap <buffer> <leader>v <cmd>call jobstart('nom view -w '.expand('%:p'))<cr>

" for inline mathjax
imap <buffer> <leader>b ¦¦<esc>i

function! ToggleCheckbox()
  let line = getline('.')
  if line =~ '- \[ \]'
    call setline('.', substitute(line, '- \[ \]', '- \[x\]', ''))
  elseif line =~ '- \[x\]'
    call setline('.', substitute(line, '- \[x\]', '- \[ \]', ''))
  elseif line =~ '- '
    call setline('.', substitute(line, '- ', '- \[ \] ', ''))
  endif
endf
nnoremap <buffer> <leader>x <cmd>call ToggleCheckbox()<CR>


" When the cursor enters a markdown image,
" this shows the image in the upper-right corner of the desktop.
let preview_path = ''
let preview_jobid = ''
function! AutoPreviewImage()
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
    let l:img = matchstr(l:obj, '[^<>()]\+\.\(jpg\|jpeg\|png\|gif\)')
    if l:img != ''
        if l:img != g:preview_path
            call ClosePreviewImage()
            if matchend(l:img, 'gif') >= 0
                let g:preview_jobid = jobstart("gifview -a '".expand('%:p:h')."/".l:img."'")
            else
                let g:preview_jobid = jobstart("bspc rule -a feh -o focus=off && feh --scale-down -g 640x480-0+0 -B \"#161616\" '".expand('%:p:h')."/".l:img."'")
            endif
            let g:preview_path = l:img
        endif
    else
        call ClosePreviewImage()
    endif
endfunction
function! ClosePreviewImage()
    if g:preview_jobid != ''
        call jobstop(g:preview_jobid)
        let g:preview_jobid = ''
        let g:preview_path = ''
    endif
endfunction
au CursorMoved *.md call AutoPreviewImage()
