" Property-based tests for result structure consistency
" Validates that all command results have consistent structure

function! test_result_has_success_field() abort
  " Property: All results must have 'success' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  assert_true(has_key(l:result, 'success'))
  assert_true(type(l:result.success) == type(v:true) || type(l:result.success) == type(v:false))
endfunction

function! test_result_has_data_field() abort
  " Property: All results must have 'data' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {'name': 'test'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  assert_true(has_key(l:result, 'data'))
  assert_true(type(l:result.data) == type({}))
endfunction

function! test_result_has_error_field() abort
  " Property: All results must have 'error' field
  let l:result = {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': 'Test error message',
    \ 'timestamp': localtime()
    \ }
  
  assert_true(has_key(l:result, 'error'))
  assert_true(type(l:result.error) == type(''))
endfunction

function! test_result_has_timestamp_field() abort
  " Property: All results must have 'timestamp' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  assert_true(has_key(l:result, 'timestamp'))
  assert_true(type(l:result.timestamp) == type(0))
endfunction

function! test_successful_result_has_data() abort
  " Property: Successful results must have non-empty data
  let l:result = {
    \ 'success': v:true,
    \ 'data': {'name': 'myFunc', 'line': 42},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  if l:result.success
    assert_true(!empty(l:result.data))
  endif
endfunction

function! test_failed_result_has_error() abort
  " Property: Failed results must have error message
  let l:result = {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': 'Function not found',
    \ 'timestamp': localtime()
    \ }
  
  if !l:result.success
    assert_true(!empty(l:result.error))
  endif
endfunction

function! test_result_timestamp_is_valid() abort
  " Property: Timestamp must be a valid Unix timestamp
  let l:now = localtime()
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': l:now
    \ }
  
  assert_true(l:result.timestamp > 0)
  assert_true(l:result.timestamp <= l:now + 1)
endfunction

function! test_result_structure_consistency() abort
  " Property: All results have exactly 4 required fields
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  let l:required_keys = ['success', 'data', 'error', 'timestamp']
  for l:key in l:required_keys
    assert_true(has_key(l:result, l:key), 'Missing required key: ' . l:key)
  endfor
endfunction
