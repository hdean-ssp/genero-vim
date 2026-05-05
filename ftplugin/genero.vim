" Genero-Tools Plugin - Filetype Plugin for Genero

" Setup completion (omnifunc always enabled, pause-based optional via config)
call genero_tools#complete#setup_auto()

" Setup completion preview window (for omnifunc fallback)
call genero_tools#complete#setup_preview()

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
