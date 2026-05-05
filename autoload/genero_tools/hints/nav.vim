" Genero-Tools Plugin - Hint Navigation Module
" Provides navigation between hints in the current buffer

" Navigate to next hint in current buffer
function! genero_tools#hints#nav#next() abort
  let bufnr = bufnr('%')
  let current_line = line('.')
  
  " Get hints for current buffer
  let hints = genero_tools#hints#get_hints(bufnr)
  if empty(hints)
    call genero_tools#error#warn('hints', 'No hints found in current buffer')
    return
  endif
  
  " Find next hint after current line
  let next_hint = v:null
  let wrapped = 0
  for hint in hints
    if hint.line > current_line
      let next_hint = hint
      break
    endif
  endfor
  
  " If no hint found after current line, wrap to first hint
  if next_hint is v:null && !empty(hints)
    let next_hint = hints[0]
    let wrapped = 1
  endif
  
  if next_hint is v:null
    call genero_tools#error#warn('hints', 'No more hints')
    return
  endif
  
  " Jump to hint line
  call cursor(next_hint.line, next_hint.column)
  call genero_tools#hints#display#highlight_hint(next_hint)
  
  " Show position feedback
  let total = len(hints)
  let idx = index(hints, next_hint) + 1
  if wrapped
    echom 'Hint ' . idx . ' of ' . total . ' (wrapped to first)'
  else
    echom 'Hint ' . idx . ' of ' . total
  endif
endfunction

" Navigate to previous hint in current buffer
function! genero_tools#hints#nav#prev() abort
  let bufnr = bufnr('%')
  let current_line = line('.')
  
  " Get hints for current buffer
  let hints = genero_tools#hints#get_hints(bufnr)
  if empty(hints)
    call genero_tools#error#warn('hints', 'No hints found in current buffer')
    return
  endif
  
  " Find previous hint before current line
  let prev_hint = v:null
  let wrapped = 0
  for hint in reverse(copy(hints))
    if hint.line < current_line
      let prev_hint = hint
      break
    endif
  endfor
  
  " If no hint found before current line, wrap to last hint
  if prev_hint is v:null && !empty(hints)
    let prev_hint = hints[-1]
    let wrapped = 1
  endif
  
  if prev_hint is v:null
    call genero_tools#error#warn('hints', 'No previous hints')
    return
  endif
  
  " Jump to hint line
  call cursor(prev_hint.line, prev_hint.column)
  call genero_tools#hints#display#highlight_hint(prev_hint)
  
  " Show position feedback
  let total = len(hints)
  let idx = index(hints, prev_hint) + 1
  if wrapped
    echom 'Hint ' . idx . ' of ' . total . ' (wrapped to last)'
  else
    echom 'Hint ' . idx . ' of ' . total
  endif
endfunction

" List all hints in current buffer
function! genero_tools#hints#nav#list() abort
  let bufnr = bufnr('%')
  
  " Get hints for current buffer
  let hints = genero_tools#hints#get_hints(bufnr)
  if empty(hints)
    call genero_tools#error#warn('hints', 'No hints found in current buffer')
    return
  endif
  
  " Format hints for display
  let formatted = []
  for hint in hints
    let line_text = printf('Line %d: [%s] %s', hint.line, hint.category, hint.message)
    call add(formatted, line_text)
  endfor
  
  " Use configured display mode
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result({'success': 1, 'data': formatted}, display_mode)
endfunction

" Show details for hint at cursor
function! genero_tools#hints#nav#details() abort
  let bufnr = bufnr('%')
  let current_line = line('.')
  let current_col = col('.')
  
  " Get hints for current buffer
  let hints = genero_tools#hints#get_hints(bufnr)
  if empty(hints)
    call genero_tools#error#warn('hints', 'No hints found in current buffer')
    return
  endif
  
  " Find hint at current line
  let hint_at_cursor = v:null
  for hint in hints
    if hint.line == current_line
      let hint_at_cursor = hint
      break
    endif
  endfor
  
  if hint_at_cursor is v:null
    call genero_tools#error#warn('hints', 'No hint at current line')
    return
  endif
  
  " Format hint details
  let details = []
  call add(details, 'Hint Details')
  call add(details, '============')
  call add(details, 'Line: ' . hint_at_cursor.line)
  call add(details, 'Column: ' . hint_at_cursor.column)
  call add(details, 'Category: ' . hint_at_cursor.category)
  call add(details, 'Check: ' . hint_at_cursor.check)
  call add(details, 'Severity: ' . hint_at_cursor.severity)
  call add(details, 'Message: ' . hint_at_cursor.message)
  
  " Use configured display mode
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result({'success': 1, 'data': details}, display_mode)
endfunction
