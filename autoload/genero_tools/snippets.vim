" Genero-Tools Snippets Bridge
" Provides VimScript interface to Lua snippet functions
" Exposes snippet commands and keybindings
" Neovim-only feature

" Ensure dependencies are loaded
if !exists('*genero_tools#error#log')
  runtime! autoload/genero_tools/error.vim
endif

" Snippet list state for selection
let s:snippet_list_state = {
  \ 'selected_index': 0,
  \ 'snippets': [],
  \ 'buffer_id': -1,
  \ 'window_id': -1
  \ }

" List all available snippets with selection support
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
    " Try Telescope first if available
    let telescope_handled = luaeval('require("genero_tools.telescope").snippets()')
    
    if !telescope_handled
      " Fall back to custom popup window if Telescope not available
      if genero_tools#config#get('snippet_list_selectable')
        call genero_tools#snippets#list_with_selection()
      else
        call luaeval('require("genero_tools.snippets").list_snippets_display()')
      endif
    endif
  catch
    call genero_tools#error#error('Snippets', 'Error listing snippets: ' . v:exception)
  endtry
endfunction

" Display snippet list with keyboard/mouse selection support
function! genero_tools#snippets#list_with_selection() abort
  if !genero_tools#lua_bridge#available()
    call genero_tools#error#warn('Snippets', 'Snippets require Neovim with Lua support')
    return
  endif

  try
    " Get snippets from Lua
    let snippets = luaeval('require("genero_tools.snippets").get_all_snippets()')
    
    if empty(snippets)
      call genero_tools#error#warn('Snippets', 'No snippets available')
      return
    endif
    
    " Store snippets for selection
    let s:snippet_list_state.snippets = snippets
    let s:snippet_list_state.selected_index = 0
    
    " Create floating window with snippet list
    call genero_tools#snippets#show_snippet_list()
  catch
    call genero_tools#error#error('Snippets', 'Error displaying snippet list: ' . v:exception)
  endtry
endfunction

" Show snippet list in floating window with selection
function! genero_tools#snippets#show_snippet_list() abort
  let snippets = s:snippet_list_state.snippets
  
  if empty(snippets)
    return
  endif
  
  " Format snippet list for display
  let lines = []
  let index = 0
  for snippet in snippets
    let trigger = get(snippet, 'trigger', 'unknown')
    let description = get(snippet, 'description', '')
    let line = printf('[%d] %s - %s', index + 1, trigger, description)
    call add(lines, line)
    let index += 1
  endfor
  
  " Create buffer for snippet list
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, lines)
  
  " Create floating window
  let width = min([80, &columns - 4])
  let height = min([len(lines) + 2, &lines - 4])
  let row = (&lines - height) / 2
  let col = (&columns - width) / 2
  
  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'row': row,
    \ 'col': col,
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' Snippets '
    \ }
  
  let win = nvim_open_win(buf, v:true, opts)
  
  " Store window and buffer IDs
  let s:snippet_list_state.buffer_id = buf
  let s:snippet_list_state.window_id = win
  
  " Set buffer options
  call nvim_buf_set_option(buf, 'modifiable', v:false)
  call nvim_buf_set_option(buf, 'buftype', 'nofile')
  call nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  " Setup keybindings for selection
  call genero_tools#snippets#setup_list_keybindings()
  
  " Highlight first item
  call genero_tools#snippets#highlight_selected_snippet()
endfunction

" Setup keybindings for snippet list selection
function! genero_tools#snippets#setup_list_keybindings() abort
  " Enter to select
  nnoremap <buffer> <CR> :call genero_tools#snippets#select_snippet()<CR>
  
  " Escape to cancel
  nnoremap <buffer> <Esc> :call genero_tools#snippets#close_snippet_list()<CR>
  
  " j/k or arrow keys to navigate
  nnoremap <buffer> j :call genero_tools#snippets#next_snippet()<CR>
  nnoremap <buffer> k :call genero_tools#snippets#prev_snippet()<CR>
  nnoremap <buffer> <Down> :call genero_tools#snippets#next_snippet()<CR>
  nnoremap <buffer> <Up> :call genero_tools#snippets#prev_snippet()<CR>
  
  " Mouse click to select
  nnoremap <buffer> <LeftMouse> :call genero_tools#snippets#mouse_select_snippet()<CR>
endfunction

