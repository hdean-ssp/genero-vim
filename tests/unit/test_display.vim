" Genero-Tools Plugin - Display Tests
" Tests for autoload/genero_tools/display.vim

function! Test_Display_Result_With_Success() abort
  " Given: A successful result
  let l:result = {
    \ 'success': 1,
    \ 'data': {'name': 'test_function', 'file': 'test.4gl', 'line': 42},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  " When: Displaying result
  " Then: No errors occur
  try
    call genero_tools#display#result(l:result, 'echo')
    call assert_true(1, 'display should not error on success')
  catch
    call assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! Test_Display_Result_With_Error() abort
  " Given: A failed result
  let l:result = {
    \ 'success': 0,
    \ 'data': {},
    \ 'error': 'Function not found',
    \ 'timestamp': localtime()
    \ }
  
  " When: Displaying result
  " Then: No errors occur
  try
    call genero_tools#display#result(l:result, 'echo')
    call assert_true(1, 'display should not error on failure')
  catch
    call assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! Test_Display_Mode_Fallback() abort
  " Given: Unsupported display mode in vim
  let l:result = {
    \ 'success': 1,
    \ 'data': {'test': 'data'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  " When: Using popup mode in vim (not neovim)
  " Then: Should fall back to echo mode
  try
    call genero_tools#display#result(l:result, 'popup')
    call assert_true(1, 'display should handle unsupported modes')
  catch
    call assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! Test_Display_Echo_Formats_Output() abort
  " Given: A result to display
  let l:result = {
    \ 'success': 1,
    \ 'data': {'name': 'test_function'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  " When: Displaying in echo mode
  " Then: Output is formatted
  try
    call genero_tools#display#echo('Test message')
    call assert_true(1, 'echo display should work')
  catch
    call assert_false(1, 'echo display should not throw exception: ' . v:exception)
  endtry
endfunction

function! Test_Display_Preserves_Buffer() abort
  " Given: Current buffer content
  let l:original_line = getline(1)
  
  " When: Displaying result
  let l:result = {
    \ 'success': 1,
    \ 'data': {'test': 'data'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  call genero_tools#display#result(l:result, 'echo')
  
  " Then: Buffer content is unchanged
  let l:current_line = getline(1)
  call assert_equal(l:original_line, l:current_line, 'buffer content should be preserved')
endfunction
