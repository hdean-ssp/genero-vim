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
function! genero_tools#compiler#quickfix#populate(result, filter) abort
  let qf_list = []
  
  if !a:result.success
    return {
      \ 'success': v:false,
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
  
  " Populate quickfix list
  call setqflist(qf_list)
  
  return {
    \ 'success': v:true,
    \ 'count': len(qf_list),
    \ 'error': ''
    \ }
endfunction

" Open quickfix window
function! genero_tools#compiler#quickfix#open() abort
  try
    copen
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'Failed to open quickfix window: ' . v:exception
      \ }
  endtry
endfunction

" Close quickfix window
function! genero_tools#compiler#quickfix#close() abort
  try
    cclose
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'Failed to close quickfix window: ' . v:exception
      \ }
  endtry
endfunction

" Navigate to next error in quickfix
function! genero_tools#compiler#quickfix#next() abort
  try
    cnext
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'No next error'
      \ }
  endtry
endfunction

" Navigate to previous error in quickfix
function! genero_tools#compiler#quickfix#prev() abort
  try
    cprevious
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'No previous error'
      \ }
  endtry
endfunction

" Clear quickfix list
function! genero_tools#compiler#quickfix#clear() abort
  try
    call setqflist([])
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'Failed to clear quickfix list: ' . v:exception
      \ }
  endtry
endfunction
