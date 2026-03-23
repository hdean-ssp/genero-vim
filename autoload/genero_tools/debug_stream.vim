" Genero-Tools Plugin - Debug File Streaming
" Streams debug output from debug directory in a split window

" Debug stream state
let s:debug_stream_state = {
  \ 'enabled': 0,
  \ 'window_id': -1,
  \ 'buffer_id': -1,
  \ 'file_path': '',
  \ 'last_size': 0,
  \ 'last_mtime': 0,
  \ 'timer_id': -1,
  \ 'lines': []
  \ }

" Initialize debug streaming
function! genero_tools#debug_stream#init() abort
  " Initialize configuration
  call genero_tools#config#init_key('debug_stream_enabled', 0)
  call genero_tools#config#init_key('debug_stream_width', 0)
  call genero_tools#config#init_key('debug_stream_max_lines', 1000)
  call genero_tools#config#init_key('debug_stream_auto_scroll', 1)
  call genero_tools#config#init_key('debug_stream_directory', './debug')
endfunction

" Start debug streaming
function! genero_tools#debug_stream#start(file_path) abort
  if s:debug_stream_state.enabled
    call genero_tools#debug_stream#stop()
  endif
  
  " Validate file exists
  if !filereadable(a:file_path)
    call genero_tools#error#log('Debug file not found: ' . a:file_path)
    return
  endif
  
  " Create split window with configured width (1/3 of screen if not set)
  let width = genero_tools#config#get('debug_stream_width')
  if width <= 0
    " Calculate 1/3 of available width, minimum 50 columns
    let available_width = &columns
    let width = max([available_width / 3, 50])
  endif
  
  " Create the split
  execute 'rightbelow ' . width . 'vsplit'
  
  " Explicitly set the window width
  execute 'vertical resize ' . width
  
  " Create buffer
  let buf = nvim_create_buf(0, 1)
  call nvim_set_current_buf(buf)
  
  " Store state
  let s:debug_stream_state.enabled = 1
  let s:debug_stream_state.buffer_id = buf
  let s:debug_stream_state.window_id = nvim_get_current_win()
  let s:debug_stream_state.file_path = a:file_path
  let s:debug_stream_state.last_size = 0
  let s:debug_stream_state.last_mtime = 0
  let s:debug_stream_state.lines = []
  
  " Set buffer options
  call nvim_buf_set_option(buf, 'buftype', 'nofile')
  call nvim_buf_set_option(buf, 'modifiable', v:false)
  call nvim_buf_set_option(buf, 'swapfile', v:false)
  
  " Set window options
  call nvim_win_set_option(s:debug_stream_state.window_id, 'wrap', v:true)
  call nvim_win_set_option(s:debug_stream_state.window_id, 'number', v:true)
  
  " Set buffer name with timestamp to ensure uniqueness
  let buf_name = 'debug-stream: ' . fnamemodify(a:file_path, ':t')
  try
    call nvim_buf_set_name(buf, buf_name)
  catch /E95/
    " Buffer name already exists, use a unique name
    call nvim_buf_set_name(buf, buf_name . ' [' . localtime() . ']')
  endtry
  
  " Start file watcher timer
  let s:debug_stream_state.timer_id = timer_start(500, function('s:update_debug_stream'), {'repeat': -1})
  
  " Initial read
  call s:update_debug_stream(s:debug_stream_state.timer_id)
  
  call genero_tools#display#echo('Debug streaming started: ' . a:file_path)
endfunction

" Stop debug streaming
function! genero_tools#debug_stream#stop() abort
  if !s:debug_stream_state.enabled
    return
  endif
  
  " Stop timer
  if s:debug_stream_state.timer_id != -1
    call timer_stop(s:debug_stream_state.timer_id)
    let s:debug_stream_state.timer_id = -1
  endif
  
  " Close window
  if s:debug_stream_state.window_id != -1
    try
      call nvim_win_close(s:debug_stream_state.window_id, 1)
    catch
    endtry
    let s:debug_stream_state.window_id = -1
  endif
  
  " Reset state
  let s:debug_stream_state.enabled = 0
  let s:debug_stream_state.buffer_id = -1
  let s:debug_stream_state.file_path = ''
  let s:debug_stream_state.last_size = 0
  let s:debug_stream_state.last_mtime = 0
  let s:debug_stream_state.lines = []
  
  call genero_tools#display#echo('Debug streaming stopped')
endfunction

