" Genero-Tools Plugin - Debug File Streaming
" Streams debug output from debug directory in a split window

" Debug stream state
let s:debug_stream_state = {
  \ 'enabled': 0,
  \ 'window_id': -1,
  \ 'buffer_id': -1,
  \ 'file_path': '',
  \ 'last_size': 0,
  \ 'timer_id': -1,
  \ 'lines': []
  \ }

" Initialize debug streaming
function! genero_tools#debug_stream#init() abort
  " Initialize configuration
  call genero_tools#config#init_key('debug_stream_enabled', 0)
  call genero_tools#config#init_key('debug_stream_width', 33)
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
  
  " Create split window
  let width = genero_tools#config#get('debug_stream_width')
  execute 'rightbelow vsplit'
  
  " Create buffer
  let buf = nvim_create_buf(0, 1)
  call nvim_set_current_buf(buf)
  
  " Store state
  let s:debug_stream_state.enabled = 1
  let s:debug_stream_state.buffer_id = buf
  let s:debug_stream_state.window_id = nvim_get_current_win()
  let s:debug_stream_state.file_path = a:file_path
  let s:debug_stream_state.last_size = 0
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
  
  let file_path = s:debug_stream_state.file_path
  if !filereadable(file_path)
    return
  endif
  
  " Read file
  let lines = readfile(file_path)
  let current_size = len(lines)
  
  " Check if file has new content
  if current_size <= s:debug_stream_state.last_size
    return
  endif
  
  " Get new lines
  let new_lines = lines[s:debug_stream_state.last_size:]
  let s:debug_stream_state.last_size = current_size
  
  " Add to buffer
  let max_lines = genero_tools#config#get('debug_stream_max_lines')
  let all_lines = s:debug_stream_state.lines + new_lines
  
  " Trim if exceeds max
  if len(all_lines) > max_lines
    let all_lines = all_lines[-max_lines:]
  endif
  
  let s:debug_stream_state.lines = all_lines
  
  " Update buffer
  try
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:true)
    call nvim_buf_set_lines(s:debug_stream_state.buffer_id, 0, -1, 0, all_lines)
    call nvim_buf_set_option(s:debug_stream_state.buffer_id, 'modifiable', v:false)
    
    " Auto-scroll if enabled
    if genero_tools#config#get('debug_stream_auto_scroll')
      call nvim_win_set_cursor(s:debug_stream_state.window_id, [len(all_lines), 0])
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
