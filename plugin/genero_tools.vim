" Vim Genero-Tools Plugin
" Main plugin entry point
" Provides code navigation and lookup for large-scale Genero codebases

if exists('g:loaded_genero_tools')
  finish
endif
let g:loaded_genero_tools = 1

" Initialize configuration
call genero_tools#config#init()

" Initialize compiler autocompile if enabled
call genero_tools#compiler#autocompile#init()

" Initialize SVN module
call genero_tools#svn#init()

" Initialize Lua layer if available (Neovim only)
call genero_tools#lua_bridge#init()

" Register user commands
command! -nargs=? GeneroLookup call genero_tools#lookup_function(<q-args>)
command! -nargs=? GeneroListModuleFiles call genero_tools#list_module_files(<q-args>)
command! -nargs=? GeneroListFunctions call genero_tools#list_functions_in_file(<q-args>)
command! -nargs=? GeneroFunctionSignature call genero_tools#get_function_signature(<q-args>)
command! -nargs=? GeneroFileMetadata call genero_tools#get_file_metadata(<q-args>)
command! GeneroClearCache call genero_tools#cache#clear()
command! GeneroConfigShow call genero_tools#config#show()
command! GeneroCompleteEnable call genero_tools#complete#enable()
command! GeneroCompleteDisable call genero_tools#complete#disable()

" Register compiler commands
command! -nargs=? -complete=file GeneroCompile call genero_tools#compiler#commands#compile(<q-args>)
command! GeneroClearErrors call genero_tools#compiler#commands#clear_errors()
command! GeneroNextError call genero_tools#compiler#commands#next_error()
command! GeneroPrevError call genero_tools#compiler#commands#prev_error()
command! GeneroFirstError call genero_tools#compiler#commands#first_error()
command! GeneroLastError call genero_tools#compiler#commands#last_error()
command! GeneroAutocompileEnable call genero_tools#compiler#commands#autocompile_enable()
command! GeneroAutocompileDisable call genero_tools#compiler#commands#autocompile_disable()
command! GeneroAutocompileStatus call genero_tools#compiler#commands#autocompile_status()

" Register snippet commands (Neovim only)
if has('nvim')
  command! GeneroSnippetList call genero_tools#snippets#list()
  command! -nargs=? GeneroSnippetHelp call genero_tools#snippets#help(<q-args>)
  command! -nargs=? GeneroSnippet call genero_tools#snippets#expand(<q-args>)
endif

" Register SVN commands
command! GeneroSVNRefresh call genero_tools#svn#commands#refresh()
command! GeneroSVNToggle call genero_tools#svn#commands#toggle()
command! GeneroSVNStatus call genero_tools#svn#commands#status()
command! GeneroSVNCacheStats call genero_tools#svn#commands#cache_stats()
command! GeneroSVNCacheClear call genero_tools#svn#commands#cache_clear()

" Register sign commands
call genero_tools#signs#commands#register()

" Register keybindings if enabled
if genero_tools#config#get('keybindings_enabled')
  call genero_tools#keybindings#register()
endif


