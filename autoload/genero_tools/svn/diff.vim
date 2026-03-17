" Genero-Tools Plugin - SVN Diff Retrieval Module
" Provides SVN diff retrieval with timeout handling and binary file detection

" Get SVN diff for a file
" Returns: dict with keys: success (bool), error (string), diff (string)
function! genero_tools#svn#diff#get_diff(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'diff': ''}
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#detection#is_available()
    return {'success': 0, 'error': genero_tools#svn#error#format_not_available(), 'diff': ''}
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_not_in_working_copy(file_path), 'diff': ''}
  endif
  
  " Execute svn diff command
  let cmd = 'svn diff ' . shellescape(file_path) . ' 2>&1'
  
  try
    let diff_output = system(cmd)
    
    if v:shell_error != 0
      " Check if it's a binary file error
      if diff_output =~? 'binary'
        return {'success': 0, 'error': genero_tools#svn#error#format_binary_file(file_path), 'diff': ''}
      endif
      
      " Check for authentication errors
      if diff_output =~? 'authentication'
        return {'success': 0, 'error': genero_tools#svn#error#format_auth_failure(), 'diff': ''}
      endif
      
      " Check for permission errors
      if diff_output =~? 'permission denied'
        return {'success': 0, 'error': genero_tools#svn#error#format_permission_denied(file_path), 'diff': ''}
      endif
      
      return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('diff', diff_output), 'diff': ''}
    endif
    
    return {'success': 1, 'error': '', 'diff': diff_output}
  catch
    return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('diff', v:exception), 'diff': ''}
  endtry
endfunction

" Get SVN diff with caching
" Returns: dict with keys: success (bool), error (string), diff (string)
function! genero_tools#svn#diff#get_diff_cached(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return {'success': 0, 'error': 'No file path provided', 'diff': ''}
  endif
  
  " Check cache first
  let cached = genero_tools#svn#cache_get(file_path)
  if !empty(cached)
    return cached.diff
  endif
  
  " Get fresh diff
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  " Cache the result if successful
  if diff_result.success
    call genero_tools#svn#cache_set(file_path, diff_result)
  endif
  
  return diff_result
endfunction

" Check if a file is binary
" Returns: 1 if binary, 0 if text
function! genero_tools#svn#diff#is_binary(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return 0
  endif
  
  " Try to get file type using file command
  let cmd = 'file ' . shellescape(file_path) . ' 2>&1'
  let output = system(cmd)
  
  " Check if output indicates binary file
  if output =~? 'binary' || output =~? 'executable'
    return 1
  endif
  
  return 0
endfunction

" Get SVN status for a file
" Returns: dict with keys: success (bool), error (string), status (string)
function! genero_tools#svn#diff#get_status(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'status': ''}
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#detection#is_available()
    return {'success': 0, 'error': genero_tools#svn#error#format_not_available(), 'status': ''}
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_not_in_working_copy(file_path), 'status': ''}
  endif
  
  " Execute svn status command
  let cmd = 'svn status ' . shellescape(file_path) . ' 2>&1'
  
  try
    let status_output = system(cmd)
    
    if v:shell_error != 0
      " Check for authentication errors
      if status_output =~? 'authentication'
        return {'success': 0, 'error': genero_tools#svn#error#format_auth_failure(), 'status': ''}
      endif
      
      " Check for permission errors
      if status_output =~? 'permission denied'
        return {'success': 0, 'error': genero_tools#svn#error#format_permission_denied(file_path), 'status': ''}
      endif
      
      return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('status', status_output), 'status': ''}
    endif
    
    return {'success': 1, 'error': '', 'status': status_output}
  catch
    return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('status', v:exception), 'status': ''}
  endtry
endfunction
