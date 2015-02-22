"SCRIPT SETTINGS {{{
let save_cpo = &cpo   "allow line continuation
set cpo&vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

"AUTO COMMANDS {{{
augroup range_mode
    autocmd!
    autocmd CursorMoved * let g:range_mode = mode()
augroup END "}}}

"FUNCTIONS {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#New() "{{{2
    """
    """

    let retValue = {
                \  'Type'         : '',
                \  'Range'        : '',
                \  'FirstLine'    : 0,
                \  'LastLine'     : 0,
                \  'SetType'      : function('range#range#SetType'),
                \  'GetType'      : function('range#range#GetType'),
                \  'OverWrite'    : function('range#range#OverWrite'),
                \  'GetLines'     : function('range#range#GetLines'),
                \  'GetSelection' : function('range#range#GetSelection'),
                \  'Capture'      : function('range#range#Capture'),
                \  }

    return retValue


endfunction "}}} 2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#SetType(count, firstLine, lastLine) dict "{{{2
    """
    """

    if a:count == 0 "no range given
        let self.Type = "none"
    else "range was given
        if g:range_mode =~ '\v\Cv|'
            let self.Type = "selection"
        else "line wise mark, %, or visual line range given
            let self.Type = "lines"
            let self.FirstLine = a:firstLine
            let self.LastLine = a:lastLine
        endif
    endif
    call util#debug#PrintMsg(self.FirstLine.'= first line')
    call util#debug#PrintMsg(self.LastLine.'= last line')
endfunction range#range#Range.setType "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#GetType() dict "{{{2
    """
    """

    return self.Type
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#Capture() dict "{{{2
    """
    """

    if self.Type == "selection"
        let self.Range = self.GetSelection()
    elseif self.Type == "lines"
        let self.Range = self.GetLines()
    elseif self.Type == "none"
        let self.Range =""
    else
        call range#range#Throw("Invalid value for s:Range.type")
    endif
    call util#debug#PrintMsg(self.Type.'= type of selection')
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#OverWrite(rangeToPut) dict "{{{2
    """
    """

    call util#debug#PrintHeader('Range.overWrite')
    let a_save = @a

    call util#debug#PrintVarMsg("pasting as", self.Type)
    call util#debug#PrintVarMsg("pasting", a:rangeToPut)
    if self.Type == "selection"
        call setreg('a', a:rangeToPut, g:range_mode)
        normal! gv"ap
    elseif self.Type == "lines"
        call setline(self.FirstLine, split(a:rangeToPut, "\n"))
    else
        call range#range#Throw("Invalid value for s:Range.type call s:Range.setType first")
    endif

    let @a = a_save
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#GetLines() dict "{{{2
    return join(getline(self.FirstLine, self.LastLine), "\n")
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! range#range#GetSelection() dict "{{{2
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
