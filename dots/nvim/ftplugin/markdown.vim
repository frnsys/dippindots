set nocursorcolumn
setlocal spell
set complete+=kspell
setlocal linebreak

" open markdown syntax urls
" open local images with vu
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
        execute '!firefox ' fnameescape(l:url)
    elseif l:img != ''
        seif matchend(l:img, 'mp4') >= 0 || matchend(l:img, 'webm') >= 0
            call jobstart("mpv '".expand('%:p:h')."/".l:img."'")
        else
            call jobstart("vu '".expand('%:p:h')."/".l:img."'")
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

lua <<EOF
local function insert_text_at_cursor(text)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get current cursor position
    row = row - 1  -- Convert to zero-based indexing

    -- Ensure the buffer is not read-only
    if vim.api.nvim_buf_get_option(0, 'modifiable') then
        vim.api.nvim_buf_set_text(0, row, col, row, col, {text})
    else
        print("Buffer is read-only")
    end
end

--- screenshot, move to assets folder, paste in markdown
local function screenshot()
  local fpath = vim.fn.system {
    'shot',
    'region',
    'path',
  }
  fpath = fpath:gsub("\n", "")
  if vim.fn.filereadable(fpath) == 1 then
    local fname = vim.fs.basename(fpath)
    local dir = vim.fn.expand('%:p:h')
    local relpath = "assets/" .. fname
    os.rename(fpath, dir .. "/" .. relpath)
    local img_ref = "![screenshot](" .. relpath .. ")"
    insert_text_at_cursor(img_ref)
  end
end

vim.keymap.set('n', '<leader>s', screenshot)

-- vim.api.nvim_create_autocmd('FileType', {
--   desc = 'Bind keymaps for markdown files',
--   pattern = 'markdown',
--   callback = function(opts)
--     vim.keymap.set('n', '<leader>s', screenshot, { silent = true, buffer = opts['buffer'] })
--     end,
-- })
EOF

" quickly fix the closest previous spelling error.
imap <buffer> <c-s-k> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <buffer> <c-s-k> [s1z=``

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

    " Handle potentially nested parentheses
    let l:open_parens = 0
    let l:rcol = l:coln
    while l:line[l:rcol] != '>' && l:rcol <= col("$")-1
        if l:line[l:rcol] == '('
            let l:open_parens += 1
        endif
        if l:line[l:rcol] == ')'
            if l:open_parens == 0
                break
            endif
            let l:open_parens -= 1
        endif
        let l:rcol += 1
    endwhile

    let l:obj = l:line[l:lcol + 1: l:rcol - 1]
    let l:caption = matchstr(l:obj, '!\[[^\]]\+\]')
    let l:path = l:obj[len(l:caption) + 1:len(l:obj) - 2]
    let l:img = matchstr(l:path, '\.\(jpg\|jpeg\|png\|gif\)$')
    if l:img != ''
        if l:path != g:preview_path
            call ClosePreviewImage()
            let g:preview_jobid = jobstart("vu '".expand('%:p:h')."/".l:path."' md-vu-preview")
            let g:preview_path = l:path
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