" Toggle debug streaming
function! genero_tools#debug_stream#toggle(file_path) abort
  if s:debug_stream_state.enabled
    call genero_tools#debug_stream#stop()
  else
    call genero_tools#debug_stream#start(a:file_path)
  endif
endfunction

" Update debug stream from file
function! s:update_debug_stream(timer_id) abort
  if !s:debug_stream_state.enabled
    return
  endif
  
  " Validate buffer still exists
  if !nvim_buf_is_valid(s:debug_stream_state.buffer_id)
    let s:debug_stream_state.enabled = 0
    return
  endif
  
  let file_path = s:debug_stream_state.file_path
  if !filereadable(file_path)
    return
  endif
  
  " Check file modification time
  let file_stat = getfperm(file_path)
  let file_mtime = getftime(file_path)
  
  " If file hasn't been modified, skip update
  if file_mtime == s:debug_stream_state.last_mtime
    return
  endif
  
  let s:debug_stream_state.last_mtime = file_mtime
  
  " Read file
  let lines = readfile(file_path)
  let current_size = len(lines)
  
  " Add to buffer
  let max_lines = genero_tools#config#get('debug_stream_max_lines')
  let all_lines = lines
  
  " Trim if exceeds max
  if len(all_lines) > max_lines
    let all_lines = all_lines[-max_lines:]
  endif
  
  let s:debug_stream_state.lines = all_lines
  let s:debug_stream_state.last_size = current_size
  
  " Update buffer
  try
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:true)
    call nvim_buf_set_lines(s:debug_stream_state.buffer_id, 0, -1, 0, all_lines)
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:false)
    
    " Auto-scroll to end (always keep focus on final line)
    let line_count = len(all_lines)
    if line_count > 0
      call nvim_win_set_cursor(s:debug_stream_state.window_id, [line_count, 0])
    endif
  catch
    " Silently ignore if buffer is closed
  endtry
endfunction

" Clear debug stream
function! genero_tools#debug_stream#clear() abort
  if !s:debug_stream_state.enabled
    return
  endif
  
  let s:debug_stream_state.lines = []
  let s:debug_stream_state.last_size = 0
  
  try
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:true)
    call nvim_buf_set_lines(s:debug_stream_state.buffer_id, 0, -1, 0, [])
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:false)
  catch
  endtry
  
  call genero_tools#display#echo('Debug stream cleared')
endfunction

" Get debug stream status
function! genero_tools#debug_stream#status() abort
  return {
    \ 'enabled': s:debug_stream_state.enabled,
    \ 'file': s:debug_stream_state.file_path,
    \ 'lines': len(s:debug_stream_state.lines),
    \ 'window_id': s:debug_stream_state.window_id
    \ }
endfunction

" Select debug file from directory
function! genero_tools#debug_stream#select_file() abort
  let debug_dir = genero_tools#config#get('debug_stream_directory')
  
  " Expand path
  let debug_dir = expand(debug_dir)
  
  " Check if directory exists
  if !isdirectory(debug_dir)
    call genero_tools#error#log('Debug directory not found: ' . debug_dir)
    return
  endif
  
  " Get list of files in debug directory
  let files = glob(debug_dir . '/*', 0, 1)
  
  " Filter to only files (not directories)
  let files = filter(files, '!isdirectory(v:val)')
  
  if empty(files)
    call genero_tools#error#log('No files found in debug directory: ' . debug_dir)
    return
  endif
  
  " Sort by modification time (most recent first)
  let files = sort(files, function('s:sort_by_mtime'))
  
  " Get just the filenames
  let file_names = map(copy(files), 'fnamemodify(v:val, ":t")')
  
  " Create floating window for selection
  call s:show_file_selector(file_names, files)
endfunction

" Sort files by modification time (most recent first)
function! s:sort_by_mtime(a, b) abort
  let mtime_a = getftime(a:a)
  let mtime_b = getftime(a:b)
  return mtime_b - mtime_a
endfunction

" File selector state
let s:file_selector_state = {
  \ 'file_paths': [],
  \ 'file_names': [],
  \ 'selected_index': 0,
  \ 'buffer_id': -1,
  \ 'window_id': -1
  \ }

