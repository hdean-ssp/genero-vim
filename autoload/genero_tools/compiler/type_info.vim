" Genero-Tools Plugin - Type Info Virtual Text
" Shows function signature as virtual text when cursor is on a function name
" Neovim only — silently does nothing in Vim

" Namespace for type info extmarks
let s:ns_id = -1

" Track last word we looked up to avoid redundant work
let s:last_word = ''
let s:last_bufnr = -1
let s:last_line = -1

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

  if !hlexists('GeneroTypeInfoParam')
    highlight GeneroTypeInfoParam guifg=#5a8a6a guibg=NONE gui=italic ctermfg=DarkGreen ctermbg=NONE
  endif

  " Set up CursorHold autocommand — fires after 'updatetime' ms of inactivity
  " This avoids calling query.sh on every cursor movement
  augroup GeneroTypeInfo
    autocmd!
    autocmd CursorHold *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#on_cursor_hold()
    autocmd CursorMoved *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#on_cursor_moved()
    autocmd BufLeave *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#clear_extmarks()
    autocmd InsertEnter *.4gl,*.m3,*.m4,*.per call genero_tools#compiler#type_info#clear_extmarks()
  augroup END
endfunction

" Called on CursorMoved — clear virtual text if we moved to a different word/line
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

  " If we're still on the same word on the same line, keep the virtual text
  if word ==# s:last_word && bufnr == s:last_bufnr && current_line == s:last_line
    return
  endif

  " Moved to a different word/line — clear the extmarks but don't reset tracking
  " (CursorHold will do the new lookup)
  call genero_tools#compiler#type_info#clear_extmarks()
  let s:last_word = ''
  let s:last_bufnr = -1
  let s:last_line = -1
endfunction

" Called on CursorHold — look up the word under cursor
function! genero_tools#compiler#type_info#on_cursor_hold() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#config#get('compiler_type_info')
    return
  endif

  call genero_tools#compiler#type_info#show_for_cursor()
endfunction

" Core lookup logic — also used by the manual :GeneroTypeInfo command
function! genero_tools#compiler#type_info#show_for_cursor() abort
  let word = expand('<cword>')
  if empty(word)
    return
  endif

  " Skip very short words
  if len(word) < 3
    return
  endif

  " Skip Genero keywords (case-insensitive check)
  let upper = toupper(word)
  if upper =~# '^\(DEFINE\|FUNCTION\|END\|IF\|THEN\|ELSE\|FOR\|WHILE\|RETURN\|CALL\|LET\|DISPLAY\|INPUT\|CASE\|WHEN\|MAIN\|REPORT\|SELECT\|INSERT\|UPDATE\|DELETE\|FROM\|WHERE\|INTO\|VALUES\|SET\|AND\|OR\|NOT\|NULL\|TRUE\|FALSE\|INTEGER\|STRING\|SMALLINT\|FLOAT\|DECIMAL\|DATE\|CHAR\|VARCHAR\|BOOLEAN\|RECORD\|ARRAY\|LIKE\|TYPE\|CONSTANT\|GLOBALS\|MODULE\|IMPORT\|OPEN\|CLOSE\|FETCH\|FOREACH\|PREPARE\|EXECUTE\|FREE\|DECLARE\|CURSOR\|DATABASE\|CONNECT\|DISCONNECT\|BEGIN\|WORK\|COMMIT\|ROLLBACK\|OUTPUT\|TO\|MENU\|COMMAND\|DIALOG\|CONSTRUCT\|ON\|BEFORE\|AFTER\|CONTINUE\|EXIT\|SLEEP\|ERROR\|STATUS\|SQLCA\|WHENEVER\|GOTO\|LABEL\|INITIALIZE\|VALIDATE\|LOCATE\|ALLOCATE\|REALLOCATE\|DEFER\|OPTIONS\|PROMPT\|MESSAGE\|ATTRIBUTE\|ATTRIBUTES\|WINDOW\|SCREEN\|FORM\|CLEAR\|SCROLL\|NEXT\|PREVIOUS\|ACCEPT\|CANCEL\|IDLE\|ACTION\|STEP\|SKIP\|PRINT\|NEED\|HEADER\|TRAILER\|PAGE\|FIRST\|LAST\|CURRENT\|OUTER\|GROUP\|ORDER\|BY\|HAVING\|UNION\|BETWEEN\|EXISTS\|IN\|ANY\|ALL\|SOME\|ASC\|DESC\|DISTINCT\|UNIQUE\|COUNT\|SUM\|AVG\|MIN\|MAX\|CLIPPED\|USING\|SPACES\|COLUMN\|TODAY\|YEAR\|MONTH\|DAY\|HOUR\|MINUTE\|SECOND\|FRACTION\|INTERVAL\|UNITS\|EXTEND\|MATCHES\|THRU\|THROUGH\|WITH\|RESUME\|RETURNING\|RETURNS\|PRIVATE\|PUBLIC\|STATIC\|DYNAMIC\)$'
    return
  endif

  let bufnr = bufnr('%')
  let current_line = line('.')

  " Skip if same word on same line (already showing)
  if word ==# s:last_word && bufnr == s:last_bufnr && current_line == s:last_line
    return
  endif

  " Try to get signature from cache first (fast path — no shell call)
  let cache_key = 'find-function:' . word
  let cached = genero_tools#cache#get(cache_key)

  if !empty(cached)
    if has_key(cached, 'success') && cached.success
      call s:show_signature(bufnr, current_line, word, cached.data)
    elseif has_key(cached, 'data')
      call s:show_signature(bufnr, current_line, word, cached.data)
    endif
    let s:last_word = word
    let s:last_bufnr = bufnr
    let s:last_line = current_line
    return
  endif

  " Not in cache — try the concise format cache
  let concise_key = 'find-function-concise:' . word
  let concise_cached = genero_tools#cache#get(concise_key)

  if !empty(concise_cached)
    if has_key(concise_cached, 'success') && concise_cached.success
      call s:show_concise(bufnr, current_line, concise_cached.data)
    elseif has_key(concise_cached, 'data')
      call s:show_concise(bufnr, current_line, concise_cached.data)
    endif
    let s:last_word = word
    let s:last_bufnr = bufnr
    let s:last_line = current_line
    return
  endif

  " Nothing in cache — do a lookup (this calls query.sh, but only on CursorHold)
  let result = genero_tools#command#execute_shell('find-function', [word])

  if result.success && !empty(result.data)
    " Cache it for future use
    call genero_tools#cache#set(cache_key, result)
    call s:show_signature(bufnr, current_line, word, result.data)
  endif

  " Record word so we don't retry on next CursorHold
  let s:last_word = word
  let s:last_bufnr = bufnr
  let s:last_line = current_line
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

  " Force a fresh lookup (bypass same-word check)
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

