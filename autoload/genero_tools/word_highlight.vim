" Genero-Tools Plugin - Word Highlight
" Highlights all occurrences of the word under cursor within the current
" function scope. Uses subtle background highlighting matching block_match style.
" OPTIMIZED: Debounced to avoid expensive scans on every column change.
"            Caches function scope boundaries per-buffer.
" Neovim only

let s:ns_id = -1
let s:last_word = ''
let s:last_line = -1
let s:last_bufnr = -1

" Debounce timer for word highlight
let s:highlight_timer = -1

" Scope cache: bufnr -> { func_name -> {start: N, end: N} }
" Reused across calls to avoid repeated linear scans
let s:scope_cache = {}
let s:scope_cache_tick = {}

function! genero_tools#word_highlight#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_word_highlight')

  " Subtle background highlight — same style as block matching
  highlight! GeneroWordHighlight guifg=NONE guibg=#2a2a3a gui=NONE ctermbg=59 ctermfg=NONE cterm=NONE
endfunction

" Called by cursor dispatcher when word or column changes
" Now debounced — clears immediately but delays the expensive scan
function! genero_tools#word_highlight#on_word_changed(word, bufnr, current_line) abort
  " Always clear previous highlights immediately for responsiveness
  call genero_tools#word_highlight#clear()

  " Cancel any pending highlight timer
  if s:highlight_timer != -1
    call timer_stop(s:highlight_timer)
    let s:highlight_timer = -1
  endif

  if empty(a:word) || len(a:word) < 3
    let s:last_word = ''
    return
  endif

  " Skip keywords — they're too common and noisy
  if s:is_keyword(toupper(a:word))
    let s:last_word = ''
    return
  endif

  " Skip if cursor is inside a comment or string
  if s:in_comment_or_string(a:current_line)
    let s:last_word = ''
    return
  endif

  " Schedule the expensive highlight operation after debounce delay
  let delay = genero_tools#config#get('perf_word_highlight_debounce')
  let s:highlight_timer = timer_start(delay, function('s:do_highlight', [a:word, a:bufnr, a:current_line]))
endfunction

" Debounced callback — performs the actual highlighting work
function! s:do_highlight(word, bufnr, current_line, timer_id) abort
  let s:highlight_timer = -1

  " Verify cursor hasn't moved to a different word/position
  if expand('<cword>') !=# a:word || bufnr('%') != a:bufnr || line('.') != a:current_line
    return
  endif

  let s:last_word = a:word
  let s:last_line = a:current_line
  let s:last_bufnr = a:bufnr

  " Find the current function scope boundaries (cached)
  let [scope_start, scope_end] = s:find_function_scope_cached(a:bufnr, a:current_line)

  " Enforce max scope size to prevent CPU spikes in very large functions
  let max_scope = genero_tools#config#get('perf_word_highlight_max_scope')
  let scope_size = scope_end - scope_start + 1
  if scope_size > max_scope
    " Center the search window around the cursor
    let half = max_scope / 2
    let scope_start = max([scope_start, a:current_line - half])
    let scope_end = min([scope_end, a:current_line + half])
  endif

  " Find all occurrences of the word within scope
  let pattern = '\<' . escape(a:word, '\') . '\>'
  let lines = getbufline(a:bufnr, scope_start, scope_end)

  for i in range(len(lines))
    let line_nr = scope_start + i
    let line_text = lines[i]

    " Skip comment lines entirely
    let trimmed = substitute(line_text, '^\s*', '', '')
    if trimmed =~# '^[#]' || trimmed =~# '^--' || trimmed =~# '^{'
      continue
    endif

    " Get the code portion (strip inline comments)
    let code_part = s:strip_strings_and_comments(line_text)

    let start = 0
    while 1
      let match_pos = matchstrpos(code_part, '\c' . pattern, start)
      if empty(match_pos[0]) || match_pos[1] == -1
        break
      endif

      " Don't highlight the word under the cursor itself
      if line_nr == a:current_line
        let start = match_pos[2]
        continue
      endif

      " Add extmark highlight for this occurrence
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, line_nr - 1, match_pos[1], {
          \ 'end_col': match_pos[2],
          \ 'hl_group': 'GeneroWordHighlight',
          \ 'priority': 10
          \ })
      catch
      endtry

      let start = match_pos[2]
    endwhile
  endfor
endfunction

" Find function scope using cached boundaries
" Avoids repeated linear scans by caching the full function index per-buffer
function! s:find_function_scope_cached(bufnr, current_line) abort
  let changedtick = getbufvar(a:bufnr, 'changedtick')

  " Rebuild cache if buffer has changed or cache doesn't exist
  if !has_key(s:scope_cache, a:bufnr) || get(s:scope_cache_tick, a:bufnr, -1) != changedtick
    call s:build_scope_cache(a:bufnr)
    let s:scope_cache_tick[a:bufnr] = changedtick
  endif

  " Look up which function contains the current line
  let boundaries = s:scope_cache[a:bufnr]
  for [func_name, range] in items(boundaries)
    if a:current_line >= range.start && a:current_line <= range.end
      return [range.start, range.end]
    endif
  endfor

  " Fallback: not inside any function — use a limited window around cursor
  let max_scope = genero_tools#config#get('perf_word_highlight_max_scope')
  let half = max_scope / 2
  return [max([1, a:current_line - half]), min([line('$'), a:current_line + half])]
endfunction

