" Genero-Tools Plugin - Navigation Module
" Go to definition, peek definition, and related navigation features

" Go to definition: jump to the file and line where a function is defined
" Uses find-function data (file + line_start)
function! genero_tools#navigation#goto_definition(...) abort
  let word = a:0 > 0 && !empty(a:1) ? a:1 : expand('<cword>')

  if empty(word)
    call genero_tools#error#warn('navigation', 'No word under cursor')
    return
  endif

  " Push current position to jumplist so user can jump back with Ctrl+O
  normal! m'

  " Try cache first
  let cache_key = 'find-function:' . word
  let cached = genero_tools#cache#get(cache_key)
  let result = {}

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let result = cached
  else
    let result = genero_tools#command#execute_shell('find-function', [word])
    if result.success && !empty(result.data)
      call genero_tools#cache#set(cache_key, result)
    endif
  endif

  if !result.success || empty(result.data)
    " Not a function — try local DEFINE (jump to the DEFINE line)
    let define_info = s:find_local_define(word)
    if !empty(define_info)
      execute define_info.line
      normal! zz
      echom 'DEFINE ' . word . ' (line ' . define_info.line . ')'
      return
    endif
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  " Extract function info
  let func = s:pick_function(result.data, word)
  if empty(func)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let file = get(func, 'file', '')
  let line_nr = get(func, 'line_start', get(func, 'line', 0))

  if empty(file)
    call genero_tools#error#warn('navigation', 'No file location for: ' . word)
    return
  endif

  " Resolve file path relative to codebase root
  let full_path = s:resolve_path(file)

  " Open the file and jump to the line
  try
    if full_path !=# expand('%:p')
      execute 'edit ' . fnameescape(full_path)
    endif
    if line_nr > 0
      execute line_nr
    endif
    normal! zz
    echom 'Jumped to ' . word . ' (' . fnamemodify(full_path, ':t') . ':' . line_nr . ')'
  catch
    call genero_tools#error#warn('navigation', 'Failed to open: ' . full_path . ' — ' . v:exception)
  endtry
endfunction

" Peek definition: show function body in a floating window without leaving current position
function! genero_tools#navigation#peek_definition(...) abort
  if !has('nvim')
    " Fall back to goto for Vim
    call call('genero_tools#navigation#goto_definition', a:000)
    return
  endif

  let word = a:0 > 0 && !empty(a:1) ? a:1 : expand('<cword>')

  if empty(word)
    call genero_tools#error#warn('navigation', 'No word under cursor')
    return
  endif

  " Try cache first
  let cache_key = 'find-function:' . word
  let cached = genero_tools#cache#get(cache_key)
  let result = {}

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let result = cached
  else
    let result = genero_tools#command#execute_shell('find-function', [word])
    if result.success && !empty(result.data)
      call genero_tools#cache#set(cache_key, result)
    endif
  endif

  if !result.success || empty(result.data)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let func = s:pick_function(result.data, word)
  if empty(func)
    call genero_tools#error#warn('navigation', 'Definition not found: ' . word)
    return
  endif

  let file = get(func, 'file', '')
  let line_start = get(func, 'line_start', get(func, 'line', 1))
  let line_end = get(func, 'line_end', line_start + 20)

  if empty(file)
    call genero_tools#error#warn('navigation', 'No file location for: ' . word)
    return
  endif

  " Read the function body from the file
  let full_path = s:resolve_path(file)
  let preview_end = min([line_end, line_start + 30])  " Cap at 30 lines

  try
    let file_lines = readfile(full_path, '', preview_end)
    if line_start > 0
      let file_lines = file_lines[line_start - 1:]
    endif
  catch
    call genero_tools#error#warn('navigation', 'Cannot read: ' . full_path)
    return
  endtry

  if empty(file_lines)
    call genero_tools#error#warn('navigation', 'Empty function body')
    return
  endif

  " Add header
  let header = '── ' . word . ' ── ' . fnamemodify(full_path, ':t') . ':' . line_start . ' ──'
  let display_lines = [header, ''] + file_lines

  " Show in floating window
  call s:show_peek_window(display_lines, word)
endfunction

" Show peek floating window
function! s:show_peek_window(lines, title) abort
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, a:lines)

  " Try to set filetype for syntax highlighting
  call nvim_buf_set_option(buf, 'filetype', 'fgl')

  " Calculate dimensions
  let max_width = 0
  for line in a:lines
    let max_width = max([max_width, strdisplaywidth(line)])
  endfor
  let width = min([max([max_width + 2, 60], 40), &columns - 4])
  let height = min([len(a:lines), 25, &lines - 4])

  let row = (&lines - height) / 2
  let col = (&columns - width) / 2

  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'col': col,
    \ 'row': row,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' ' . a:title . ' ',
    \ 'title_pos': 'center'
    \ }

  let win = nvim_open_win(buf, v:true, opts)

  " Set window options
  call nvim_win_set_option(win, 'cursorline', v:true)
  call nvim_win_set_option(win, 'wrap', v:false)

  " Keybindings to close the peek window
  call nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {'noremap': v:true, 'silent': v:true})

  " Make buffer non-modifiable
  call nvim_buf_set_option(buf, 'modifiable', v:false)
endfunction

" Pick the best matching function from results
function! s:pick_function(data, word) abort
  if type(a:data) == type([]) && !empty(a:data)
    for item in a:data
      if type(item) == type({}) && get(item, 'name', '') ==? a:word
        return item
      endif
    endfor
    if type(a:data[0]) == type({})
      return a:data[0]
    endif
  elseif type(a:data) == type({})
    return a:data
  endif
  return {}
endfunction

" Resolve a file path relative to codebase root
function! s:resolve_path(file) abort
  let file = a:file

  " If already absolute, use as-is
  if file[0] == '/'
    return file
  endif

  " Strip leading ./
  if file[0:1] == './'
    let file = file[2:]
  endif

  " Try relative to codebase root
  let root = genero_tools#codebase#get_root()
  let candidate = root . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Try relative to current working directory
  let candidate = getcwd() . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Try as-is
  if filereadable(file)
    return fnamemodify(file, ':p')
  endif

  " Return best guess
  return root . '/' . file
endfunction

" Find a local DEFINE for a variable (simple upward scan in current buffer)
function! s:find_local_define(word) abort
  let pattern = '\c^\s*DEFINE\>.*\<' . escape(a:word, '\') . '\>'
  let line_nr = line('.')

  " Search upward
  while line_nr > 0
    let line_text = getline(line_nr)
    let upper = toupper(substitute(line_text, '^\s*', '', ''))

    " Stop at function boundary
    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    if line_text =~? pattern
      return {'line': line_nr}
    endif

    let line_nr -= 1
  endwhile

  " Search module-level defines
  let line_nr = 1
  while line_nr <= line('$')
    let line_text = getline(line_nr)
    let upper = toupper(substitute(line_text, '^\s*', '', ''))

    if upper =~# '^\(FUNCTION\|MAIN\|REPORT\)\>'
      break
    endif

    if line_text =~? pattern
      return {'line': line_nr}
    endif

    let line_nr += 1
  endwhile

  return {}
endfunction
