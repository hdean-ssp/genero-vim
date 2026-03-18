" Genero-Tools Plugin - SVN Error Handling Module
" Provides comprehensive error handling and messages for SVN operations

" Format error message for SVN not available
function! genero_tools#svn#error#format_not_available() abort
  return 'SVN is not installed or not available in PATH. Please install SVN to use diff markers.'
endfunction

" Format error message for file not in working copy
function! genero_tools#svn#error#format_not_in_working_copy(file_path) abort
  return 'File ' . a:file_path . ' is not in an SVN working copy.'
endfunction

" Format error message for binary file
function! genero_tools#svn#error#format_binary_file(file_path) abort
  return 'File ' . a:file_path . ' is a binary file. SVN diff markers not available for binary files.'
endfunction

" Format error message for SVN command failure
function! genero_tools#svn#error#format_svn_failure(command, error_msg) abort
  return 'SVN ' . a:command . ' failed: ' . a:error_msg
endfunction

" Format error message for authentication failure
function! genero_tools#svn#error#format_auth_failure() abort
  return 'SVN authentication failed. Please check your SVN credentials and try again.'
endfunction

" Format error message for permission denied
function! genero_tools#svn#error#format_permission_denied(file_path) abort
  return 'Permission denied accessing ' . a:file_path . '. Check file permissions.'
endfunction

" Format error message for no file open
function! genero_tools#svn#error#format_no_file() abort
  return 'No file is currently open. Open a file to use SVN diff markers.'
endfunction

" Format error message for SVN disabled
function! genero_tools#svn#error#format_disabled() abort
  return 'SVN diff markers are disabled. Enable with: let g:genero_tools_config.svn_enabled = 1'
endfunction

" Format error message for cache error
function! genero_tools#svn#error#format_cache_error(error_msg) abort
  return 'Cache error: ' . a:error_msg
endfunction

" Format error message for diff parsing error
function! genero_tools#svn#error#format_parse_error() abort
  return 'Failed to parse SVN diff output. The diff format may be unsupported.'
endfunction

" Display error message to user
function! genero_tools#svn#error#show(error_msg) abort
  call genero_tools#display#echo('Error: ' . a:error_msg)
endfunction

" Log error message (for debugging)
function! genero_tools#svn#error#log(error_msg) abort
  if genero_tools#config#get('startup_messages') == 'verbose'
    echomsg '[SVN] ' . a:error_msg
  endif
endfunction

" Check if SVN is available and show error if not
function! genero_tools#svn#error#check_availability() abort
  if !genero_tools#svn#detection#is_available()
    call genero_tools#svn#error#show(genero_tools#svn#error#format_not_available())
    return 0
  endif
  return 1
endfunction

" Check if file is in working copy and show error if not
function! genero_tools#svn#error#check_in_working_copy(file_path) abort
  if !genero_tools#svn#detection#is_in_working_copy(a:file_path)
    call genero_tools#svn#error#show(genero_tools#svn#error#format_not_in_working_copy(a:file_path))
    return 0
  endif
  return 1
endfunction

" Check if SVN is enabled and show error if not
function! genero_tools#svn#error#check_enabled() abort
  if !genero_tools#config#get('svn_enabled')
    call genero_tools#svn#error#show(genero_tools#svn#error#format_disabled())
    return 0
  endif
  return 1
endfunction

" Check if file is open and show error if not
function! genero_tools#svn#error#check_file_open() abort
  if empty(expand('%'))
    call genero_tools#svn#error#show(genero_tools#svn#error#format_no_file())
    return 0
  endif
  return 1
endfunction

" Handle SVN diff result and show error if failed
function! genero_tools#svn#error#handle_diff_result(result) abort
  if !a:result.success
    call genero_tools#svn#error#show(a:result.error)
    return 0
  endif
  return 1
endfunction

" Handle SVN status result and show error if failed
function! genero_tools#svn#error#handle_status_result(result) abort
  if !a:result.success
    call genero_tools#svn#error#show(a:result.error)
    return 0
  endif
  return 1
endfunction
