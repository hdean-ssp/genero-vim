" Genero-Tools Plugin - Filetype Plugin for Genero

" Set omnifunc for genero files (only if the function exists)
if exists('*genero_tools#complete#omnifunc')
  setlocal omnifunc=genero_tools#complete#omnifunc
endif

" Set comment string for genero files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for genero files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif
