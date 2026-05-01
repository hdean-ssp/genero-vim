" Genero-Tools Plugin - Block Matching Highlights
" Highlights matching block pairs: IF/END IF, FOR/END FOR, FUNCTION/END FUNCTION, etc.
" Neovim only for extmark highlights; Vim gets matchaddpos fallback

let s:ns_id = -1
let s:last_line = -1
let s:last_bufnr = -1

" Block pairs: opener → closer pattern
let s:block_pairs = {
  \ 'IF':        'END\s\+IF',
  \ 'FOR':       'END\s\+FOR',
  \ 'WHILE':     'END\s\+WHILE',
  \ 'CASE':      'END\s\+CASE',
  \ 'FUNCTION':  'END\s\+FUNCTION',
  \ 'MAIN':      'END\s\+MAIN',
  \ 'REPORT':    'END\s\+REPORT',
  \ 'MENU':      'END\s\+MENU',
  \ 'INPUT':     'END\s\+INPUT',
  \ 'DIALOG':    'END\s\+DIALOG',
  \ 'CONSTRUCT': 'END\s\+CONSTRUCT',
  \ 'FOREACH':   'END\s\+FOREACH',
  \ 'DISPLAY':   'END\s\+DISPLAY',
  \ }

function! genero_tools#block_match#init() abort
  if has('nvim')
    let s:ns_id = nvim_create_namespace('genero_block_match')
  endif

  if !hlexists('GeneroBlockMatch')
    highlight GeneroBlockMatch guibg=#2a2a3a guifg=NONE gui=underline ctermbg=236 ctermfg=NONE cterm=underline
  endif

  " Autocommands are handled by the unified cursor dispatcher (cursor.vim)
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

  " Check if cursor is on an END block
  if upper =~# '^END\s\+'
    let match_line = s:find_opener(a:current_line, upper)
    if match_line > 0
      call s:highlight_line(a:bufnr, match_line)
      call s:highlight_line(a:bufnr, a:current_line)
    endif
    return
  endif

  " Check if cursor is on an opener block
  for [opener, closer_pattern] in items(s:block_pairs)
    if upper =~# '^\V' . opener . '\v\>'
      let match_line = s:find_closer(a:current_line, opener, closer_pattern)
      if match_line > 0
        call s:highlight_line(a:bufnr, match_line)
        call s:highlight_line(a:bufnr, a:current_line)
      endif
      return
    endif
  endfor
endfunction

" Find the opening block for an END statement
function! s:find_opener(end_line, upper_text) abort
  " Determine which block type this END closes
  let block_type = ''
  for [opener, closer_pattern] in items(s:block_pairs)
    if a:upper_text =~# '^\V' . closer_pattern
      let block_type = opener
      break
    endif
  endfor

  if empty(block_type)
    return 0
  endif

  let closer_pattern = s:block_pairs[block_type]
  let nesting = 1
  let i = a:end_line - 1

  while i >= 1
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    " Check for closer (increases nesting)
    if upper =~# '^\V' . closer_pattern
      let nesting += 1
    " Check for opener (decreases nesting)
    elseif upper =~# '^\V' . block_type . '\v\>'
      let nesting -= 1
      if nesting == 0
        return i
      endif
    endif

    let i -= 1
  endwhile

  return 0
endfunction

" Find the closing block for an opener statement
function! s:find_closer(open_line, opener, closer_pattern) abort
  let nesting = 1
  let i = a:open_line + 1
  let total = line('$')

  while i <= total
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    " Check for opener (increases nesting)
    if upper =~# '^\V' . a:opener . '\v\>'
      let nesting += 1
    " Check for closer (decreases nesting)
    elseif upper =~# '^\V' . a:closer_pattern
      let nesting -= 1
      if nesting == 0
        return i
      endif
    endif

    let i += 1
  endwhile

  return 0
endfunction

" Highlight a line
function! s:highlight_line(bufnr, line_nr) abort
  if has('nvim') && s:ns_id != -1
    try
      call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line_nr - 1, 0, {
        \ 'line_hl_group': 'GeneroBlockMatch',
        \ 'priority': 20
        \ })
    catch
    endtry
  endif
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
