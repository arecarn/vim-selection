command! -nargs=* -range=0 -bang Range
            \ call range#Command(<count>, <line1>, <line2>, <q-args>, "<bang>")
