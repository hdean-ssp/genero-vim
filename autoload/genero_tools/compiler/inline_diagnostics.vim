" Genero-Tools Plugin - Inline Diagnostics Virtual Text
" Errors: always show full text on all error lines
" Warnings/Info: only show on current cursor line
" Neovim only

let s:ns_id = -1

function! genero_tools#compiler#inline_diagnostics#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_compiler_inline_diag')

  if !hlexists('GeneroInlineError')
    highlight GeneroInlineError guifg=#b05050 guibg=#1e2030 gui=italic ctermfg=DarkRed ctermbg=234
  endif

  if !hlexists('GeneroInlineWarning')
    highlight GeneroInlineWarning guifg=#a08050 guibg=#1e2030 gui=italic ctermfg=DarkYellow ctermbg=234
  endif

  if !hlexists('GeneroInlineInfo')
    highlight GeneroInlineInfo guifg=#5080a0 guibg=#1e2030 gui=italic ctermfg=DarkCyan ctermbg=234
  endif
endfunction

" Called by cursor dispatcher when line changes
function! genero_tools#compiler#inline_diagnostics#on_line_changed(bufnr, current_line) abort
  if !genero_tools#config#get('compiler_inline_diagnostics')
    return
  endif
  call genero_tools#compiler#inline_diagnostics#update()
endfunction

function! genero_tools#compiler#inline_diagnostics#update() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#config#get('compiler_inline_diagnostics')
    call genero_tools#compiler#inline_diagnostics#clear()
    return
  endif

  if s:ns_id == -1
    let s:ns_id = nvim_create_namespace('genero_compiler_inline_diag')
  endif

  let bufnr = bufnr('%')
  let current_line = line('.')

  let result = genero_tools#compiler#get_buffer_result(bufnr)
  if empty(result)
    call nvim_buf_clear_namespace(bufnr, s:ns_id, 0, -1)
    return
  endif

  " Incremental mode: only update the lines that change (warnings/info follow cursor)
  " Errors are static — only redraw them if the result set changed
  if genero_tools#config#get('perf_inline_diag_incremental_update')
    call s:incremental_diag_update(bufnr, current_line, result)
  else
    " Legacy: clear all and redraw
    call nvim_buf_clear_namespace(bufnr, s:ns_id, 0, -1)
    call s:draw_all_diagnostics(bufnr, current_line, result)
  endif
endfunction

" Track state for incremental diagnostics
let s:diag_prev_line = -1
let s:diag_errors_drawn = 0

" Incremental update: errors are drawn once and left alone,
" warnings/info only update when cursor line changes
function! s:incremental_diag_update(bufnr, current_line, result) abort
  let prev_line = s:diag_prev_line
  let s:diag_prev_line = a:current_line

  " If errors haven't been drawn yet (first call or after clear), do full draw
  if !s:diag_errors_drawn
    call nvim_buf_clear_namespace(a:bufnr, s:ns_id, 0, -1)
    call s:draw_all_diagnostics(a:bufnr, a:current_line, a:result)
    let s:diag_errors_drawn = 1
    return
  endif

  " Only update if cursor line actually changed
  if prev_line == a:current_line
    return
  endif

  " Clear extmarks on the previous and current lines (warnings/info move with cursor)
  if prev_line > 0
    try
      call nvim_buf_clear_namespace(a:bufnr, s:ns_id, prev_line - 1, prev_line)
    catch
    endtry
    " Re-place error on previous line if there was one
    for error in get(a:result, 'errors', [])
      if get(error, 'line', 0) == prev_line
        try
          call nvim_buf_set_extmark(a:bufnr, s:ns_id, prev_line - 1, 0, {
            \ 'virt_text': [['  ✕ ' . error.message . ' ', 'GeneroInlineError']],
            \ 'virt_text_pos': 'eol',
            \ 'priority': 100
            \ })
        catch
        endtry
      endif
    endfor
  endif

  " Clear current line and redraw with warning/info if applicable
  try
    call nvim_buf_clear_namespace(a:bufnr, s:ns_id, a:current_line - 1, a:current_line)
  catch
  endtry

  " Re-place error on current line if there is one
  for error in get(a:result, 'errors', [])
    if get(error, 'line', 0) == a:current_line
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:current_line - 1, 0, {
          \ 'virt_text': [['  ✕ ' . error.message . ' ', 'GeneroInlineError']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 100
          \ })
      catch
      endtry
    endif
  endfor

  " Show warning on current line
  for warning in get(a:result, 'warnings', [])
    if get(warning, 'line', 0) == a:current_line
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:current_line - 1, 0, {
          \ 'virt_text': [['  ▸ ' . warning.message . ' ', 'GeneroInlineWarning']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 90
          \ })
      catch
      endtry
    endif
  endfor

  " Show info on current line
  for info_item in get(a:result, 'info', [])
    if get(info_item, 'line', 0) == a:current_line
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:current_line - 1, 0, {
          \ 'virt_text': [['  ℹ ' . info_item.message . ' ', 'GeneroInlineInfo']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 80
          \ })
      catch
      endtry
    endif
  endfor
endfunction

" Draw all diagnostics (used for initial draw and legacy mode)
function! s:draw_all_diagnostics(bufnr, current_line, result) abort
  " Errors: always show full text on every error line
  for error in get(a:result, 'errors', [])
    let lnum = get(error, 'line', 0)
    if lnum > 0
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, lnum - 1, 0, {
          \ 'virt_text': [['  ✕ ' . error.message . ' ', 'GeneroInlineError']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 100
          \ })
      catch
      endtry
    endif
  endfor

  " Warnings: only show on current cursor line
  for warning in get(a:result, 'warnings', [])
    if get(warning, 'line', 0) == a:current_line
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:current_line - 1, 0, {
          \ 'virt_text': [['  ▸ ' . warning.message . ' ', 'GeneroInlineWarning']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 90
          \ })
      catch
      endtry
    endif
  endfor

  " Info: only show on current cursor line
  for info_item in get(a:result, 'info', [])
    if get(info_item, 'line', 0) == a:current_line
      try
        call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:current_line - 1, 0, {
          \ 'virt_text': [['  ℹ ' . info_item.message . ' ', 'GeneroInlineInfo']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 80
          \ })
      catch
      endtry
    endif
  endfor
endfunction

function! genero_tools#compiler#inline_diagnostics#clear() abort
  if !has('nvim') || s:ns_id == -1
    return
  endif
  let s:diag_prev_line = -1
  let s:diag_errors_drawn = 0
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction
