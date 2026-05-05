" Genero-Tools Plugin - Filetype Plugin for Genero

" Setup completion (omnifunc for Vim compatibility, cmp handles Neovim)
if has('nvim')
  " Neovim: omnifunc as fallback, cmp is primary
  setlocal omnifunc=genero_tools#complete#omnifunc
  " Disable pause-based autocomplete (cmp handles triggering)
  let b:genero_autocomplete_on_pause = 0
else
  " Vim: use omnifunc with pause-based triggering
  call genero_tools#complete#setup_auto()
  call genero_tools#complete#setup_preview()
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
