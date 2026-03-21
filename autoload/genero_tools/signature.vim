" Genero-Tools Plugin - Function Signature Formatting
" Parses and formats function signatures for concise display

" Display a single signature using configured display mode
function! genero_tools#signature#show(func_obj) abort
  if type(a:func_obj) != type({})
    return
  endif
  
  " Get effective display mode for signatures (respects signatures_display_mode override)
  let display_mode = genero_tools#display#get_mode('signatures')
  
  " Format complete info
  let info = genero_tools#signature#format_complete_info(a:func_obj)
  
  " Display using configured mode
  let result = {
    \ 'success': 1,
    \ 'data': split(info, "\n"),
    \ 'error': ''
    \ }
  
  call genero_tools#display#result(result, display_mode)
endfunction

" Display multiple signatures using configured display mode
function! genero_tools#signature#show_list(func_objects) abort
  if type(a:func_objects) != type([])
    return
  endif
  
  if empty(a:func_objects)
    call genero_tools#display#notify('No signatures found', 0)
    return
  endif
  
  " Get effective display mode for signatures (respects signatures_display_mode override)
  let display_mode = genero_tools#display#get_mode('signatures')
  
  " Format all signatures
  let lines = []
  call add(lines, '=== Function Signatures ===')
  call add(lines, '')
  
  for func_obj in a:func_objects
    if type(func_obj) == type({})
      let info = genero_tools#signature#format_complete_info(func_obj)
      call extend(lines, split(info, "\n"))
      call add(lines, '')
      call add(lines, repeat('-', 60))
      call add(lines, '')
    endif
  endfor
  
  " Display using configured mode
  let result = {
    \ 'success': 1,
    \ 'data': lines,
    \ 'error': ''
    \ }
  
  call genero_tools#display#result(result, display_mode)
endfunction

" Format function signature for display
" Abbreviates types and handles long signatures intelligently
function! genero_tools#signature#format(func_obj) abort
  if type(a:func_obj) != type({})
    return ''
  endif
  
  let name = get(a:func_obj, 'name', '?')
  let params = get(a:func_obj, 'parameters', [])
  let returns = get(a:func_obj, 'returns', [])
  
  " Format parameters
  let param_strs = []
  for param in params
    if type(param) == type({})
      let pname = get(param, 'name', '?')
      let ptype = get(param, 'type', '')
      let abbr_type = genero_tools#signature#abbreviate_type(ptype)
      call add(param_strs, pname . ':' . abbr_type)
    endif
  endfor
  
  " Format return types
  let return_strs = []
  for ret in returns
    if type(ret) == type({})
      let rtype = get(ret, 'type', '')
      let abbr_type = genero_tools#signature#abbreviate_type(rtype)
      call add(return_strs, abbr_type)
    endif
  endfor
  
  " Build signature string
  let sig = name . '('
  
  if len(param_strs) > 0
    let sig .= join(param_strs, ', ')
  endif
  
  let sig .= ')'
  
  if len(return_strs) > 0
    let sig .= ' -> ' . join(return_strs, ', ')
  endif
  
  return sig
endfunction

" Abbreviate type names for concise display
function! genero_tools#signature#abbreviate_type(type_str) abort
  if empty(a:type_str)
    return ''
  endif
  
  let abbr_map = {
    \ 'STRING': 'STR',
    \ 'INTEGER': 'INT',
    \ 'DECIMAL': 'DEC',
    \ 'BOOLEAN': 'BOOL',
    \ 'DATETIME': 'DT',
    \ 'INTERVAL': 'INTV',
    \ 'SMALLINT': 'SINT',
    \ 'BIGINT': 'BINT',
    \ 'FLOAT': 'FLT',
    \ 'DOUBLE': 'DBL',
    \ 'MONEY': 'MON',
    \ 'CHAR': 'CHR',
    \ 'VARCHAR': 'VAR',
    \ 'BYTE': 'BYT',
    \ 'TEXT': 'TXT',
    \ 'BLOB': 'BLB',
    \ 'CLOB': 'CLB',
    \ 'ARRAY': 'ARR',
    \ 'RECORD': 'REC',
    \ 'DYNAMIC ARRAY': 'DARR',
    \ }
  
  let upper_type = toupper(a:type_str)
  
  if has_key(abbr_map, upper_type)
    return abbr_map[upper_type]
  endif
  
  " Return first 3 chars if no abbreviation found
  return toupper(strpart(a:type_str, 0, 3))
endfunction

" Truncate long signature for display
" Returns truncated signature with ellipsis if needed
function! genero_tools#signature#truncate(sig_str, max_len) abort
  if len(a:sig_str) <= a:max_len
    return a:sig_str
  endif
  
  " Try to truncate at parameter boundary
  let paren_pos = stridx(a:sig_str, '(')
  if paren_pos > 0 && paren_pos < a:max_len - 5
    let name_part = strpart(a:sig_str, 0, paren_pos)
    let remaining = a:max_len - paren_pos - 4
    if remaining > 5
      return name_part . '(...)'
    endif
  endif
  
  " Fallback: simple truncation
  return strpart(a:sig_str, 0, a:max_len - 3) . '...'
endfunction

" Format signature for autocomplete menu
" Optimized for display in completion menu (typically 80 chars wide)
function! genero_tools#signature#format_for_menu(func_obj) abort
  let full_sig = genero_tools#signature#format(a:func_obj)
  
  " Truncate to fit in typical completion menu width (60 chars)
  return genero_tools#signature#truncate(full_sig, 60)
endfunction

" Format signature for info/preview
" More detailed, can be longer
function! genero_tools#signature#format_for_info(func_obj) abort
  let full_sig = genero_tools#signature#format(a:func_obj)
  
  " Allow up to 100 chars for info display
  return genero_tools#signature#truncate(full_sig, 100)
