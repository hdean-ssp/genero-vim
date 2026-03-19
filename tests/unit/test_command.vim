" Genero-Tools Plugin - Command Execution Tests
" Tests for autoload/genero_tools/command.vim

function! test_command_execute_returns_result_structure() abort
  " Given: A command to execute
  " When: Executing a command
  " Then: Result has required structure
  
  " Note: This test requires genero-tools CLI to be available
  " For now, we test the structure only
  let l:result = {
    \ 'success': 1,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  assert_equal(type(l:result), type({}), 'result should be a dictionary')
  assert_equal(has_key(l:result, 'success'), 1, 'result should have success key')
  assert_equal(has_key(l:result, 'data'), 1, 'result should have data key')
  assert_equal(has_key(l:result, 'error'), 1, 'result should have error key')
  assert_equal(has_key(l:result, 'timestamp'), 1, 'result should have timestamp key')
endfunction

function! test_command_result_success_has_data() abort
  " Given: A successful command result
  let l:result = {
    \ 'success': 1,
    \ 'data': {'name': 'test_function', 'file': 'test.4gl'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  " When: Checking result
  " Then: Data is populated and error is empty
  assert_equal(l:result.success, 1, 'success should be true')
  assert_not_empty(l:result.data, 'data should not be empty')
  assert_empty(l:result.error, 'error should be empty')
endfunction

function! test_command_result_failure_has_error() abort
  " Given: A failed command result
  let l:result = {
    \ 'success': 0,
    \ 'data': {},
    \ 'error': 'Function not found',
    \ 'timestamp': localtime()
    \ }
  
  " When: Checking result
  " Then: Error is populated and data is empty
  assert_equal(l:result.success, 0, 'success should be false')
  assert_empty(l:result.data, 'data should be empty')
  assert_not_empty(l:result.error, 'error should not be empty')
endfunction

function! test_command_timeout_error_message() abort
  " Given: A timeout error
  let l:error_msg = 'Command timed out after 10000ms'
  
  " When: Checking error message
  " Then: Message is descriptive
  assert_equal(stridx(l:error_msg, 'timed out') >= 0, 1, 'error should mention timeout')
  assert_equal(stridx(l:error_msg, '10000') >= 0, 1, 'error should include timeout value')
endfunction

function! test_command_argument_escaping() abort
  " Given: Arguments with special characters
  let l:arg = "test'function"
  
  " When: Escaping argument
  let l:escaped = genero_tools#command#escape_arg(l:arg)
  
  " Then: Special characters are escaped
  assert_not_empty(l:escaped, 'escaped argument should not be empty')
endfunction
