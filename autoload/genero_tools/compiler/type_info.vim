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

" Floating window for schema column lists
let s:schema_float_win = -1
let s:schema_float_buf = -1

" Initialize the type info system
function! genero_tools#compiler#type_info#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_type_info')

  if !hlexists('GeneroTypeInfo')
    highlight GeneroTypeInfo guifg=#6a7a8a guibg=#1e2030 gui=italic ctermfg=DarkGray ctermbg=234
  endif

  if !hlexists('GeneroTypeInfoVar')
    highlight GeneroTypeInfoVar guifg=#7a8a6a guibg=#1e2030 gui=italic ctermfg=DarkGreen ctermbg=234
  endif

  if !hlexists('GeneroTypeInfoSchema')
    highlight GeneroTypeInfoSchema guifg=#6a8a9a guibg=#1e2030 gui=italic ctermfg=DarkCyan ctermbg=234
  endif

  " Autocommands are handled by the unified cursor dispatcher (cursor.vim)
endfunction

" Called by cursor dispatcher when the word under cursor changes
function! genero_tools#compiler#type_info#on_word_changed(word, bufnr, current_line) abort
  call genero_tools#compiler#type_info#clear_extmarks()
endfunction

" Called by cursor dispatcher after debounce — do the actual lookup
function! genero_tools#compiler#type_info#do_lookup(word, bufnr, line) abort
  if !genero_tools#config#get('compiler_type_info')
    return
  endif

  if empty(a:word) || len(a:word) < 3
    return
  endif

  if s:cursor_in_comment(a:line)
    return
  endif

  " If cursor is anywhere on a FUNCTION definition line, show the function's
  " own signature regardless of which word the cursor is on
  let line_text = getline(a:line)
  let trimmed = substitute(line_text, '^\s*', '', '')
  if toupper(trimmed) =~# '^FUNCTION\>'
    let func_name = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
    if !empty(func_name)
      call s:lookup_function(func_name, a:bufnr, a:line)
      return
    endif
  endif

  let upper = toupper(a:word)
  if s:is_keyword(upper)
    return
  endif

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
    let s:last_word = a:word
    let s:last_bufnr = a:bufnr
    let s:last_line = a:line
    return
  endif

  " Check if word is a record field access (e.g., l_rec.field_name — cursor on field_name)
  let record_field = s:resolve_record_field(a:word, a:bufnr, a:line)
  if !empty(record_field)
    call genero_tools#compiler#type_info#clear_extmarks()
    let display = s:translate_type(record_field.type)
    if !empty(record_field.record)
      let display .= '  (' . record_field.record . '.' . a:word . ')'
    endif
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ◇ ' . display . ' ', 'GeneroTypeInfoVar']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry
    let s:last_word = a:word
    let s:last_bufnr = a:bufnr
    let s:last_line = a:line
    return
  endif

  " No DEFINE found — try schema lookup (table.column or table name)
  " This also handles hovering on table/column names inside DEFINE type references
  let schema_info = s:lookup_schema(a:word, a:line)
  if !empty(schema_info)
    call s:show_schema_info(a:bufnr, a:line, schema_info)
  endif

  let s:last_word = a:word
  let s:last_bufnr = a:bufnr
  let s:last_line = a:line
endfunction

