" Genero-Tools Plugin - Find References
" Shows all callers of a function via Telescope picker (with file preview)
" Falls back to a floating window if Telescope is not available
" Leverages find-function-dependents (same data as refcount, but displayed)
" Also supports variable references with scope-aware searching

let s:ref_win = -1
let s:ref_buf = -1
let s:ref_data = []
let s:ref_type = 'function'  " 'function' or 'variable'

" Smart find references - detects if cursor is on function or variable
" Calls find() for functions, find_variable() for variables
function! genero_tools#references#find_smart() abort
  " Check if we're on a FUNCTION definition line
  let line_text = getline('.')
  let trimmed = substitute(line_text, '^\s*', '', '')
  let upper = toupper(trimmed)
  
  if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
    " On a function definition - use function references
    call genero_tools#references#find()
    return
  endif
  
  " Get the word under cursor and check context
  let word = expand('<cword>')
  let col = col('.')
  
  " Get text immediately after the word under cursor
  " We need to check if there's a '(' right after the word (not just anywhere on the line)
  let word_end_col = col + len(word) - 1
  let line_after_word = strpart(line_text, word_end_col)
  
  " Check if this is a CALL statement
  if upper =~# '^\s*CALL\>'
    " On a CALL line - check if cursor is on the function name (before the '(')
    " Extract the function name from CALL statement
    let call_func = matchstr(upper, '^\s*CALL\s\+\zs\w\+')
    if !empty(call_func) && toupper(word) ==# call_func
      " Cursor is on the function name in CALL statement
      call genero_tools#references#find(word)
      return
    endif
    " Otherwise cursor is on a parameter - treat as variable
  endif
  
  " Check if cursor is directly on a function call (word followed immediately by '(')
  if line_after_word =~# '^\s*('
    " Cursor is on the function name itself
    call genero_tools#references#find(word)
    return
  endif
  
  " Check if word matches function naming pattern (no prefix like l_, m_, gl_)
  " Variables typically have prefixes, functions typically don't
  if word !~# '^[lmg][lr_]_' && word !~# '^p_'
    " Could be a function - try function references first
    " If it fails, fall back to variable references
    let cache_key = 'find-function-dependents:' . word
    let cached = genero_tools#cache#get(cache_key)
    
    if !empty(cached) && has_key(cached, 'success') && cached.success
      " Function exists in cache - use function references
      call genero_tools#references#find(word)
      return
    else
      " Try querying for function
      let result = genero_tools#command#execute_shell('find-function-dependents', [word])
      if result.success && !empty(result.data) && type(result.data) == type([])
        " Function found - use function references
        call genero_tools#references#find(word)
        return
      endif
    endif
  endif
  
  " Default to variable references (local scope-aware scanning)
  call genero_tools#references#find_variable(word)
endfunction

" Find references for the function under cursor (or on the current FUNCTION line)
function! genero_tools#references#find(...) abort
  let func_name = a:0 > 0 && !empty(a:1) ? a:1 : s:get_function_name()

  if empty(func_name)
    call genero_tools#error#warn('references', 'No function name under cursor')
    return
  endif

  let s:ref_type = 'function'

  " Check refcount cache first — if we already fetched dependents, reuse the count
  " But we need the full data, not just the count, so always query
  let cache_key = 'find-function-dependents:' . func_name
  let cached = genero_tools#cache#get(cache_key)
  let data = []

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let data = cached.data
  else
    let result = genero_tools#command#execute_shell('find-function-dependents', [func_name])
    if !result.success || empty(result.data)
      call genero_tools#error#warn('references', 'No references found for: ' . func_name)
      return
    endif
    let data = result.data
    call genero_tools#cache#set(cache_key, result)
  endif

  if type(data) != type([]) || empty(data)
    call genero_tools#error#warn('references', 'No references found for: ' . func_name)
    return
  endif

  " Try Telescope picker first (Neovim + Telescope available)
  if has('nvim')
    try
      let data_json = json_encode(data)
      let handled = luaeval('require("genero_tools.references").find(_A[1], _A[2])', [func_name, data_json])
      if handled
        return
      endif
    catch
      " Telescope not available or error — fall through to floating window
    endtry
  endif

  " Fallback: floating window
  let s:ref_data = data
  let lines = s:format_references(func_name, data)
  call s:show_references_window(lines, func_name, len(data))
endfunction

