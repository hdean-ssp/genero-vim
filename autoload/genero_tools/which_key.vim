" Genero-Tools Plugin - which-key Integration
" Registers all keybindings with which-key for improved discoverability

" Initialize which-key integration
function! genero_tools#which_key#init() abort
  " Check if which-key is available
  if !exists('g:which_key_map')
    return
  endif
  
  " Register keybindings with which-key
  call genero_tools#which_key#register()
endfunction

" Register all keybindings with which-key
function! genero_tools#which_key#register() abort
  if !exists('g:which_key_map')
    return
  endif
  
  " Get the leader key (default is space)
  let leader = get(g:, 'mapleader', '\')
  
  " Create main group for genero-tools (under leader + g)
  let g:which_key_map.g = {
    \ 'name': '+genero-tools',
    \ 'l': ['GeneroLookup', 'Lookup function definition'],
    \ 'f': ['call genero_tools#list_functions_in_file(expand("%"))', 'List functions in file'],
    \ 's': ['GeneroFunctionSignature', 'Get function signature'],
    \ 'm': ['call genero_tools#get_file_metadata(expand("%"))', 'Get file metadata'],
    \ 'c': {
      \ 'name': '+compiler',
      \ 'c': ['GeneroCompile', 'Compile file'],
      \ 'e': ['GeneroNextError', 'Next error'],
      \ 'E': ['GeneroPrevError', 'Previous error'],
      \ 'C': ['GeneroClearErrors', 'Clear error markers'],
    \ },
    \ 'a': {
      \ 'name': '+cache',
      \ 'c': ['GeneroClearCache', 'Clear cache'],
      \ 'm': ['GeneroHandleMemoryPressure', 'Handle memory pressure'],
    \ },
    \ 'v': {
      \ 'name': '+svn',
      \ 'd': ['GeneroSvnDiffMarkers', 'Toggle SVN diff markers'],
      \ 's': ['GeneroSvnStatus', 'Show SVN status'],
    \ },
    \ 'h': ['GeneroHelp', 'Show help'],
    \ 'C': ['GeneroConfigShow', 'Show configuration'],
  \ }
endfunction

" Register keybindings with which-key (alternative API)
function! genero_tools#which_key#register_with_api() abort
  if !exists(':WhichKey')
    return
  endif
  
  " Define keybinding groups
  let keybindings = {
    \ 'name': '+genero-tools',
    \ 'l': {
      \ 'name': 'Lookup function definition',
      \ 'cmd': 'GeneroLookup'
    \ },
    \ 'f': {
      \ 'name': 'List functions in file',
      \ 'cmd': 'call genero_tools#list_functions_in_file(expand("%"))'
    \ },
    \ 's': {
      \ 'name': 'Get function signature',
      \ 'cmd': 'GeneroFunctionSignature'
    \ },
    \ 'm': {
      \ 'name': 'Get file metadata',
      \ 'cmd': 'call genero_tools#get_file_metadata(expand("%"))'
    \ },
    \ 'c': {
      \ 'name': '+compiler',
      \ 'c': {
        \ 'name': 'Compile file',
        \ 'cmd': 'GeneroCompile'
      \ },
      \ 'e': {
        \ 'name': 'Next error',
        \ 'cmd': 'GeneroNextError'
      \ },
      \ 'E': {
        \ 'name': 'Previous error',
        \ 'cmd': 'GeneroPrevError'
      \ },
      \ 'C': {
        \ 'name': 'Clear error markers',
        \ 'cmd': 'GeneroClearErrors'
      \ },
    \ },
    \ 'a': {
      \ 'name': '+cache',
      \ 'c': {
        \ 'name': 'Clear cache',
        \ 'cmd': 'GeneroClearCache'
      \ },
      \ 'm': {
        \ 'name': 'Handle memory pressure',
        \ 'cmd': 'GeneroHandleMemoryPressure'
      \ },
    \ },
    \ 'v': {
      \ 'name': '+svn',
      \ 'd': {
        \ 'name': 'Toggle SVN diff markers',
        \ 'cmd': 'GeneroSvnDiffMarkers'
      \ },
      \ 's': {
        \ 'name': 'Show SVN status',
        \ 'cmd': 'GeneroSvnStatus'
      \ },
    \ },
    \ 'h': {
      \ 'name': 'Show help',
      \ 'cmd': 'GeneroHelp'
    \ },
    \ 'C': {
      \ 'name': 'Show configuration',
      \ 'cmd': 'GeneroConfigShow'
    \ },
  \ }
  
  " Register with which-key
  try
    call which_key#register(keybindings, 'g')
  catch
    " Silently ignore if which-key API is different
  endtry
endfunction

" Check if which-key is installed
function! genero_tools#which_key#available() abort
  return exists('g:which_key_map') || exists(':WhichKey')
endfunction

" Get which-key status
function! genero_tools#which_key#status() abort
  if genero_tools#which_key#available()
    return {
      \ 'available': 1,
      \ 'message': 'which-key integration active'
    \ }
  else
    return {
      \ 'available': 0,
      \ 'message': 'which-key not installed'
    \ }
  endif
endfunction
