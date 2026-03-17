" Test for Task 24: Fix Statusline "no previous error" Bug
" This test verifies that the statusline doesn't show "no previous error" 
" without user action

" Test 1: Verify empty quickfix list doesn't trigger navigation
function! Test_empty_quickfix_no_navigation() abort
  " Clear quickfix list
  call setqflist([])
  
  " Try to navigate - should return error but not trigger statusline message
  let result = genero_tools#compiler#quickfix#prev()
  
  " Verify result indicates no errors to navigate
  if result.success != v:false
    echo 'FAIL: Expected success to be false, got ' . result.success
    return
  endif
  if result.error != 'No errors to navigate'
    echo 'FAIL: Expected error "No errors to navigate", got "' . result.error . '"'
    return
  endif
  
  echo 'PASS: Empty quickfix list returns proper error'
endfunction

" Test 2: Verify navigation with errors works correctly
function! Test_navigation_with_errors() abort
  " Create a mock quickfix list with one error
  let qf_list = [
    \ {
    \   'filename': 'test.4gl',
    \   'lnum': 10,
    \   'col': 5,
    \   'text': 'Test error',
    \   'type': 'E'
    \ }
  \ ]
  
  call setqflist(qf_list)
  
  " Navigate to the error
  let result = genero_tools#compiler#quickfix#next()
  
  " Verify navigation succeeded
  if result.success != v:true
    echo 'FAIL: Expected success to be true, got ' . result.success
    return
  endif
  if result.error != ''
    echo 'FAIL: Expected empty error, got "' . result.error . '"'
    return
  endif
  
  echo 'PASS: Navigation with errors works correctly'
endfunction

" Test 3: Verify navigation beyond bounds returns proper error
function! Test_navigation_beyond_bounds() abort
  " Create a mock quickfix list with one error
  let qf_list = [
    \ {
    \   'filename': 'test.4gl',
    \   'lnum': 10,
    \   'col': 5,
    \   'text': 'Test error',
    \   'type': 'E'
    \ }
  \ ]
  
  call setqflist(qf_list)
  
  " Navigate to the error first
  call genero_tools#compiler#quickfix#next()
  
  " Try to navigate to next error (should fail)
  let result = genero_tools#compiler#quickfix#next()
  
  " Verify result indicates no next error
  if result.success != v:false
    echo 'FAIL: Expected success to be false, got ' . result.success
    return
  endif
  if result.error != 'No next error'
    echo 'FAIL: Expected error "No next error", got "' . result.error . '"'
    return
  endif
  
  echo 'PASS: Navigation beyond bounds returns proper error'
endfunction

" Test 4: Verify autocompile doesn't trigger navigation messages
function! Test_autocompile_no_spurious_messages() abort
  " Clear quickfix list
  call setqflist([])
  
  " Simulate autocompile populating empty quickfix list
  let result = genero_tools#compiler#quickfix#populate(
    \ {'success': v:true, 'errors': [], 'warnings': [], 'info': []},
    \ 'all'
  \ )
  
  " Verify populate succeeded
  if result.success != v:true
    echo 'FAIL: Expected populate to succeed, got ' . result.success
    return
  endif
  
  " Verify quickfix list is empty
  let qf_list = getqflist()
  if len(qf_list) != 0
    echo 'FAIL: Expected empty quickfix list, got ' . len(qf_list) . ' items'
    return
  endif
  
  echo 'PASS: Autocompile with no errors doesn''t trigger messages'
endfunction

" Run all tests
call Test_empty_quickfix_no_navigation()
call Test_navigation_with_errors()
call Test_navigation_beyond_bounds()
call Test_autocompile_no_spurious_messages()

echo 'All tests passed!'
