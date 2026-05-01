" Genero-Tools Plugin - Block Matching Highlights
" Highlights matching block pairs: IF/END IF, FOR/END FOR, FUNCTION/END FUNCTION, etc.
" Neovim only for extmark highlights

let s:ns_id = -1
let s:last_line = -1
let s:last_bufnr = -1

" Block openers and their END patterns
" Each entry: [opener_keyword, end_pattern_for_regex]
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

function! genero_tools#block_match#init() abort
  if has('nvim')
    let s:ns_id = nvim_create_namespace('genero_block_match')
  endif

  if !hlexists('GeneroBlockMatch')
    highlight GeneroBlockMatch guibg=#2a2a3a guifg=NONE gui=underline ctermbg=236 ctermfg=NONE cterm=underline
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
          call s:highlight_line(a:bufnr, match_line)
          call s:highlight_line(a:bufnr, a:current_line)
        endif
        return
      endif
    endfor
    return
  endif

  " Check if line starts with a block opener — find the closer
  for [opener, end_pattern] in s:block_types
    if upper =~# '^' . opener . '\>'
      let match_line = s:find_closer(a:current_line, opener, end_pattern)
      if match_line > 0
        call s:highlight_line(a:bufnr, match_line)
        call s:highlight_line(a:bufnr, a:current_line)
      endif
      return
    endif
  endfor
endfunction

" Find the opening block for an END statement (search upward)
function! s:find_opener(end_line, opener, end_pattern) abort
  let nesting = 1
  let i = a:end_line - 1

  while i >= 1
    let line = getline(i)
    let upper = toupper(substitute(line, '^\s*', '', ''))

    " Check for another END of the same type (increases nesting)
    if upper =~# '^' . a:end_pattern . '\>'
      let nesting += 1
    " Check for opener (decreases nesting)
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

    " Check for another opener of the same type (increases nesting)
    if upper =~# '^' . a:opener . '\>'
      let nesting += 1
    " Check for END of the same type (decreases nesting)
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
