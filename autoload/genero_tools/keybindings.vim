" Genero-Tools Plugin - Keybindings

" Register default keybindings
function! genero_tools#keybindings#register() abort
  " Lookup function definition
  if empty(maparg('<leader>gl', 'n'))
    nnoremap <silent> <leader>gl :GeneroLookup <C-R><C-W><CR>
  endif
  
  " List functions in file (expand % to current filename)
  if empty(maparg('<leader>gf', 'n'))
    nnoremap <silent> <leader>gf :call genero_tools#list_functions_in_file(expand('%'))<CR>
  endif
  
  " Get function signature
  if empty(maparg('<leader>gs', 'n'))
    nnoremap <silent> <leader>gs :GeneroFunctionSignature <C-R><C-W><CR>
  endif
  
  " Get file metadata (expand % to current filename)
  if empty(maparg('<leader>gm', 'n'))
    nnoremap <silent> <leader>gm :call genero_tools#get_file_metadata(expand('%'))<CR>
  endif
  
  " Error navigation keybindings
  if empty(maparg('<C-.>', 'n'))
    nnoremap <silent> <C-.> :call genero_tools#compiler#commands#next_error()<CR>
  endif
  if empty(maparg('<C-,>', 'n'))
    nnoremap <silent> <C-,> :call genero_tools#compiler#commands#prev_error()<CR>
  endif
  
  " Autocomplete keybinding (Ctrl+N for omnifunc)
  if empty(maparg('<C-n>', 'i'))
    inoremap <silent> <C-n> <C-x><C-o>
  endif
  
  " Debug streaming (Neovim only)
  if has('nvim')
    if empty(maparg('<leader>gd', 'n'))
      nnoremap <silent> <leader>gd :GeneroDebugStreamToggle<CR>
    endif
  endif
endfunction
