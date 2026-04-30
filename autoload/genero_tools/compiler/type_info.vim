" Genero-Tools Plugin - Type Info Virtual Text
" Shows function signatures and variable types as virtual text
" Functions: looked up via query.sh (with cache)
" Variables: scanned from DEFINE statements in the current buffer
" Neovim only — silently does nothing in Vim

" Namespace for type info extmarks
let s:ns_id = -1

" Track last word to avoid redundant lookups
let s:last_word = ''
let s:last_bufnr = -1
let s:last_line = -1

" Debounce timer
let s:timer_id = -1

" Initialize the type info system
function! genero_tools#compiler#type_info#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_type_info')

  if !hlexists('GeneroTypeInfo')
    highlight GeneroTypeInfo guifg=#6a7a8a guibg=NONE gui=italic ctermfg=DarkGray ctermbg=NONE
  endif

  if !hlexists('GeneroTypeInfoVar')
    highlight GeneroTypeInfoVar guifg=#7a8a6a guibg=NONE gui=italic ctermfg=DarkGreen ctermbg=NONE
  endif

  augroup GeneroTypeInfo
    autocmd!
    autocmd CursorMoved *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#on_cursor_moved()
    autocmd BufLeave *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#clear()
    autocmd InsertEnter *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#clear()
  augroup END
endfunction

" Called on CursorMoved — debounce and schedule a lookup
function! genero_tools#compiler#type_info#on_cursor_moved() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#config#get('compiler_type_info')
    return
  endif

  let word = expand('<cword>')
  let bufnr = bufnr('%')
  let current_line = line('.')

  if word ==# s:last_word && bufnr == s:last_bufnr && current_line == s:last_line
    return
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  if s:timer_id != -1
    call timer_stop(s:timer_id)
    let s:timer_id = -1
  endif

  if empty(word) || len(word) < 3
    let s:last_word = ''
    let s:last_bufnr = -1
    let s:last_line = -1
    return
  endif

  let upper = toupper(word)
  if s:is_keyword(upper)
    let s:last_word = word
    let s:last_bufnr = bufnr
    let s:last_line = current_line
    return
  endif

  let s:timer_id = timer_start(400, function('s:debounced_lookup', [word, bufnr, current_line]))
endfunction

" Debounced callback — determine if word is a function call or variable, then look up
function! s:debounced_lookup(word, bufnr, line, timer_id) abort
  let s:timer_id = -1

  " Verify cursor hasn't moved
  if expand('<cword>') !=# a:word || bufnr('%') != a:bufnr || line('.') != a:line
    return
  endif

  " Determine if this is a function call: word followed by ( with optional whitespace
  let is_function_call = s:word_is_function_call(a:word, a:line)

  if is_function_call
    call s:lookup_function(a:word, a:bufnr, a:line)
  else
    call s:lookup_variable(a:word, a:bufnr, a:line)
  endif
endfunction

