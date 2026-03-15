" Genero-Tools Plugin - Keybindings

" Register default keybindings
function! genero_tools#keybindings#register() abort
  " Lookup function definition
  nnoremap <silent> <leader>gl :GeneroLookup <C-R><C-W><CR>
  
  " List functions in file (expand % to current filename)
  nnoremap <silent> <leader>gf :call genero_tools#list_functions_in_file(expand('%'))<CR>
  
  " Get function signature
  nnoremap <silent> <leader>gs :GeneroFunctionSignature <C-R><C-W><CR>
  
  " Get file metadata (expand % to current filename)
  nnoremap <silent> <leader>gm :call genero_tools#get_file_metadata(expand('%'))<CR>
endfunction