" Show file selector using floating window with navigation
function! s:show_file_selector(file_names, file_paths) abort
  " Store file paths and names
  let s:file_selector_state.file_paths = a:file_paths
  let s:file_selector_state.file_names = a:file_names
  let s:file_selector_state.selected_index = 0
  
  " Format file list with numbering for display
  let formatted_list = []
  for idx in range(len(a:file_names))
    let line_num = idx + 1
    call add(formatted_list, printf('%2d. %s', line_num, a:file_names[idx]))
  endfor
  
  " Create buffer for file list
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, formatted_list)
  
  " Calculate window dimensions
  let width = min([80, &columns - 4])
  let height = min([len(formatted_list) + 2, &lines - 4])
  let row = (&lines - height) / 2
  let col = (&columns - width) / 2
  
  " Create floating window
  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'row': row,
    \ 'col': col,
    \ 'style': 'minimal',
    \ 'border': 'rounded',
    \ 'title': ' Debug Stream Files '
    \ }
  
  let win = nvim_open_win(buf, v:true, opts)
  
  " Store window and buffer IDs
  let s:file_selector_state.buffer_id = buf
  let s:file_selector_state.window_id = win
  
  " Set buffer options
  call nvim_buf_set_option(buf, 'modifiable', v:false)
  call nvim_buf_set_option(buf, 'buftype', 'nofile')
  call nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  " Setup keybindings for selection
  call s:setup_file_selector_keybindings()
  
  " Highlight first item
  call s:highlight_selected_file()
endfunction

" Setup keybindings for file selector
function! s:setup_file_selector_keybindings() abort
  " Enter to select
  nnoremap <buffer> <CR> :call <SID>select_file()<CR>
  
  " Escape to cancel
  nnoremap <buffer> <Esc> :call <SID>close_file_selector()<CR>
  
  " j/k or arrow keys to navigate
  nnoremap <buffer> j :call <SID>next_file()<CR>
  nnoremap <buffer> k :call <SID>prev_file()<CR>
  nnoremap <buffer> <Down> :call <SID>next_file()<CR>
  nnoremap <buffer> <Up> :call <SID>prev_file()<CR>
  
  " Mouse click to select
  nnoremap <buffer> <LeftMouse> :call <SID>mouse_select_file()<CR>
endfunction

" Select current file
function! s:select_file() abort
  let index = s:file_selector_state.selected_index
  let file_paths = s:file_selector_state.file_paths
  
  if index < 0 || index >= len(file_paths)
    return
  endif
  
  let selected_file = file_paths[index]
  
  " Close the selector
  call s:close_file_selector()
  
  " Start debug streaming with selected file
  call genero_tools#debug_stream#start(selected_file)
endfunction

" Navigate to next file in list
function! s:next_file() abort
  let max_index = len(s:file_selector_state.file_paths) - 1
  if s:file_selector_state.selected_index < max_index
    let s:file_selector_state.selected_index += 1
    call s:highlight_selected_file()
  endif
endfunction

" Navigate to previous file in list
function! s:prev_file() abort
  if s:file_selector_state.selected_index > 0
    let s:file_selector_state.selected_index -= 1
    call s:highlight_selected_file()
  endif
endfunction

" Handle mouse click selection
function! s:mouse_select_file() abort
  let line = line('.') - 1
  if line >= 0 && line < len(s:file_selector_state.file_paths)
    let s:file_selector_state.selected_index = line
    call s:select_file()
  endif
endfunction

" Highlight the currently selected file
function! s:highlight_selected_file() abort
  if s:file_selector_state.window_id == -1
    return
  endif
  
  try
    " Clear previous highlights
    call nvim_buf_clear_namespace(s:file_selector_state.buffer_id, -1, 0, -1)
    
    " Highlight current line
    let line = s:file_selector_state.selected_index
    call nvim_buf_add_highlight(
      \ s:file_selector_state.buffer_id,
      \ -1,
      \ 'CursorLine',
      \ line,
      \ 0,
      \ -1
      \ )
    
    " Move cursor to selected line
    call nvim_win_set_cursor(s:file_selector_state.window_id, [line + 1, 0])
  catch
    " Silently handle highlight errors
  endtry
endfunction

" Close file selector
function! s:close_file_selector() abort
  if s:file_selector_state.window_id != -1
    try
      call nvim_win_close(s:file_selector_state.window_id, v:true)
    catch
      " Window already closed
    endtry
    let s:file_selector_state.window_id = -1
    let s:file_selector_state.buffer_id = -1
  endif
endfunction

" Prompt user to select a file (legacy - kept for compatibility)
function! s:prompt_file_selection() abort
  " This function is no longer used - file selection is now done via floating window
  " Kept for backward compatibility
endfunction
