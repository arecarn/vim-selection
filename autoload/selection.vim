""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Original Author: Ryan Carney
" License: WTFPL
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" BOILER PLATE {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:save_cpo = &cpo
set cpo&vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}


" CLASS {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#new(count, first_line, last_line) abort "{{{2
    " Constructor for the selection object. Provides the means to get
    " selection, and overwrite them. Also allows commands to act on visual
    " block selections.

    " Parameters:
    " count: should be the command escape sequence <count>
    " first_line: should be the command escape sequence <line1>
    " last_line: should be the command escape sequence <line2>

    let selection = {
                \  'content'      : '',
                \  'type'         : '',
                \  'first_line'    : 0,
                \  'last_line'     : 0,
                \  'over_write'    : function('selection#over_write'),
                \  'get_lines'     : function('selection#get_lines'),
                \  'get_selection' : function('selection#get_selection'),
                \  }

    if a:count == 0 " no selection given
        let selection.type = "none"
    else " selection was given
        if g:selection_mode =~ '\v\Cv|'
            let selection.type = "selection"
        else " line wise mark, %, or visual line selection given
            let selection.type = "lines"
            let selection.first_line = a:first_line
            let selection.last_line = a:last_line
        endif
    endif

    " Capture the selection
    if selection.type == 'selection'
        let selection.content = selection.get_selection()
    elseif selection.type == 'lines'
        let selection.content = selection.get_lines()
    elseif selection.type == 'none'
        let selection.content =''
    else
        throw "selection.vim invalid value for selection.type"
    endif

    return selection
endfunction "}}}2

" METHODS {{{2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#over_write(selection_to_put) abort dict "{{{3
    " Overwrite a selection with a string

    let a_save = @a

    if self.type == "selection"
        call setreg('a', a:selection_to_put, g:selection_mode)
        normal! gv"ap
    elseif self.type == "lines"
        call setline(self.first_line, split(a:selection_to_put, "\n"))
    else
        call throw "selection.vim: invalid value for selection.type"
    endif

    let @a = a_save
endfunction "}}}3


function! selection#get_lines() abort dict "{{{3
    " Returns the whole lines between a range or visual line selection

    return join(getline(self.first_line, self.last_line), "\n")
endfunction "}}}3


function! selection#get_selection() abort dict "{{{3
    " Returns the content of the last selection while preserving registers

    try
        let a_save = getreg('a')
        normal! gv"ay
        return @a
    finally
        call setreg('a', a_save)
    endtry
endfunction "}}}3
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}2
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}


" BOILER PLATE {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:foldmethod=marker
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}


