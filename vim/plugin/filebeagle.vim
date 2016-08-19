function! RefreshFileBeagle()
    let win = winsaveview()
    redraw!
    call feedkeys("R") " refresh filebeagle
    call winrestview(win) " doesn't seem to be working?
endfunction

function! RemoveFile(path)
    if isdirectory(a:path)
        echo "Not a file"
        return
    endif

    let choice = confirm("are you sure?", "&y\n&n", 2, "Question")
    if choice == 0
        return
    elseif choice == 2
        return
    else
        execute 'silent !rm' shellescape(a:path)
        call RefreshFileBeagle()
    endif
endfunction

function! RemoveDir(path)
    if !isdirectory(a:path)
        echo "Not a directory"
        return
    endif

    let choice = confirm("are you sure?", "yes\n&n", 2, "Question")
    if choice == 0
        return
    elseif choice == 2
        return
    else
        execute 'silent !rm -rf' shellescape(a:path)
        call RefreshFileBeagle()
    endif
endfunction

function! Rename(path)
    call inputsave()
    let target = input("rename to: ", a:path, "file")
    call inputrestore()
    execute 'silent !mv' shellescape(a:path) shellescape(target)
    call RefreshFileBeagle()
endfunction

function! MakeDir(path)
    let current_dir = fnamemodify(a:path, ':p:h')
    call inputsave()
    let target = input("make dir: ", current_dir . "/", "file")
    execute 'silent !mkdir' shellescape(target)
    call inputrestore()
    call RefreshFileBeagle()
endfunction

command -nargs=1 RemoveFile :call RemoveFile(<f-args>)
command -nargs=1 RemoveDir :call RemoveDir(<f-args>)
command -nargs=1 Rename :call Rename(<f-args>)
command -nargs=1 MakeDir :call MakeDir(<f-args>)

" % and + already create a new file
autocmd User FileBeagleReadPost nnoremap <buffer> X :PreFill! RemoveFile<CR>
autocmd User FileBeagleReadPost nnoremap <buffer> D :PreFill! RemoveDir<CR>
autocmd User FileBeagleReadPost nnoremap <buffer> m :PreFill! Rename<CR>
autocmd User FileBeagleReadPost nnoremap <buffer> d :PreFill! MakeDir<CR>
