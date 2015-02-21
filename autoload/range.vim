function! Range#Command(count, firstLine, lastLine, cmdInput, bang) "{{{2
    """
    "The top level function that handles arguments and user input
    """
    let cmdInputExpr  = s:HandleCmdInput(a:cmdInput, a:bang)

    if cmdInputExpr != '' "an expression was passed in
    else "no command was passed in

        call s:Range.setType(a:count, a:firstLine, a:lastLine)
        call s:Range.capture()

        if s:Range.range == '' "no lines or Selection was returned
            echom s:Range.range
        else
            call s:Range.overWrite()
        endif
    endif
    let s:bang = '' "TODO refactor
endfunction "}}}2

"RANGE {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:Range = { 'type' : "", 'range' : "", 'firstLine' : 0, 'lastLine' : 0 }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.setType(count, firstLine, lastLine) dict "{{{2
    """
    """

    if a:count == 0 "no range given
        let self.type = "none"
    else "range was given
        if g:range_mode =~ '\v\Cv|'
            let self.type = "selection"
        else "line wise mark, %, or visual line range given
            let self.type = "lines"
            let self.firstLine = a:firstLine
            let self.lastLine = a:lastLine
        endif
    endif
    call debug#PrintMsg(self.firstLine.'= first line')
    call debug#PrintMsg(self.lastLine.'= last line')
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.getType() dict "{{{2
    """
    """

    return self.type
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.capture() dict "{{{2
    """
    """

    if self.type == "selection"
        let self.range = self.getSelection()
    elseif self.type == "lines"
        let self.range = self.getLines()
    elseif self.type == "none"
        let self.range =""
    else
        call s:Throw("Invalid value for s:Range.type")
    endif
    call debug#PrintMsg(self.type.'= type of selection')
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.overWrite(rangeToPut) dict "{{{2
    """
    """

    call debug#PrintHeader('Range.overWrite')
    let a_save = @a

    call debug#PrintVarMsg("pasting as", self.type)
    call debug#PrintVarMsg("pasting", a:rangeToPut)
    if self.type == "selection"
        call setreg('a', a:rangeToPut, g:range_mode)
        normal! gv"ap
    elseif self.type == "lines"
        call setline(self.firstLine, split(a:rangeToPut, "\n"))
    else
        call s:Throw("Invalid value for s:Range.type call s:Range.setType first")
    endif

    let @a = a_save
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.getLines() dict "{{{2
    return join(getline(self.firstLine, self.lastLine), "\n")
endfunction "}}}2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Range.getSelection() dict "{{{2
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
