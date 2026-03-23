" Genero-Tools Plugin - Compiler Quickfix Integration

" Format a single compiler entry for quickfix
function! genero_tools#compiler#quickfix#format_entry(entry, type) abort
  return {
    \ 'filename': a:entry.file,
    \ 'lnum': a:entry.line,
    \ 'col': a:entry.col,
    \ 'text': a:entry.message,
    \ 'type': a:type
    \ }
endfunction

" Populate quickfix list with compiler results
" This function now respects display_mode configuration
function! genero_tools#compiler#quickfix#populate(result, filter) abort
  let qf_list = []
  
  if !a:result.success
    return {
      \ 'success': 0,
      \ 'count': 0,
      \ 'error': 'Compilation failed'
      \ }
  endif
  
  " Add errors if filter includes them
  if a:filter == 'all' || a:filter == 'errors'
    for error in get(a:result, 'errors', [])
      call add(qf_list, genero_tools#compiler#quickfix#format_entry(error, 'E'))
    endfor
  endif
  
  " Add warnings if filter includes them
  if a:filter == 'all' || a:filter == 'warnings'
    for warning in get(a:result, 'warnings', [])
      call add(qf_list, genero_tools#compiler#quickfix#format_entry(warning, 'W'))
    endfor
  endif
  
  " Add info if filter includes them
  if a:filter == 'all'
    for info_item in get(a:result, 'info', [])
      call add(qf_list, genero_tools#compiler#quickfix#format_entry(info_item, 'I'))
    endfor
  endif
  
  " Get effective display mode for compiler (respects compiler_display_mode override)
  let display_mode = genero_tools#display#get_mode('compiler')
  
  " For quickfix mode, populate the quickfix list directly
  if display_mode == 'quickfix'
    call setqflist(qf_list)
  else
    " For other display modes, only display if there are results
    if !empty(qf_list)
      " Format results for display module
      let formatted_result = {
        \ 'success': 1,
        \ 'data': qf_list,
        \ 'error': ''
        \ }
      call genero_tools#display#result(formatted_result, display_mode)
    endif
  endif
  
  return {
    \ 'success': 1,
    \ 'count': len(qf_list),
    \ 'error': ''
    \ }
endfunction

" Open quickfix window
function! genero_tools#compiler#quickfix#open() abort
  try
    copen
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to open quickfix window: ' . v:exception
      \ }
  endtry
endfunction

" Close quickfix window
function! genero_tools#compiler#quickfix#close() abort
  try
    cclose
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to close quickfix window: ' . v:exception
      \ }
  endtry
endfunction

" Navigate to next error in quickfix
function! genero_tools#compiler#quickfix#next() abort
  " Check if quickfix list is empty
  let qf_list = getqflist()
  if empty(qf_list)
    return {
      \ 'success': 0,
      \ 'error': 'No errors to navigate. Run :GeneroCompile first.'
      \ }
  endif
  
  try
    cnext
    " Get current position for feedback
    let current = getqflist({'idx': 0})
    let idx = get(current, 'idx', 0)
    let total = len(qf_list)
    echom 'Error ' . idx . ' of ' . total
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch /E553/
    " E553: No more items
    return {
      \ 'success': 0,
      \ 'error': 'No next error (at end of list)'
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Navigation failed: ' . v:exception
      \ }
  endtry
endfunction

" Navigate to previous error in quickfix
function! genero_tools#compiler#quickfix#prev() abort
  " Check if quickfix list is empty
  let qf_list = getqflist()
  if empty(qf_list)
    return {
      \ 'success': 0,
      \ 'error': 'No errors to navigate. Run :GeneroCompile first.'
      \ }
  endif
  
  try
    cprevious
    " Get current position for feedback
    let current = getqflist({'idx': 0})
    let idx = get(current, 'idx', 0)
    let total = len(qf_list)
    echom 'Error ' . idx . ' of ' . total
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch /E553/
    " E553: No more items
    return {
      \ 'success': 0,
      \ 'error': 'No previous error (at start of list)'
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Navigation failed: ' . v:exception
      \ }
  endtry
endfunction

" Clear quickfix list
function! genero_tools#compiler#quickfix#clear() abort
  try
    call setqflist([])
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to clear quickfix list: ' . v:exception
      \ }
  endtry
endfunction

" Jump to first error
function! genero_tools#compiler#quickfix#first() abort
  let qf_list = getqflist()
  if empty(qf_list)
    return {
      \ 'success': 0,
      \ 'error': 'No errors to navigate. Run :GeneroCompile first.'
      \ }
  endif
  
  try
    cfirst
    echom 'Error 1 of ' . len(qf_list)
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to jump to first error: ' . v:exception
      \ }
  endtry
endfunction

" Jump to last error
function! genero_tools#compiler#quickfix#last() abort
  let qf_list = getqflist()
  if empty(qf_list)
    return {
      \ 'success': 0,
      \ 'error': 'No errors to navigate. Run :GeneroCompile first.'
      \ }
  endif
  
  try
    clast
    echom 'Error ' . len(qf_list) . ' of ' . len(qf_list)
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to jump to last error: ' . v:exception
      \ }
  endtry
endfunction

" Open compiler results in floating window (Neovim only)
function! genero_tools#compiler#quickfix#open_floating(result) abort
  if !has('nvim')
    " Fall back to quickfix for Vim
    return genero_tools#compiler#quickfix#open()
  endif
  
  try
    " Format results for display
    let lines = []
    call add(lines, '=== Compilation Results ===')
    call add(lines, '')
    
    " Add errors
    if !empty(a:result.errors)
      call add(lines, 'ERRORS:')
      for error in a:result.errors
        call add(lines, printf('  %s:%d:%d - %s', error.file, error.line, error.col, error.message))
      endfor
      call add(lines, '')
    endif
    
    " Add warnings
    if !empty(a:result.warnings)
      call add(lines, 'WARNINGS:')
      for warning in a:result.warnings
        call add(lines, printf('  %s:%d:%d - %s', warning.file, warning.line, warning.col, warning.message))
      endfor
      call add(lines, '')
    endif
    
    " Add info
    if !empty(a:result.info)
      call add(lines, 'INFO:')
      for info_item in a:result.info
        call add(lines, printf('  %s:%d:%d - %s', info_item.file, info_item.line, info_item.col, info_item.message))
      endfor
    endif
    
    if len(lines) == 2
      call add(lines, 'No errors or warnings')
    endif
    
    " Use Lua layer if available for floating window
    if exists('*luaeval') && genero_tools#config#get('lua_enabled')
      call genero_tools#lua_bridge#show_floating_window(lines, 'Compilation Results')
    else
      " Fall back to quickfix
      call genero_tools#compiler#quickfix#open()
    endif
    
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to open floating window: ' . v:exception
      \ }
  endtry
endfunction
