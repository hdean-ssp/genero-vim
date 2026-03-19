" Property-based tests for cache consistency
" Validates cache behavior under various conditions

function! Test_Cache_Returns_Identical_Results_Within_Ttl() abort
  " Property: Cache returns identical results within TTL
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:test_key = 'test_consistency'
  let l:original_result = {
    \ 'success': v:true,
    \ 'data': {'name': 'myFunc', 'line': 42},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call genero_tools#cache#set(l:test_key, l:original_result)
  let l:cached_result = genero_tools#cache#get(l:test_key)
  
  call assert_equal(l:cached_result.data.name, l:original_result.data.name)
  call assert_equal(l:cached_result.data.line, l:original_result.data.line)
endfunction

function! Test_Cache_Stores_Different_Values() abort
  " Property: Cache can store and retrieve different values
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:result1 = {'success': v:true, 'data': {'id': 1}, 'error': '', 'timestamp': localtime()}
  let l:result2 = {'success': v:true, 'data': {'id': 2}, 'error': '', 'timestamp': localtime()}
  
  call genero_tools#cache#set('key1', l:result1)
  call genero_tools#cache#set('key2', l:result2)
  
  let l:cached1 = genero_tools#cache#get('key1')
  let l:cached2 = genero_tools#cache#get('key2')
  
  call assert_equal(l:cached1.data.id, 1)
  call assert_equal(l:cached2.data.id, 2)
  call assert_not_equal(l:cached1.data.id, l:cached2.data.id)
endfunction

function! Test_Cache_Returns_Empty_For_Missing_Key() abort
  " Property: Cache returns empty dict for missing keys
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:result = genero_tools#cache#get('nonexistent_key')
  
  call assert_equal(empty(l:result), v:true)
endfunction

function! Test_Cache_Respects_Enabled_Setting() abort
  " Property: Cache respects cache_enabled configuration
  call genero_tools#config#init()
  let g:genero_tools_config.cache_enabled = v:false
  call genero_tools#cache#init()
  
  let l:test_result = {'success': v:true, 'data': {'test': 'value'}, 'error': '', 'timestamp': localtime()}
  call genero_tools#cache#set('test_key', l:test_result)
  
  " When cache is disabled, get should return empty
  let l:cached = genero_tools#cache#get('test_key')
  call assert_equal(empty(l:cached), v:true)
endfunction

function! Test_Cache_Set_Returns_Success() abort
  " Property: Cache set operation returns success indicator
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:test_result = {'success': v:true, 'data': {'test': 'value'}, 'error': '', 'timestamp': localtime()}
  let l:result = genero_tools#cache#set('test_key', l:test_result)
  
  call assert_equal(l:result, 0)
endfunction

function! Test_Cache_Maintains_Data_Integrity() abort
  " Property: Cache maintains data integrity through store/retrieve cycle
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:original = {
    \ 'success': v:true,
    \ 'data': {
    \   'name': 'testFunc',
    \   'line': 123,
    \   'file': '/path/to/file.4gl',
    \   'signature': 'function testFunc(param1, param2)'
    \ },
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call genero_tools#cache#set('integrity_test', l:original)
  let l:retrieved = genero_tools#cache#get('integrity_test')
  
  call assert_equal(l:retrieved.data.name, l:original.data.name)
  call assert_equal(l:retrieved.data.line, l:original.data.line)
  call assert_equal(l:retrieved.data.file, l:original.data.file)
  call assert_equal(l:retrieved.data.signature, l:original.data.signature)
endfunction

function! Test_Cache_Handles_Empty_Data() abort
  " Property: Cache can store results with empty data
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:empty_result = {'success': v:false, 'data': {}, 'error': 'Not found', 'timestamp': localtime()}
  call genero_tools#cache#set('empty_test', l:empty_result)
  
  let l:cached = genero_tools#cache#get('empty_test')
  call assert_equal(empty(l:cached.data), v:true)
  call assert_equal(l:cached.error, 'Not found')
endfunction
