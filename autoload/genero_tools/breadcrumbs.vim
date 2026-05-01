" Genero-Tools Plugin - Breadcrumbs
" Shows the current function name in the winbar (Neovim) or statusline (Vim)
" Scans upward from cursor to find the enclosing FUNCTION/MAIN/REPORT

let s:last_func = ''
let s:last_line = -1

function! genero_tools#breadcrumbs#init() abort
  if !has('nvim')
    return
  endif

  augroup GeneroBreadcrumbs
    autocmd!
    autocmd CursorMoved,CursorMovedI *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#update()
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#update()
    autocmd BufLeave *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#clear()
  augroup END
endfunction

function! genero_tools#breadcrumbs#update() abort
  if !has('nvim')
    return
  endif

  let current_line = line('.')

  " Quick check: if we haven't moved far, the function is likely the same
  if current_line == s:last_line
    return
  endif
  let s:last_line = current_line

  let func_name = s:find_enclosing_function(current_line)

  if func_name ==# s:last_func
    return
  endif
  let s:last_func = func_name

  if empty(func_name)
    setlocal winbar=
  else
    let file = expand('%:t')
    let &l:winbar = '%#Comment# ' . file . ' > %*%#Function# ' . func_name . ' %*'
  endif
endfunction

function! genero_tools#breadcrumbs#clear() abort
  let s:last_func = ''
  let s:last_line = -1
  try
    setlocal winbar=
  catch
  endtry
endfunction

" Scan upward from cursor to find the enclosing FUNCTION/MAIN/REPORT
function! s:find_enclosing_function(line_nr) abort
  let i = a:line_nr

  while i >= 1
    let line = getline(i)
    let trimmed = substitute(line, '^\s*', '', '')
    let upper = toupper(trimmed)

    " Match FUNCTION name(...) or MAIN or REPORT name(...)
    if upper =~# '^FUNCTION\>'
      return matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
    elseif upper =~# '^MAIN\>'
      return 'MAIN'
    elseif upper =~# '^REPORT\>'
      return matchstr(trimmed, '\c^REPORT\s\+\zs\w\+')
    endif

    let i -= 1
  endwhile

  return ''
endfunction
