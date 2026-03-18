" Genero-Tools Plugin - Error Handling Module
" Provides error message formatting and guidance for various failure scenarios

" Log an error message
function! genero_tools#error#log(message) abort
  echomsg '[genero-tools] ' . a:message
endfunction

" Format error for resource not found
function! genero_tools#error#format_not_found(resource_type, resource_name) abort
  let message = 'Error: ' . a:resource_type . ' not found: ' . a:resource_name
  let guidance = 'Tip: Check the spelling and ensure the ' . a:resource_type . ' exists in the codebase.'
  return message . "\n" . guidance
endfunction

" Format error for invalid path
function! genero_tools#error#format_invalid_path(path) abort
  let message = 'Error: Invalid path: ' . a:path
  let guidance = 'Tip: Ensure the path is correct and the file/directory exists.'
  return message . "\n" . guidance
endfunction

" Format error for timeout with guidance for large codebases (Requirement 17.2)
function! genero_tools#error#format_timeout(command) abort
  let message = 'Error: Command timed out: ' . a:command
  let guidance = [
    \ 'Tip: The search took too long. For large codebases, try:',
    \ '  1. Use a more specific search term (e.g., "myFunc" instead of "func")',
    \ '  2. Filter by module name (e.g., "mymodule.m3:myFunc")',
    \ '  3. Filter by file path (e.g., "src/myfile.4gl:myFunc")',
    \ '  4. Increase timeout in config: let g:genero_tools_config.timeout = 20000',
    \ '  5. Enable async mode: let g:genero_tools_config.async_enabled = 1',
    \ '  6. For very large codebases (6M+ LOC), consider increasing to 30000ms'
    \ ]
  return message . "\n" . join(guidance, "\n")
endfunction

" Format error for JSON parse failure
function! genero_tools#error#format_parse_error(error_detail) abort
  let message = 'Error: Failed to parse genero-tools output'
  let guidance = 'Tip: This may indicate a genero-tools version mismatch or corrupted output.'
  let detail = 'Details: ' . a:error_detail
  return message . "\n" . guidance . "\n" . detail
endfunction

" Format error for permission denied
function! genero_tools#error#format_permission_denied(resource) abort
  let message = 'Error: Permission denied accessing: ' . a:resource
  let guidance = 'Tip: Check file permissions and ensure you have read access to the codebase.'
  return message . "\n" . guidance
endfunction

" Format error for result too large (Requirement 17.1)
function! genero_tools#error#format_result_too_large(result_count, limit) abort
  let message = 'Error: Too many results (' . a:result_count . ' > ' . a:limit . ')'
  let guidance = [
    \ 'Tip: The search returned too many results. For large codebases, try:',
    \ '  1. Use a more specific search term (e.g., "myFunc" instead of "func")',
    \ '  2. Filter by module name (e.g., "mymodule.m3:myFunc")',
    \ '  3. Filter by file path (e.g., "src/myfile.4gl:myFunc")',
    \ '  4. Increase result_limit in config: let g:genero_tools_config.result_limit = 2000',
    \ '  5. Use pagination to view results in smaller chunks'
    \ ]
  return message . "\n" . join(guidance, "\n")
endfunction

" Detect error type from command output and return formatted message
function! genero_tools#error#format_from_output(output, command) abort
  let output_lower = tolower(a:output)
  
  " Check for timeout
  if output_lower =~? 'timeout\|timed out'
    return genero_tools#error#format_timeout(a:command)
  endif
  
  " Check for not found
  if output_lower =~? 'not found\|no such\|does not exist'
    return genero_tools#error#format_not_found('resource', a:command)
  endif
  
  " Check for permission denied
  if output_lower =~? 'permission denied\|access denied'
    return genero_tools#error#format_permission_denied(a:command)
  endif
  
  " Check for invalid path
  if output_lower =~? 'invalid path\|bad path'
    return genero_tools#error#format_invalid_path(a:command)
  endif
  
  " Default: return as-is with generic guidance
  return 'Error: ' . a:output . "\n" . 'Tip: Check genero-tools configuration and codebase path.'
endfunction

" Check if result set is too large and return formatted error if needed
function! genero_tools#error#check_result_size(result_data) abort
  let limit = genero_tools#config#get('result_limit')
  
  " Handle different result data structures
  if type(a:result_data) == type([])
    let count = len(a:result_data)
  elseif type(a:result_data) == type({})
    if has_key(a:result_data, 'results')
      let count = len(a:result_data.results)
    elseif has_key(a:result_data, 'functions')
      let count = len(a:result_data.functions)
    elseif has_key(a:result_data, 'files')
      let count = len(a:result_data.files)
    else
      return ''
    endif
  else
    return ''
  endif
  
  if count > limit
    return genero_tools#error#format_result_too_large(count, limit)
  endif
  
  return ''
endfunction
