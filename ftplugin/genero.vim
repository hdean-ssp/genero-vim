" Genero-Tools Plugin - Filetype Plugin for Genero

" Set omnifunc for genero files
setlocal omnifunc=genero_tools#complete#omnifunc

" Set other useful options for genero files
setlocal commentstring=--\ %s

" Enable autocompile for genero files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif
