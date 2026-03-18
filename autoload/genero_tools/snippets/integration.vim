" Genero-Tools Snippet Integration
" Provides VimScript interface to snippet integration functions
" Integrates snippets with GeneroLookup and autocomplete

" Ensure dependencies are loaded
if !exists('*genero_tools#error#log')
  runtime! autoload/genero_tools/error.vim
endif

" Offer snippet expansion after GeneroLookup
function! genero_tools#snippets#integration#offer_after_lookup(function_name) abort
  if !has('nvim')
    return
  endif

  if !genero_tools#lua_bridge#available()
    return
  endif

  try
    call luaeval('require("genero_tools.snippets.integration").offer_snippet_after_lookup(...)', [a:function_name])
  catch
    " Silently fail - integration is optional
  endtry
endfunction

" Expand function call snippet with given function name
function! genero_tools#snippets#integration#expand_function_call(function_name) abort
  if !has('nvim')
    call genero_tools#error#log('Snippets are a Neovim-only feature')
    return
  endif

  if !genero_tools#lua_bridge#available()
    call genero_tools#error#log('Snippets require Neovim with Lua support')
    return
  endif

  if empty(a:function_name)
    call genero_tools#error#log('Please specify a function name')
    return
  endif

  try
    call luaeval('require("genero_tools.snippets.integration").expand_function_call_snippet(...)', [a:function_name])
  catch
    call genero_tools#error#log('Error expanding function call snippet: ' . v:exception)
  endtry
endfunction

" Check if snippets are available
function! genero_tools#snippets#integration#available() abort
  if !has('nvim')
    return 0
  endif

  if !genero_tools#lua_bridge#available()
    return 0
  endif

  try
    return luaeval('require("genero_tools.snippets.integration").snippets_available()')
  catch
    return 0
  endtry
endfunction

" Get snippet configuration
function! genero_tools#snippets#integration#get_config() abort
  if !has('nvim')
    return {}
  endif

  if !genero_tools#lua_bridge#available()
    return {}
  endif

  try
    return luaeval('require("genero_tools.snippets.integration").get_snippet_config()')
  catch
    return {}
  endtry
endfunction
