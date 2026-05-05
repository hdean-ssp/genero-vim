" Genero-Tools Plugin - Code Structure Detector
" Detects structural code issues

" Detect code structure issues - optimized for current scope only
function! genero_tools#hints#structure#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  " Only check nesting depth for visible area or current function
  if a:config.nesting_depth
    let hints = hints + s:check_nesting_depth_current_scope(a:bufnr, a:config)
  endif
  
  return hints
endfunction

" Check nesting depth only in current function scope
function! s:check_nesting_depth_current_scope(bufnr, config) abort
  let hints = []
  let max_depth = a:config.max_nesting_depth
  
  " Get current cursor position
  let current_line = line('.')
  let lines = getbufline(a:bufnr, 1, '$')
  
  " Find the current function boundaries
  let func_start = 0
  let func_end = 0
  
  " Search backwards for FUNCTION/MAIN/REPORT
  for line_num in range(current_line, 1, -1)
    let line = lines[line_num - 1]
    if line =~? '^\s*\(FUNCTION\|MAIN\|REPORT\)\>'
      let func_start = line_num
      break
    endif
  endfor
  
  " If we found a function start, search forward for its END
  if func_start > 0
    for line_num in range(func_start + 1, len(lines))
      let line = lines[line_num - 1]
      if line =~? '^\s*END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
        let func_end = line_num
        break
      endif
    endfor
  endif
  
  " If we couldn't find function boundaries, only check visible screen area
  if func_start == 0 || func_end == 0
    let func_start = max([1, line('w0')])  " First visible line
    let func_end = min([len(lines), line('w$')])  " Last visible line
  endif
  
  " Limit scope to reasonable size (max 500 lines to avoid performance issues)
  if func_end - func_start > 500
    " Just check visible screen area instead
    let func_start = max([1, line('w0')])
    let func_end = min([len(lines), line('w$')])
  endif
  
  " Now check nesting depth only within this scope
  let current_depth = 0
  
  for line_num in range(func_start, func_end)
    let line = lines[line_num - 1]
    
    " Skip comments and empty lines
    if line =~ '^\s*#' || line =~ '^\s*$'
      continue
    endif
    
    " Skip the FUNCTION/MAIN/REPORT line itself
    if line =~? '^\s*\(FUNCTION\|MAIN\|REPORT\)\>'
      continue
    endif
    
    " Skip END FUNCTION/MAIN/REPORT line
    if line =~? '^\s*END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      continue
    endif
    
    let line_upper = toupper(line)
    
    " Count block closers first (to handle same-line open/close correctly)
    let closes = 0
    if line_upper =~# '\<END\s\+IF\>'
      let closes += 1
    endif
    if line_upper =~# '\<END\s\+WHILE\>'
      let closes += 1
    endif
    if line_upper =~# '\<END\s\+FOR\>'
      let closes += 1
    endif
    if line_upper =~# '\<END\s\+FOREACH\>'
      let closes += 1
    endif
    if line_upper =~# '\<END\s\+CASE\>'
      let closes += 1
    endif
    if line_upper =~# '\<END\s\+TRY\>'
      let closes += 1
    endif
    
    " Update depth (closes first)
    let current_depth -= closes
    
    " Ensure depth doesn't go negative
    if current_depth < 0
      let current_depth = 0
    endif
    
    " Count block openers (excluding FUNCTION/MAIN/REPORT which are top-level)
    let opens = 0
    if line_upper =~# '\<IF\>.*\<THEN\>'
      let opens += 1
    endif
    if line_upper =~# '\<WHILE\>'
      let opens += 1
    endif
    if line_upper =~# '\<FOR\>'
      let opens += 1
    endif
    if line_upper =~# '\<FOREACH\>'
      let opens += 1
    endif
    if line_upper =~# '\<CASE\>'
      let opens += 1
    endif
    if line_upper =~# '\<TRY\>'
      let opens += 1
    endif
    
    let current_depth += opens
    
    " Report if depth exceeds maximum (only for lines in visible area)
    if current_depth > max_depth && line_num >= line('w0') && line_num <= line('w$')
      call add(hints, genero_tools#hints#create_hint(
        \ line_num,
        \ 1,
        \ 'Nesting depth exceeds maximum (' . current_depth . ' > ' . max_depth . ')',
        \ 'structure',
        \ 'nesting_depth',
        \ 'warning'
        \ ))
    endif
  endfor
  
  return hints
endfunction
