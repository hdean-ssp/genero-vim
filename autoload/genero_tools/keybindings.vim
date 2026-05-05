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
  
  " Clear errors keybinding
  if empty(maparg('<leader>cc', 'n'))
    nnoremap <silent> <leader>cc :GeneroClearErrors<CR>
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

    " Find variable references (Neovim only — scope-aware buffer scanning)
    " Note: Using nnoremap (not checking if exists) to ensure correct mapping
    nnoremap <silent> gr :GeneroFindVariableReferences<CR>
    
    " Find function references (Neovim only — uses floating window)
    nnoremap <silent> gR :GeneroFindReferences<CR>

    " Telescope pickers (Neovim only)
    if empty(maparg('<leader>gF', 'n'))
      nnoremap <silent> <leader>gF :GeneroFileFunctions<CR>
    endif
    if empty(maparg('<leader>gM', 'n'))
      nnoremap <silent> <leader>gM :GeneroModuleFunctions<CR>
    endif
    if empty(maparg('<leader>gS', 'n'))
      nnoremap <silent> <leader>gS :GeneroModuleFiles<CR>
    endif
    if empty(maparg('<leader>cD', 'n'))
      nnoremap <silent> <leader>cD :GeneroDiagnostics<CR>
    endif
  endif
  
  " Snippet placeholder navigation (Neovim only)
  if has('nvim')
    " NOTE: Tab/Shift+Tab for snippet navigation is handled by nvim-cmp
    " See init.lua.example cmp.mapping configuration
    " These keybindings are disabled to prevent conflicts with cmp
    
    " Tab to jump to next placeholder
    " if empty(maparg('<Tab>', 'i'))
    "   inoremap <silent> <Tab> <C-R>=genero_tools#snippets#next_placeholder_or_tab()<CR>
    " endif
    
    " Shift+Tab to jump to previous placeholder
    " if empty(maparg('<S-Tab>', 'i'))
    "   inoremap <silent> <S-Tab> <C-R>=genero_tools#snippets#prev_placeholder_or_tab()<CR>
    " endif
  endif
endfunction
