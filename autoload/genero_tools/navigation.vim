" Genero-Tools Plugin - Navigation Module
" Go to definition, peek definition, and related navigation features

" Go to definition: jump to the file and line where a function is defined
function! genero_tools#navigation#goto_definition(...) abort
  let word = a:0 > 0 && !empty(a:1) ? a:1 : expand('<cword>')

  if empty(word)
    call genero_tools#error#warn('navigation', 'No word under cursor')
    return
  endif

  " Push current position to jumplist so user can jump back with Ctrl+O
  normal! m'

  " First: try to find the function in the current buffer (local function)
  let local_line = s:find_function_in_buffer(word)
  if local_line > 0
    execute local_line
    normal! zz
    echom 'ƒ ' . word . ' (line ' . local_line . ')'
    return
  endif

  " Second: try to find a DEFINE for a variable
  let define_info = s:find_local_define(word)
  if !empty(define_info)
    execute define_info.line
    normal! zz
    echom 'DEFINE ' . word . ' (line ' . define_info.line . ')'
    return
  endif

  " Third: look up via query.sh (external function in another file)
  let cache_key = 'find-function:' . word
  let cached = genero_tools#cache#get(cache_key)
  let result = {}

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let result = cached
  else
    let result = genero_tools#command#execute_shell('find-function', [word])
    if result.success && !empty(result.data)
      call genero_tools#cache#set(cache_key, result)
    endif
  endif

  if !result.success || empty(result.data)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  " Extract function info from query result
  let func = s:extract_function(result.data, word)
  if empty(func)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let file = get(func, 'file', get(func, 'file_path', get(func, 'path', '')))
  let line_nr = get(func, 'line_start', get(func, 'line', 0))

  " Handle line as dict (e.g. {"start": N, "end": M})
  if type(line_nr) == type({})
    let line_nr = get(line_nr, 'start', 0)
  endif

  if empty(file)
    call genero_tools#error#warn('navigation', 'No file location for: ' . word)
    return
  endif

  " Resolve file path relative to codebase root
  let full_path = s:resolve_path(file)

  " Open the file and jump to the line
  try
    if full_path !=# expand('%:p')
      execute 'edit ' . fnameescape(full_path)
    endif
    if line_nr > 0
      execute line_nr
    endif
    normal! zz
    echom 'ƒ ' . word . ' → ' . fnamemodify(full_path, ':t') . ':' . line_nr
  catch
    call genero_tools#error#warn('navigation', 'Failed to open: ' . full_path . ' — ' . v:exception)
  endtry
endfunction

" Peek definition: show function body in a floating window without leaving current position
function! genero_tools#navigation#peek_definition(...) abort
  if !has('nvim')
    call call('genero_tools#navigation#goto_definition', a:000)
    return
  endif

  let word = a:0 > 0 && !empty(a:1) ? a:1 : expand('<cword>')

  if empty(word)
    call genero_tools#error#warn('navigation', 'No word under cursor')
    return
  endif

  " Try local buffer first
  let local_line = s:find_function_in_buffer(word)
  if local_line > 0
    let end_line = s:find_function_end(local_line)
    let preview_end = min([end_line, local_line + 30])
    let file_lines = getline(local_line, preview_end)
    let header = '── ' . word . ' ── ' . expand('%:t') . ':' . local_line . ' ──'
    call s:show_peek_window([header, ''] + file_lines, word)
    return
  endif

  " Try query.sh
  let cache_key = 'find-function:' . word
  let cached = genero_tools#cache#get(cache_key)
  let result = {}

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let result = cached
  else
    let result = genero_tools#command#execute_shell('find-function', [word])
    if result.success && !empty(result.data)
      call genero_tools#cache#set(cache_key, result)
    endif
  endif

  if !result.success || empty(result.data)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let func = s:extract_function(result.data, word)
  if empty(func)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let file = get(func, 'file', get(func, 'file_path', get(func, 'path', '')))
  let line_start = get(func, 'line_start', get(func, 'line', 1))
  let line_end = get(func, 'line_end', line_start + 20)

  " Handle line as dict
  if type(line_start) == type({})
    let line_end = get(line_start, 'end', line_start + 20)
    let line_start = get(line_start, 'start', 1)
  endif

  if empty(file)
    call genero_tools#error#warn('navigation', 'No file location for: ' . word)
    return
  endif

  let full_path = s:resolve_path(file)
  let preview_end = min([line_end, line_start + 30])

  try
    let file_lines = readfile(full_path, '', preview_end)
    if line_start > 0
      let file_lines = file_lines[line_start - 1:]
    endif
  catch
    call genero_tools#error#warn('navigation', 'Cannot read: ' . full_path)
    return
  endtry

  if empty(file_lines)
    call genero_tools#error#warn('navigation', 'Empty function body')
    return
  endif

  let header = '── ' . word . ' ── ' . fnamemodify(full_path, ':t') . ':' . line_start . ' ──'
  call s:show_peek_window([header, ''] + file_lines, word)
