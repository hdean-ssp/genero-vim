" Genero-Tools Plugin - Filetype Plugin for Genero Form Files (.per)

" Setup auto-completion on pause if enabled
if genero_tools#config#get('autocomplete_on_pause')
  call genero_tools#complete#setup_auto()
endif

" Set comment string for per files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for per files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Navigation in completion menu
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