" Resolve a record field access: given 'field_name' on a line like 'l_rec.field_name',
" find the DEFINE for l_rec, check if it's a RECORD with fields or RECORD LIKE table.*,
" and return the field type
" Returns: {'type': 'STRING', 'record': 'l_rec'} or {}
function! s:resolve_record_field(word, bufnr, line) abort
  let line_text = getline(a:line)

  " Look for pattern: something.word (word is the field name)
  let pattern = '\c\(\w\+\)\.' . escape(a:word, '\') . '\>'
  let match = matchlist(line_text, pattern)
  if empty(match)
    return {}
  endif

  let record_var = match[1]

  " Look up the record variable's DEFINE
  let define_info = s:find_define(record_var, a:bufnr, a:line)
  if empty(define_info)
    return {}
  endif

  " Case 1: Inline RECORD with parsed fields
  let fields = get(define_info, 'fields', [])
  if !empty(fields)
    for field in fields
      if field.name ==? a:word
        let clean_type = substitute(field.type, '\c\s*END\s\+RECORD.*$', '', '')
        return {'type': clean_type, 'record': record_var}
      endif
    endfor
    return {}
  endif

  " Case 2: RECORD LIKE table.* — resolve via schema lookup
  let type_str = get(define_info, 'type', '')
  if type_str =~? '\<RECORD\s\+LIKE\s\+'
    let like_ref = substitute(type_str, '\c.*LIKE\s\+', '', '')
    let like_ref = substitute(like_ref, '\s*$', '', '')
    " like_ref is now 'table_name.*' — replace * with the field name
    let table_name = substitute(like_ref, '\.\*\s*$', '', '')
    if !empty(table_name)
      let schema = s:resolve_like_cached(table_name . '.' . a:word)
      if !empty(schema) && !has_key(schema, 'error')
        let resolved_type = s:translate_type(get(schema, 'type', a:word))
        return {'type': resolved_type, 'record': record_var}
      endif
    endif
  endif

  return {}
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
" Also handles RECORD...END RECORD blocks
function! s:collect_define_statement(lines, start_idx) abort
  let total = len(a:lines)
  let result = ''
  let i = a:start_idx
  let in_record = 0

  while i < total
    let line = substitute(a:lines[i], '^\s*', '', '')
    let line = substitute(line, '\s*$', '', '')

    " Skip comment lines
    if line =~# '^[#\-\-]' || line =~# '^{' || line =~# '^\s*$'
      let i += 1
      continue
    endif

    let upper_line = toupper(line)

    " Track inline RECORD...END RECORD blocks (not RECORD LIKE which is a schema ref)
    " Check END RECORD first to avoid double-counting (END RECORD contains RECORD)
    if upper_line =~# '^END\s\+RECORD'
      let in_record -= 1
    elseif upper_line =~# '\<RECORD\>' && upper_line !~# '\<RECORD\s\+LIKE\>'
      let in_record += 1
    endif

    let result .= ' ' . line

    " If we just closed the last RECORD block, we're done
    if upper_line =~# '^END\s\+RECORD' && in_record <= 0
      break
    endif

    " If inside a RECORD block, keep collecting
    if in_record > 0
      let i += 1
      continue
    endif

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
" Handles: DEFINE var RECORD ... END RECORD (inline records)
" Handles: DEFINE var DYNAMIC ARRAY OF RECORD ... END RECORD
" Strips inline comments (#SR-1234, -- comment, etc.)
" Returns: {'type': 'INTEGER', 'line': N} or {}
" For RECORD types, also returns 'fields': [{'name': 'f1', 'type': 'STRING'}, ...]
function! s:parse_variable_from_define(define_text, var_pattern, line_nr) abort
  let text = a:define_text

  " Remove the DEFINE keyword
  let text = substitute(text, '\c^\s*DEFINE\s\+', '', '')

  " Check if this DEFINE contains an inline RECORD block for our variable
  " Pattern: varname [DYNAMIC ARRAY OF] RECORD ... END RECORD
  " Excludes RECORD LIKE (which is a schema reference, not inline fields)
  let record_pattern = '\c\<\(' . a:var_pattern . '\)\>\s\+\(DYNAMIC\s\+ARRAY\s\+OF\s\+\)\?\(ARRAY\s*\[[^\]]*\]\s\+OF\s\+\)\?\s*RECORD\>'
  if text =~? record_pattern && text !~? '\c\<RECORD\s\+LIKE\>'
    " Extract the variable name
    let var_name = matchstr(text, '\c\<\(' . a:var_pattern . '\)\>\ze\s\+\(DYNAMIC\|ARRAY\|RECORD\)')
    if empty(var_name)
      let var_name = matchstr(text, '\c\<\(' . a:var_pattern . '\)\>')
    endif

    " Extract the prefix (DYNAMIC ARRAY OF, etc.)
    let prefix = matchstr(text, '\c\<' . var_name . '\>\s\+\zs\(DYNAMIC\s\+ARRAY\s\+OF\s\+\|ARRAY\s*\[[^\]]*\]\s\+OF\s\+\)\ze\s*RECORD')
    let prefix = substitute(prefix, '\s\+', ' ', 'g')

    " Extract fields between RECORD and END RECORD
    " Take everything after RECORD, then strip END RECORD and anything after it
    let fields_text = matchstr(text, '\c\<RECORD\>\s*\zs.*')
    let fields_text = substitute(fields_text, '\c\s*END\s\+RECORD.*$', '', '')
    let fields = s:parse_record_fields(fields_text)

    let type_str = prefix . 'RECORD'
    let result = {'type': type_str, 'line': a:line_nr}
    if !empty(fields)
      let result.fields = fields
    endif
    return result
  endif

  " Standard non-RECORD parsing: split by comma
  let chunks = split(text, ',')

  for chunk in chunks
    let chunk = substitute(chunk, '^\s*\|\s*$', '', 'g')

    " Strip inline comments before matching variable name
    let code_part = substitute(chunk, '\s*[#].*$', '', '')
    let code_part = substitute(code_part, '\s*--.*$', '', '')
    let code_part = substitute(code_part, '\s*{[^}]*}.*$', '', '')

    " Check if the FIRST WORD of the chunk (the variable name) matches our pattern
    let var_name = matchstr(code_part, '^\s*\zs\w\+')
    if var_name =~? a:var_pattern
      " Extract the type — everything after the variable name
      let type_match = matchstr(chunk, '\c\<' . '\S\+' . '\>\s\+\zs.*')
      if !empty(type_match)
        " Strip inline comments
        let type_str = substitute(type_match, '\s*[#].*$', '', '')
        let type_str = substitute(type_str, '\s*--.*$', '', '')
        let type_str = substitute(type_str, '\s*{[^}]*}.*$', '', '')
        let type_str = substitute(type_str, '^\s*\|\s*$', '', 'g')
        let type_str = substitute(type_str, '\s\+', ' ', 'g')
        let type_str = substitute(type_str, ',\s*$', '', '')
        if !empty(type_str)
          return {'type': type_str, 'line': a:line_nr}
        endif
      endif
    endif
  endfor

  return {}
endfunction

" Parse RECORD field definitions from the text between RECORD and END RECORD
" Fields are separated by commas: field1 TYPE, field2 TYPE (last field has no comma)
" Returns: [{'name': 'field1', 'type': 'STRING'}, ...]
function! s:parse_record_fields(fields_text) abort
  let fields = []
  if empty(a:fields_text)
    return fields
  endif

  " Strip END RECORD and anything after it before splitting
  let clean = substitute(a:fields_text, '\c\s*END\s\+RECORD.*$', '', '')

  " Split by comma
  let chunks = split(clean, ',')

  for chunk in chunks
    let chunk = substitute(chunk, '^\s*\|\s*$', '', 'g')
    " Strip comments
    let chunk = substitute(chunk, '\s*[#].*$', '', '')
    let chunk = substitute(chunk, '\s*--.*$', '', '')

    if empty(chunk)
      continue
    endif

    " Extract field_name and type
    let field_name = matchstr(chunk, '^\s*\zs\w\+')
    let field_type = matchstr(chunk, '^\s*\w\+\s\+\zs.*')
    let field_type = substitute(field_type, '^\s*\|\s*$', '', 'g')
    let field_type = substitute(field_type, '\s\+', ' ', 'g')
    " Strip any END RECORD that leaked into the type
    let field_type = substitute(field_type, '\c\s*END\s\+RECORD.*$', '', '')

    " Skip if field_name looks like a keyword (safety check)
    if field_name =~? '^\(END\|RECORD\|DEFINE\|FUNCTION\|LET\|CALL\|IF\|FOR\|WHILE\|RETURN\)$'
      continue
    endif

    if !empty(field_name) && !empty(field_type)
      call add(fields, {'name': field_name, 'type': field_type})
    endif
  endfor

  return fields
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
  let file = get(func, 'file', get(func, 'file_path', get(func, 'path', '')))
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
        \ 'virt_text': [['  ƒ ' . full_text . ' ', 'GeneroTypeInfo']],
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

" Translate schema types to Genero types
function! s:translate_type(type_str) abort
  let t = a:type_str
  " SERIAL is represented as INTEGER in Genero
  let t = substitute(t, '\cSERIAL', 'INTEGER', 'g')
  return t
endfunction

" Show variable type from DEFINE scan
" If the type is a LIKE reference, resolve it to get the actual column type
" For LIKE table.*, shows the full column list as virtual lines
function! s:show_variable_type(bufnr, line, word, define_info) abort
  let type_str = a:define_info.type
  let def_line = a:define_info.line
  let scope = get(a:define_info, 'scope', 'local')
  let fields = get(a:define_info, 'fields', [])

  " If type is a LIKE reference, resolve it
  let schema = {}
  if type_str =~? '^LIKE\s\+'
    let like_ref = substitute(type_str, '\c^LIKE\s\+', '', '')
    let like_ref = substitute(like_ref, '\s*$', '', '')
    if !empty(like_ref)
      let schema = s:resolve_like_cached(like_ref)
    endif
  endif

  " Also handle RECORD LIKE table.*
  if type_str =~? 'RECORD\s\+LIKE\s\+'
    let like_ref = substitute(type_str, '\c.*LIKE\s\+', '', '')
    let like_ref = substitute(like_ref, '\s*$', '', '')
    if !empty(like_ref)
      let schema = s:resolve_like_cached(like_ref)
    endif
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  let kind = get(schema, 'kind', '')

  " LIKE table.* or RECORD LIKE table.* → show column list
  if kind ==# 'record' || (has_key(schema, 'columns') && !empty(get(schema, 'columns', [])))
    let table = get(schema, 'table', '')
    let columns = get(schema, 'columns', [])
    let col_count = get(schema, 'column_count', len(columns))

    let summary = 'RECORD (' . col_count . ' cols)'
    if !empty(table)
      let summary .= '  ' . table . '.*'
    endif
    if scope == 'module'
      let summary .= '  (module)'
    elseif scope == 'param'
      let summary .= '  (param)'
    endif

    " Show summary inline
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ◇ ' . summary . ' ', 'GeneroTypeInfoVar']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry

    " Show columns in a floating window next to cursor
    if !empty(columns)
      let float_title = table . '.*  (' . col_count . ' columns)'
      call s:show_schema_float(columns, float_title)
    endif
    return
  endif

  " Inline RECORD (parsed from DEFINE ... RECORD ... END RECORD) → show fields popup
  if !empty(fields)
    let col_count = len(fields)
    let summary = type_str . ' (' . col_count . ' fields)'
    if scope == 'module'
      let summary .= '  (module)'
    elseif scope == 'param'
      let summary .= '  (param)'
    endif

    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ◇ ' . summary . ' ', 'GeneroTypeInfoVar']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry

    " Show fields in floating window (same format as schema columns)
    let float_columns = []
    for field in fields
      let clean_type = substitute(field.type, '\c\s*END\s\+RECORD.*$', '', '')
      call add(float_columns, {'name': field.name, 'type': clean_type})
    endfor
    call s:show_schema_float(float_columns, a:word . '  (' . col_count . ' fields)')
    return
  endif

  " LIKE table.column → single column, show resolved type
  if kind ==# 'column' || has_key(schema, 'type')
    let actual_type = s:translate_type(get(schema, 'type', ''))
    let display = actual_type . '  (' . type_str . ')'
    if scope == 'module'
      let display .= '  (module)'
    elseif scope == 'param'
      let display .= '  (param)'
    endif

    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ◇ ' . display . ' ', 'GeneroTypeInfoVar']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry
    return
  endif

  " No schema resolution — show raw type
  let display = s:translate_type(type_str)
  if scope == 'module'
    let display .= '  (module)'
  elseif scope == 'param'
    let display .= '  (param)'
  endif

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_text': [['  ◇ ' . display . ' ', 'GeneroTypeInfoVar']],
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
" SCHEMA LOOKUP (table/column via query.sh resolve-like, get-table, get-column)
" ============================================================================

" Try to resolve the word as a table or column reference
" Checks the current line for table.column patterns (LIKE, FROM, INTO, etc.)
" If the word is the TABLE part of table.column, shows the full table definition
function! s:lookup_schema(word, line_nr) abort
  let line_text = getline(a:line_nr)

  " Strategy 1: Check if word is part of a table.column reference on this line
  let dotref = s:extract_dot_reference(a:word, line_text)
  if !empty(dotref)
    " Determine if the hovered word is the table part or the column part
    let parts = split(dotref, '\.')
    if len(parts) == 2 && parts[0] ==? a:word
      " Hovering on the TABLE name — show full table definition
      let table_data = s:lookup_table_cached(a:word)
      if !empty(table_data)
        return table_data
      endif
    endif
    " Hovering on the column name or fallback — resolve the specific reference
    return s:resolve_like_cached(dotref)
  endif

  " Strategy 2: Check if the line has LIKE ... before or around the word
  let like_ref = s:extract_like_reference(a:word, line_text)
  if !empty(like_ref)
    let parts = split(like_ref, '\.')
    if len(parts) == 2 && parts[0] ==? a:word
      let table_data = s:lookup_table_cached(a:word)
      if !empty(table_data)
        return table_data
      endif
    endif
    return s:resolve_like_cached(like_ref)
  endif

  " Strategy 3: Try as a standalone table name
  return s:lookup_table_cached(a:word)
endfunction

" Extract a table.column reference containing the word from the line
function! s:extract_dot_reference(word, line_text) abort
  " Look for word.something or something.word patterns
  let pattern = '\c\(\w\+\)\.\(\w\+\|\*\)'
  let start = 0
  while 1
    let match = matchstrpos(a:line_text, pattern, start)
    if empty(match[0])
      break
    endif
    " Check if our word is part of this match
    if match[0] =~? '\<' . escape(a:word, '\') . '\>'
      return match[0]
    endif
    let start = match[2]
  endwhile
  return ''
endfunction

" Extract a LIKE reference from the line
function! s:extract_like_reference(word, line_text) abort
  " Match: LIKE table.column or LIKE table.*
  let pattern = '\c\<LIKE\s\+\(\w\+\.\(\w\+\|\*\)\)'
  let match = matchlist(a:line_text, pattern)
  if !empty(match) && match[1] =~? '\<' . escape(a:word, '\') . '\>'
    return match[1]
  endif
  return ''
endfunction

" Call resolve-like with caching
function! s:resolve_like_cached(reference) abort
  let cache_key = 'resolve-like:' . a:reference
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached) && has_key(cached, 'success') && cached.success && !empty(get(cached, 'data', {}))
    let d = cached.data
    " Skip cached error responses
    if has_key(d, 'error')
      return {}
    endif
    return d
  endif

  let tool_path = genero_tools#config#get('genero_tools_path')
  let escaped = genero_tools#command#escape_arg(a:reference)
  let cmd = tool_path . ' resolve-like ' . escaped

  try
    silent let output = system(cmd)
    if v:shell_error != 0
      return {}
    endif
    let data = json_decode(output)
    " Check for error response: {"error": "not_found", "message": "..."}
    if has_key(data, 'error')
      return {}
    endif
    call genero_tools#cache#set(cache_key, {'success': 1, 'data': data, 'timestamp': localtime()})
    return data
  catch
    return {}
  endtry
endfunction

" Call get-table with caching
function! s:lookup_table_cached(table_name) abort
  let cache_key = 'get-table:' . a:table_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached) && has_key(cached, 'success') && cached.success && !empty(get(cached, 'data', {}))
    let d = cached.data
    if has_key(d, 'error')
      return {}
    endif
    return d
  endif

  let tool_path = genero_tools#config#get('genero_tools_path')
  let escaped = genero_tools#command#escape_arg(a:table_name)
  let cmd = tool_path . ' get-table ' . escaped

  try
    silent let output = system(cmd)
    if v:shell_error != 0
      return {}
    endif
    let data = json_decode(output)
    if empty(data) || has_key(data, 'error')
      return {}
    endif
    call genero_tools#cache#set(cache_key, {'success': 1, 'data': data, 'timestamp': localtime()})
    return data
  catch
    return {}
  endtry
endfunction

" Display schema info as virtual text
" Handles all response shapes from resolve-like, get-table, get-column
function! s:show_schema_info(bufnr, line, data) abort
  if empty(a:data) || has_key(a:data, 'error')
    return
  endif

  let kind = get(a:data, 'kind', '')
  let display = ''

  if kind ==# 'column'
    " resolve-like "table.column" → single column
    " {"table": "account", "column": "acc_code", "type": "VARCHAR(8)", "kind": "column"}
    let col_type = s:translate_type(get(a:data, 'type', ''))
    let table = get(a:data, 'table', '')
    let col_name = get(a:data, 'column', '')
    if !empty(col_type)
      let display = col_type
      if !empty(table) && !empty(col_name)
        let display .= '  ' . table . '.' . col_name
      endif
    endif

  elseif kind ==# 'record'
    " resolve-like "table.*" → full record
    " {"table": "account", "column_count": 10, "columns": [...], "kind": "record"}
    let table = get(a:data, 'table', '')
    let col_count = get(a:data, 'column_count', 0)
    let columns = get(a:data, 'columns', [])
    if col_count == 0 && !empty(columns)
      let col_count = len(columns)
    endif
    let display = 'RECORD (' . col_count . ' cols)'
    if !empty(table)
      let display .= '  ' . table . '.*'
    endif

  else
    " No kind field — from get-table or get-column responses
    " Distinguish by checking for 'columns' key (table) vs 'type' key (column)
    if has_key(a:data, 'columns')
      " get-table response: {"table": "acc_type", "column_count": 2, "columns": [...]}
      let table = get(a:data, 'table', '')
      let col_count = get(a:data, 'column_count', len(get(a:data, 'columns', [])))
      let display = 'TABLE (' . col_count . ' cols)'
      if !empty(table)
        let display .= '  ' . table
      endif
    elseif has_key(a:data, 'type')
      " get-column response: {"table": "account", "column": "acc_balance", "type": "DECIMAL(3842)"}
      let col_type = s:translate_type(get(a:data, 'type', ''))
      let table = get(a:data, 'table', '')
      let col_name = get(a:data, 'column', '')
      if !empty(col_type)
        let display = col_type
        if !empty(table) && !empty(col_name)
          let display .= '  ' . table . '.' . col_name
        endif
      endif
    endif
  endif

  if empty(display)
    return
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  " Calculate available space
  let line_text = getline(a:line)
  let line_len = strdisplaywidth(line_text)
  let win_width = winwidth(0)
  let available = win_width - line_len - 4

  " For records/tables with columns, always show floating window
  let columns = get(a:data, 'columns', [])
  if !empty(columns)
    " Show summary inline
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ⊞ ' . display . ' ', 'GeneroTypeInfoSchema']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry

    " Show full column list in floating window
    let table = get(a:data, 'table', '')
    let float_title = table . '  (' . len(columns) . ' columns)'
    call s:show_schema_float(columns, float_title)
  else
    " Single column or no columns — just inline display
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
        \ 'virt_text': [['  ⊞ ' . display . ' ', 'GeneroTypeInfoSchema']],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 30
        \ })
    catch
    endtry
  endif
