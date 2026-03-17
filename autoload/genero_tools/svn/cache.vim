" Genero-Tools Plugin - SVN Cache Module
" Provides caching system for SVN diff results with TTL and statistics

" Initialize cache storage
if !exists('g:genero_tools_svn_cache')
  let g:genero_tools_svn_cache = {}
endif

" Initialize cache statistics
if !exists('g:genero_tools_svn_cache_stats')
  let g:genero_tools_svn_cache_stats = {
    \ 'hits': 0,
    \ 'misses': 0,
    \ 'evictions': 0,
    \ 'total_requests': 0
    \ }
endif

" Get cached SVN diff result
" Returns: dict with keys: success (bool), error (string), diff (string), cached (bool)
function! genero_tools#svn#cache#get(file_path) abort
  let cache_key = 'svn_diff:' . a:file_path
  
  " Update statistics
  let g:genero_tools_svn_cache_stats.total_requests += 1
  
  " Check if cache is enabled
  if !genero_tools#config#get('svn_cache_ttl')
    let g:genero_tools_svn_cache_stats.misses += 1
    return {'cached': 0}
  endif
  
  " Check if entry exists
  if !has_key(g:genero_tools_svn_cache, cache_key)
    let g:genero_tools_svn_cache_stats.misses += 1
    return {'cached': 0}
  endif
  
  let entry = g:genero_tools_svn_cache[cache_key]
  let cache_ttl = genero_tools#config#get('svn_cache_ttl')
  let current_time = localtime()
  
  " Check if entry has expired
  if current_time - entry.timestamp > cache_ttl
    call remove(g:genero_tools_svn_cache, cache_key)
    let g:genero_tools_svn_cache_stats.misses += 1
    return {'cached': 0}
  endif
  
  " Cache hit
  let g:genero_tools_svn_cache_stats.hits += 1
  let result = entry.diff
  let result.cached = 1
  return result
endfunction

" Store SVN diff in cache
" Returns: 0 on success, 1 on error
function! genero_tools#svn#cache#set(file_path, diff_result) abort
  let cache_key = 'svn_diff:' . a:file_path
  
  " Check if cache is enabled
  if !genero_tools#config#get('svn_cache_ttl')
    return 0
  endif
  
  " Store in cache
  let g:genero_tools_svn_cache[cache_key] = {
    \ 'diff': a:diff_result,
    \ 'timestamp': localtime()
    \ }
  
  " Check cache size and evict if necessary
  let cache_max_size = genero_tools#config#get('svn_cache_ttl')
  if cache_max_size > 0 && len(g:genero_tools_svn_cache) > cache_max_size
    call genero_tools#svn#cache#evict_oldest()
  endif
  
  return 0
endfunction

" Clear cache for a specific file
function! genero_tools#svn#cache#invalidate(file_path) abort
  let cache_key = 'svn_diff:' . a:file_path
  if has_key(g:genero_tools_svn_cache, cache_key)
    call remove(g:genero_tools_svn_cache, cache_key)
  endif
endfunction

" Clear all SVN cache
function! genero_tools#svn#cache#clear() abort
  let g:genero_tools_svn_cache = {}
endfunction

" Evict oldest cache entry (LRU)
function! genero_tools#svn#cache#evict_oldest() abort
  if empty(g:genero_tools_svn_cache)
    return
  endif
  
  " Find oldest entry
  let oldest_key = ''
  let oldest_time = localtime()
  
  for [key, entry] in items(g:genero_tools_svn_cache)
    if entry.timestamp < oldest_time
      let oldest_time = entry.timestamp
      let oldest_key = key
    endif
  endfor
  
  " Remove oldest entry
  if !empty(oldest_key)
    call remove(g:genero_tools_svn_cache, oldest_key)
    let g:genero_tools_svn_cache_stats.evictions += 1
  endif
endfunction

" Get cache statistics
" Returns: dict with cache stats
function! genero_tools#svn#cache#stats() abort
  let stats = copy(g:genero_tools_svn_cache_stats)
  let stats.size = len(g:genero_tools_svn_cache)
  let stats.ttl = genero_tools#config#get('svn_cache_ttl')
  let stats.enabled = stats.ttl > 0
  
  " Calculate hit rate
  if stats.total_requests > 0
    let stats.hit_rate = (stats.hits * 100) / stats.total_requests
  else
    let stats.hit_rate = 0
  endif
  
  return stats
endfunction

" Get cache memory usage estimate (in KB)
" Returns: estimated memory usage
function! genero_tools#svn#cache#memory_usage() abort
  let total_size = 0
  
  for [key, entry] in items(g:genero_tools_svn_cache)
    " Estimate size: key + diff content
    let total_size += len(key)
    let total_size += len(entry.diff.diff)
  endfor
  
  " Convert to KB (rough estimate)
  return (total_size / 1024) + 1
endfunction

" Reset cache statistics
function! genero_tools#svn#cache#reset_stats() abort
  let g:genero_tools_svn_cache_stats = {
    \ 'hits': 0,
    \ 'misses': 0,
    \ 'evictions': 0,
    \ 'total_requests': 0
    \ }
endfunction

" Display cache statistics
function! genero_tools#svn#cache#show_stats() abort
  let stats = genero_tools#svn#cache#stats()
  let memory = genero_tools#svn#cache#memory_usage()
  
  let output = []
  call add(output, '=== SVN Cache Statistics ===')
  call add(output, '')
  call add(output, 'Cache Status:')
  call add(output, '  Enabled: ' . (stats.enabled ? 'yes' : 'no'))
  call add(output, '  TTL: ' . stats.ttl . ' seconds')
  call add(output, '  Size: ' . stats.size . ' entries')
  call add(output, '  Memory: ~' . memory . ' KB')
  call add(output, '')
  call add(output, 'Performance:')
  call add(output, '  Total Requests: ' . stats.total_requests)
  call add(output, '  Cache Hits: ' . stats.hits)
  call add(output, '  Cache Misses: ' . stats.misses)
  call add(output, '  Hit Rate: ' . stats.hit_rate . '%')
  call add(output, '  Evictions: ' . stats.evictions)
  call add(output, '')
  
  if stats.hit_rate > 80
    call add(output, 'Status: Excellent cache efficiency')
  elseif stats.hit_rate > 50
    call add(output, 'Status: Good cache efficiency')
  elseif stats.hit_rate > 20
    call add(output, 'Status: Moderate cache efficiency')
  else
    call add(output, 'Status: Low cache efficiency - consider adjusting TTL')
  endif
  
  call genero_tools#display#echo(join(output, "\n"))
endfunction