endfunction

" ============================================================================
" BUFFER SEARCH FUNCTIONS
" ============================================================================

" Find a FUNCTION definition in the current buffer by name
" Returns the line number or 0 if not found
function! s:find_function_in_buffer(word) abort
  let total = line('$')
  let pattern = '\c^\s*FUNCTION\s\+' . escape(a:word, '\') . '\>'
  let i = 1
  while i <= total
    if getline(i) =~? pattern
      return i
    endif
    let i += 1
  endwhile
  return 0
endfunction

" Find the END FUNCTION line for a function starting at the given line
function! s:find_function_end(start_line) abort
  let i = a:start_line + 1
  let total = line('$')
  while i <= total
    let upper = toupper(substitute(getline(i), '^\s*', '', ''))
    if upper =~# '^END\s\+FUNCTION'
      return i
    endif
    let i += 1
  endwhile
  return min([a:start_line + 30, total])
endfunction

" ============================================================================
" DATA EXTRACTION
" ============================================================================

" Extract function info from query.sh result data
" Handles various data shapes: list of dicts, single dict, nested structures
function! s:extract_function(data, word) abort
  " Direct dict with name/file/line
  if type(a:data) == type({})
    if has_key(a:data, 'file') || has_key(a:data, 'name')
      return a:data
    endif
    " Maybe the data is wrapped: {data: [...]}
    if has_key(a:data, 'data')
      return s:extract_function(a:data.data, a:word)
    endif
    return {}
  endif

  " List of results
  if type(a:data) == type([]) && !empty(a:data)
    " Find exact name match first
    for item in a:data
      if type(item) == type({}) && get(item, 'name', '') ==? a:word
        return item
      endif
    endfor
    " Fall back to first dict in list
    for item in a:data
      if type(item) == type({})
        return item
      endif
    endfor
  endif

  return {}
endfunction

" ============================================================================
" PATH RESOLUTION
" ============================================================================

" Resolve a file path relative to codebase root
function! s:resolve_path(file) abort
  let file = a:file

  " If already absolute, use as-is
  if file[0] == '/'
    return file
  endif

  " Strip leading ./
  if file[0:1] == './'
    let file = file[2:]
  endif

  " Try relative to codebase root
  let root = genero_tools#codebase#get_root()
  let candidate = root . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Try relative to current working directory
  let candidate = getcwd() . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Try as-is
  if filereadable(file)
    return fnamemodify(file, ':p')
  endif

  " Return best guess
  return root . '/' . file
endfunction

" ============================================================================
" DEFINE LOOKUP
" ============================================================================

" Find a local DEFINE for a variable (simple upward scan in current buffer)
function! s:find_local_define(word) abort
  let pattern = '\c^\s*DEFINE\>.*\<' . escape(a:word, '\') . '\>'
  let line_nr = line('.')

  " Search upward
  while line_nr > 0
    let line_text = getline(line_nr)
    let upper = toupper(substitute(line_text, '^\s*', '', ''))

    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    if line_text =~? pattern
      return {'line': line_nr}
    endif

    let line_nr -= 1
  endwhile

  " Search module-level defines
  let line_nr = 1
  while line_nr <= line('$')
    let line_text = getline(line_nr)
    let upper = toupper(substitute(line_text, '^\s*', '', ''))

    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    if line_text =~? pattern
      return {'line': line_nr}
    endif

    let line_nr += 1
  endwhile

  return {}
endfunction

" ============================================================================
" PEEK WINDOW
" ============================================================================

" Show peek floating window
function! s:show_peek_window(lines, title) abort
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, a:lines)

  try
    call nvim_buf_set_option(buf, 'filetype', 'fgl')
  catch
  endtry

  let max_width = 0
  for line in a:lines
    let max_width = max([max_width, strdisplaywidth(line)])
  endfor
  let width = min([max([max_width + 2, 60], 40), &columns - 4])
  let height = min([len(a:lines), 25, &lines - 4])

  let row = (&lines - height) / 2
  let col = (&columns - width) / 2

  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'col': col,
    \ 'row': row,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' ' . a:title . ' ',
    \ 'title_pos': 'center'
    \ }

  let win = nvim_open_win(buf, v:true, opts)

  call nvim_win_set_option(win, 'cursorline', v:true)
  call nvim_win_set_option(win, 'wrap', v:false)

  call nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {'noremap': v:true, 'silent': v:true})

  call nvim_buf_set_option(buf, 'modifiable', v:false)
endfunction
