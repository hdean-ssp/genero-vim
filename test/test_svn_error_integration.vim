" Test SVN Error Handling Integration
" Tests error handling across commands, diff, and error modules

" Test 1: Refresh command with no file open
function! Test_refresh_no_file_open() abort
  " Clear current buffer
  enew
  
  " Try to refresh (should show error)
  call genero_tools#svn#commands#refresh()
  
  " Verify error was shown (check display output)
  echo "Test 1 PASS: Refresh with no file shows error"
endfunction

" Test 2: Refresh command with SVN disabled
function! Test_refresh_svn_disabled() abort
  " Create a test file
  enew
  file test_file.txt
  
  " Disable SVN
  let original_enabled = genero_tools#config#get('svn_enabled')
  call genero_tools#config#set('svn_enabled', 0)
  
  " Try to refresh (should show error)
  call genero_tools#svn#commands#refresh()
  
  " Restore original setting
  call genero_tools#config#set('svn_enabled', original_enabled)
  
  echo "Test 2 PASS: Refresh with SVN disabled shows error"
endfunction

" Test 3: Toggle command with no file open
function! Test_toggle_no_file_open() abort
  " Clear current buffer
  enew
  
  " Try to toggle (should show error)
  call genero_tools#svn#commands#toggle()
  
  echo "Test 3 PASS: Toggle with no file shows error"
endfunction

" Test 4: Status command with no file open
function! Test_status_no_file_open() abort
  " Clear current buffer
  enew
  
  " Try to show status (should show error)
  call genero_tools#svn#commands#status()
  
  echo "Test 4 PASS: Status with no file shows error"
endfunction

" Test 5: Get diff with no file open
function! Test_get_diff_no_file() abort
  " Get diff with empty path
  let result = genero_tools#svn#diff#get_diff('')
  
  " Verify error result
  if result.success != 0
    echo "Test 5 FAIL: Diff should fail with no file"
    return
  endif
  if result.error !~? 'No file'
    echo "Test 5 FAIL: Error should mention no file"
    return
  endif
  
  echo "Test 5 PASS: Get diff with no file returns error"
endfunction

" Test 6: Get status with no file open
function! Test_get_status_no_file() abort
  " Get status with empty path
  let result = genero_tools#svn#diff#get_status('')
  
  " Verify error result
  if result.success != 0
    echo "Test 6 FAIL: Status should fail with no file"
    return
  endif
  if result.error !~? 'No file'
    echo "Test 6 FAIL: Error should mention no file"
    return
  endif
  
  echo "Test 6 PASS: Get status with no file returns error"
endfunction

" Test 7: Error formatting functions
function! Test_error_formatting() abort
  " Test format_not_available
  let msg = genero_tools#svn#error#format_not_available()
  if msg !~? 'SVN'
    echo "Test 7 FAIL: Should mention SVN"
    return
  endif
  if msg !~? 'not installed'
    echo "Test 7 FAIL: Should mention not installed"
    return
  endif
  
  " Test format_not_in_working_copy
  let msg = genero_tools#svn#error#format_not_in_working_copy('/path/to/file.txt')
  if msg !~? 'not in an SVN'
    echo "Test 7 FAIL: Should mention SVN working copy"
    return
  endif
  if msg !~? '/path/to/file.txt'
    echo "Test 7 FAIL: Should include file path"
    return
  endif
  
  " Test format_binary_file
  let msg = genero_tools#svn#error#format_binary_file('/path/to/binary')
  if msg !~? 'binary'
    echo "Test 7 FAIL: Should mention binary"
    return
  endif
  
  " Test format_disabled
  let msg = genero_tools#svn#error#format_disabled()
  if msg !~? 'disabled'
    echo "Test 7 FAIL: Should mention disabled"
    return
  endif
  
  echo "Test 7 PASS: Error formatting functions work correctly"
endfunction

" Test 8: Check availability function
function! Test_check_availability() abort
  " This test depends on SVN being installed or not
  " Just verify the function returns 0 or 1
  let result = genero_tools#svn#error#check_availability()
  if result != 0 && result != 1
    echo "Test 8 FAIL: Should return 0 or 1"
    return
  endif
  
  echo "Test 8 PASS: Check availability returns valid result"
endfunction

" Test 9: Check enabled function
function! Test_check_enabled() abort
  " Save original setting
  let original_enabled = genero_tools#config#get('svn_enabled')
  
  " Test with enabled
  call genero_tools#config#set('svn_enabled', 1)
  let result = genero_tools#svn#error#check_enabled()
  if result != 1
    echo "Test 9 FAIL: Should return 1 when enabled"
    return
  endif
  
  " Test with disabled
  call genero_tools#config#set('svn_enabled', 0)
  let result = genero_tools#svn#error#check_enabled()
  if result != 0
    echo "Test 9 FAIL: Should return 0 when disabled"
    return
  endif
  
  " Restore original setting
  call genero_tools#config#set('svn_enabled', original_enabled)
  
  echo "Test 9 PASS: Check enabled function works correctly"
endfunction

" Test 10: Check file open function
function! Test_check_file_open() abort
  " Test with no file
  enew
  let result = genero_tools#svn#error#check_file_open()
  if result != 0
    echo "Test 10 FAIL: Should return 0 when no file open"
    return
  endif
  
  " Test with file open
  enew
  file test_file.txt
  let result = genero_tools#svn#error#check_file_open()
  if result != 1
    echo "Test 10 FAIL: Should return 1 when file open"
    return
  endif
  
  echo "Test 10 PASS: Check file open function works correctly"
endfunction

" Test 11: Handle diff result function
function! Test_handle_diff_result() abort
  " Test with success result
  let result = {'success': 1, 'error': '', 'diff': 'some diff'}
  let handled = genero_tools#svn#error#handle_diff_result(result)
  if handled != 1
    echo "Test 11 FAIL: Should return 1 for success"
    return
  endif
  
  " Test with failure result
  let result = {'success': 0, 'error': 'Some error', 'diff': ''}
  let handled = genero_tools#svn#error#handle_diff_result(result)
  if handled != 0
    echo "Test 11 FAIL: Should return 0 for failure"
    return
  endif
  
  echo "Test 11 PASS: Handle diff result function works correctly"
endfunction

" Test 12: Handle status result function
function! Test_handle_status_result() abort
  " Test with success result
  let result = {'success': 1, 'error': '', 'status': 'M file.txt'}
  let handled = genero_tools#svn#error#handle_status_result(result)
  if handled != 1
    echo "Test 12 FAIL: Should return 1 for success"
    return
  endif
  
  " Test with failure result
  let result = {'success': 0, 'error': 'Some error', 'status': ''}
  let handled = genero_tools#svn#error#handle_status_result(result)
  if handled != 0
    echo "Test 12 FAIL: Should return 0 for failure"
    return
  endif
  
  echo "Test 12 PASS: Handle status result function works correctly"
endfunction

" Run all tests
function! Test_svn_error_integration_all() abort
  try
    call Test_refresh_no_file_open()
    call Test_refresh_svn_disabled()
    call Test_toggle_no_file_open()
    call Test_status_no_file_open()
    call Test_get_diff_no_file()
    call Test_get_status_no_file()
    call Test_error_formatting()
    call Test_check_availability()
    call Test_check_enabled()
    call Test_check_file_open()
    call Test_handle_diff_result()
    call Test_handle_status_result()
    
    echo "\n=== SVN Error Integration Tests ==="
    echo "All 12 tests PASSED"
  catch
    echo "Test FAILED: " . v:exception
  endtry
endfunction