" Select current snippet
function! genero_tools#snippets#select_snippet() abort
  let index = s:snippet_list_state.selected_index
  let snippets = s:snippet_list_state.snippets
  
  if index < 0 || index >= len(snippets)
    return
  endif
  
  let snippet = snippets[index]
  let trigger = get(snippet, 'trigger', '')
  
  " Close the list
  call genero_tools#snippets#close_snippet_list()
  
  " Expand the selected snippet
  if !empty(trigger)
    call genero_tools#snippets#expand(trigger)
  endif
endfunction

" Navigate to next snippet in list
function! genero_tools#snippets#next_snippet() abort
  let max_index = len(s:snippet_list_state.snippets) - 1
  if s:snippet_list_state.selected_index < max_index
    let s:snippet_list_state.selected_index += 1
    call genero_tools#snippets#highlight_selected_snippet()
  endif
endfunction

" Navigate to previous snippet in list
function! genero_tools#snippets#prev_snippet() abort
  if s:snippet_list_state.selected_index > 0
    let s:snippet_list_state.selected_index -= 1
    call genero_tools#snippets#highlight_selected_snippet()
  endif
endfunction

" Handle mouse click selection
function! genero_tools#snippets#mouse_select_snippet() abort
  let line = line('.') - 1
  if line >= 0 && line < len(s:snippet_list_state.snippets)
    let s:snippet_list_state.selected_index = line
    call genero_tools#snippets#select_snippet()
  endif
endfunction

" Highlight the currently selected snippet
function! genero_tools#snippets#highlight_selected_snippet() abort
  if s:snippet_list_state.window_id == -1
    return
  endif
  
  try
    " Clear previous highlights
    call nvim_buf_clear_namespace(s:snippet_list_state.buffer_id, -1, 0, -1)
    
    " Highlight current line
    let line = s:snippet_list_state.selected_index
    call nvim_buf_add_highlight(
      \ s:snippet_list_state.buffer_id,
      \ -1,
      \ 'CursorLine',
      \ line,
      \ 0,
      \ -1
      \ )
    
    " Move cursor to selected line
    call nvim_win_set_cursor(s:snippet_list_state.window_id, [line + 1, 0])
  catch
    " Silently handle highlight errors
  endtry
endfunction

" Close snippet list
function! genero_tools#snippets#close_snippet_list() abort
  if s:snippet_list_state.window_id != -1
    try
      call nvim_win_close(s:snippet_list_state.window_id, v:true)
    catch
      " Window already closed
    endtry
    let s:snippet_list_state.window_id = -1
    let s:snippet_list_state.buffer_id = -1
  endif
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

" Expand a snippet by name/trigger using luasnip
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
    " Use luasnip expansion mode
    let expansion_mode = genero_tools#config#get('snippet_expansion_mode')
    if expansion_mode == 'luasnip'
      call luaeval('require("genero_tools.snippets").expand_with_luasnip(...)', a:trigger)
    else
      " Fallback to basic expansion
      call luaeval('require("genero_tools.snippets").expand_by_name(...)', a:trigger)
    endif
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

" Navigate to next placeholder in snippet
function! genero_tools#snippets#next_placeholder() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#lua_bridge#available()
    return
  endif

  try
    call luaeval('require("genero_tools.snippets").next_placeholder()')
  catch
    " Silently handle errors
  endtry
endfunction

" Navigate to previous placeholder in snippet
function! genero_tools#snippets#prev_placeholder() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#lua_bridge#available()
    return
  endif

  try
    call luaeval('require("genero_tools.snippets").prev_placeholder()')
  catch
    " Silently handle errors
  endtry
endfunction

" Tab key handler - jump to next placeholder or insert tab
function! genero_tools#snippets#next_placeholder_or_tab() abort
  if !has('nvim') || !genero_tools#lua_bridge#available()
    return "\<Tab>"
  endif

  try
    " Check if we're in a snippet and can jump
    let result = luaeval('require("genero_tools.snippets").next_placeholder()')
    if result
      return ''
    endif
  catch
    " Silently handle errors
  endtry
  
  " Fall back to regular tab
  return "\<Tab>"
endfunction

" Shift+Tab handler - jump to previous placeholder or insert shift+tab
function! genero_tools#snippets#prev_placeholder_or_tab() abort
  if !has('nvim') || !genero_tools#lua_bridge#available()
    return "\<S-Tab>"
  endif

  try
    " Check if we're in a snippet and can jump
    let result = luaeval('require("genero_tools.snippets").prev_placeholder()')
    if result
      return ''
    endif
  catch
    " Silently handle errors
  endtry
  
  " Fall back to regular shift+tab
  return "\<S-Tab>"
endfunction
