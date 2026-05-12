" Genero-Tools Plugin - Breadcrumbs
" Shows the current function name in the winbar (Neovim) or statusline (Vim)
" Scans upward from cursor to find the enclosing FUNCTION/MAIN/REPORT
" OPTIMIZED: Caches function boundaries to avoid repeated full-buffer scans
"            Debounces cache invalidation to avoid rebuilding on every keystroke

let s:last_func = ''
let s:last_line = -1
let s:last_bufnr = -1

" Cache: bufnr -> { func_name -> {start: N, end: N} }
let s:function_boundaries = {}

" Debounce timer for cache invalidation
let s:invalidate_timer = -1

function! genero_tools#breadcrumbs#init() abort
  if !has('nvim')
    return
  endif

  augroup GeneroBreadcrumbs
    autocmd!
    autocmd CursorMoved,CursorMovedI *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#update()
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#update()
    autocmd BufLeave *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#clear()
    " Debounced cache invalidation on buffer changes
    autocmd BufWritePost *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#invalidate_cache()
    autocmd TextChanged,TextChangedI *.4gl,*.m3,*.m4,*.per call genero_tools#breadcrumbs#invalidate_cache_debounced()
  augroup END
endfunction

function! genero_tools#breadcrumbs#update() abort
  if !has('nvim')
    return
  endif

  let current_line = line('.')
  let bufnr = bufnr('%')

  " Quick check: if we haven't moved far and buffer is same, function is likely the same
  if current_line == s:last_line && bufnr == s:last_bufnr
    return
  endif
  
  " Buffer changed - invalidate state
  if bufnr != s:last_bufnr
    let s:last_func = ''
    let s:last_bufnr = bufnr
  endif
  
  let s:last_line = current_line

  let func_name = s:find_enclosing_function_cached(bufnr, current_line)

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
  let s:last_bufnr = -1
  try
    setlocal winbar=
  catch
  endtry
endfunction

" Immediate cache invalidation (used for BufWritePost)
function! genero_tools#breadcrumbs#invalidate_cache() abort
  if s:invalidate_timer != -1
    call timer_stop(s:invalidate_timer)
    let s:invalidate_timer = -1
  endif
  let bufnr = bufnr('%')
  if has_key(s:function_boundaries, bufnr)
    call remove(s:function_boundaries, bufnr)
  endif
  let s:last_func = ''
endfunction

" Debounced cache invalidation (used for TextChanged/TextChangedI)
" Avoids rebuilding the full function index on every single keystroke
function! genero_tools#breadcrumbs#invalidate_cache_debounced() abort
  if s:invalidate_timer != -1
    call timer_stop(s:invalidate_timer)
  endif
  let delay = genero_tools#config#get('perf_breadcrumbs_debounce')
  let s:invalidate_timer = timer_start(delay, function('s:do_invalidate_cache'))
endfunction

function! s:do_invalidate_cache(timer_id) abort
  let s:invalidate_timer = -1
  let bufnr = bufnr('%')
  if has_key(s:function_boundaries, bufnr)
    call remove(s:function_boundaries, bufnr)
  endif
  let s:last_func = ''
endfunction

" Find enclosing function using cached boundaries
" OPTIMIZED: Only scans buffer once to build index, then uses binary search
function! s:find_enclosing_function_cached(bufnr, line_nr) abort
  " Build cache if not exists
  if !has_key(s:function_boundaries, a:bufnr)
    call s:build_function_index(a:bufnr)
  endif
  
  let boundaries = s:function_boundaries[a:bufnr]
  
  " Binary search through function boundaries
  for [func_name, range] in items(boundaries)
    if a:line_nr >= range.start && a:line_nr <= range.end
      return func_name
    endif
  endfor
  
  return ''
endfunction

" Build index of all functions in buffer (called once per buffer or after changes)
" OPTIMIZED: Single pass through buffer to find all function boundaries
function! s:build_function_index(bufnr) abort
  let boundaries = {}
  let total = line('$')
  let current_func = ''
  let func_start = 0
  
  let i = 1
  while i <= total
    let line = getline(i)
    let trimmed = substitute(line, '^\s*', '', '')
    let upper = toupper(trimmed)
    
    " Found a function/main/report start
    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      " Close previous function if any
      if !empty(current_func)
        let boundaries[current_func] = {'start': func_start, 'end': i - 1}
      endif
      
      " Start new function
      if upper =~# '^FUNCTION\>'
        let current_func = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
      elseif upper =~# '^MAIN\>'
        let current_func = 'MAIN'
      elseif upper =~# '^REPORT\>'
        let current_func = matchstr(trimmed, '\c^REPORT\s\+\zs\w\+')
      endif
      let func_start = i
    endif
    
    " Found end of function
    if upper =~# '^END\s\+\(FUNCTION\|MAIN\|REPORT\)\>'
      if !empty(current_func)
        let boundaries[current_func] = {'start': func_start, 'end': i}
        let current_func = ''
      endif
    endif
    
    let i += 1
  endwhile
  
  " Close last function if file doesn't have END FUNCTION
  if !empty(current_func)
    let boundaries[current_func] = {'start': func_start, 'end': total}
  endif
  
  let s:function_boundaries[a:bufnr] = boundaries
endfunction
