" Genero-Tools Plugin - Command Execution Engine

" Execute a genero-tools shell command
function! genero_tools#command#execute_shell(command, args) abort
  let tool_path = genero_tools#config#get('genero_tools_path')
  let timeout = genero_tools#config#get('timeout')
  
  " Build command line: query.sh <command> <arg1> <arg2> ...
  let cmd_line = tool_path . ' ' . a:command
  
  " Add arguments
  for arg in a:args
    let escaped_arg = genero_tools#command#escape_arg(arg)
    let cmd_line .= ' ' . escaped_arg
  endfor
  
  " Execute command with timeout
  let start_time = localtime()
  let result = {
    \ 'success': 0,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  try
    " Show progress for async operations
    if genero_tools#config#get('async_enabled')
      call genero_tools#progress#show('Executing genero-tools: ' . a:command)
    endif
    
    " Execute system command
    let output = system(cmd_line)
    let exit_code = v:shell_error
    let elapsed = localtime() - start_time
    
    " Hide progress
    if genero_tools#config#get('async_enabled')
      call genero_tools#progress#hide()
    endif
    
    " Show elapsed time for commands taking >2 seconds (Requirement 17.4, 17.7)
    if elapsed > 2
      call genero_tools#progress#show_elapsed('Command completed', start_time)
    endif
    
    " Check for errors
    if exit_code != 0
      let result.error = genero_tools#error#format_from_output(output, a:command)
      return result
    endif
    
    " Parse JSON output
    try
      let data = json_decode(output)
      let result.success = 1
      let result.data = data
      let result.error = ''
      
      " Check if result set is too large (Requirement 17.1)
      let size_error = genero_tools#error#check_result_size(data)
      if !empty(size_error)
        let result.error = size_error
        let result.success = 0
        return result
      endif
      
    catch
      let result.error = genero_tools#error#format_parse_error(v:exception)
      return result
    endtry
    
  catch
    let result.error = genero_tools#error#format_from_output(v:exception, a:command)
  endtry
  
  let result.timestamp = localtime()
  return result
endfunction

" Execute a genero-tools command (legacy - kept for compatibility)
function! genero_tools#command#execute(command, args, codebase_path) abort
  let tool_path = genero_tools#config#get('genero_tools_path')
  let timeout = genero_tools#config#get('timeout')
  
  " Build command line
  let cmd_line = tool_path . ' ' . a:command
  
  " Add arguments
  for [key, value] in items(a:args)
    let escaped_value = genero_tools#command#escape_arg(value)
    let cmd_line .= ' --' . key . ' ' . escaped_value
  endfor
  
  " Add codebase path
  let escaped_codebase = genero_tools#command#escape_arg(a:codebase_path)
  let cmd_line .= ' --codebase ' . escaped_codebase
  
  " Execute command with timeout
  let start_time = localtime()
  let result = {
    \ 'success': 0,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  try
    " Show progress for async operations
    if genero_tools#config#get('async_enabled')
      call genero_tools#progress#show('Executing genero-tools command...')
    endif
    
    " Execute system command
    let output = system(cmd_line)
    let exit_code = v:shell_error
    
    " Hide progress
    if genero_tools#config#get('async_enabled')
      call genero_tools#progress#hide()
    endif
    
    " Check for errors
    if exit_code != 0
      let result.error = genero_tools#error#format_from_output(output, a:command)
      return result
    endif
    
    " Parse JSON output
    try
      let data = json_decode(output)
      let result.success = 1
      let result.data = data
      let result.error = ''
      
      " Check if result set is too large
      let size_error = genero_tools#error#check_result_size(data)
      if !empty(size_error)
        let result.error = size_error
        let result.success = 0
        return result
      endif
      
    catch
      let result.error = genero_tools#error#format_parse_error(v:exception)
      return result
    endtry
    
  catch
    let result.error = genero_tools#error#format_from_output(v:exception, a:command)
  endtry
  
  let result.timestamp = localtime()
  return result
endfunction

" Escape argument for shell execution
function! genero_tools#command#escape_arg(arg) abort
  " Escape single quotes and wrap in single quotes
  let escaped = substitute(a:arg, "'", "'\\\\''", 'g')
  return "'" . escaped . "'"
endfunction