endfunction

" ============================================================================
" UTILITY FUNCTIONS
" ============================================================================

" Check if the cursor position is inside a comment or string literal
function! s:cursor_in_comment(line_nr) abort
  let line_text = getline(a:line_nr)
  let cursor_col = col('.')

  " Check if entire line is a comment
  let trimmed = substitute(line_text, '^\s*', '', '')
  if trimmed =~# '^[#]' || trimmed =~# '^--' || trimmed =~# '^{'
    return 1
  endif

  let before_cursor = strpart(line_text, 0, cursor_col - 1)

  " Check if cursor is inside a string literal
  " Count unescaped double quotes before cursor — odd means inside a string
  let quote_count = 0
  let i = 0
  while i < len(before_cursor)
    if before_cursor[i] == '"'
      " Check it's not escaped (preceded by backslash)
      if i == 0 || before_cursor[i - 1] != '\'
        let quote_count += 1
      endif
    endif
    let i += 1
  endwhile
  if quote_count % 2 == 1
    return 1
  endif

  " Also check single-quoted strings (Genero uses both)
  let sq_count = 0
  let i = 0
  while i < len(before_cursor)
    if before_cursor[i] == "'"
      if i == 0 || before_cursor[i - 1] != '\'
        let sq_count += 1
      endif
    endif
    let i += 1
  endwhile
  if sq_count % 2 == 1
    return 1
  endif

  " Check if cursor is after a # comment start (not inside a string)
  if before_cursor =~# '#'
    let hash_pos = strridx(before_cursor, '#')
    let quotes_before = len(substitute(strpart(before_cursor, 0, hash_pos), '[^"]', '', 'g'))
    if quotes_before % 2 == 0
      return 1
    endif
  endif

  " Check if cursor is after a -- comment start (not inside a string)
  if before_cursor =~# '--'
    let dash_pos = strridx(before_cursor, '--')
    let quotes_before = len(substitute(strpart(before_cursor, 0, dash_pos), '[^"]', '', 'g'))
    if quotes_before % 2 == 0
      return 1
    endif
  endif

  return 0
