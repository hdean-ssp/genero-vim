" Genero-Tools Plugin - Hint Auto-Fix Module
" Provides automatic fixes for common hint issues

" Apply auto-fix for hint at cursor
function! genero_tools#hints#autofix#apply() abort
  if !genero_tools#config#get('auto_fix_enabled')
    call genero_tools#error#warn('hints', 'Auto-fix is disabled')
    return
  endif
  
  let bufnr = bufnr('%')
  let current_line = line('.')
  
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
  
  " Apply fix based on hint category
  let fixed = 0
  if hint_at_cursor.category == 'whitespace'
    let fixed = genero_tools#hints#autofix#fix_whitespace(bufnr, hint_at_cursor)
  elseif hint_at_cursor.category == 'keyword'
    let fixed = genero_tools#hints#autofix#fix_keyword(bufnr, hint_at_cursor)
  elseif hint_at_cursor.category == 'structure'
    let fixed = genero_tools#hints#autofix#fix_structure(bufnr, hint_at_cursor)
  else
    call genero_tools#error#warn('hints', 'No auto-fix available for this hint')
    return
  endif
  
  if fixed
    call genero_tools#error#echo('hints', 'Auto-fix applied successfully')
    " Invalidate cache and re-analyze
    call genero_tools#hints#cache#invalidate(bufnr)
    let new_hints = genero_tools#hints#analyze(bufnr)
    call genero_tools#hints#display#show(bufnr, new_hints)
  else
    call genero_tools#error#warn('hints', 'Auto-fix failed')
  endif
endfunction

" Fix whitespace issues
function! genero_tools#hints#autofix#fix_whitespace(bufnr, hint) abort
  let line_num = a:hint.line
  let line_text = getline(line_num)
  
  if a:hint.check == 'trailing_whitespace'
    " Remove trailing whitespace
    let fixed_line = substitute(line_text, '\s\+$', '', '')
    call setline(line_num, fixed_line)
    return 1
  elseif a:hint.check == 'mixed_indentation'
    " Convert leading spaces to tabs (assuming 4 spaces = 1 tab)
    " Only convert spaces at the beginning of the line (indentation)
    let indent = matchstr(line_text, '^\s*')
    let rest = strpart(line_text, len(indent))
    
    " Convert groups of 4 spaces to tabs, then any remaining spaces
    let fixed_indent = substitute(indent, '    ', '\t', 'g')
    " Also convert any remaining space+tab or tab+space combinations to just tabs
    let fixed_indent = substitute(fixed_indent, ' \+\t\|\t \+', '\t', 'g')
    
    let fixed_line = fixed_indent . rest
    call setline(line_num, fixed_line)
    return 1
  elseif a:hint.check == 'multiple_blank_lines'
    " Remove extra blank lines
    if line_num > 1 && getline(line_num - 1) == '' && line_text == ''
      call deletebufline(a:bufnr, line_num)
      return 1
    endif
  endif
  
  return 0
endfunction

" Fix keyword issues
function! genero_tools#hints#autofix#fix_keyword(bufnr, hint) abort
  let line_num = a:hint.line
  let line_text = getline(line_num)
  
  if a:hint.check == 'lowercase_keywords'
    " Convert lowercase keywords to uppercase
    let keywords = ['function', 'end', 'if', 'then', 'else', 'for', 'while', 'do', 'return', 'define', 'record', 'type', 'constant', 'variable', 'let', 'call', 'display', 'input', 'open', 'close', 'fetch', 'insert', 'update', 'delete', 'select', 'from', 'where', 'order', 'by', 'group', 'having', 'join', 'on', 'and', 'or', 'not', 'in', 'like', 'between', 'is', 'null', 'true', 'false']
    
    let fixed_line = line_text
    for keyword in keywords
      let fixed_line = substitute(fixed_line, '\<' . keyword . '\>', toupper(keyword), 'g')
    endfor
    
    call setline(line_num, fixed_line)
    return 1
  endif
  
  return 0
endfunction

" Fix structure issues
function! genero_tools#hints#autofix#fix_structure(bufnr, hint) abort
  " Structure fixes are typically more complex and may require user input
  " For now, just return false
  return 0
endfunction