" Check if the word under cursor is followed by parentheses (function call)
function! s:word_is_function_call(word, line_nr) abort
  let line_text = getline(a:line_nr)
  let col = col('.')

  " Find the end of the current word from cursor position
  " Look for the word in the line and check what follows it
  let word_end = matchend(line_text, '\V' . escape(a:word, '\'), col - len(a:word) - 1)
  if word_end == -1
    " Fallback: search from beginning of line
    let word_end = matchend(line_text, '\V' . escape(a:word, '\'))
  endif

  if word_end == -1
    return 0
  endif

  " Check what follows the word (skip whitespace)
  let after = strpart(line_text, word_end)
  return after =~# '^\s*('
endfunction

" ============================================================================
" FUNCTION LOOKUP (via query.sh)
" ============================================================================

function! s:lookup_function(word, bufnr, line) abort
  " Check cache first
  let cache_key = 'find-function:' . a:word
  let cached = genero_tools#cache#get(cache_key)

  if !empty(cached)
    if has_key(cached, 'success') && cached.success && !empty(get(cached, 'data', {}))
      call s:show_function_signature(a:bufnr, a:line, a:word, cached.data)
      let s:last_word = a:word
      let s:last_bufnr = a:bufnr
      let s:last_line = a:line
    endif
    return
  endif

  " Silent shell lookup
  let result = s:silent_lookup(a:word)

  if result.success && !empty(result.data)
    call genero_tools#cache#set(cache_key, result)

    if expand('<cword>') ==# a:word && bufnr('%') == a:bufnr && line('.') == a:line
      call s:show_function_signature(a:bufnr, a:line, a:word, result.data)
      let s:last_word = a:word
      let s:last_bufnr = a:bufnr
      let s:last_line = a:line
    endif
  else
    " Not a known function — try variable lookup as fallback
    call s:lookup_variable(a:word, a:bufnr, a:line)
  endif
endfunction

" ============================================================================
" VARIABLE LOOKUP (buffer-local DEFINE scan)
" ============================================================================

function! s:lookup_variable(word, bufnr, line) abort
  let define_info = s:find_define(a:word, a:bufnr, a:line)

  if !empty(define_info)
    call s:show_variable_type(a:bufnr, a:line, a:word, define_info)
  endif

  let s:last_word = a:word
  let s:last_bufnr = a:bufnr
  let s:last_line = a:line
endfunction

" Search for a DEFINE statement for the given variable name
" Strategy:
"   1. If cursor is on a FUNCTION definition line, search downward (params are defined below)
"   2. Otherwise search upward from cursor line, stop at FUNCTION boundary
"   3. Fall back to module-level defines at top of file
" Returns: {'type': 'INTEGER', 'line': 42, 'scope': 'local'} or {}
function! s:find_define(word, bufnr, cursor_line) abort
  let lines = getbufline(a:bufnr, 1, '$')
  if empty(lines)
    return {}
  endif

  " Build a case-insensitive pattern for the variable name
  let var_pattern = '\c\<' . escape(a:word, '\') . '\>'

  " Check if cursor is on a FUNCTION definition line
  let current_line_text = get(lines, a:cursor_line - 1, '')
  let upper_current = toupper(substitute(current_line_text, '^\s*', '', ''))
  if upper_current =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
    " Cursor is on the function signature — search downward for DEFINE
    let found = s:search_define_downward(lines, var_pattern, a:cursor_line)
    if !empty(found)
      let found.scope = 'param'
      return found
    endif
  endif

  " Phase 1: Search upward from cursor line for a local DEFINE
  " Stop at the enclosing FUNCTION line (don't cross function boundaries)
  let found = s:search_define_upward(lines, var_pattern, a:cursor_line)
  if !empty(found)
    let found.scope = 'local'
    return found
  endif

  " Phase 2: Search module-level defines at the top of the file
  " These are DEFINE statements before the first FUNCTION keyword
  let found = s:search_module_defines(lines, var_pattern)
  if !empty(found)
    let found.scope = 'module'
    return found
  endif

  return {}
endfunction

" Search upward from cursor_line for a DEFINE containing the variable
" Stops at the enclosing FUNCTION line
function! s:search_define_upward(lines, var_pattern, cursor_line) abort
  let in_define_block = 0
  let define_start_line = 0
  let define_text = ''

  " Walk upward from cursor line
  let i = a:cursor_line - 1  " 0-indexed
  while i >= 0
    let line = a:lines[i]
    let trimmed = substitute(line, '^\s*', '', '')
    let upper_trimmed = toupper(trimmed)

    " Stop at FUNCTION boundary (we've left the current function scope)
    if upper_trimmed =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    " Check if this line is part of a DEFINE statement
    " DEFINE can span multiple lines with comma continuation
    if upper_trimmed =~# '^DEFINE\>'
      " Found a DEFINE line — collect the full statement
      let define_text = s:collect_define_statement(a:lines, i)
      let result = s:parse_variable_from_define(define_text, a:var_pattern, i + 1)
      if !empty(result)
        return result
      endif
    endif

    let i -= 1
  endwhile

  return {}
endfunction

" Search downward from a FUNCTION line for DEFINE statements
" Used when cursor is on the function signature (params are defined below)
" Stops at the next FUNCTION or END FUNCTION
function! s:search_define_downward(lines, var_pattern, func_line) abort
  let i = a:func_line  " Start from the line after the FUNCTION line (0-indexed = func_line)
  let total = len(a:lines)

  while i < total
    let line = a:lines[i]
    let trimmed = substitute(line, '^\s*', '', '')
    let upper_trimmed = toupper(trimmed)

    " Stop at END FUNCTION or next FUNCTION definition
    if upper_trimmed =~# '^\(END\s\+FUNCTION\|END\s\+MAIN\|END\s\+REPORT\)\>'
      break
    endif
    " Stop if we hit another FUNCTION (shouldn't happen, but safety)
    if i > a:func_line && upper_trimmed =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    " Stop once we pass the DEFINE section (first non-DEFINE, non-blank, non-comment line)
    if !empty(trimmed) && upper_trimmed !~# '^\(DEFINE\>\|--\|#\|{\)' && upper_trimmed !~# '^\s*$'
      " Check if this looks like a continuation of a DEFINE (type name, comma, etc.)
      " If not, we've passed the DEFINE block
      if upper_trimmed !~# '^\w' || upper_trimmed =~# '^\(LET\|CALL\|IF\|FOR\|WHILE\|RETURN\|DISPLAY\|INPUT\|CASE\|SELECT\|OPEN\|CLOSE\|WHENEVER\|INITIALIZE\|PREPARE\|DECLARE\)\>'
        break
      endif
    endif

    if upper_trimmed =~# '^DEFINE\>'
      let define_text = s:collect_define_statement(a:lines, i)
      let result = s:parse_variable_from_define(define_text, a:var_pattern, i + 1)
      if !empty(result)
        return result
      endif
    endif

    let i += 1
  endwhile

  return {}
endfunction

" Search module-level defines (before the first FUNCTION keyword)
function! s:search_module_defines(lines, var_pattern) abort
  let i = 0
  let total = len(a:lines)

  while i < total
    let line = a:lines[i]
    let trimmed = substitute(line, '^\s*', '', '')
    let upper_trimmed = toupper(trimmed)

    " Stop when we hit the first FUNCTION/MAIN/REPORT
    if upper_trimmed =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    if upper_trimmed =~# '^DEFINE\>'
      let define_text = s:collect_define_statement(a:lines, i)
      let result = s:parse_variable_from_define(define_text, a:var_pattern, i + 1)
      if !empty(result)
        return result
      endif
    endif

    let i += 1
  endwhile

  return {}
endfunction

" Collect a full DEFINE statement that may span multiple lines
" Lines ending with comma indicate continuation
function! s:collect_define_statement(lines, start_idx) abort
  let total = len(a:lines)
  let result = ''
  let i = a:start_idx

  while i < total
    let line = substitute(a:lines[i], '^\s*', '', '')
    let line = substitute(line, '\s*$', '', '')

    " Skip comment lines
    if line =~# '^[#\-\-]' || line =~# '^{' || line =~# '^\s*$'
      let i += 1
      continue
    endif

    let result .= ' ' . line

    " If line ends with comma, the DEFINE continues
    if line =~# ',\s*$'
      let i += 1
      continue
    endif

    " If next line starts with a type or variable name (not a keyword that starts
    " a new statement), it might be a continuation
    if i + 1 < total
      let next = substitute(a:lines[i + 1], '^\s*', '', '')
      let upper_next = toupper(next)
      " If next line doesn't start a new statement, it's a continuation
      if !empty(next) && upper_next !~# '^\(DEFINE\|FUNCTION\|MAIN\|REPORT\|END\|IF\|FOR\|WHILE\|CALL\|LET\|RETURN\|DISPLAY\|INPUT\|CASE\|SELECT\|INSERT\|UPDATE\|DELETE\|OPEN\|CLOSE\|FETCH\|FOREACH\|PREPARE\|EXECUTE\|FREE\|DECLARE\|WHENEVER\|MENU\|DIALOG\|CONSTRUCT\|OUTPUT\|PRINT\|GLOBALS\|IMPORT\|DATABASE\|CONNECT\|CONSTANT\|TYPE\)\>'
        let i += 1
        continue
      endif
    endif

    break
  endwhile

  return result
endfunction

" Parse a DEFINE statement text to find a specific variable and its type
" Handles: DEFINE var1 TYPE, var2 TYPE, var3 LIKE table.column
" Returns: {'type': 'INTEGER', 'line': N} or {}
function! s:parse_variable_from_define(define_text, var_pattern, line_nr) abort
  let text = a:define_text

  " Remove the DEFINE keyword
  let text = substitute(text, '\c^\s*DEFINE\s\+', '', '')

  " Split by comma to get individual variable declarations
  " But be careful: commas inside RECORD...END RECORD shouldn't split
  " Simple approach: split by comma and try to match each chunk
  let chunks = split(text, ',')

  for chunk in chunks
    let chunk = substitute(chunk, '^\s*\|\s*$', '', 'g')

    " Check if this chunk contains our variable
    if chunk =~? a:var_pattern
      " Extract the type — everything after the variable name
      " Pattern: variable_name TYPE_DEFINITION
      let type_match = matchstr(chunk, '\c\<' . '\S\+' . '\>\s\+\zs.*')
      if !empty(type_match)
        " Clean up the type string
        let type_str = substitute(type_match, '^\s*\|\s*$', '', 'g')
        " Remove trailing comma if present
        let type_str = substitute(type_str, ',\s*$', '', '')
        if !empty(type_str)
          return {'type': type_str, 'line': a:line_nr}
        endif
      endif
    endif
  endfor

  return {}
endfunction

" ============================================================================
" DISPLAY FUNCTIONS
" ============================================================================

" Show function signature (existing logic, renamed)
function! s:show_function_signature(bufnr, line, word, data) abort
  let func = {}
  if type(a:data) == type([]) && !empty(a:data)
    for item in a:data
      if type(item) == type({}) && get(item, 'name', '') ==? a:word
        let func = item
        break
      endif
    endfor
    if empty(func) && type(a:data[0]) == type({})
      let func = a:data[0]
    endif
  elseif type(a:data) == type({})
    let func = a:data
  else
    return
  endif

  if empty(func)
    return
  endif

  " Build parameter string
  let params = get(func, 'parameters', [])
  let param_str = ''
  if !empty(params)
    let param_strs = []
    for p in params
      if type(p) == type({})
        call add(param_strs, get(p, 'name', '?') . ' ' . get(p, 'type', '?'))
      endif
    endfor
    let param_str = '(' . join(param_strs, ', ') . ')'
  else
    let param_str = '()'
  endif

  " Return types
  let ret_str = ''
  let returns = get(func, 'returns', [])
  if !empty(returns)
    let ret_strs = []
    for r in returns
      if type(r) == type({})
        call add(ret_strs, get(r, 'type', get(r, 'name', '?')))
      endif
    endfor
    let ret_str = '→ ' . join(ret_strs, ', ')
  endif

  " File location
  let file_str = ''
  let file = get(func, 'file', '')
  if !empty(file)
    let file_str = fnamemodify(file, ':t')
  endif

  " Calculate available space
  let line_text = getline(a:line)
  let line_len = strdisplaywidth(line_text)
  let win_width = winwidth(0)
  let available = win_width - line_len - 4

  let full_text = param_str
  if !empty(ret_str)
    let full_text .= ' ' . ret_str
  endif
  if !empty(file_str)
    let full_text .= '  ' . file_str
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  " Fits on one line
  if len(full_text) <= available && available >= 20
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ƒ ' . full_text, 'GeneroTypeInfo']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry
    return
  endif

  " Wrap into virtual lines below
  let virt_lines = []
  let indent = matchstr(line_text, '^\s*')
  let pad = indent . repeat(' ', 4)

  call add(virt_lines, [[pad . 'ƒ ' . param_str, 'GeneroTypeInfo']])

  if !empty(ret_str) || !empty(file_str)
    let second = pad
    if !empty(ret_str)
      let second .= ret_str
    endif
    if !empty(file_str)
      let second .= '  ' . file_str
    endif
    call add(virt_lines, [[second, 'GeneroTypeInfo']])
  endif

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_lines': virt_lines,
      \ 'virt_lines_above': v:false,
      \ 'priority': 30
      \ })
  catch
  endtry
endfunction

" Show variable type from DEFINE scan
function! s:show_variable_type(bufnr, line, word, define_info) abort
  let type_str = a:define_info.type
  let def_line = a:define_info.line
  let scope = get(a:define_info, 'scope', 'local')

  let display = type_str
  if scope == 'module'
    let display .= '  (module)'
  elseif scope == 'param'
    let display .= '  (param)'
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_text': [['  ◇ ' . display, 'GeneroTypeInfoVar']],
      \ 'virt_text_pos': 'eol',
      \ 'priority': 30
      \ })
  catch
  endtry
endfunction

" ============================================================================
" MANUAL COMMAND
" ============================================================================

function! genero_tools#compiler#type_info#manual() abort
  if !has('nvim')
    echom '[type_info] Neovim required for virtual text'
    return
  endif

  let word = expand('<cword>')
  if empty(word)
    echom '[type_info] No word under cursor'
    return
  endif

  let s:last_word = ''
  let s:last_bufnr = -1
  let s:last_line = -1

  let is_func = s:word_is_function_call(word, line('.'))
  echom '[type_info] Word: ' . word . ' | Is function call: ' . is_func

  if is_func
    echom '[type_info] Looking up function via query.sh...'
    let result = genero_tools#command#execute_shell('find-function', [word])
    if result.success && !empty(result.data)
      echom '[type_info] Found function signature'
      let cache_key = 'find-function:' . word
      call genero_tools#cache#set(cache_key, result)
      call s:show_function_signature(bufnr('%'), line('.'), word, result.data)
    else
      echom '[type_info] Function not found, trying variable lookup...'
      let define_info = s:find_define(word, bufnr('%'), line('.'))
      if !empty(define_info)
        echom '[type_info] Found DEFINE: ' . define_info.type . ' (line ' . define_info.line . ', ' . define_info.scope . ')'
        call s:show_variable_type(bufnr('%'), line('.'), word, define_info)
      else
        echom '[type_info] No DEFINE found for: ' . word
      endif
    endif
  else
    echom '[type_info] Looking up variable DEFINE...'
    let define_info = s:find_define(word, bufnr('%'), line('.'))
    if !empty(define_info)
      echom '[type_info] Found DEFINE: ' . define_info.type . ' (line ' . define_info.line . ', ' . define_info.scope . ')'
      call s:show_variable_type(bufnr('%'), line('.'), word, define_info)
    else
      echom '[type_info] No DEFINE found, trying function lookup...'
      let result = genero_tools#command#execute_shell('find-function', [word])
      if result.success && !empty(result.data)
        echom '[type_info] Found function signature'
        call s:show_function_signature(bufnr('%'), line('.'), word, result.data)
      else
        echom '[type_info] Nothing found for: ' . word
      endif
    endif
  endif

  let s:last_word = word
  let s:last_bufnr = bufnr('%')
  let s:last_line = line('.')
endfunction

" ============================================================================
" UTILITY FUNCTIONS
" ============================================================================

function! s:is_keyword(upper_word) abort
  let keywords = {
    \ 'DEFINE': 1, 'FUNCTION': 1, 'END': 1, 'IF': 1, 'THEN': 1, 'ELSE': 1,
    \ 'FOR': 1, 'WHILE': 1, 'RETURN': 1, 'CALL': 1, 'LET': 1, 'DISPLAY': 1,
    \ 'INPUT': 1, 'CASE': 1, 'WHEN': 1, 'MAIN': 1, 'REPORT': 1, 'SELECT': 1,
    \ 'INSERT': 1, 'UPDATE': 1, 'DELETE': 1, 'FROM': 1, 'WHERE': 1, 'INTO': 1,
    \ 'VALUES': 1, 'SET': 1, 'AND': 1, 'OR': 1, 'NOT': 1, 'NULL': 1,
    \ 'TRUE': 1, 'FALSE': 1, 'INTEGER': 1, 'STRING': 1, 'SMALLINT': 1,
    \ 'FLOAT': 1, 'DECIMAL': 1, 'DATE': 1, 'CHAR': 1, 'VARCHAR': 1,
    \ 'BOOLEAN': 1, 'RECORD': 1, 'ARRAY': 1, 'LIKE': 1, 'TYPE': 1,
    \ 'CONSTANT': 1, 'GLOBALS': 1, 'MODULE': 1, 'IMPORT': 1, 'OPEN': 1,
    \ 'CLOSE': 1, 'FETCH': 1, 'FOREACH': 1, 'PREPARE': 1, 'EXECUTE': 1,
    \ 'FREE': 1, 'DECLARE': 1, 'CURSOR': 1, 'DATABASE': 1, 'CONNECT': 1,
    \ 'DISCONNECT': 1, 'BEGIN': 1, 'WORK': 1, 'COMMIT': 1, 'ROLLBACK': 1,
    \ 'OUTPUT': 1, 'TO': 1, 'MENU': 1, 'COMMAND': 1, 'DIALOG': 1,
    \ 'CONSTRUCT': 1, 'ON': 1, 'BEFORE': 1, 'AFTER': 1, 'CONTINUE': 1,
    \ 'EXIT': 1, 'SLEEP': 1, 'ERROR': 1, 'STATUS': 1, 'SQLCA': 1,
    \ 'WHENEVER': 1, 'GOTO': 1, 'INITIALIZE': 1, 'VALIDATE': 1,
    \ 'LOCATE': 1, 'ALLOCATE': 1, 'DEFER': 1, 'OPTIONS': 1, 'PROMPT': 1,
    \ 'MESSAGE': 1, 'ATTRIBUTE': 1, 'ATTRIBUTES': 1, 'WINDOW': 1,
    \ 'SCREEN': 1, 'FORM': 1, 'CLEAR': 1, 'SCROLL': 1, 'NEXT': 1,
    \ 'PREVIOUS': 1, 'ACCEPT': 1, 'CANCEL': 1, 'IDLE': 1, 'ACTION': 1,
    \ 'STEP': 1, 'SKIP': 1, 'PRINT': 1, 'NEED': 1, 'HEADER': 1,
    \ 'TRAILER': 1, 'PAGE': 1, 'FIRST': 1, 'LAST': 1, 'CURRENT': 1,
    \ 'OUTER': 1, 'GROUP': 1, 'ORDER': 1, 'BY': 1, 'HAVING': 1,
    \ 'UNION': 1, 'BETWEEN': 1, 'EXISTS': 1, 'IN': 1, 'ANY': 1,
    \ 'ALL': 1, 'SOME': 1, 'ASC': 1, 'DESC': 1, 'DISTINCT': 1,
    \ 'UNIQUE': 1, 'COUNT': 1, 'SUM': 1, 'AVG': 1, 'MIN': 1, 'MAX': 1,
    \ 'CLIPPED': 1, 'USING': 1, 'SPACES': 1, 'COLUMN': 1, 'TODAY': 1,
    \ 'RETURNING': 1, 'RETURNS': 1, 'PRIVATE': 1, 'PUBLIC': 1,
    \ 'STATIC': 1, 'DYNAMIC': 1
    \ }
  return has_key(keywords, a:upper_word)
endfunction

" Silent lookup — calls query.sh directly without any echo output
function! s:silent_lookup(word) abort
  let tool_path = genero_tools#config#get('genero_tools_path')
  let escaped_word = genero_tools#command#escape_arg(a:word)
  let cmd = tool_path . ' find-function ' . escaped_word

  let result = {
    \ 'success': 0,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }

  try
    silent let output = system(cmd)
    if v:shell_error != 0
      let result.error = 'exit code ' . v:shell_error
      return result
    endif

    let data = json_decode(output)
    let result.success = 1
    let result.data = data
  catch
    let result.error = v:exception
  endtry

  return result
endfunction

" Clear extmarks only
function! genero_tools#compiler#type_info#clear_extmarks() abort
  if !has('nvim') || s:ns_id == -1
    return
  endif
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction

" Full clear — extmarks, tracking, and pending timer
function! genero_tools#compiler#type_info#clear() abort
  if s:timer_id != -1
    call timer_stop(s:timer_id)
    let s:timer_id = -1
  endif
  call genero_tools#compiler#type_info#clear_extmarks()
  let s:last_word = ''
  let s:last_bufnr = -1
  let s:last_line = -1
endfunction