" Show signature from full function data (find-function result)
function! s:show_signature(bufnr, line, word, data) abort
  " data is typically a list of function matches
  let func = {}
  if type(a:data) == type([]) && !empty(a:data)
    " Find exact match by name
    for item in a:data
      if type(item) == type({}) && get(item, 'name', '') ==? a:word
        let func = item
        break
      endif
    endfor
    " Fall back to first result if it's a dict
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

  " Build signature text
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

  " File location (just the filename, not full path)
  let file = get(func, 'file', '')
  if !empty(file)
    let filename = fnamemodify(file, ':t')
    call add(sig_parts, '  ' . filename)
  endif

  let display_text = join(sig_parts, ' ')

  call genero_tools#compiler#type_info#clear_extmarks()

  try
    let virt_text = [['  ' . display_text, 'GeneroTypeInfo']]
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_text': virt_text,
      \ 'virt_text_pos': 'eol',
      \ 'priority': 30
      \ })
  catch
  endtry
endfunction

" Show signature from concise format data (string)
function! s:show_concise(bufnr, line, data) abort
  let text = ''
  if type(a:data) == type('')
    let text = trim(a:data)
  elseif type(a:data) == type([]) && !empty(a:data)
    let text = trim(a:data[0])
  elseif type(a:data) == type({}) && has_key(a:data, 'data')
    if type(a:data.data) == type('')
      let text = trim(a:data.data)
    elseif type(a:data.data) == type([]) && !empty(a:data.data)
      let text = trim(a:data.data[0])
    endif
  endif

  if empty(text)
    return
  endif

  call genero_tools#compiler#type_info#clear_extmarks()

  try
    let virt_text = [['  ' . text, 'GeneroTypeInfo']]
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line - 1, 0, {
      \ 'virt_text': virt_text,
      \ 'virt_text_pos': 'eol',
      \ 'priority': 30
      \ })
  catch
  endtry
endfunction

" Clear extmarks only (not tracking state)
function! genero_tools#compiler#type_info#clear_extmarks() abort
  if !has('nvim')
    return
  endif

  if s:ns_id == -1
    return
  endif

  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction

" Full clear — extmarks and tracking state
function! genero_tools#compiler#type_info#clear() abort
  call genero_tools#compiler#type_info#clear_extmarks()
  let s:last_word = ''
  let s:last_bufnr = -1
  let s:last_line = -1
endfunction
