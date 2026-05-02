" Genero-Tools Plugin - Find References
" Shows all callers of a function via Telescope picker (with file preview)
" Falls back to a floating window if Telescope is not available
" Leverages find-function-dependents (same data as refcount, but displayed)

let s:ref_win = -1
let s:ref_buf = -1
let s:ref_data = []

" Find references for the function under cursor (or on the current FUNCTION line)
function! genero_tools#references#find(...) abort
  let func_name = a:0 > 0 && !empty(a:1) ? a:1 : s:get_function_name()

  if empty(func_name)
    call genero_tools#error#warn('references', 'No function name under cursor')
    return
  endif

  " Check refcount cache first — if we already fetched dependents, reuse the count
  " But we need the full data, not just the count, so always query
  let cache_key = 'find-function-dependents:' . func_name
  let cached = genero_tools#cache#get(cache_key)
  let data = []

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let data = cached.data
  else
    let result = genero_tools#command#execute_shell('find-function-dependents', [func_name])
    if !result.success || empty(result.data)
      call genero_tools#error#warn('references', 'No references found for: ' . func_name)
      return
    endif
    let data = result.data
    call genero_tools#cache#set(cache_key, result)
  endif

  if type(data) != type([]) || empty(data)
    call genero_tools#error#warn('references', 'No references found for: ' . func_name)
    return
  endif

  " Try Telescope picker first (Neovim + Telescope available)
  if has('nvim')
    try
      let data_json = json_encode(data)
      let handled = luaeval('require("genero_tools.references").find(_A[1], _A[2])', [func_name, data_json])
      if handled
        return
      endif
    catch
      " Telescope not available or error — fall through to floating window
    endtry
  endif

  " Fallback: floating window
  let s:ref_data = data
  let lines = s:format_references(func_name, data)
  call s:show_references_window(lines, func_name, len(data))
endfunction

" Extract function name from context
" Works when cursor is on a FUNCTION line, on a function call, or on the refcount virtual text
function! s:get_function_name() abort
  " Check if cursor is on a FUNCTION definition line
  let line_text = getline('.')
  let trimmed = substitute(line_text, '^\s*', '', '')
  let upper = toupper(trimmed)

  if upper =~# '^FUNCTION\>'
    let name = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
    if !empty(name)
      return name
    endif
  endif

  " Fall back to word under cursor (e.g., on a function call)
  return expand('<cword>')
endfunction

" Format reference data into display lines
function! s:format_references(func_name, data) abort
  let lines = []
  let idx = 0

  for ref in a:data
    let idx += 1

    " Extract fields — query.sh returns: name, signature, path, line_number
    let caller_name = get(ref, 'name', get(ref, 'function', get(ref, 'caller', '?')))
    let file = get(ref, 'path', get(ref, 'file', get(ref, 'file_path', '')))
    let line_nr = get(ref, 'line_number', get(ref, 'line', get(ref, 'line_start', '')))
    let module = get(ref, 'module', '')

    " Handle line as dict (some query.sh responses use {start, end})
    if type(line_nr) == type({})
      let line_nr = get(line_nr, 'start', '')
    endif

    " Build display line
    let display = printf('  %2d  ', idx)

    if !empty(caller_name)
      let display .= caller_name
    endif

    if !empty(file)
      let short_file = fnamemodify(file, ':t')
      let display .= '  ' . short_file
      if !empty(line_nr)
        let display .= ':' . line_nr
      endif
    endif

    if !empty(module)
      let display .= '  [' . module . ']'
    endif

    call add(lines, display)
  endfor

  return lines
endfunction

" Show references in a floating window with navigation
function! s:show_references_window(lines, func_name, count) abort
  call s:close_references_window()

  let header = a:count == 1
    \ ? '1 reference to ' . a:func_name
    \ : a:count . ' references to ' . a:func_name
  let separator = repeat('─', len(header) + 4)
  let footer = '  Enter: jump  q/Esc: close'

  let all_lines = ['  ' . header, separator] + a:lines + ['', footer]

  " Calculate dimensions
  let max_width = 0
  for line in all_lines
    let max_width = max([max_width, strdisplaywidth(line)])
  endfor
  let width = max([max_width + 4, 50])
  let width = min([width, &columns - 4])
  let height = min([len(all_lines), 30, &lines - 4])

  let row = (&lines - height) / 2
  let col = (&columns - width) / 2

  let s:ref_buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(s:ref_buf, 0, -1, v:false, all_lines)

  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'col': col,
    \ 'row': row,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' References ',
    \ 'title_pos': 'center'
    \ }

  let s:ref_win = nvim_open_win(s:ref_buf, v:true, opts)

  call nvim_win_set_option(s:ref_win, 'cursorline', v:true)
  call nvim_win_set_option(s:ref_win, 'wrap', v:false)

  " Position cursor on first reference line (skip header + separator)
  call cursor(3, 1)

  " Keybindings
  call nvim_buf_set_keymap(s:ref_buf, 'n', 'q', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(s:ref_buf, 'n', '<Esc>', ':close<CR>', {'noremap': v:true, 'silent': v:true})
  call nvim_buf_set_keymap(s:ref_buf, 'n', '<CR>',
    \ ':call genero_tools#references#jump_to_reference()<CR>',
    \ {'noremap': v:true, 'silent': v:true})

  call nvim_buf_set_option(s:ref_buf, 'modifiable', v:false)
endfunction

" Jump to the reference under the cursor
function! genero_tools#references#jump_to_reference() abort
  " Line 1 = header, line 2 = separator, references start at line 3
  let cursor_line = line('.')
  let ref_index = cursor_line - 3  " 0-based index into s:ref_data

  if ref_index < 0 || ref_index >= len(s:ref_data)
    return
  endif

  let ref = s:ref_data[ref_index]
  let file = get(ref, 'path', get(ref, 'file', get(ref, 'file_path', '')))
  let line_nr = get(ref, 'line_number', get(ref, 'line', get(ref, 'line_start', 0)))

  " Handle line as dict
  if type(line_nr) == type({})
    let line_nr = get(line_nr, 'start', 0)
  endif

  if empty(file)
    call genero_tools#error#warn('references', 'No file location for this reference')
    return
  endif

  " Close the references window
  call s:close_references_window()

  " Resolve the file path
  let full_path = s:resolve_ref_path(file)

  " Push current position to jumplist
  normal! m'

  " Open the file
  if expand('%:p') !=# full_path
    execute 'edit ' . fnameescape(full_path)
  endif

  " Jump to line if available
  if line_nr > 0
    execute line_nr
    normal! zz
  endif
endfunction

" Resolve a file path from query.sh output to an absolute path
function! s:resolve_ref_path(file) abort
  let file = a:file

  " Already absolute
  if file[0] ==# '/'
    return file
  endif

  " Strip leading ./
  if file[0:1] ==# './'
    let file = file[2:]
  endif

  " Try relative to codebase root
  let root = genero_tools#codebase#get_root()
  if !empty(root)
    let candidate = root . '/' . file
    if filereadable(candidate)
      return candidate
    endif
  endif

  " Try relative to CWD
  let candidate = getcwd() . '/' . file
  if filereadable(candidate)
    return candidate
  endif

  " Return as-is and let Vim resolve it
  return file
endfunction

" Close the references floating window
function! s:close_references_window() abort
  if s:ref_win != -1
    try
      call nvim_win_close(s:ref_win, v:true)
    catch
    endtry
    let s:ref_win = -1
  endif
  if s:ref_buf != -1
    try
      execute 'bwipeout! ' . s:ref_buf
    catch
    endtry
    let s:ref_buf = -1
  endif
endfunction
