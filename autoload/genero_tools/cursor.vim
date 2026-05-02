" Genero-Tools Plugin - Unified Cursor Event Dispatcher
" Single CursorMoved handler that dispatches to all subsystems
" Reduces overhead from 6 separate autocommand calls to 1

let s:last_line = -1
let s:last_col = -1
let s:last_bufnr = -1
let s:last_word = ''

" Debounce timer for expensive operations
let s:expensive_timer = -1

function! genero_tools#cursor#init() abort
  augroup GeneroCursorDispatch
    autocmd!
    autocmd CursorMoved *.4gl,*.m3,*.m4,*.per call genero_tools#cursor#on_moved()
    autocmd CursorMovedI *.4gl,*.m3,*.m4,*.per call genero_tools#cursor#on_moved_insert()
    autocmd InsertEnter *.4gl,*.m3,*.m4,*.per call genero_tools#cursor#on_insert_enter()
    autocmd BufLeave *.4gl,*.m3,*.m4,*.per call genero_tools#cursor#on_buf_leave()
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#cursor#on_buf_enter()
  augroup END
endfunction

" Main CursorMoved handler — runs once, dispatches to subsystems
function! genero_tools#cursor#on_moved() abort
  let bufnr = bufnr('%')
  let current_line = line('.')
  let current_col = col('.')
  let word = expand('<cword>')

  let line_changed = current_line != s:last_line || bufnr != s:last_bufnr
  let col_changed = current_col != s:last_col
  let word_changed = word !=# s:last_word || line_changed

  " === CHEAP operations (run every CursorMoved, but only if line changed) ===

  if line_changed
    " Block matching — keywords (IF/END IF etc.)
    call genero_tools#block_match#on_line_changed(bufnr, current_line)

    " Inline diagnostics — just extmark lookup from cached data
    if has('nvim')
      call genero_tools#compiler#inline_diagnostics#on_line_changed(bufnr, current_line)
    endif

    " Hints current-line-only virtual text
    if has('nvim')
      call genero_tools#hints#display#on_line_changed(bufnr, current_line)
    endif

    " Refcount — only if on a FUNCTION line (very cheap check)
    if has('nvim')
      call genero_tools#refcount#on_line_changed(bufnr, current_line)
    endif
  endif

  " Quote matching — needs to run on column changes too (moving within a line)
  if line_changed || col_changed
    call genero_tools#block_match#check_quotes(bufnr, current_line)
  endif

  " === EXPENSIVE operations (debounced, only if word changed) ===

  if word_changed && has('nvim')
    " Cancel pending expensive timer
    if s:expensive_timer != -1
      call timer_stop(s:expensive_timer)
      let s:expensive_timer = -1
    endif

    " Clear stale type info immediately
    call genero_tools#compiler#type_info#on_word_changed(word, bufnr, current_line)

    " Schedule expensive lookup after 400ms
    " Allow short words on FUNCTION definition lines (signature shown for whole line)
    let on_func_line = (toupper(substitute(getline(current_line), '^\s*', '', '')) =~# '^FUNCTION\>')
    if !empty(word) && (len(word) >= 3 || on_func_line)
      let s:expensive_timer = timer_start(400, function('s:expensive_lookup', [word, bufnr, current_line]))
    endif
  endif

  let s:last_line = current_line
  let s:last_col = current_col
  let s:last_bufnr = bufnr
  let s:last_word = word
endfunction

" CursorMovedI — only update hints and breadcrumbs (lightweight)
function! genero_tools#cursor#on_moved_insert() abort
  let current_line = line('.')
  if current_line != s:last_line
    let bufnr = bufnr('%')
    if has('nvim')
      call genero_tools#hints#display#on_line_changed(bufnr, current_line)
    endif
    let s:last_line = current_line
  endif
endfunction

" Expensive debounced callback — type info lookup
function! s:expensive_lookup(word, bufnr, line, timer_id) abort
  let s:expensive_timer = -1
  " Verify cursor hasn't moved
  if expand('<cword>') !=# a:word || bufnr('%') != a:bufnr || line('.') != a:line
    return
  endif
  call genero_tools#compiler#type_info#do_lookup(a:word, a:bufnr, a:line)
endfunction

" InsertEnter — clear all visual overlays
function! genero_tools#cursor#on_insert_enter() abort
  if s:expensive_timer != -1
    call timer_stop(s:expensive_timer)
    let s:expensive_timer = -1
  endif
  call genero_tools#block_match#clear()
  if has('nvim')
    call genero_tools#compiler#type_info#clear()
    call genero_tools#compiler#inline_diagnostics#clear()
    call genero_tools#refcount#clear()
  endif
endfunction

" BufLeave — clear everything
function! genero_tools#cursor#on_buf_leave() abort
  if s:expensive_timer != -1
    call timer_stop(s:expensive_timer)
    let s:expensive_timer = -1
  endif
  call genero_tools#block_match#clear()
  if has('nvim')
    call genero_tools#compiler#type_info#clear()
    call genero_tools#compiler#inline_diagnostics#clear()
    call genero_tools#refcount#clear()
  endif
  let s:last_line = -1
  let s:last_bufnr = -1
  let s:last_word = ''
endfunction

" BufEnter — reset state
function! genero_tools#cursor#on_buf_enter() abort
  let s:last_line = -1
  let s:last_bufnr = -1
  let s:last_word = ''
endfunction
