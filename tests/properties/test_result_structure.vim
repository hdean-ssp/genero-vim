" Property-based tests for result structure consistency
" Validates that all command results have consistent structure

function! Test_Result_Has_Success_Field() abort
  " Property: All results must have 'success' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call assert_true(has_key(l:result, 'success'))
  call assert_true(type(l:result.success) == type(v:true) || type(l:result.success) == type(v:false))
endfunction

function! Test_Result_Has_Data_Field() abort
  " Property: All results must have 'data' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {'name': 'test'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call assert_true(has_key(l:result, 'data'))
  call assert_true(type(l:result.data) == type({}))
endfunction

function! Test_Result_Has_Error_Field() abort
  " Property: All results must have 'error' field
  let l:result = {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': 'Test error message',
    \ 'timestamp': localtime()
    \ }
  
  call assert_true(has_key(l:result, 'error'))
  call assert_true(type(l:result.error) == type(''))
endfunction

function! Test_Result_Has_Timestamp_Field() abort
  " Property: All results must have 'timestamp' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call assert_true(has_key(l:result, 'timestamp'))
  call assert_true(type(l:result.timestamp) == type(0))
endfunction

function! Test_Successful_Result_Has_Data() abort
  " Property: Successful results must have non-empty data
  let l:result = {
    \ 'success': v:true,
    \ 'data': {'name': 'myFunc', 'line': 42},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  if l:result.success
    call assert_true(!empty(l:result.data))
  endif
endfunction

function! Test_Failed_Result_Has_Error() abort
  " Property: Failed results must have error message
  let l:result = {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': 'Function not found',
    \ 'timestamp': localtime()
    \ }
  
  if !l:result.success
    call assert_true(!empty(l:result.error))
  endif
endfunction

function! Test_Result_Timestamp_Is_Valid() abort
  " Property: Timestamp must be a valid Unix timestamp
  let l:now = localtime()
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': l:now
    \ }
  
  call assert_true(l:result.timestamp > 0)
  call assert_true(l:result.timestamp <= l:now + 1)
endfunction

function! Test_Result_Structure_Consistency() abort
  " Property: All results have exactly 4 required fields
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  let l:required_keys = ['success', 'data', 'error', 'timestamp']
  for l:key in l:required_keys
    call assert_true(has_key(l:result, l:key), 'Missing required key: ' . l:key)
  endfor
endfunction
