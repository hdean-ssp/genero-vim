" Vim Genero-Tools Plugin
" Main plugin entry point
" Provides code navigation and lookup for large-scale Genero codebases

if exists('g:loaded_genero_tools')
  finish
endif
let g:loaded_genero_tools = 1

" Initialize configuration
call genero_tools#config#init()

" Register user commands
command! -nargs=? GeneroLookup call genero_tools#lookup_function(<q-args>)
command! -nargs=? GeneroListModuleFiles call genero_tools#list_module_files(<q-args>)
command! -nargs=? GeneroListFunctions call genero_tools#list_functions_in_file(<q-args>)
command! -nargs=? GeneroFunctionSignature call genero_tools#get_function_signature(<q-args>)
command! -nargs=? GeneroFileMetadata call genero_tools#get_file_metadata(<q-args>)
command! GeneroClearCache call genero_tools#cache#clear()
command! GeneroConfigShow call genero_tools#config#show()

" Register keybindings if enabled
if genero_tools#config#get('keybindings_enabled')
  call genero_tools#keybindings#register()
endif