" Find references for a variable (scope-aware buffer scanning)
" OPTIMIZED: Only scans current function for local variables, full buffer for module variables
function! genero_tools#references#find_variable(...) abort
  let var_name = a:0 > 0 && !empty(a:1) ? a:1 : expand('<cword>')
  
  if empty(var_name)
    call genero_tools#error#warn('references', 'No variable name under cursor')
    return
  endif
  
  let s:ref_type = 'variable'
  let bufnr = bufnr('%')
  let current_line = line('.')
  
  " Check cache first
  let cache_key = 'var-refs:' . bufnr . ':' . getbufvar(bufnr, 'changedtick', 0) . ':' . var_name
  let cached = genero_tools#cache#get(cache_key)
  
  if !empty(cached) && has_key(cached, 'data')
    let refs = cached.data
  else
    " Determine variable scope by checking type info
    let scope = s:get_variable_scope(var_name, bufnr, current_line)
    
    " Scan for references based on scope
    if scope ==# 'module' || scope ==# 'global'
      let refs = s:find_variable_refs_full_buffer(var_name, bufnr)
    else
      " Local variable - only scan current function
      let refs = s:find_variable_refs_in_function(var_name, bufnr, current_line)
    endif
    
    " Cache the results
    call genero_tools#cache#set(cache_key, {'success': 1, 'data': refs, 'timestamp': localtime()})
  endif
  
  if empty(refs)
    call genero_tools#error#warn('references', 'No references found for variable: ' . var_name)
    return
  endif
  
  " Try Telescope picker first (Neovim + Telescope available)
  if has('nvim')
    try
      let refs_json = json_encode(refs)
      let handled = luaeval('require("genero_tools.telescope").variable_references(_A[1], _A[2])', [var_name, refs_json])
      if handled
        return
      endif
    catch
      " Telescope not available or error — fall through to floating window
    endtry
  endif
  
  " Fallback: floating window
  let s:ref_data = refs
  let lines = s:format_variable_references(var_name, refs)
  call s:show_references_window(lines, var_name . ' (variable)', len(refs))
endfunction

" Check if a position in a line is inside a string or comment
" Returns 1 if inside string/comment, 0 otherwise
function! s:is_in_string_or_comment(line_text, col) abort
  " Check for line comments (# or --)
  let comment_pos = match(a:line_text, '\s*\(#\|--\)')
  if comment_pos != -1 && a:col >= comment_pos
    return 1
  endif
  
  " Check if inside a string (single or double quotes)
  " Count quotes before the position to determine if we're inside
  let before_pos = strpart(a:line_text, 0, a:col)
  
  " Count unescaped double quotes
  let double_quotes = 0
  let i = 0
  while i < len(before_pos)
    if before_pos[i] ==# '"' && (i == 0 || before_pos[i-1] !=# '\')
      let double_quotes += 1
    endif
    let i += 1
  endwhile
  
  " Count unescaped single quotes
  let single_quotes = 0
  let i = 0
  while i < len(before_pos)
    if before_pos[i] ==# "'" && (i == 0 || before_pos[i-1] !=# '\')
      let single_quotes += 1
    endif
    let i += 1
  endwhile
  
  " If odd number of quotes, we're inside a string
  if (double_quotes % 2) == 1 || (single_quotes % 2) == 1
    return 1
  endif
  
  return 0
endfunction

" Determine variable scope (module, global, or local)
" Uses the same logic as type_info to detect scope
function! s:get_variable_scope(var_name, bufnr, cursor_line) abort
  " Check naming convention first (fast)
  if a:var_name =~? '^m_'
    return 'module'
  elseif a:var_name =~? '^gl_'
    return 'global'
  endif
  
  " Try to find DEFINE to determine actual scope
  " Reuse type_info's find_define logic if available
  if exists('*genero_tools#compiler#type_info#find_define')
    let define_info = genero_tools#compiler#type_info#find_define(a:var_name, a:bufnr, a:cursor_line)
    if !empty(define_info)
      return get(define_info, 'scope', 'local')
    endif
  endif
  
  " Default to local if we can't determine
  return 'local'
endfunction

