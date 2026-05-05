" Genero-Tools Plugin - Code Structure Detector
" Detects structural code issues

" Detect code structure issues
function! genero_tools#hints#structure#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  
  " Check nesting depth - only within current function scope
  if a:config.nesting_depth
    let max_depth = a:config.max_nesting_depth
    let current_line = line('.')
    
    " Find the current function boundaries
    let func_start = 0
    let func_end = len(lines)
    
    " Search backwards for FUNCTION
    for line_num in range(current_line, 1, -1)
      let line = lines[line_num - 1]
      if line =~? '^\s*FUNCTION\>'
        let func_start = line_num
        break
      endif
    endfor
    
    " If we found a function start, search forward for END FUNCTION
    if func_start > 0
      for line_num in range(func_start + 1, len(lines))
        let line = lines[line_num - 1]
        if line =~? '^\s*END\s\+FUNCTION\>'
          let func_end = line_num
          break
        endif
      endfor
    else
      " Not in a function, check the whole file (for MAIN or module-level code)
      let func_start = 1
    endif
    
    " Now check nesting depth only within this function
    let current_depth = 0
    let base_depth = 0  " Track if we're inside the function declaration itself
    
    for line_num in range(func_start, func_end)
      let line = lines[line_num - 1]
      
      " Skip comments and empty lines
      if line =~ '^\s*#' || line =~ '^\s*$'
        continue
      endif
      
      " Skip the FUNCTION line itself
      if line =~? '^\s*FUNCTION\>'
        continue
      endif
      
      " Skip END FUNCTION line
      if line =~? '^\s*END\s\+FUNCTION\>'
        continue
      endif
      
      let line_upper = toupper(line)
      
      " Count block openers (excluding FUNCTION/MAIN/REPORT which are top-level)
      let opens = 0
      if line_upper =~# '\<IF\>'
        let opens += len(split(line_upper, '\<IF\>', 1)) - 1
      endif
      if line_upper =~# '\<WHILE\>'
        let opens += len(split(line_upper, '\<WHILE\>', 1)) - 1
      endif
      if line_upper =~# '\<FOR\>'
        let opens += len(split(line_upper, '\<FOR\>', 1)) - 1
      endif
      if line_upper =~# '\<FOREACH\>'
        let opens += len(split(line_upper, '\<FOREACH\>', 1)) - 1
      endif
      if line_upper =~# '\<CASE\>'
        let opens += len(split(line_upper, '\<CASE\>', 1)) - 1
      endif
      if line_upper =~# '\<TRY\>'
        let opens += len(split(line_upper, '\<TRY\>', 1)) - 1
      endif
      
      " Count block closers (excluding END FUNCTION/MAIN/REPORT)
      let closes = 0
      if line_upper =~# '\<END\s\+IF\>'
        let closes += len(split(line_upper, '\<END\s\+IF\>', 1)) - 1
      endif
      if line_upper =~# '\<END\s\+WHILE\>'
        let closes += len(split(line_upper, '\<END\s\+WHILE\>', 1)) - 1
      endif
      if line_upper =~# '\<END\s\+FOR\>'
        let closes += len(split(line_upper, '\<END\s\+FOR\>', 1)) - 1
      endif
      if line_upper =~# '\<END\s\+FOREACH\>'
        let closes += len(split(line_upper, '\<END\s\+FOREACH\>', 1)) - 1
      endif
      if line_upper =~# '\<END\s\+CASE\>'
        let closes += len(split(line_upper, '\<END\s\+CASE\>', 1)) - 1
      endif
      if line_upper =~# '\<END\s\+TRY\>'
        let closes += len(split(line_upper, '\<END\s\+TRY\>', 1)) - 1
      endif
      
      " Update depth (closes first to handle same-line open/close)
      let current_depth -= closes
      
      " Ensure depth doesn't go negative
      if current_depth < 0
        let current_depth = 0
      endif
      
      let current_depth += opens
      
      " Report if depth exceeds maximum
      if current_depth > max_depth
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
  endif
  
  return hints
endfunction
