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

  call nvim_buf_clear_namespace(bufnr, s:ns_id, 0, -1)

  let result = genero_tools#compiler#get_buffer_result(bufnr)
  if empty(result)
    return
  endif

  " Errors: always show full text on every error line
  for error in get(result, 'errors', [])
    let lnum = get(error, 'line', 0)
    if lnum > 0
      try
        call nvim_buf_set_extmark(bufnr, s:ns_id, lnum - 1, 0, {
          \ 'virt_text': [['  ✕ ' . error.message . ' ', 'GeneroInlineError']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 100
          \ })
      catch
      endtry
    endif
  endfor

  " Warnings: only show on current cursor line
  for warning in get(result, 'warnings', [])
    if get(warning, 'line', 0) == current_line
      try
        call nvim_buf_set_extmark(bufnr, s:ns_id, current_line - 1, 0, {
          \ 'virt_text': [['  ▸ ' . warning.message . ' ', 'GeneroInlineWarning']],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 90
          \ })
      catch
      endtry
    endif
  endfor

  " Info: only show on current cursor line
  for info_item in get(result, 'info', [])
    if get(info_item, 'line', 0) == current_line
      try
        call nvim_buf_set_extmark(bufnr, s:ns_id, current_line - 1, 0, {
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
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction
