" Genero-Tools Plugin - Filetype Plugin for Genero

" Setup auto-completion on pause if enabled
if genero_tools#config#get('autocomplete_on_pause')
  call genero_tools#complete#setup_auto()
endif

" Set comment string for genero files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for genero files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Load SVN signs on file entry if SVN is enabled
if genero_tools#config#get('svn_enabled')
  call genero_tools#svn#load_signs_for_buffer(bufnr('%'))
endif

" Setup statusline integration for error/warning counts
call genero_tools#display#setup_statusline()

" Navigation in completion menu
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
