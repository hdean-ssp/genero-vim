" Genero-Tools Plugin - Keyword & Naming Detector
" Detects keyword and naming convention violations

" Detect keyword and naming issues
function! genero_tools#hints#keyword#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  
  " List of Genero keywords that should be uppercase
  let keywords = [
    \ 'if', 'else', 'elseif', 'endif',
    \ 'while', 'endwhile',
    \ 'for', 'endfor',
    \ 'function', 'endfunction',
    \ 'define', 'enddefine',
    \ 'record', 'endrecord',
    \ 'type', 'endtype',
    \ 'class', 'endclass',
    \ 'try', 'catch', 'endtry',
    \ 'return', 'exit',
    \ 'call', 'let', 'display', 'input',
    \ 'open', 'close', 'fetch', 'insert', 'update', 'delete',
    \ 'begin', 'commit', 'rollback',
    \ 'declare', 'constant', 'variable'
    \ ]
  
  " List of built-in functions that should be uppercase
  let functions = [
    \ 'length', 'substr', 'index', 'instr',
    \ 'upcase', 'downcase', 'trim', 'ltrim', 'rtrim',
    \ 'today', 'current', 'time',
    \ 'int', 'float', 'string', 'boolean',
    \ 'abs', 'round', 'trunc', 'sqrt', 'power',
    \ 'sin', 'cos', 'tan', 'log', 'exp'
    \ ]
  
  " Check each line
  for line_num in range(1, len(lines))
    let line = lines[line_num - 1]
    
    " Skip comments
    if line =~ '^\s*#'
      continue
    endif
    
    " Check for lowercase keywords (case-sensitive match)
    if a:config.lowercase_keywords
      for keyword in keywords
        " Match whole word only, case-sensitive (lowercase only)
        let pattern = '\C\<' . keyword . '\>'
        if line =~ pattern
          let col = match(line, pattern) + 1
          call add(hints, genero_tools#hints#create_hint(
            \ line_num,
            \ col,
            \ 'Keyword should be uppercase: ' . keyword,
            \ 'keyword',
            \ 'lowercase_keywords',
            \ 'style'
            \ ))
        endif
      endfor
    endif
    
    " Check for lowercase built-in functions (case-sensitive match)
    if a:config.lowercase_functions
      for func in functions
        " Match function call pattern: func( (lowercase only)
        let pattern = '\C\<' . func . '\s*('
        if line =~ pattern
          let col = match(line, pattern) + 1
          call add(hints, genero_tools#hints#create_hint(
            \ line_num,
            \ col,
            \ 'Built-in function should be uppercase: ' . func,
            \ 'keyword',
            \ 'lowercase_functions',
            \ 'style'
            \ ))
        endif
      endfor
    endif
  endfor
  
  return hints
endfunction
