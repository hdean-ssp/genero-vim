" Genero-Tools Plugin - Type Info Virtual Text
" Shows function signature as virtual text when cursor is on a function name
" Uses a debounced timer on CursorMoved instead of CursorHold for reliability
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

  " Create namespace
  let s:ns_id = nvim_create_namespace('genero_type_info')

  " Define subtle highlight groups
  if !hlexists('GeneroTypeInfo')
    highlight GeneroTypeInfo guifg=#6a7a8a guibg=NONE gui=italic ctermfg=DarkGray ctermbg=NONE
  endif

  " Set up autocommands — use CursorMoved with debounce timer instead of CursorHold
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

  " If still on the same word/line, do nothing
  if word ==# s:last_word && bufnr == s:last_bufnr && current_line == s:last_line
    return
  endif

  " Clear stale virtual text immediately
  call genero_tools#compiler#type_info#clear_extmarks()

  " Cancel any pending timer
  if s:timer_id != -1
    call timer_stop(s:timer_id)
    let s:timer_id = -1
  endif

  " Skip empty or short words
  if empty(word) || len(word) < 3
    let s:last_word = ''
    let s:last_bufnr = -1
    let s:last_line = -1
    return
  endif

  " Skip Genero keywords
  let upper = toupper(word)
  if s:is_keyword(upper)
    let s:last_word = word
    let s:last_bufnr = bufnr
    let s:last_line = current_line
    return
  endif

  " Schedule lookup after a short delay (debounce)
  let s:timer_id = timer_start(400, function('s:debounced_lookup', [word, bufnr, current_line]))
endfunction

" Debounced callback — runs after cursor has been still for 400ms
function! s:debounced_lookup(word, bufnr, line, timer_id) abort
  let s:timer_id = -1

  " Verify cursor is still on the same word (user might have moved)
  if expand('<cword>') !=# a:word || bufnr('%') != a:bufnr || line('.') != a:line
    return
  endif

  " Check cache first (instant, no shell call)
  let cache_key = 'find-function:' . a:word
  let cached = genero_tools#cache#get(cache_key)

  if !empty(cached)
    if has_key(cached, 'success') && cached.success && !empty(get(cached, 'data', {}))
      call s:show_signature(a:bufnr, a:line, a:word, cached.data)
      let s:last_word = a:word
      let s:last_bufnr = a:bufnr
      let s:last_line = a:line
    endif
    return
  endif

  " Not in cache — do a silent shell lookup
  let result = s:silent_lookup(a:word)

  if result.success && !empty(result.data)
    call genero_tools#cache#set(cache_key, result)

    " Verify cursor hasn't moved during the shell call
    if expand('<cword>') ==# a:word && bufnr('%') == a:bufnr && line('.') == a:line
      call s:show_signature(a:bufnr, a:line, a:word, result.data)
      let s:last_word = a:word
      let s:last_bufnr = a:bufnr
      let s:last_line = a:line
    endif
  else
    " Not a function — record so we skip quickly next time
    let s:last_word = a:word
    let s:last_bufnr = a:bufnr
    let s:last_line = a:line
  endif
endfunction

" Manual trigger command — useful for testing
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

  echom '[type_info] Looking up: ' . word

  " Force a fresh lookup
  let s:last_word = ''
  let s:last_bufnr = -1
  let s:last_line = -1

  let result = genero_tools#command#execute_shell('find-function', [word])

  if result.success && !empty(result.data)
    echom '[type_info] Found function, showing signature'
    let cache_key = 'find-function:' . word
    call genero_tools#cache#set(cache_key, result)
    call s:show_signature(bufnr('%'), line('.'), word, result.data)
    let s:last_word = word
    let s:last_bufnr = bufnr('%')
    let s:last_line = line('.')
  else
    echom '[type_info] Function not found: ' . word . ' (error: ' . result.error . ')'
  endif
endfunction

" Check if a word is a Genero keyword
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

" Show signature from full function data
function! s:show_signature(bufnr, line, word, data) abort
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

  let sig_parts = []

  " Parameters
  let params = get(func, 'parameters', [])
  if !empty(params)
    let param_strs = []
    for p in params
      if type(p) == type({})
        call add(param_strs, get(p, 'name', '?') . ' ' . get(p, 'type', '?'))
      endif
    endfor
    call add(sig_parts, '(' . join(param_strs, ', ') . ')')
  else
    call add(sig_parts, '()')
  endif

  " Return types
  let returns = get(func, 'returns', [])
  if !empty(returns)
    let ret_strs = []
    for r in returns
      if type(r) == type({})
        call add(ret_strs, get(r, 'type', get(r, 'name', '?')))
      endif
    endfor
    call add(sig_parts, '→ ' . join(ret_strs, ', '))
  endif

  " File location
  let file = get(func, 'file', '')
  if !empty(file)
    call add(sig_parts, '  ' . fnamemodify(file, ':t'))
  endif

  let display_text = join(sig_parts, ' ')

  call genero_tools#compiler#type_info#clear_extmarks()

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_text': [['  ' . display_text, 'GeneroTypeInfo']],
      \ 'virt_text_pos': 'eol',
      \ 'priority': 30
      \ })
  catch
  endtry
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
