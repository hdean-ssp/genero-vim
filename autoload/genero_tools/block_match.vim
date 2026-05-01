" Genero-Tools Plugin - Block Matching Highlights
" Highlights matching block keywords: IF/ELSE/END IF, FOR/END FOR, etc.
" Highlights just the keyword text, not the whole line
" Neovim only

let s:ns_id = -1
let s:last_line = -1
let s:last_bufnr = -1

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
  endif

  " Keyword-only highlight — subtle colored background on just the keyword
  if !hlexists('GeneroBlockMatch')
    highlight GeneroBlockMatch guifg=#c0c8d0 guibg=#3a3a50 gui=bold ctermbg=60 ctermfg=252 cterm=bold
  endif

  if !hlexists('GeneroBlockMatchPair')
    highlight GeneroBlockMatchPair guifg=#c0c8d0 guibg=#3a3a50 gui=bold ctermbg=60 ctermfg=252 cterm=bold
  endif
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

  while i >= 1
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

  while i <= total
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

function! genero_tools#block_match#clear() abort
  let s:last_line = -1
  let s:last_bufnr = -1

  if has('nvim') && s:ns_id != -1
    try
      call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
    catch
    endtry
  endif
endfunction
