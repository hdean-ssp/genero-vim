" Genero-Tools Plugin - Block Matching Highlights
" Highlights matching block keywords: IF/ELSE/END IF, FOR/END FOR, etc.
" Highlights just the keyword text, not the whole line
" Neovim only

let s:ns_id = -1
let s:quote_ns_id = -1
let s:last_line = -1
let s:last_bufnr = -1
let s:last_quote_col = -1

" Block openers and their END patterns
let s:block_types = [
  \ ['FUNCTION',  'END\s\+FUNCTION'],
  \ ['MAIN',      'END\s\+MAIN'],
  \ ['REPORT',    'END\s\+REPORT'],
  \ ['IF',        'END\s\+IF'],
  \ ['FOR',       'END\s\+FOR'],
  \ ['FOREACH',   'END\s\+FOREACH'],
  \ ['WHILE',     'END\s\+WHILE'],
  \ ['CASE',      'END\s\+CASE'],
  \ ['MENU',      'END\s\+MENU'],
  \ ['INPUT',     'END\s\+INPUT'],
  \ ['DIALOG',    'END\s\+DIALOG'],
  \ ['CONSTRUCT', 'END\s\+CONSTRUCT'],
  \ ['DISPLAY',   'END\s\+DISPLAY'],
  \ ]

" Keywords that belong to an IF block (between IF and END IF)
let s:if_inner_keywords = ['ELSE', 'WHEN']

function! genero_tools#block_match#init() abort
  if has('nvim')
    let s:ns_id = nvim_create_namespace('genero_block_match')
    let s:quote_ns_id = nvim_create_namespace('genero_quote_match')
  endif

  " Keyword-only highlight — background only, preserve syntax foreground
  " Use highlight! to force override any existing definition
  highlight! GeneroBlockMatch guifg=NONE guibg=#2e3450 gui=NONE ctermbg=60 ctermfg=NONE cterm=NONE
  highlight! GeneroBlockMatchPair guifg=NONE guibg=#2e3450 gui=NONE ctermbg=60 ctermfg=NONE cterm=NONE
endfunction

" Called by cursor dispatcher when line changes
function! genero_tools#block_match#on_line_changed(bufnr, current_line) abort
  if a:current_line == s:last_line && a:bufnr == s:last_bufnr
    return
  endif

  call genero_tools#block_match#clear()
  let s:last_line = a:current_line
  let s:last_bufnr = a:bufnr

  let line_text = getline(a:current_line)
  let trimmed = substitute(line_text, '^\s*', '', '')
  let upper = toupper(trimmed)

  " Check if line starts with END — find the opener
  if upper =~# '^END\s\+'
    for [opener, end_pattern] in s:block_types
      if upper =~# '^' . end_pattern . '\>'
        let match_line = s:find_opener(a:current_line, opener, end_pattern)
        if match_line > 0
          call s:highlight_keyword(a:bufnr, a:current_line)
          call s:highlight_keyword(a:bufnr, match_line)
        endif
        return
      endif
    endfor
    return
  endif

  " Check if line starts with ELSE — highlight the enclosing IF and END IF
  if upper =~# '^ELSE\>'
    let if_line = s:find_opener(a:current_line, 'IF', 'END\s\+IF')
    let endif_line = s:find_closer(a:current_line, 'IF', 'END\s\+IF')
    if if_line > 0
      call s:highlight_keyword(a:bufnr, if_line)
    endif
    call s:highlight_keyword(a:bufnr, a:current_line)
    if endif_line > 0
      call s:highlight_keyword(a:bufnr, endif_line)
    endif
    return
  endif

  " Check if line starts with WHEN (inside CASE) — highlight CASE and END CASE
  if upper =~# '^WHEN\>'
    let case_line = s:find_opener(a:current_line, 'CASE', 'END\s\+CASE')
    let endcase_line = s:find_closer(a:current_line, 'CASE', 'END\s\+CASE')
    if case_line > 0
      call s:highlight_keyword(a:bufnr, case_line)
    endif
    call s:highlight_keyword(a:bufnr, a:current_line)
    if endcase_line > 0
      call s:highlight_keyword(a:bufnr, endcase_line)
    endif
    return
  endif

  " Check if line starts with a block opener — find the closer
  for [opener, end_pattern] in s:block_types
    if upper =~# '^' . opener . '\>'
      let match_line = s:find_closer(a:current_line, opener, end_pattern)
      if match_line > 0
        call s:highlight_keyword(a:bufnr, a:current_line)
        call s:highlight_keyword(a:bufnr, match_line)
        " For IF blocks, also highlight ELSE lines between
        if opener ==# 'IF'
          call s:highlight_inner_keywords(a:bufnr, a:current_line, match_line, 'IF', 'END\s\+IF')
        endif
        " For CASE blocks, highlight WHEN lines
        if opener ==# 'CASE'
          call s:highlight_inner_keywords(a:bufnr, a:current_line, match_line, 'CASE', 'END\s\+CASE')
        endif
      endif
      return
    endif
  endfor
endfunction

" Highlight inner keywords (ELSE inside IF, WHEN inside CASE) at the same nesting level
function! s:highlight_inner_keywords(bufnr, open_line, close_line, opener, end_pattern) abort
  let nesting = 0
  let i = a:open_line + 1

  while i < a:close_line
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    " Track nesting — only highlight at nesting level 0
    if upper =~# '^' . a:opener . '\>'
      let nesting += 1
    elseif upper =~# '^' . a:end_pattern . '\>'
      let nesting -= 1
    elseif nesting == 0
      if upper =~# '^ELSE\>' || upper =~# '^WHEN\>'
        call s:highlight_keyword(a:bufnr, i)
      endif
    endif

    let i += 1
  endwhile
endfunction

" Find the opening block for an END/ELSE statement (search upward)
function! s:find_opener(end_line, opener, end_pattern) abort
  let nesting = 1
  let i = a:end_line - 1
  let max_lines = genero_tools#config#get('perf_block_match_max_lines')
  let min_line = max([1, a:end_line - max_lines])

  while i >= min_line
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    if upper =~# '^' . a:end_pattern . '\>'
      let nesting += 1
    elseif upper =~# '^' . a:opener . '\>'
      let nesting -= 1
      if nesting == 0
        return i
      endif
    endif

    let i -= 1
  endwhile

  return 0
endfunction

" Find the closing block for an opener statement (search downward)
function! s:find_closer(open_line, opener, end_pattern) abort
  let nesting = 1
  let i = a:open_line + 1
  let total = line('$')
  let max_lines = genero_tools#config#get('perf_block_match_max_lines')
  let max_line = min([total, a:open_line + max_lines])

  while i <= max_line
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    if upper =~# '^' . a:opener . '\>'
      let nesting += 1
    elseif upper =~# '^' . a:end_pattern . '\>'
      let nesting -= 1
      if nesting == 0
        return i
      endif
    endif

    let i += 1
  endwhile

  return 0
endfunction

" Highlight just the keyword at the start of a line (not the whole line)
function! s:highlight_keyword(bufnr, line_nr) abort
  if !has('nvim') || s:ns_id == -1
    return
  endif

  let line_text = getline(a:line_nr)

  " Find the leading whitespace to get the keyword start column
  let indent_len = matchend(line_text, '^\s*')
  if indent_len == -1
    let indent_len = 0
  endif

  " Find the keyword end — first keyword word(s) on the line
  let trimmed = strpart(line_text, indent_len)
  let upper = toupper(trimmed)

  " Determine keyword length
  let kw_len = 0
  if upper =~# '^END\s\+\w\+'
    " END IF, END FOR, etc. — highlight both words
    let kw_len = matchend(upper, '^END\s\+\w\+')
  elseif upper =~# '^\w\+'
    " Single keyword: IF, FOR, ELSE, WHEN, FUNCTION, etc.
    let kw_len = matchend(upper, '^\w\+')
  endif

  if kw_len == 0
    return
  endif

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line_nr - 1, indent_len, {
      \ 'end_col': indent_len + kw_len,
      \ 'hl_group': 'GeneroBlockMatch',
      \ 'priority': 200
      \ })
  catch
  endtry
endfunction

" Public entry point for quote matching — called by cursor dispatcher on every col change
function! genero_tools#block_match#check_quotes(bufnr, current_line) abort
  if !has('nvim') || s:quote_ns_id == -1
    return
  endif

  let cursor_col = col('.') - 1

  " Skip if same position
  if cursor_col == s:last_quote_col && a:current_line == s:last_line
    return
  endif
  let s:last_quote_col = cursor_col

  " Clear previous quote highlights
  try
    call nvim_buf_clear_namespace(a:bufnr, s:quote_ns_id, 0, -1)
  catch
  endtry

  call s:do_quote_match(a:bufnr, a:current_line, cursor_col)
endfunction

" Check if cursor is near a quote and highlight the matching one
function! s:do_quote_match(bufnr, current_line, cursor_col) abort
  let line_text = getline(a:current_line)

  " Check if cursor is on or adjacent to a quote character
  let char_at = a:cursor_col < len(line_text) ? line_text[a:cursor_col] : ''
  let char_before = a:cursor_col > 0 ? line_text[a:cursor_col - 1] : ''

  let quote_char = ''
  let quote_col = -1

  if char_at == '"' || char_at == "'"
    let quote_char = char_at
    let quote_col = a:cursor_col
  elseif char_before == '"' || char_before == "'"
    let quote_char = char_before
    let quote_col = a:cursor_col - 1
  endif

  if empty(quote_char)
    return
  endif

  " Count quotes before this position on the current line to determine if opening or closing
  let count_before = 0
  let i = 0
  while i < quote_col
    if line_text[i] == quote_char && (i == 0 || line_text[i - 1] != '\')
      let count_before += 1
    endif
    let i += 1
  endwhile

  " Even count = this is an opening quote, odd count = this is a closing quote
  let is_opening = count_before % 2 == 0

  if is_opening
    " Search forward for the closing quote (same line first, then subsequent lines)
    let match_pos = s:find_closing_quote(a:current_line, quote_col, quote_char)
  else
    " Search backward for the opening quote
    let match_pos = s:find_opening_quote(a:current_line, quote_col, quote_char)
  endif

  if !empty(match_pos)
    " Highlight both quotes
    call s:highlight_char(a:bufnr, a:current_line, quote_col)
    call s:highlight_char(a:bufnr, match_pos.line, match_pos.col)
  endif
endfunction

" Find the closing quote starting after the given position
function! s:find_closing_quote(start_line, start_col, quote_char) abort
  let line_text = getline(a:start_line)

  " Search on the same line first
  let i = a:start_col + 1
  while i < len(line_text)
    if line_text[i] == a:quote_char && (i == 0 || line_text[i - 1] != '\')
      return {'line': a:start_line, 'col': i}
    endif
    let i += 1
  endwhile

  " Search subsequent lines (multi-line strings)
  let max_search = min([a:start_line + 50, line('$')])
  let line_nr = a:start_line + 1
  while line_nr <= max_search
    let line_text = getline(line_nr)
    let i = 0
    while i < len(line_text)
      if line_text[i] == a:quote_char && (i == 0 || line_text[i - 1] != '\')
        return {'line': line_nr, 'col': i}
      endif
      let i += 1
    endwhile
    let line_nr += 1
  endwhile

  return {}
endfunction

" Find the opening quote searching backward from the given position
function! s:find_opening_quote(start_line, start_col, quote_char) abort
  let line_text = getline(a:start_line)

  " Search backward on the same line
  let i = a:start_col - 1
  while i >= 0
    if line_text[i] == a:quote_char && (i == 0 || line_text[i - 1] != '\')
      return {'line': a:start_line, 'col': i}
    endif
    let i -= 1
  endwhile

  " Search previous lines (multi-line strings)
  let min_search = max([a:start_line - 50, 1])
  let line_nr = a:start_line - 1
  while line_nr >= min_search
    let line_text = getline(line_nr)
    " Search from end of line backward
    let i = len(line_text) - 1
    while i >= 0
      if line_text[i] == a:quote_char && (i == 0 || line_text[i - 1] != '\')
        return {'line': line_nr, 'col': i}
      endif
      let i -= 1
    endwhile
    let line_nr -= 1
  endwhile

  return {}
endfunction

" Highlight a single character at a specific position (quote matching)
function! s:highlight_char(bufnr, line_nr, col) abort
  if !has('nvim') || s:quote_ns_id == -1
    return
  endif

  try
    call nvim_buf_set_extmark(a:bufnr, s:quote_ns_id, a:line_nr - 1, a:col, {
      \ 'end_col': a:col + 1,
      \ 'hl_group': 'GeneroBlockMatch',
      \ 'priority': 200
      \ })
  catch
  endtry
endfunction

function! genero_tools#block_match#clear() abort
  let s:last_line = -1
  let s:last_bufnr = -1
  let s:last_quote_col = -1

  if has('nvim') && s:ns_id != -1
    try
      call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
    catch
    endtry
  endif

  if has('nvim') && s:quote_ns_id != -1
    try
      call nvim_buf_clear_namespace(bufnr('%'), s:quote_ns_id, 0, -1)
    catch
    endtry
  endif
endfunction
