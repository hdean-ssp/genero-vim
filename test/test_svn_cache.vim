" Tests for SVN Cache Module
" Tests caching system for SVN diff results with TTL and statistics

" Test: Cache get/set basic functionality
function! Test_svn_cache_get_set() abort
  " Clear cache first
  call genero_tools#svn#cache#clear()
  
  let file_path = '/test/file.fgl'
  let diff_result = {'success': 1, 'error': '', 'diff': 'test diff content'}
  
  " Set cache
  let result = genero_tools#svn#cache#set(file_path, diff_result)
  call assert_equal(0, result, 'Cache set should return 0')
  
  " Get cache
  let cached = genero_tools#svn#cache#get(file_path)
  call assert_equal(1, cached.cached, 'Should return cached result')
  call assert_equal(1, cached.success, 'Cached result should have success=1')
  call assert_equal('test diff content', cached.diff, 'Cached diff should match')
  
  echo 'Test passed: Cache get/set basic functionality'
endfunction

" Test: Cache miss
function! Test_svn_cache_miss() abort
  " Clear cache
  call genero_tools#svn#cache#clear()
  
  let file_path = '/test/nonexistent.fgl'
  
  " Get non-existent cache
  let cached = genero_tools#svn#cache#get(file_path)
  call assert_equal(0, cached.cached, 'Should return cache miss')
  
  echo 'Test passed: Cache miss'
endfunction

" Test: Cache TTL expiration
function! Test_svn_cache_ttl_expiration() abort
  " Save original config
  let original_ttl = genero_tools#config#get('svn_cache_ttl')
  
  try
    " Set very short TTL (1 second)
    let g:genero_tools_config.svn_cache_ttl = 1
    
    " Clear cache
    call genero_tools#svn#cache#clear()
    
    let file_path = '/test/file.fgl'
    let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
    
    " Set cache
    call genero_tools#svn#cache#set(file_path, diff_result)
    
    " Get immediately (should hit)
    let cached = genero_tools#svn#cache#get(file_path)
    call assert_equal(1, cached.cached, 'Should be cached immediately')
    
    " Wait for TTL to expire (simulate by modifying timestamp)
    let cache_key = 'svn_diff:' . file_path
    let g:genero_tools_svn_cache[cache_key].timestamp = localtime() - 2
    
    " Get after expiration (should miss)
    let cached = genero_tools#svn#cache#get(file_path)
    call assert_equal(0, cached.cached, 'Should expire after TTL')
    
    echo 'Test passed: Cache TTL expiration'
  finally
    " Restore original config
    let g:genero_tools_config.svn_cache_ttl = original_ttl
  endtry
endfunction

" Test: Cache invalidation
function! Test_svn_cache_invalidate() abort
  " Clear cache
  call genero_tools#svn#cache#clear()
  
  let file_path = '/test/file.fgl'
  let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
  
  " Set cache
  call genero_tools#svn#cache#set(file_path, diff_result)
  
  " Verify cached
  let cached = genero_tools#svn#cache#get(file_path)
  call assert_equal(1, cached.cached, 'Should be cached')
  
  " Invalidate
  call genero_tools#svn#cache#invalidate(file_path)
  
  " Verify invalidated
  let cached = genero_tools#svn#cache#get(file_path)
  call assert_equal(0, cached.cached, 'Should be invalidated')
  
  echo 'Test passed: Cache invalidation'
endfunction

" Test: Cache clear
function! Test_svn_cache_clear() abort
  " Clear cache
  call genero_tools#svn#cache#clear()
  
  " Add multiple entries
  call genero_tools#svn#cache#set('/test/file1.fgl', {'success': 1, 'error': '', 'diff': 'diff1'})
  call genero_tools#svn#cache#set('/test/file2.fgl', {'success': 1, 'error': '', 'diff': 'diff2'})
  call genero_tools#svn#cache#set('/test/file3.fgl', {'success': 1, 'error': '', 'diff': 'diff3'})
  
  " Verify entries exist
  call assert_equal(3, len(g:genero_tools_svn_cache), 'Should have 3 entries')
  
  " Clear all
  call genero_tools#svn#cache#clear()
  
  " Verify cleared
  call assert_equal(0, len(g:genero_tools_svn_cache), 'Cache should be empty')
  
  echo 'Test passed: Cache clear'
endfunction

