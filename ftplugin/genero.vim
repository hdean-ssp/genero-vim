" Genero-Tools Plugin - Filetype Plugin for Genero

" Set omnifunc for genero files
setlocal omnifunc=genero_tools#complete#omnifunc

" Set comment string for genero files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for genero files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif
