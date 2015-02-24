"SCRIPT SETTINGS {{{
let save_cpo = &cpo   "allow line continuation
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
                \  'Selection'    : '',
                \  'Type'         : '',
                \  'FirstLine'    : 0,
                \  'LastLine'     : 0,
                \  'OverWrite'    : function('selection#OverWrite'),
                \  'GetLines'     : function('selection#GetLines'),
                \  'GetSelection' : function('selection#GetSelection'),
                \  }

    if a:count == 0 "no selection given
        let selection.Type = "none"
    else "selection was given
        if g:selection_mode =~ '\v\Cv|'
            let selection.Type = "selection"
        else "line wise mark, %, or visual line selection given
            let selection.Type = "lines"
            let selection.FirstLine = a:firstLine
            let selection.LastLine = a:lastLine
        endif
    endif


    "Capture the selection
    if selection.Type == 'selection'
        let selection.Selection = selection.GetSelection()
    elseif selection.Type == 'lines'
        let selection.Selection = selection.GetLines()
    elseif selection.Type == 'none'
        let selection.Selection =''
    else
        call throw "selection.vim invalid value for Selection.Type"
    endif

    return selection
endfunction "}}} 2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#OverWrite(selectionToPut) dict "{{{2
    """
    """

    let a_save = @a

    if self.Type == "selection"
        call setreg('a', a:selectionToPut, g:selection_mode)
        normal! gv"ap
    elseif self.Type == "lines"
        call setline(self.FirstLine, split(a:selectionToPut, "\n"))
    else
        call throw "selection.vim: invalid value for Selection.Type"
    endif

    let @a = a_save
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! selection#GetLines() dict "{{{2
    return join(getline(self.FirstLine, self.LastLine), "\n")
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
let &cpo = save_cpo
" vim:foldmethod=marker
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}
