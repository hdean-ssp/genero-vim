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
      
      " Count opening blocks using matchstr with global flag
      let opens = 0
      let temp_line = line_upper
      while match(temp_line, '\<\(IF\|WHILE\|FOR\|FUNCTION\|CLASS\|TRY\|RECORD\|TYPE\|DEFINE\)\>') >= 0
        let opens += 1
        let match_pos = match(temp_line, '\<\(IF\|WHILE\|FOR\|FUNCTION\|CLASS\|TRY\|RECORD\|TYPE\|DEFINE\)\>')
        let temp_line = temp_line[match_pos + 1:]
      endwhile
      
      " Count closing blocks using matchstr with global flag
      let closes = 0
      let temp_line = line_upper
      while match(temp_line, '\<\(ENDIF\|ENDWHILE\|ENDFOR\|ENDFUNCTION\|ENDCLASS\|ENDTRY\|ENDRECORD\|ENDTYPE\|ENDDEFINE\)\>') >= 0
        let closes += 1
        let match_pos = match(temp_line, '\<\(ENDIF\|ENDWHILE\|ENDFOR\|ENDFUNCTION\|ENDCLASS\|ENDTRY\|ENDRECORD\|ENDTYPE\|ENDDEFINE\)\>')
        let temp_line = temp_line[match_pos + 1:]
      endwhile
      
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