" Test: Cache statistics
function! Test_svn_cache_stats() abort
  " Reset stats
  call genero_tools#svn#cache#reset_stats()
  call genero_tools#svn#cache#clear()
  
  let file_path = '/test/file.fgl'
  let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
  
  " Set cache
  call genero_tools#svn#cache#set(file_path, diff_result)
  
  " Get stats before any requests
  let stats = genero_tools#svn#cache#stats()
  call assert_equal(0, stats.total_requests, 'Should have 0 requests initially')
  
  " Make cache hit
  call genero_tools#svn#cache#get(file_path)
  
  " Get stats after hit
  let stats = genero_tools#svn#cache#stats()
  call assert_equal(1, stats.total_requests, 'Should have 1 request')
  call assert_equal(1, stats.hits, 'Should have 1 hit')
  call assert_equal(0, stats.misses, 'Should have 0 misses')
  
  " Make cache miss
  call genero_tools#svn#cache#get('/test/nonexistent.fgl')
  
  " Get stats after miss
  let stats = genero_tools#svn#cache#stats()
  call assert_equal(2, stats.total_requests, 'Should have 2 requests')
  call assert_equal(1, stats.hits, 'Should have 1 hit')
  call assert_equal(1, stats.misses, 'Should have 1 miss')
  call assert_equal(50, stats.hit_rate, 'Hit rate should be 50%')
  
  echo 'Test passed: Cache statistics'
endfunction

" Test: Cache memory usage
function! Test_svn_cache_memory_usage() abort
  " Clear cache
  call genero_tools#svn#cache#clear()
  
  " Add entry
  call genero_tools#svn#cache#set('/test/file.fgl', {'success': 1, 'error': '', 'diff': 'test diff content'})
  
  " Get memory usage
  let memory = genero_tools#svn#cache#memory_usage()
  call assert_true(memory > 0, 'Memory usage should be positive')
  
  echo 'Test passed: Cache memory usage'
endfunction

" Test: Cache hit rate calculation
function! Test_svn_cache_hit_rate() abort
  " Reset stats
  call genero_tools#svn#cache#reset_stats()
  call genero_tools#svn#cache#clear()
  
  let file_path = '/test/file.fgl'
  let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
  
  " Set cache
  call genero_tools#svn#cache#set(file_path, diff_result)
  
  " Make 10 requests: 8 hits, 2 misses
  for i in range(8)
    call genero_tools#svn#cache#get(file_path)
  endfor
  
  for i in range(2)
    call genero_tools#svn#cache#get('/test/nonexistent' . i . '.fgl')
  endfor
  
  " Get stats
  let stats = genero_tools#svn#cache#stats()
  call assert_equal(10, stats.total_requests, 'Should have 10 requests')
  call assert_equal(8, stats.hits, 'Should have 8 hits')
  call assert_equal(2, stats.misses, 'Should have 2 misses')
  call assert_equal(80, stats.hit_rate, 'Hit rate should be 80%')
  
  echo 'Test passed: Cache hit rate calculation'
endfunction

" Test: Cache size tracking
function! Test_svn_cache_size_tracking() abort
  " Clear cache
  call genero_tools#svn#cache#clear()
  
  " Add entries
  for i in range(5)
    let file_path = '/test/file' . i . '.fgl'
    call genero_tools#svn#cache#set(file_path, {'success': 1, 'error': '', 'diff': 'diff' . i})
  endfor
  
  " Get stats
  let stats = genero_tools#svn#cache#stats()
  call assert_equal(5, stats.size, 'Cache should have 5 entries')
  
  echo 'Test passed: Cache size tracking'
endfunction

" Test: Cache configuration disabled
function! Test_svn_cache_disabled() abort
  " Save original config
  let original_ttl = genero_tools#config#get('svn_cache_ttl')
  
  try
    " Disable cache
    let g:genero_tools_config.svn_cache_ttl = 0
    
    " Clear cache
    call genero_tools#svn#cache#clear()
    
    let file_path = '/test/file.fgl'
    let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
    
    " Try to set cache (should not cache)
    call genero_tools#svn#cache#set(file_path, diff_result)
    
    " Try to get cache (should miss)
    let cached = genero_tools#svn#cache#get(file_path)
    call assert_equal(0, cached.cached, 'Should not cache when disabled')
    
    echo 'Test passed: Cache configuration disabled'
  finally
    " Restore original config
    let g:genero_tools_config.svn_cache_ttl = original_ttl
  endtry
endfunction

" Run all tests
function! Test_svn_cache_all() abort
  call Test_svn_cache_get_set()
  call Test_svn_cache_miss()
  call Test_svn_cache_ttl_expiration()
  call Test_svn_cache_invalidate()
  call Test_svn_cache_clear()
  call Test_svn_cache_stats()
  call Test_svn_cache_memory_usage()
  call Test_svn_cache_hit_rate()
  call Test_svn_cache_size_tracking()
  call Test_svn_cache_disabled()
  
  echo 'All SVN cache tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_cache_all()
endif
