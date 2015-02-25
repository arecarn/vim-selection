"SCRIPT SETTINGS {{{
let s:saveCpo = &cpo   "allow line continuation
set cpo&vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

"AUTO COMMANDS {{{
augroup selection_mode
    autocmd!
    autocmd CursorMoved * let g:selection_mode = mode()
augroup END "}}}

"FUNCTIONS {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#New(count, firstLine, lastLine) "{{{2
    "Constructor for the selection object. That uses escape sequence parameters
    "passed in from commands.
    "
    "Parameters:
    "count: should be the command escape sequence <count>
    "firstLine: should be the command escape sequence <line1>
    "lastLine: should be the command escape sequence <line2>

    let selection = {
                \  'content'      : '',
                \  'type'         : '',
                \  'firstLine'    : 0,
                \  'lastLine'     : 0,
                \  'OverWrite'    : function('selection#OverWrite'),
                \  'GetLines'     : function('selection#GetLines'),
                \  'GetSelection' : function('selection#GetSelection'),
                \  }

    if a:count == 0 "no selection given
        let selection.type = "none"
    else "selection was given
        if g:selection_mode =~ '\v\Cv|'
            let selection.type = "selection"
        else "line wise mark, %, or visual line selection given
            let selection.type = "lines"
            let selection.firstLine = a:firstLine
            let selection.lastLine = a:lastLine
        endif
    endif


    "Capture the selection
    if selection.type == 'selection'
        let selection.content = selection.GetSelection()
    elseif selection.type == 'lines'
        let selection.content = selection.GetLines()
    elseif selection.type == 'none'
        let selection.content =''
    else
        throw "selection.vim invalid value for selection.type"
    endif

    return selection
endfunction "}}} 2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#OverWrite(selectionToPut) dict "{{{2
    """
    """

    let a_save = @a

    if self.type == "selection"
        call setreg('a', a:selectionToPut, g:selection_mode)
        normal! gv"ap
    elseif self.type == "lines"
        call setline(self.firstLine, split(a:selectionToPut, "\n"))
    else
        call throw "selection.vim: invalid value for selection.type"
    endif

    let @a = a_save
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#GetLines() dict "{{{2
    return join(getline(self.firstLine, self.lastLine), "\n")
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#GetSelection() dict "{{{2
    """
    """

    try
        let a_save = getreg('a')
        normal! gv"ay
        return @a
    finally
        call setreg('a', a_save)
    endtry
endfunction "}}}2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

"SCRIPT SETTINGS {{{
let &cpo = s:saveCpo
" vim:foldmethod=marker
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}
