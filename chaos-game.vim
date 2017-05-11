let s:width = 80 * 2
let s:height = 32 * 4

let s:vertices = []

let s:row = 0
let s:col = 0


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
    let l:dice = s:rand(len(s:vertices))
    let s:row = (s:row + s:vertices[l:dice][0]) / 2
    let s:col = (s:col + s:vertices[l:dice][1]) / 2
    call s:plot(s:row, s:col)
endfunction


function s:next_1000_point ()
    for l:i in range(1000)
        call s:next_point()
    endfor
endfunction


function s:main ()
    setlocal buftype=nofile
    setlocal noswapfile

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

    for l:i in range(len(s:vertices))
        call s:plot(s:vertices[(l:i)][0], s:vertices[(l:i)][1])
    endfor

    let s:row = s:rand(s:height)
    let s:col = s:rand(s:width)
    call s:plot(s:row, s:col)
endfunction


nnoremap <space> :call <SID>next_point()<CR>
nnoremap <cr> :call <SID>next_1000_point()<CR>


call s:main()
