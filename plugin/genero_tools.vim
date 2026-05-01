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

" Initialize inline diagnostics (Neovim only)
if has('nvim')
  call genero_tools#compiler#inline_diagnostics#init()
  call genero_tools#compiler#type_info#init()
endif

" Initialize block matching highlights
call genero_tools#block_match#init()

" Initialize breadcrumbs (disabled — using lualine statusline component instead)
" To use winbar breadcrumbs instead of lualine, uncomment the line below:
" if has('nvim')
"   call genero_tools#breadcrumbs#init()
" endif

" Initialize reference counts (Neovim only)
if has('nvim')
  call genero_tools#refcount#init()
endif

" Initialize auto-close blocks
call genero_tools#autoclose#init()

" Initialize unified cursor event dispatcher (must be last — dispatches to all above)
call genero_tools#cursor#init()

" Initialize hint system
call genero_tools#hints#init()

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
command! GeneroCacheStats call genero_tools#cache#show_stats()
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

" Error filtering commands
command! GeneroFilterErrors call genero_tools#compiler#commands#filter_errors()
command! GeneroFilterWarnings call genero_tools#compiler#commands#filter_warnings()
command! GeneroFilterAll call genero_tools#compiler#commands#filter_all()

" Type info command (manual trigger for testing/debugging)
command! GeneroTypeInfo call genero_tools#compiler#type_info#manual()

" Navigation commands
command! -nargs=? GeneroGotoDefinition call genero_tools#navigation#goto_definition(<q-args>)
command! -nargs=? GeneroPeekDefinition call genero_tools#navigation#peek_definition(<q-args>)

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

" Register hint commands
command! GeneroNextHint call genero_tools#hints#nav#next()
command! GeneroPrevHint call genero_tools#hints#nav#prev()
command! GeneroListHints call genero_tools#hints#nav#list()
command! GeneroHintDetails call genero_tools#hints#nav#details()
command! GeneroHintAutofix call genero_tools#hints#autofix#apply()
command! GeneroClearHintCache call genero_tools#hints#cache#clear()
command! -nargs=? GeneroHintHelp call genero_tools#hints#help(<q-args>)

" Register debug streaming commands (Neovim only)
if has('nvim')
  command! -nargs=? GeneroDebugStream call genero_tools#debug_stream#start(<q-args>)
  command! GeneroDebugStreamStop call genero_tools#debug_stream#stop()
  command! GeneroDebugStreamToggle call genero_tools#commands#debug_stream_select()
  command! GeneroDebugStreamSelect call genero_tools#commands#debug_stream_select()
  command! GeneroDebugStreamClear call genero_tools#debug_stream#clear()
  command! GeneroDebugStreamStatus call genero_tools#debug_stream#status()
  
  " Lua API commands (Neovim only)
  command! -nargs=? GeneroLuaUI call luaeval("require('genero_tools').ui()." . <q-args>)
  command! -nargs=? GeneroLuaAsync call luaeval("require('genero_tools').async()." . <q-args>)
endif

" Register sign commands
call genero_tools#signs#commands#register()

" Register keybindings if enabled
if genero_tools#config#get('keybindings_enabled')
  call genero_tools#keybindings#register()
endif

" Initialize which-key integration if available
call genero_tools#which_key#init()

" Initialize debug streaming if available
if has('nvim')
  call genero_tools#debug_stream#init()
  
  " Setup completion callback for snippet expansion
  call genero_tools#complete#setup_completion_callback()
endif

