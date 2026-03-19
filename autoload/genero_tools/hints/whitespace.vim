" Genero-Tools Plugin - Whitespace & Formatting Detector
" Detects whitespace and formatting issues in code

" Detect all whitespace issues in buffer
function! genero_tools#hints#whitespace#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  
  " Check each line for whitespace issues
  for line_num in range(1, len(lines))
    let line = lines[line_num - 1]
    
    " Check trailing whitespace
    if a:config.trailing_whitespace && line =~ '\s$'
      call add(hints, genero_tools#hints#create_hint(
        \ line_num,
        \ len(line),
        \ 'Trailing whitespace detected',
        \ 'whitespace',
        \ 'trailing_whitespace',
        \ 'style'
        \ ))
    endif
    
    " Check mixed indentation
    if a:config.mixed_indentation && line =~ '^\t* \+\t\| \+\t'
      call add(hints, genero_tools#hints#create_hint(
        \ line_num,
        \ 1,
        \ 'Mixed tabs and spaces in indentation',
        \ 'whitespace',
        \ 'mixed_indentation',
        \ 'warning'
        \ ))
    endif
    
    " Check line length
    if a:config.line_length
      let max_length = a:config.max_line_length
      if len(line) > max_length
        call add(hints, genero_tools#hints#create_hint(
          \ line_num,
          \ max_length + 1,
          \ 'Line exceeds maximum length (' . len(line) . ' > ' . max_length . ')',
          \ 'whitespace',
          \ 'line_length',
          \ 'style'
          \ ))
      endif
    endif
  endfor
  
  " Check for multiple consecutive blank lines
  if a:config.multiple_blank_lines
    let max_blank = a:config.max_blank_lines
    let blank_count = 0
    let blank_start = 0
    
    for line_num in range(1, len(lines))
      let line = lines[line_num - 1]
      
      if line =~ '^\s*$'
        if blank_count == 0
          let blank_start = line_num
        endif
        let blank_count += 1
      else
        if blank_count > max_blank
          call add(hints, genero_tools#hints#create_hint(
            \ blank_start + max_blank,
            \ 1,
            \ 'Too many consecutive blank lines (' . blank_count . ' > ' . max_blank . ')',
            \ 'whitespace',
            \ 'multiple_blank_lines',
            \ 'style'
            \ ))
        endif
        let blank_count = 0
      endif
    endfor
  endif
  
  return hints
endfunction
