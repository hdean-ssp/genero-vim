" Genero-Tools Plugin - Error Module Tests
" Tests for autoload/genero_tools/error.vim

function! test_error_format_creates_correct_format() abort
  " Given: Module name and message
  let l:module = 'config'
  let l:message = 'test error'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format(l:module, l:message)
  
  " Then: Format is [MODULE] message
  assert_equal(l:formatted, '[config] test error')
endfunction

function! test_error_format_with_different_modules() abort
  " Given: Different module names
  let l:config_error = genero_tools#error#format('config', 'invalid value')
  let l:cache_error = genero_tools#error#format('cache', 'eviction failed')
  let l:command_error = genero_tools#error#format('command', 'timeout')
  
  " When: Formatting errors
  " Then: Each has correct module prefix
  assert_equal(l:config_error, '[config] invalid value')
  assert_equal(l:cache_error, '[cache] eviction failed')
  assert_equal(l:command_error, '[command] timeout')
endfunction

function! test_error_result_creates_error_result() abort
  " Given: Module name and message
  let l:module = 'cache'
  let l:message = 'not found'
  
  " When: Creating error result
  let l:result = genero_tools#error#result(l:module, l:message)
  
  " Then: Result has correct structure
  assert_equal(l:result.success, v:false)
  assert_equal(l:result.error, '[cache] not found')
  assert_equal(empty(l:result.data), v:true)
  assert_true(l:result.timestamp > 0)
endfunction

function! test_error_result_has_all_required_fields() abort
  " Given: Error result created
  let l:result = genero_tools#error#result('test', 'error message')
  
  " When: Checking result structure
  " Then: All required fields are present
  assert_true(has_key(l:result, 'success'))
  assert_true(has_key(l:result, 'data'))
  assert_true(has_key(l:result, 'error'))
  assert_true(has_key(l:result, 'timestamp'))
endfunction

function! test_error_format_with_special_characters() abort
  " Given: Message with special characters
  let l:message = 'Invalid value: "test" (expected: number)'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format('config', l:message)
  
  " Then: Special characters are preserved
  assert_equal(l:formatted, '[config] Invalid value: "test" (expected: number)')
endfunction

function! test_error_format_with_long_message() abort
  " Given: Long error message
  let l:message = 'This is a very long error message that describes a complex issue in detail'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format('command', l:message)
  
  " Then: Full message is preserved
  assert_equal(l:formatted, '[command] This is a very long error message that describes a complex issue in detail')
endfunction

function! test_error_result_with_multiple_errors() abort
  " Given: Multiple error results
  let l:error1 = genero_tools#error#result('config', 'timeout invalid')
  let l:error2 = genero_tools#error#result('cache', 'size exceeded')
  let l:error3 = genero_tools#error#result('command', 'execution failed')
  
  " When: Creating multiple error results
  " Then: Each has correct error message
  assert_equal(l:error1.error, '[config] timeout invalid')
  assert_equal(l:error2.error, '[cache] size exceeded')
  assert_equal(l:error3.error, '[command] execution failed')
  
  " And: All are marked as failures
  assert_equal(l:error1.success, v:false)
  assert_equal(l:error2.success, v:false)
  assert_equal(l:error3.success, v:false)
endfunction

function! test_error_format_consistency() abort
  " Given: Same error formatted multiple times
  let l:error1 = genero_tools#error#format('test', 'message')
  let l:error2 = genero_tools#error#format('test', 'message')
  let l:error3 = genero_tools#error#format('test', 'message')
  
  " When: Formatting same error multiple times
  " Then: Results are identical
  assert_equal(l:error1, l:error2)
  assert_equal(l:error2, l:error3)
endfunction
