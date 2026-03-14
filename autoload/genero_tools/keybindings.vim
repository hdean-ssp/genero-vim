" Genero-Tools Plugin - Keybindings

" Register default keybindings
function! genero_tools#keybindings#register() abort
  " Lookup function definition
  nnoremap <silent> <leader>gl :GeneroLookup <C-R><C-W><CR>
  
  " List functions in file
  nnoremap <silent> <leader>gf :GeneroListFunctions %<CR>
  
  " Get function signature
  nnoremap <silent> <leader>gs :GeneroFunctionSignature <C-R><C-W><CR>
  
  " Get file metadata
  nnoremap <silent> <leader>gm :GeneroFileMetadata %<CR>
endfunction
