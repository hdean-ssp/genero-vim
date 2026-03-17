" Tests for SVN Error Handling Module
" Tests error handling and messages for SVN operations

" Test: Error message formatting - not available
function! Test_svn_error_not_available() abort
  let msg = genero_tools#svn#error#format_not_available()
  call assert_match('SVN is not installed', msg, 'Should format not available error')
  
  echo 'Test passed: Error message - not available'
endfunction

" Test: Error message formatting - not in working copy
function! Test_svn_error_not_in_working_copy() abort
  let file_path = '/test/file.fgl'
  let msg = genero_tools#svn#error#format_not_in_working_copy(file_path)
  call assert_match('not in an SVN working copy', msg, 'Should format not in working copy error')
  call assert_match(file_path, msg, 'Should include file path')
  
  echo 'Test passed: Error message - not in working copy'
endfunction

" Test: Error message formatting - binary file
function! Test_svn_error_binary_file() abort
  let file_path = '/test/image.png'
  let msg = genero_tools#svn#error#format_binary_file(file_path)
  call assert_match('binary file', msg, 'Should format binary file error')
  call assert_match(file_path, msg, 'Should include file path')
  
  echo 'Test passed: Error message - binary file'
endfunction

" Test: Error message formatting - SVN failure
function! Test_svn_error_svn_failure() abort
  let msg = genero_tools#svn#error#format_svn_failure('diff', 'connection timeout')
  call assert_match('SVN diff failed', msg, 'Should format SVN failure error')
  call assert_match('connection timeout', msg, 'Should include error details')
  
  echo 'Test passed: Error message - SVN failure'
endfunction

" Test: Error message formatting - authentication failure
function! Test_svn_error_auth_failure() abort
  let msg = genero_tools#svn#error#format_auth_failure()
  call assert_match('authentication failed', msg, 'Should format auth failure error')
  
  echo 'Test passed: Error message - authentication failure'
endfunction

" Test: Error message formatting - permission denied
function! Test_svn_error_permission_denied() abort
  let file_path = '/test/file.fgl'
  let msg = genero_tools#svn#error#format_permission_denied(file_path)
  call assert_match('Permission denied', msg, 'Should format permission denied error')
  call assert_match(file_path, msg, 'Should include file path')
  
  echo 'Test passed: Error message - permission denied'
endfunction

" Test: Error message formatting - no file open
function! Test_svn_error_no_file() abort
  let msg = genero_tools#svn#error#format_no_file()
  call assert_match('No file is currently open', msg, 'Should format no file error')
  
  echo 'Test passed: Error message - no file open'
endfunction

" Test: Error message formatting - disabled
function! Test_svn_error_disabled() abort
  let msg = genero_tools#svn#error#format_disabled()
  call assert_match('disabled', msg, 'Should format disabled error')
  call assert_match('svn_enabled', msg, 'Should include config option')
  
  echo 'Test passed: Error message - disabled'
endfunction

" Test: Error message formatting - cache error
function! Test_svn_error_cache_error() abort
  let msg = genero_tools#svn#error#format_cache_error('out of memory')
  call assert_match('Cache error', msg, 'Should format cache error')
  call assert_match('out of memory', msg, 'Should include error details')
  
  echo 'Test passed: Error message - cache error'
endfunction

" Test: Error message formatting - parse error
function! Test_svn_error_parse_error() abort
  let msg = genero_tools#svn#error#format_parse_error()
  call assert_match('Failed to parse', msg, 'Should format parse error')
  
  echo 'Test passed: Error message - parse error'
endfunction

" Test: Check availability
function! Test_svn_error_check_availability() abort
  " This test checks the function exists and returns a boolean
  let result = genero_tools#svn#error#check_availability()
  call assert_true(type(result) == type(0), 'Should return a number')
  
  echo 'Test passed: Check availability'
endfunction