endfunction

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

" Show a small floating window next to the cursor with column list
function! s:show_schema_float(columns, title) abort
  call s:close_schema_float()

  " Find the longest column name for alignment
  let max_name_len = 0
  for c in a:columns
    let name_len = len(get(c, 'name', '?'))
    if name_len > max_name_len
      let max_name_len = name_len
    endif
  endfor

  " Calculate max width from column rows first (title will be centered to this)
  let col_lines = []
  for c in a:columns
    let col_name = get(c, 'name', '?')
    let col_type = s:translate_type(get(c, 'type', '?'))
    let padding = repeat(' ', max_name_len - len(col_name))
    call add(col_lines, col_name . padding . '  ' . col_type)
  endfor

  let max_width = 0
  for l in col_lines
    let max_width = max([max_width, strdisplaywidth(l)])
  endfor
  let max_width = max([max_width, strdisplaywidth(a:title)])

  " Center the title
  let title_len = strdisplaywidth(a:title)
  let left_pad = (max_width - title_len) / 2
  let centered_title = repeat(' ', left_pad) . a:title

  let lines = [centered_title, repeat('─', max_width)] + col_lines

  let width = min([max_width, &columns - 10])
  let height = min([len(lines), &lines - 6])

  try
    let result = luaeval('(function(lines, width, height) ' .
      \ 'local buf = vim.api.nvim_create_buf(false, true) ' .
      \ 'vim.bo[buf].buftype = "nofile" ' .
      \ 'vim.bo[buf].bufhidden = "wipe" ' .
      \ 'vim.bo[buf].swapfile = false ' .
      \ 'vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) ' .
      \ 'vim.bo[buf].modifiable = false ' .
      \ 'local win = vim.api.nvim_open_win(buf, false, { ' .
      \ '  relative = "cursor", row = 1, col = 0, ' .
      \ '  width = width, height = height, ' .
      \ '  style = "minimal", border = "rounded", ' .
      \ '  focusable = false ' .
      \ '}) ' .
      \ 'return {buf = buf, win = win} ' .
      \ 'end)(_A[1], _A[2], _A[3])', [lines, width, height])
    let s:schema_float_buf = result.buf
    let s:schema_float_win = result.win
  catch
    call s:close_schema_float()
  endtry
endfunction

" Close the schema floating window if open
function! s:close_schema_float() abort
  if s:schema_float_win != -1
    try
      if nvim_win_is_valid(s:schema_float_win)
        call nvim_win_close(s:schema_float_win, v:true)
      endif
    catch
    endtry
    let s:schema_float_win = -1
  endif
  if s:schema_float_buf != -1
    try
      if nvim_buf_is_valid(s:schema_float_buf)
        call nvim_buf_delete(s:schema_float_buf, {'force': v:true})
      endif
    catch
    endtry
    let s:schema_float_buf = -1
  endif
endfunction

" Clear extmarks only
function! genero_tools#compiler#type_info#clear_extmarks() abort
  if !has('nvim') || s:ns_id == -1
    return
  endif
  call s:close_schema_float()
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
