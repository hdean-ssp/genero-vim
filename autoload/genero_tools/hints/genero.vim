" Genero-Tools Plugin - Genero-Specific Detector
" Detects Genero-specific code quality issues

" Detect Genero-specific issues
function! genero_tools#hints#genero#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  
  " List of deprecated Genero functions
  let deprecated_functions = []
  
  " Check for deprecated functions
  if a:config.deprecated_functions && !empty(deprecated_functions)
    for line_num in range(1, len(lines))
      let line = lines[line_num - 1]
      
      for func in deprecated_functions
        let pattern = '\<' . func . '\s*('
        if line =~ pattern
          let col = match(line, pattern) + 1
          call add(hints, genero_tools#hints#create_hint(
            \ line_num,
            \ col,
            \ 'Deprecated function: ' . func,
            \ 'genero',
            \ 'deprecated_functions',
            \ 'warning'
            \ ))
        endif
      endfor
    endfor
  endif
  
  return hints
endfunction