" Build the function boundary cache for a buffer (single pass)
function! s:build_scope_cache(bufnr) abort
  let boundaries = {}
  let total = nvim_buf_line_count(a:bufnr)
  let current_func = ''
  let func_start = 0

  let lines = getbufline(a:bufnr, 1, total)
  let i = 0
  while i < len(lines)
    let trimmed = substitute(lines[i], '^\s*', '', '')
    let upper = toupper(trimmed)

    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      if !empty(current_func)
        let boundaries[current_func] = {'start': func_start, 'end': i}
      endif
      if upper =~# '^FUNCTION\>'
        let current_func = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
      elseif upper =~# '^MAIN\>'
        let current_func = 'MAIN'
      elseif upper =~# '^REPORT\>'
        let current_func = matchstr(trimmed, '\c^REPORT\s\+\zs\w\+')
      endif
      let func_start = i + 1
    endif

    if upper =~# '^END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      if !empty(current_func)
        let boundaries[current_func] = {'start': func_start, 'end': i + 1}
        let current_func = ''
      endif
    endif

    let i += 1
  endwhile

  if !empty(current_func)
    let boundaries[current_func] = {'start': func_start, 'end': total}
  endif

  let s:scope_cache[a:bufnr] = boundaries
endfunction

" Common Genero keywords to skip (too noisy to highlight)
function! s:is_keyword(upper_word) abort
  let keywords = {
    \ 'DEFINE': 1, 'FUNCTION': 1, 'END': 1, 'IF': 1, 'THEN': 1, 'ELSE': 1,
    \ 'FOR': 1, 'WHILE': 1, 'CASE': 1, 'WHEN': 1, 'RETURN': 1, 'CALL': 1,
    \ 'LET': 1, 'DISPLAY': 1, 'INPUT': 1, 'SELECT': 1, 'INSERT': 1,
    \ 'UPDATE': 1, 'DELETE': 1, 'FROM': 1, 'WHERE': 1, 'INTO': 1,
    \ 'AND': 1, 'NOT': 1, 'NULL': 1, 'TRUE': 1, 'FALSE': 1,
    \ 'LIKE': 1, 'RECORD': 1, 'ARRAY': 1, 'DYNAMIC': 1, 'INTEGER': 1,
    \ 'STRING': 1, 'SMALLINT': 1, 'DECIMAL': 1, 'DATE': 1, 'CHAR': 1,
    \ 'VARCHAR': 1, 'FLOAT': 1, 'MONEY': 1, 'BYTE': 1, 'TEXT': 1,
    \ 'FOREACH': 1, 'PREPARE': 1, 'EXECUTE': 1, 'DECLARE': 1, 'OPEN': 1,
    \ 'CLOSE': 1, 'FETCH': 1, 'FREE': 1, 'WHENEVER': 1, 'CONTINUE': 1,
    \ 'EXIT': 1, 'RETURNING': 1, 'RETURNS': 1, 'MAIN': 1, 'REPORT': 1,
    \ 'OUTPUT': 1, 'PRINT': 1, 'MENU': 1, 'DIALOG': 1, 'CONSTRUCT': 1,
    \ 'INITIALIZE': 1, 'VALIDATE': 1, 'ERROR': 1, 'STATUS': 1,
    \ 'BEGIN': 1, 'WORK': 1, 'COMMIT': 1, 'ROLLBACK': 1,
    \ 'THE': 1, 'SET': 1, 'USING': 1, 'CLIPPED': 1, 'SPACES': 1,
    \ }
  return has_key(keywords, a:upper_word)
endfunction

" Clear all word highlights
function! genero_tools#word_highlight#clear() abort
  if !has('nvim') || s:ns_id == -1
    return
  endif
  if s:highlight_timer != -1
    call timer_stop(s:highlight_timer)
    let s:highlight_timer = -1
  endif
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
  let s:last_word = ''
endfunction

" Check if cursor position is inside a comment or string literal
function! s:in_comment_or_string(line_nr) abort
  let line_text = getline(a:line_nr)
  let cursor_col = col('.')

  " Full-line comments
  let trimmed = substitute(line_text, '^\s*', '', '')
  if trimmed =~# '^[#]' || trimmed =~# '^--' || trimmed =~# '^{'
    return 1
  endif

  " Check if cursor is inside a string or after an inline comment
  let in_string = 0
  let string_char = ''
  let i = 0
  while i < len(line_text) && i < cursor_col - 1
    let ch = line_text[i]

    if in_string
      if ch ==# string_char
        let in_string = 0
      endif
    else
      if ch ==# '"' || ch ==# "'"
        let in_string = 1
        let string_char = ch
      elseif ch ==# '#'
        " Rest of line is a comment
        return 1
      elseif i + 1 < len(line_text) && line_text[i : i + 1] ==# '--'
        return 1
      endif
    endif

    let i += 1
  endwhile

  return in_string
endfunction

" Strip string literals and inline comments from a line
" Replaces string contents with spaces (preserves column positions)
function! s:strip_strings_and_comments(line_text) abort
  let result = ''
  let in_string = 0
  let string_char = ''
  let i = 0

  while i < len(a:line_text)
    let ch = a:line_text[i]

    if in_string
      if ch ==# string_char
        let in_string = 0
        let result .= ' '
      else
        let result .= ' '
      endif
    else
      if ch ==# '"' || ch ==# "'"
        let in_string = 1
        let string_char = ch
        let result .= ' '
      elseif ch ==# '#'
        " Rest of line is a comment — pad with spaces
        let result .= repeat(' ', len(a:line_text) - i)
        break
      elseif i + 1 < len(a:line_text) && a:line_text[i : i + 1] ==# '--'
        let result .= repeat(' ', len(a:line_text) - i)
        break
      else
        let result .= ch
      endif
    endif

    let i += 1
  endwhile

  return result
endfunction
