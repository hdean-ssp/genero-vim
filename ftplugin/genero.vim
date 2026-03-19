" Genero-Tools Plugin - Filetype Plugin for Genero

" Disable omnifunc to avoid conflicts with Tab key
" Users can trigger completion manually with Ctrl+Space
" setlocal omnifunc=genero_tools#complete#omnifunc

" Set comment string for genero files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for genero files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Manual completion keybinding (Ctrl+Space)
" This avoids conflicts with Tab and other keys used for indentation
inoremap <buffer> <C-Space> <C-x><C-o>
