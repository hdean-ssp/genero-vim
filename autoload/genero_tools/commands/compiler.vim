" Genero-Tools Plugin - Compiler User Commands

" Register compiler commands
function! genero_tools#commands#compiler#register() abort
  " GeneroCompile command
  command! -nargs=? -complete=file GeneroCompile 
    \ call genero_tools#compiler#commands#compile(<q-args>)
  
  " GeneroClearErrors command
  command! -nargs=0 GeneroClearErrors 
    \ call genero_tools#compiler#commands#clear_errors()
  
  " GeneroNextError command
  command! -nargs=0 GeneroNextError 
    \ call genero_tools#compiler#commands#next_error()
  
  " GeneroPrevError command
  command! -nargs=0 GeneroPrevError 
    \ call genero_tools#compiler#commands#prev_error()
endfunction