" Find all references to a variable in the current function only
" OPTIMIZED: Only scans function boundaries, not entire buffer
function! s:find_variable_refs_in_function(var_name, bufnr, cursor_line) abort
  let refs = []
  
  " Find function boundaries
  let func_start = s:find_function_start(a:cursor_line)
  let func_end = s:find_function_end(a:cursor_line)
  
  if func_start == 0 || func_end == 0
    return refs
  endif
  
  " Build pattern to match variable references
  let pattern = '\<' . escape(a:var_name, '\') . '\>'
  
  " Scan only within function boundaries
  for line_nr in range(func_start, func_end)
    let line_text = getline(line_nr)
    
    " Skip full-line comments
    if line_text =~# '^\s*[#\-\-]'
      continue
    endif
    
    " Check if line contains the variable
    if line_text =~# pattern
      " Find all occurrences in the line
      let col = 0
      while 1
        let col = match(line_text, pattern, col)
        if col == -1
          break
        endif
        
        " Skip if inside string or comment
        if !s:is_in_string_or_comment(line_text, col)
          call add(refs, {
            \ 'line': line_nr,
            \ 'column': col + 1,
            \ 'text': line_text,
            \ 'file': expand('%:p')
            \ })
        endif
        
        let col += len(a:var_name)
      endwhile
    endif
  endfor
  
  return refs
endfunction

" Find all references to a variable in the entire buffer
" Used for module-level and global variables
function! s:find_variable_refs_full_buffer(var_name, bufnr) abort
  let refs = []
  let total_lines = line('$')
  
  " Build pattern to match variable references
  let pattern = '\<' . escape(a:var_name, '\') . '\>'
  
  " Scan entire buffer
  for line_nr in range(1, total_lines)
    let line_text = getline(line_nr)
    
    " Skip full-line comments
    if line_text =~# '^\s*[#\-\-]'
      continue
    endif
    
    " Check if line contains the variable
    if line_text =~# pattern
      " Find all occurrences in the line
      let col = 0
      while 1
        let col = match(line_text, pattern, col)
        if col == -1
          break
        endif
        
        " Skip if inside string or comment
        if !s:is_in_string_or_comment(line_text, col)
          call add(refs, {
            \ 'line': line_nr,
            \ 'column': col + 1,
            \ 'text': line_text,
            \ 'file': expand('%:p')
            \ })
        endif
        
        let col += len(a:var_name)
      endwhile
    endif
  endfor
  
  return refs
endfunction

" Find the start line of the function containing the cursor
function! s:find_function_start(cursor_line) abort
  let i = a:cursor_line
  
  while i >= 1
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))
    
    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      return i
    endif
    
    let i -= 1
  endwhile
  
  return 0
endfunction

" Find the end line of the function containing the cursor
function! s:find_function_end(cursor_line) abort
  let i = a:cursor_line
  let total = line('$')
  
  while i <= total
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))
    
    if upper =~# '^END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      return i
    endif
    
    let i += 1
  endwhile
  
  return total
endfunction

" Format variable reference data into display lines
function! s:format_variable_references(var_name, refs) abort
  let lines = []
  let idx = 0
  
  for ref in a:refs
    let idx += 1
    let line_nr = ref.line
    let col = ref.column
    let text = substitute(ref.text, '^\s*', '', '')  " Trim leading whitespace
    
    " Truncate long lines
    if len(text) > 80
      let text = text[:77] . '...'
    endif
    
    let display = printf('  %3d  %4d:%2d  %s', idx, line_nr, col, text)
    call add(lines, display)
  endfor
  
  return lines
endfunction

" Extract function name from context
" Works when cursor is on a FUNCTION line, on a function call, or on the refcount virtual text
function! s:get_function_name() abort
  " Check if cursor is on a FUNCTION definition line
  let line_text = getline('.')
  let trimmed = substitute(line_text, '^\s*', '', '')
  let upper = toupper(trimmed)

  if upper =~# '^FUNCTION\>'
    let name = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
    if !empty(name)
      return name
    endif
  endif

  " Fall back to word under cursor (e.g., on a function call)
  return expand('<cword>')
endfunction

" Format reference data into display lines
function! s:format_references(func_name, data) abort
  let lines = []
  let idx = 0

  for ref in a:data
    let idx += 1

    " Extract fields — query.sh returns: name, signature, path, line_number
    let caller_name = get(ref, 'name', get(ref, 'function', get(ref, 'caller', '?')))
    let file = get(ref, 'path', get(ref, 'file', get(ref, 'file_path', '')))
    let line_nr = get(ref, 'line_number', get(ref, 'line', get(ref, 'line_start', '')))
    let module = get(ref, 'module', '')

    " Handle line as dict (some query.sh responses use {start, end})
    if type(line_nr) == type({})
      let line_nr = get(line_nr, 'start', '')
    endif

    " Build display line
    let display = printf('  %2d  ', idx)

    if !empty(caller_name)
      let display .= caller_name
    endif

    if !empty(file)
      let short_file = fnamemodify(file, ':t')
      let display .= '  ' . short_file
      if !empty(line_nr)
        let display .= ':' . line_nr
      endif
    endif

    if !empty(module)
      let display .= '  [' . module . ']'
    endif

    call add(lines, display)
  endfor

  return lines
