" Genero-Tools Plugin - Word Highlight
" Highlights all occurrences of the word under cursor within the current
" function scope. Uses subtle background highlighting matching block_match style.
" Neovim only

let s:ns_id = -1
let s:last_word = ''
let s:last_line = -1
let s:last_bufnr = -1

function! genero_tools#word_highlight#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_word_highlight')

  " Subtle background highlight — same style as block matching
  highlight! GeneroWordHighlight guifg=NONE guibg=#2a2a3a gui=NONE ctermbg=59 ctermfg=NONE cterm=NONE
endfunction

" Called by cursor dispatcher when word changes
function! genero_tools#word_highlight#on_word_changed(word, bufnr, current_line) abort
  " Clear previous highlights
  call genero_tools#word_highlight#clear()

  if empty(a:word) || len(a:word) < 3
    let s:last_word = ''
    return
  endif

  " Skip keywords — they're too common and noisy
  if s:is_keyword(toupper(a:word))
    let s:last_word = ''
    return
  endif

  let s:last_word = a:word
  let s:last_line = a:current_line
  let s:last_bufnr = a:bufnr

  " Find the current function scope boundaries
  let [scope_start, scope_end] = s:find_function_scope(a:current_line)

  " Find all occurrences of the word within scope
  let pattern = '\<' . escape(a:word, '\') . '\>'
  let lines = getbufline(a:bufnr, scope_start, scope_end)

  for i in range(len(lines))
    let line_nr = scope_start + i
    let line_text = lines[i]
    let start = 0

    while 1
      let match_pos = matchstrpos(line_text, '\c' . pattern, start)
      if empty(match_pos[0]) || match_pos[1] == -1
        break
      endif

      " Don't highlight the word under the cursor itself (cursor already shows it)
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

" Find the start and end lines of the current function scope
" Returns [start_line, end_line] (1-indexed)
function! s:find_function_scope(current_line) abort
  let total = line('$')

  " Search upward for FUNCTION/MAIN/REPORT
  let scope_start = 1
  let i = a:current_line
  while i >= 1
    let upper = toupper(substitute(getline(i), '^\s*', '', ''))
    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      let scope_start = i
      break
    endif
    " If we hit END FUNCTION before finding an opener, we're between functions
    if upper =~# '^END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      let scope_start = i + 1
      break
    endif
    let i -= 1
  endwhile

  " Search downward for END FUNCTION/MAIN/REPORT
  let scope_end = total
  let i = a:current_line
  while i <= total
    let upper = toupper(substitute(getline(i), '^\s*', '', ''))
    if upper =~# '^END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      let scope_end = i
      break
    endif
    " If we hit another FUNCTION opener, stop before it
    if i > a:current_line && upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      let scope_end = i - 1
      break
    endif
    let i += 1
  endwhile

  return [scope_start, scope_end]
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
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
  let s:last_word = ''
endfunction