endfunction

" Get parameter count
function! genero_tools#signature#param_count(func_obj) abort
  if type(a:func_obj) != type({})
    return 0
  endif
  
  let params = get(a:func_obj, 'parameters', [])
  return len(params)
endfunction

" Get return type count
function! genero_tools#signature#return_count(func_obj) abort
  if type(a:func_obj) != type({})
    return 0
  endif
  
  let returns = get(a:func_obj, 'returns', [])
  return len(returns)
endfunction

" Format full parameter list for info display
" Shows parameter names and full type names
function! genero_tools#signature#format_parameters(func_obj) abort
  if type(a:func_obj) != type({})
    return []
  endif
  
  let params = get(a:func_obj, 'parameters', [])
  let formatted = []
  
  for param in params
    if type(param) == type({})
      let pname = get(param, 'name', '?')
      let ptype = get(param, 'type', '')
      let full_type = genero_tools#signature#get_full_type(ptype)
      call add(formatted, '  ' . pname . ': ' . full_type)
    endif
  endfor
  
  return formatted
endfunction

" Format full return list for info display
" Shows return names and full type names
function! genero_tools#signature#format_returns(func_obj) abort
  if type(a:func_obj) != type({})
    return []
  endif
  
  let returns = get(a:func_obj, 'returns', [])
  let formatted = []
  
  for ret in returns
    if type(ret) == type({})
      let rname = get(ret, 'name', '')
      let rtype = get(ret, 'type', '')
      let full_type = genero_tools#signature#get_full_type(rtype)
      
      if empty(rname)
        call add(formatted, '  ' . full_type)
      else
        call add(formatted, '  ' . rname . ': ' . full_type)
      endif
    endif
  endfor
  
  return formatted
endfunction

" Format function calls for info display
function! genero_tools#signature#format_calls(func_obj) abort
  if type(a:func_obj) != type({})
    return []
  endif
  
  let calls = get(a:func_obj, 'calls', [])
  
  if empty(calls)
    return ['  (no function calls)']
  endif
  
  let call_names = []
  for call in calls
    if type(call) == type({})
      let cname = get(call, 'name', '?')
      call add(call_names, cname)
    endif
  endfor
  
  if empty(call_names)
    return ['  (no function calls)']
  endif
  
  let call_str = '  ' . join(call_names, ', ') . ' (' . len(call_names) . ' functions)'
  return [call_str]
endfunction

" Get full type name from abbreviated or full type
function! genero_tools#signature#get_full_type(type_str) abort
  if empty(a:type_str)
    return ''
  endif
  
  let upper_type = toupper(a:type_str)
  
  " Map abbreviated types back to full names
  let abbr_to_full = {
    \ 'STR': 'STRING',
    \ 'INT': 'INTEGER',
    \ 'DEC': 'DECIMAL',
    \ 'BOOL': 'BOOLEAN',
    \ 'DT': 'DATETIME',
    \ 'INTV': 'INTERVAL',
    \ 'SINT': 'SMALLINT',
    \ 'BINT': 'BIGINT',
    \ 'FLT': 'FLOAT',
    \ 'DBL': 'DOUBLE',
    \ 'MON': 'MONEY',
    \ 'CHR': 'CHAR',
    \ 'VAR': 'VARCHAR',
    \ 'BYT': 'BYTE',
    \ 'TXT': 'TEXT',
    \ 'BLB': 'BLOB',
    \ 'CLB': 'CLOB',
    \ 'ARR': 'DYNAMIC ARRAY',
    \ 'REC': 'RECORD',
    \ 'DARR': 'DYNAMIC ARRAY',
    \ }
  
  " If it's already abbreviated, expand it
  if has_key(abbr_to_full, upper_type)
    return abbr_to_full[upper_type]
  endif
  
  " If it's already full, return as-is
  if upper_type =~? '^STRING$\|^INTEGER$\|^DECIMAL$\|^BOOLEAN$\|^DATETIME$\|^RECORD$\|^DYNAMIC ARRAY$'
    return a:type_str
  endif
  
  " Return as-is if not recognized
  return a:type_str
endfunction

" Format complete info section for completion
function! genero_tools#signature#format_complete_info(func_obj) abort
  if type(a:func_obj) != type({})
    return ''
  endif
  
  let lines = []
  
  " Header with signature and location
  let name = get(a:func_obj, 'name', '?')
  let param_count = genero_tools#signature#param_count(a:func_obj)
  let return_count = genero_tools#signature#return_count(a:func_obj)
  let file = get(a:func_obj, 'file', '?')
  let line_start = get(a:func_obj, 'line_start', '?')
  let line_end = get(a:func_obj, 'line_end', '?')
  
  let header = name . '(' . param_count . ' params) -> ' . return_count . ' return'
  if return_count != 1
    let header = name . '(' . param_count . ' params) -> ' . return_count . ' returns'
  endif
  let header .= ' | ' . file . ':' . line_start . '-' . line_end
  
  call add(lines, header)
  call add(lines, '')
  
  " Parameters section
  let params = genero_tools#signature#format_parameters(a:func_obj)
  if !empty(params)
    call add(lines, 'Parameters:')
    call extend(lines, params)
    call add(lines, '')
  endif
  
  " Returns section
  let returns = genero_tools#signature#format_returns(a:func_obj)
  if !empty(returns)
    call add(lines, 'Returns:')
    call extend(lines, returns)
    call add(lines, '')
  endif
  
  " Calls section
  let calls = genero_tools#signature#format_calls(a:func_obj)
  if !empty(calls)
    call add(lines, 'Calls:')
    call extend(lines, calls)
  endif
  
  return join(lines, "\n")
endfunction