endfunction

" Show references in a floating window with navigation
function! s:show_references_window(lines, func_name, count) abort
  call s:close_references_window()

  let header = a:count == 1
    \ ? '1 reference to ' . a:func_name
    \ : a:count . ' references to ' . a:func_name
  let separator = repeat('─', len(header) + 4)
  let footer = '  Enter: jump  q/Esc: close'

  let all_lines = ['  ' . header, separator] + a:lines + ['', footer]

  " Calculate dimensions
  let max_width = 0
  for line in all_lines
    let max_width = max([max_width, strdisplaywidth(line)])
  endfor
  let width = max([max_width + 4, 50])
  let width = min([width, &columns - 4])
  let height = min([len(all_lines), 30, &lines - 4])

  let row = (&lines - height) / 2
  let col = (&columns - width) / 2

  let s:ref_buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(s:ref_buf, 0, -1, v:false, all_lines)

  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'col': col,
    \ 'row': row,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' References ',
    \ 'title_pos': 'center'
    \ }

  let s:ref_win = nvim_open_win(s:ref_buf, v:true, opts)

  call nvim_win_set_option(s:ref_win, 'cursorline', v:true)
  call nvim_win_set_option(s:ref_win, 'wrap', v:false)

  " Position cursor on first reference line (skip header + separator)
  call cursor(3, 1)

  " Keybindings
  call nvim_buf_set_keymap(s:ref_buf, 'n', 'q', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(s:ref_buf, 'n', '<Esc>', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(s:ref_buf, 'n', '<CR>',
    \ ':call genero_tools#references#jump_to_reference()<CR>',
    \ {'noremap': v:true, 'silent': v:true})

  call nvim_buf_set_option(s:ref_buf, 'modifiable', v:false)
endfunction

" Jump to the reference under the cursor
function! genero_tools#references#jump_to_reference() abort
  " Line 1 = header, line 2 = separator, references start at line 3
  let cursor_line = line('.')
  let ref_index = cursor_line - 3  " 0-based index into s:ref_data

  if ref_index < 0 || ref_index >= len(s:ref_data)
    return
  endif

  let ref = s:ref_data[ref_index]
  
  " Handle both function and variable references
  if s:ref_type ==# 'variable'
    " Variable reference - has line, column, file
    let file = get(ref, 'file', '')
    let line_nr = get(ref, 'line', 0)
    let col_nr = get(ref, 'column', 0)
  else
    " Function reference - has path, line_number
    let file = get(ref, 'path', get(ref, 'file', get(ref, 'file_path', '')))
    let line_nr = get(ref, 'line_number', get(ref, 'line', get(ref, 'line_start', 0)))
    let col_nr = 0
    
    " Handle line as dict
    if type(line_nr) == type({})
      let line_nr = get(line_nr, 'start', 0)
    endif
  endif

  if empty(file)
    call genero_tools#error#warn('references', 'No file location for this reference')
    return
  endif

  " Close the references window
  call s:close_references_window()

  " Resolve the file path
  let full_path = s:resolve_ref_path(file)

  " Push current position to jumplist
  normal! m'

  " Open the file
  if expand('%:p') !=# full_path
    execute 'edit ' . fnameescape(full_path)
  endif

  " Jump to line and column if available
  if line_nr > 0
    execute line_nr
    if col_nr > 0
      execute 'normal! ' . col_nr . '|'
    endif
    normal! zz
  endif
endfunction

" Resolve a file path from query.sh output to an absolute path
function! s:resolve_ref_path(file) abort
  let file = a:file

  " Already absolute
  if file[0] ==# '/'
    return file
  endif

  " Strip leading ./
  if file[0:1] ==# './'
    let file = file[2:]
  endif

  " Try relative to codebase root
  let root = genero_tools#codebase#get_root()
  if !empty(root)
    let candidate = root . '/' . file
    if filereadable(candidate)
      return candidate
    endif
  endif

  " Try relative to CWD
  let candidate = getcwd() . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Return as-is and let Vim resolve it
  return file
endfunction

" Close the references floating window
function! s:close_references_window() abort
  if s:ref_win != -1
    try
      call nvim_win_close(s:ref_win, v:true)
    catch
    endtry
    let s:ref_win = -1
  endif
  if s:ref_buf != -1
    try
      execute 'bwipeout! ' . s:ref_buf
    catch
    endtry
    let s:ref_buf = -1
  endif
endfunction
