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
      
      " Count opening blocks
      let opens = len(split(line, 'IF\|WHILE\|FOR\|FUNCTION\|CLASS\|TRY', 1)) - 1
      let closes = len(split(line, 'ENDIF\|ENDWHILE\|ENDFOR\|ENDFUNCTION\|ENDCLASS\|ENDTRY', 1)) - 1
      
      let current_depth += opens - closes
      
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
