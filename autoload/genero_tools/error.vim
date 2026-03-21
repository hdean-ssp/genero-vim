" Genero-Tools Plugin - Error Handling Module
" Provides standardized error message formatting and display
" Error message format: [MODULE] Error description

" Error message format: [MODULE] Error description
function! genero_tools#error#format(module, message) abort
  return '[' . a:module . '] ' . a:message
endfunction

" Echo error message
function! genero_tools#error#echo(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  call genero_tools#display#echo(l:formatted)
endfunction

" Display warning message
function! genero_tools#error#warn(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl WarningMsg
  echo l:formatted
  echohl None
endfunction

" Display error message (legacy - use display_error for new code)
function! genero_tools#error#error(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl ErrorMsg
  echo l:formatted
  echohl None
endfunction

" Display error with display mode support (Phase 7)
function! genero_tools#error#display(error_message, details) abort
  let display_mode = genero_tools#display#get_mode('error')
  
  let formatted = [a:error_message]
  
  if !empty(a:details)
    call add(formatted, '')
    call add(formatted, 'Details:')
    call add(formatted, '--------')
    
    if type(a:details) == type([])
      call extend(formatted, a:details)
    else
      call add(formatted, a:details)
    endif
  endif
  
  if genero_tools#config#get('error_show_details')
    call add(formatted, '')
    call add(formatted, 'For more information, check the debug log.')
  endif
  
  call genero_tools#display#result({'success': 0, 'data': formatted}, display_mode)
endfunction

" Display error with title and details (Phase 7)
function! genero_tools#error#display_detailed(title, error_message, details) abort
  let display_mode = genero_tools#display#get_mode('error')
  
  let formatted = [a:title]
  call add(formatted, repeat('=', len(a:title)))
  call add(formatted, '')
  call add(formatted, 'Error: ' . a:error_message)
  
  if !empty(a:details)
    call add(formatted, '')
    call add(formatted, 'Details:')
    call add(formatted, '--------')
    
    if type(a:details) == type([])
      call extend(formatted, a:details)
    else
      call add(formatted, a:details)
    endif
  endif
  
  if genero_tools#config#get('error_show_details')
    call add(formatted, '')
    call add(formatted, 'For more information, check the debug log.')
  endif
  
  call genero_tools#display#result({'success': 0, 'data': formatted}, display_mode)
endfunction

" Log debug message (if debug mode enabled)
function! genero_tools#error#debug(module, message) abort
  if genero_tools#config#get('debug_mode')
    let l:formatted = genero_tools#error#format(a:module, a:message)
    call genero_tools#debug#log(l:formatted)
  endif
endfunction

" Create error result dictionary
function! genero_tools#error#result(module, message) abort
  return {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': genero_tools#error#format(a:module, a:message),
    \ 'timestamp': localtime()
    \ }
endfunction

" Format error from command output
function! genero_tools#error#format_from_output(output, command) abort
  if empty(a:output)
    return genero_tools#error#format('Command', 'Command "' . a:command . '" failed with no output')
  endif
  
  " Try to extract error message from output
  let lines = split(a:output, '\n')
  let error_msg = ''
  
  " Look for error patterns in output
  for line in lines
    if line =~? 'error\|failed\|exception'
      let error_msg = line
      break
    endif
  endfor
  
  " If no error pattern found, use first non-empty line
  if empty(error_msg)
    for line in lines
      if !empty(line)
        let error_msg = line
        break
      endif
    endfor
  endif
  
  " Fallback to generic message
  if empty(error_msg)
    let error_msg = 'Command "' . a:command . '" failed'
  endif
  
  return genero_tools#error#format('Command', error_msg)
endfunction

" Format parse error
function! genero_tools#error#format_parse_error(exception) abort
  return genero_tools#error#format('Parser', 'Failed to parse command output: ' . a:exception)
endfunction

" Check if result size exceeds limits
function! genero_tools#error#check_result_size(data) abort
  " Check if data is a list and exceeds reasonable size (e.g., 10000 items)
  if type(a:data) == type([])
    if len(a:data) > 10000
      return genero_tools#error#format('Result', 'Result set too large (' . len(a:data) . ' items). Consider refining your search.')
    endif
  endif
  
  return ''
endfunction
