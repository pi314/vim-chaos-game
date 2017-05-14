" =========================================================================== "
" Chaos game
" Author: pi314 (cychih)
"
" Recommanded usage:
"
"   $ vim -u NONE '+source chaos-game.vim'
" =========================================================================== "

let s:width = (winwidth(0) - 1) * 2
let s:height = (winheight(0) - 1) * 4

let s:vertices = []

let s:row = -1
let s:col = -1

let s:N = 100


function s:rand (range)
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')) % a:range
endfunction


function s:vwidth (str)
    return strdisplaywidth(a:str)
endfunction


function s:plot (row, col)
    let l:line = a:row / 4 + 1
    let l:col = a:col / 2 + 1
    let l:bit = [0, 3, 1, 4, 2, 5, 6, 7][(a:row % 4) * 2 + (a:col % 2)]

    try
        for i in range(line('$'), l:line)
            call append('$', '')
        endfor
    catch /.*E727.*/
    endtry
    "     0 1
    "    ----
    " 0 | 1 4
    " 1 | 2 5
    " 2 | 3 6
    " 3 | 7 8

    let l:linestr = getline(l:line)
    call setline(l:line, l:linestr . repeat(' ', l:col - s:vwidth(l:linestr)))

    execute 'normal! '. l:line .'G'
    execute 'normal! 0'. (l:col - 1) .'l'
    normal! yl
    let l:pixel = @0

    if l:pixel == ' '
        let l:pixel = nr2char(0x2800, 1)
    endif

    let l:pixel_val = char2nr(l:pixel, 1)
    let l:pixel_val -= 0x2800
    let l:pixel_val_list = []

    for l:i in range(8)
        call add(l:pixel_val_list, l:pixel_val % 2)
        let l:pixel_val = l:pixel_val / 2
    endfor

    let l:pixel_val_list[(l:bit)] = 1

    call reverse(l:pixel_val_list)
    for l:i in range(8)
        let l:pixel_val = l:pixel_val * 2 + l:pixel_val_list[0]
        call remove(l:pixel_val_list, 0)
    endfor

    let l:pixel_val += 0x2800
    let l:pixel = nr2char(l:pixel_val, 1)

    execute 'normal! r'. l:pixel
endfunction


function s:next_point ()
    if s:row == -1 || s:col == -1
        let [s:row, s:col] = s:get_cursor_pos()
    endif

    let l:dice = s:rand(len(s:vertices))
    let s:row = (s:row + s:vertices[l:dice][0]) / 2
    let s:col = (s:col + s:vertices[l:dice][1]) / 2
    call s:plot(s:row, s:col)
endfunction


function s:next_n_point ()
    for l:i in range(s:N)
        call s:next_point()
    endfor
endfunction


function Statusline ()
    return s:N
endfunction


function s:increase_n ()
    let s:N += 100
endfunction


function s:decrease_n ()
    if s:N > 100
        let s:N -= 100
    endif
endfunction


function s:get_cursor_pos ()
    let l:pos = getpos('.')
    let l:row = (l:pos[1] - 1) * 4
    let l:col = s:vwidth(strpart(getline('.'), 0, l:pos[2] - 1)) * 2
    return [l:row, l:col]
endfunction


function s:create_vertex ()
    retab
    let l:pos = s:get_cursor_pos()
    call s:plot(l:pos[0], l:pos[1])
    call add(s:vertices, l:pos)
endfunction


setlocal buftype=nofile
setlocal noswapfile
set nonu
set statusline=%{Statusline()}
set laststatus=2
set cpo=aABceFs
set clipboard=exclude:.*
set expandtab


function s:setup_demo_value ()
    call s:canvus_init()
    let s:vertices = []
    call add(s:vertices, [
                \ s:rand(s:height/4),
                \ s:rand(s:width/2) + s:width/4
                \ ])
    call add(s:vertices, [
                \ s:rand(s:height/4) + 3*s:height/4,
                \ s:rand(s:width/4)
                \ ])
    call add(s:vertices, [
                \ s:rand(s:height/4) + 3*s:height/4,
                \ s:rand(s:width/4) + 3*s:width/4
                \ ])

    for l:i in range(3)
        call s:plot(s:vertices[(l:i)][0], s:vertices[(l:i)][1])
    endfor

    let s:row = s:rand(s:height)
    let s:col = s:rand(s:width)
    call s:plot(s:row, s:col)
endfunction


function s:canvus_init ()
    normal! ggdG
    let l:canvas_line = repeat(' ', winwidth(0) - 1) . '|'
    call setline('.', l:canvas_line)
    for l:i in range(winheight(0) - 1)
        call append('$', l:canvas_line)
    endfor
endfunction


nnoremap <space> :call <SID>next_point()<CR>
nnoremap <cr> :call <SID>next_n_point()<CR>
nnoremap + :call <SID>increase_n()<CR>
nnoremap - :call <SID>decrease_n()<CR>
nnoremap C :call <SID>create_vertex()<CR>
nnoremap D :call <SID>setup_demo_value()<CR>


call s:canvus_init()
