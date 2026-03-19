" Genero-Tools Plugin - Filetype Plugin for Genero/FGL

" Disable omnifunc to avoid conflicts with Tab key
" Users can trigger completion manually with Ctrl+Space
" setlocal omnifunc=genero_tools#complete#omnifunc

" Set comment string for fgl files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for fgl files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Manual completion keybinding (Ctrl+Space)
" This avoids conflicts with Tab and other keys used for indentation
inoremap <buffer> <C-Space> <C-x><C-o>

" Navigation in completion menu
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
