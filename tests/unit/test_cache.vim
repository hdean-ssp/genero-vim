" Genero-Tools Plugin - Cache Tests
" Tests for autoload/genero_tools/cache.vim

function! test_cache_get_returns_empty_when_not_set() abort
  " Given: Empty cache
  call genero_tools#cache#clear()
  
  " When: Getting non-existent key
  let l:result = genero_tools#cache#get('nonexistent')
  
  " Then: Empty dict is returned
  assert_empty(l:result, 'cache should return empty dict for non-existent key')
endfunction

function! test_cache_set_stores_value() abort
  " Given: Empty cache
  call genero_tools#cache#clear()
  
  " When: Setting a value
  let l:test_value = {'success': 1, 'data': {'test': 'value'}}
  call genero_tools#cache#set('test_key', l:test_value)
  
  " Then: Value can be retrieved
  let l:retrieved = genero_tools#cache#get('test_key')
  assert_not_empty(l:retrieved, 'cache should return stored value')
endfunction

function! test_cache_clear_removes_all_entries() abort
  " Given: Cache with entries
  call genero_tools#cache#clear()
  call genero_tools#cache#set('key1', {'data': 'value1'})
  call genero_tools#cache#set('key2', {'data': 'value2'})
  
  " When: Clearing cache
  call genero_tools#cache#clear()
  
  " Then: All entries are removed
  let l:result1 = genero_tools#cache#get('key1')
  let l:result2 = genero_tools#cache#get('key2')
  assert_empty(l:result1, 'cache should be empty after clear')
  assert_empty(l:result2, 'cache should be empty after clear')
endfunction

function! test_cache_get_size_returns_correct_count() abort
  " Given: Empty cache
  call genero_tools#cache#clear()
  
  " When: Adding entries
  call genero_tools#cache#set('key1', {'data': 'value1'})
  call genero_tools#cache#set('key2', {'data': 'value2'})
  call genero_tools#cache#set('key3', {'data': 'value3'})
  
  " Then: Size is correct
  let l:size = genero_tools#cache#get_size()
  assert_equal(l:size, 3, 'cache size should be 3')
endfunction

function! test_cache_respects_ttl_expiration() abort
  " Given: Cache with TTL
  call genero_tools#cache#clear()
  let g:genero_tools_config.cache_ttl = 1
  
  " When: Setting a value and waiting for TTL to expire
  call genero_tools#cache#set('test_key', {'data': 'value'})
  sleep 1100m
  
  " Then: Expired entry is not returned
  let l:result = genero_tools#cache#get('test_key')
  assert_empty(l:result, 'cache should return empty for expired entry')
endfunction

function! test_cache_lru_eviction_removes_oldest() abort
  " Given: Cache with max size of 2
  call genero_tools#cache#clear()
  let g:genero_tools_config.cache_max_size = 2
  
  " When: Adding 3 entries
  call genero_tools#cache#set('key1', {'data': 'value1'})
  sleep 10m
  call genero_tools#cache#set('key2', {'data': 'value2'})
  sleep 10m
  call genero_tools#cache#set('key3', {'data': 'value3'})
  
  " Then: Oldest entry is evicted
  let l:result1 = genero_tools#cache#get('key1')
  let l:result2 = genero_tools#cache#get('key2')
  let l:result3 = genero_tools#cache#get('key3')
  
  assert_empty(l:result1, 'oldest entry should be evicted')
  assert_not_empty(l:result2, 'second entry should still exist')
  assert_not_empty(l:result3, 'newest entry should still exist')
endfunction

function! test_cache_stats_returns_statistics() abort
  " Given: Cache with entries
  call genero_tools#cache#clear()
  call genero_tools#cache#set('key1', {'data': 'value1'})
  call genero_tools#cache#set('key2', {'data': 'value2'})
  
  " When: Getting cache statistics
  let l:stats = genero_tools#cache#stats()
  
  " Then: Statistics are returned
  assert_not_empty(l:stats, 'cache stats should not be empty')
  assert_equal(l:stats.size, 2, 'cache size should be 2')
endfunction
