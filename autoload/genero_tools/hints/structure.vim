" Genero-Tools Plugin - Code Structure Detector
" Detects structural code issues

" Detect code structure issues
function! genero_tools#hints#structure#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  
  " Check nesting depth
  if a:config.nesting_depth
    let max_depth = a:config.max_nesting_depth
    let current_depth = 0
    
    for line_num in range(1, len(lines))
      let line = lines[line_num - 1]
      
      " Skip comments and empty lines
      if line =~ '^\s*#' || line =~ '^\s*$'
        continue
      endif
      
      " Convert to uppercase for case-insensitive matching
      let line_upper = toupper(line)
      
      " Count opening blocks (case-insensitive)
      let opens = 0
      for keyword in ['IF', 'WHILE', 'FOR', 'FUNCTION', 'CLASS', 'TRY', 'RECORD', 'TYPE', 'DEFINE']
        " Count occurrences of keyword at word boundaries
        let opens += len(split(line_upper, '\<' . keyword . '\>', 1)) - 1
      endfor
      
      " Count closing blocks (case-insensitive)
      let closes = 0
      for keyword in ['ENDIF', 'ENDWHILE', 'ENDFOR', 'ENDFUNCTION', 'ENDCLASS', 'ENDTRY', 'ENDRECORD', 'ENDTYPE', 'ENDDEFINE']
        " Count occurrences of keyword at word boundaries
        let closes += len(split(line_upper, '\<' . keyword . '\>', 1)) - 1
      endfor
      
      " Update depth (closes first to handle same-line open/close)
      let current_depth -= closes
      let current_depth += opens
      
      " Ensure depth doesn't go negative
      if current_depth < 0
        let current_depth = 0
      endif
      
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
