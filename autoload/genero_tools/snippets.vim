" Genero-Tools Snippets Bridge
" Provides VimScript interface to Lua snippet functions
" Exposes snippet commands and keybindings
" Neovim-only feature

" Ensure dependencies are loaded
if !exists('*genero_tools#error#log')
  runtime! autoload/genero_tools/error.vim
endif

" List all available snippets
function! genero_tools#snippets#list() abort
  if !has('nvim')
    call genero_tools#error#warn('Snippets', 'Snippets are a Neovim-only feature. Please upgrade to Neovim to use snippets.')
    return
  endif

  if !genero_tools#lua_bridge#available()
    call genero_tools#error#warn('Snippets', 'Snippets require Neovim with Lua support')
    return
  endif

  try
    call luaeval('require("genero_tools.snippets").list_snippets_display()')
  catch
    call genero_tools#error#error('Snippets', 'Error listing snippets: ' . v:exception)
  endtry
endfunction

" Show help for a specific snippet
function! genero_tools#snippets#help(trigger) abort
  if !has('nvim')
    call genero_tools#error#warn('Snippets', 'Snippets are a Neovim-only feature. Please upgrade to Neovim to use snippets.')
    return
  endif

  if !genero_tools#lua_bridge#available()
    call genero_tools#error#warn('Snippets', 'Snippets require Neovim with Lua support')
    return
  endif

  if empty(a:trigger)
    call genero_tools#error#warn('Snippets', 'Please specify a snippet trigger')
    return
  endif

  try
    call luaeval('require("genero_tools.snippets").show_help(...)', a:trigger)
  catch
    call genero_tools#error#error('Snippets', 'Error showing snippet help: ' . v:exception)
  endtry
endfunction

" Expand a snippet by name/trigger
function! genero_tools#snippets#expand(trigger) abort
  if !has('nvim')
    call genero_tools#error#warn('Snippets', 'Snippets are a Neovim-only feature. Please upgrade to Neovim to use snippets.')
    return
  endif

  if !genero_tools#lua_bridge#available()
    call genero_tools#error#warn('Snippets', 'Snippets require Neovim with Lua support')
    return
  endif

  if empty(a:trigger)
    call genero_tools#error#warn('Snippets', 'Please specify a snippet trigger')
    return
  endif

  try
    call luaeval('require("genero_tools.snippets").expand_by_name(...)', a:trigger)
  catch
    call genero_tools#error#error('Snippets', 'Error expanding snippet: ' . v:exception)
  endtry
endfunction

" Get snippet count for status display
function! genero_tools#snippets#get_count() abort
  if !has('nvim')
    return 0
  endif

  if !genero_tools#lua_bridge#available()
    return 0
  endif

  try
    let health = luaeval('require("genero_tools.snippets").health_check()')
    return health.snippet_count
  catch
    return 0
  endtry
endfunction

" Check if snippets are available
function! genero_tools#snippets#available() abort
  if !has('nvim')
    return 0
  endif

  if !genero_tools#lua_bridge#available()
    return 0
  endif

  try
    let health = luaeval('require("genero_tools.snippets").health_check()')
    return health.luasnip_available
  catch
    return 0
  endtry
endfunction