" Test: Check in working copy
function! Test_svn_error_check_in_working_copy() abort
  " Create a temporary SVN working copy
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  let test_file = child_dir . '/test.txt'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  call writefile(['test'], test_file)
  
  try
    " Check file in working copy
    let result = genero_tools#svn#error#check_in_working_copy(test_file)
    call assert_equal(1, result, 'Should return 1 for file in working copy')
    
    " Check file not in working copy
    let non_svn_file = temp_dir . '/not_in_svn.txt'
    call writefile(['test'], non_svn_file)
    let result = genero_tools#svn#error#check_in_working_copy(non_svn_file)
    call assert_equal(0, result, 'Should return 0 for file not in working copy')
    
    echo 'Test passed: Check in working copy'
  finally
    call delete(temp_dir, 'rf')
  endtry
endfunction

" Test: Check enabled
function! Test_svn_error_check_enabled() abort
  " Save original config
  let original_enabled = genero_tools#config#get('svn_enabled')
  
  try
    " Check when enabled
    let g:genero_tools_config.svn_enabled = v:true
    let result = genero_tools#svn#error#check_enabled()
    call assert_equal(1, result, 'Should return 1 when enabled')
    
    " Check when disabled
    let g:genero_tools_config.svn_enabled = v:false
    let result = genero_tools#svn#error#check_enabled()
    call assert_equal(0, result, 'Should return 0 when disabled')
    
    echo 'Test passed: Check enabled'
  finally
    " Restore original config
    let g:genero_tools_config.svn_enabled = original_enabled
  endtry
endfunction

" Test: Check file open
function! Test_svn_error_check_file_open() abort
  " Create a new empty buffer
  enew
  
  " Check with no file
  let result = genero_tools#svn#error#check_file_open()
  call assert_equal(0, result, 'Should return 0 when no file open')
  
  " Close the buffer
  bdelete!
  
  echo 'Test passed: Check file open'
endfunction

" Test: Handle diff result - success
function! Test_svn_error_handle_diff_result_success() abort
  let result = {'success': 1, 'error': '', 'diff': 'test diff'}
  let handled = genero_tools#svn#error#handle_diff_result(result)
  call assert_equal(1, handled, 'Should return 1 for successful result')
  
  echo 'Test passed: Handle diff result - success'
endfunction

" Test: Handle diff result - failure
function! Test_svn_error_handle_diff_result_failure() abort
  let result = {'success': 0, 'error': 'SVN diff failed', 'diff': ''}
  let handled = genero_tools#svn#error#handle_diff_result(result)
  call assert_equal(0, handled, 'Should return 0 for failed result')
  
  echo 'Test passed: Handle diff result - failure'
endfunction

" Test: Handle status result - success
function! Test_svn_error_handle_status_result_success() abort
  let result = {'success': 1, 'error': '', 'status': 'M file.fgl'}
  let handled = genero_tools#svn#error#handle_status_result(result)
  call assert_equal(1, handled, 'Should return 1 for successful result')
  
  echo 'Test passed: Handle status result - success'
endfunction

" Test: Handle status result - failure
function! Test_svn_error_handle_status_result_failure() abort
  let result = {'success': 0, 'error': 'SVN status failed', 'status': ''}
  let handled = genero_tools#svn#error#handle_status_result(result)
  call assert_equal(0, handled, 'Should return 0 for failed result')
  
  echo 'Test passed: Handle status result - failure'
endfunction

" Run all tests
function! Test_svn_error_handling_all() abort
  call Test_svn_error_not_available()
  call Test_svn_error_not_in_working_copy()
  call Test_svn_error_binary_file()
  call Test_svn_error_svn_failure()
  call Test_svn_error_auth_failure()
  call Test_svn_error_permission_denied()
  call Test_svn_error_no_file()
  call Test_svn_error_disabled()
  call Test_svn_error_cache_error()
  call Test_svn_error_parse_error()
  call Test_svn_error_check_availability()
  call Test_svn_error_check_in_working_copy()
  call Test_svn_error_check_enabled()
  call Test_svn_error_check_file_open()
  call Test_svn_error_handle_diff_result_success()
  call Test_svn_error_handle_diff_result_failure()
  call Test_svn_error_handle_status_result_success()
  call Test_svn_error_handle_status_result_failure()
  
  echo 'All SVN error handling tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_error_handling_all()
endif
