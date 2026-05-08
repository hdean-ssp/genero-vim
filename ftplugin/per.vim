" Genero-Tools Plugin - Filetype Plugin for Genero Form Files (.per)

" Setup completion (omnifunc always enabled for Ctrl+N, pause-based optional)
call genero_tools#complete#setup_auto()

" Setup completion preview window
call genero_tools#complete#setup_preview()

" Set comment string for per files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for per files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Navigation in completion menu (standard IDE behavior)
" Tab/Enter: Accept current selection
" Down/Up: Navigate through options
inoremap <buffer> <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
