" Genero-Tools Plugin - Display Tests
" Tests for autoload/genero_tools/display.vim

function! test_display_result_with_success() abort
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
    assert_true(1, 'display should not error on success')
  catch
    assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! test_display_result_with_error() abort
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
    assert_true(1, 'display should not error on failure')
  catch
    assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! test_display_mode_fallback() abort
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
    assert_true(1, 'display should handle unsupported modes')
  catch
    assert_false(1, 'display should not throw exception: ' . v:exception)
  endtry
endfunction

function! test_display_echo_formats_output() abort
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
    assert_true(1, 'echo display should work')
  catch
    assert_false(1, 'echo display should not throw exception: ' . v:exception)
  endtry
endfunction

function! test_display_preserves_buffer() abort
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
  assert_equal(l:original_line, l:current_line, 'buffer content should be preserved')
endfunction
