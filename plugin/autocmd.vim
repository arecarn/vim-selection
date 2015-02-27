"AUTO COMMANDS {{{
augroup SELECTION_MODE
    autocmd!
    autocmd CursorMoved * let g:selection_mode = mode()
augroup END "}}}
