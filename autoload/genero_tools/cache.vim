" Genero-Tools Plugin - Caching System

" Initialize cache
if !exists('g:genero_tools_cache')
  let g:genero_tools_cache = {}
  let g:genero_tools_cache_access_times = {}
endif

" Get cached result
function! genero_tools#cache#get(key) abort
  if !genero_tools#config#get('cache_enabled')
    return {}
  endif
  
  if !has_key(g:genero_tools_cache, a:key)
    return {}
  endif
  
  let entry = g:genero_tools_cache[a:key]
  let cache_ttl = genero_tools#config#get('cache_ttl')
  let current_time = localtime()
  
  " Check if entry has expired
  if current_time - entry.timestamp > cache_ttl
    call genero_tools#cache#delete(a:key)
    return {}
  endif
  
  " Update access time for LRU tracking
  let g:genero_tools_cache_access_times[a:key] = current_time
  
  return entry
endfunction

" Set cached result
function! genero_tools#cache#set(key, value) abort
  if !genero_tools#config#get('cache_enabled')
    return 0
  endif
  
  let cache_max_size = genero_tools#config#get('cache_max_size')
  
  " Check cache size and evict if necessary
  if len(g:genero_tools_cache) >= cache_max_size
    call genero_tools#cache#evict_lru()
  endif
  
  let g:genero_tools_cache[a:key] = a:value
  let g:genero_tools_cache_access_times[a:key] = localtime()
  
  return 0
endfunction

" Delete cache entry
function! genero_tools#cache#delete(key) abort
  if has_key(g:genero_tools_cache, a:key)
    call remove(g:genero_tools_cache, a:key)
  endif
  if has_key(g:genero_tools_cache_access_times, a:key)
    call remove(g:genero_tools_cache_access_times, a:key)
  endif
endfunction

" Evict least recently used entry
function! genero_tools#cache#evict_lru() abort
  if empty(g:genero_tools_cache_access_times)
    return
  endif
  
  " Find key with oldest access time
  let oldest_key = ''
  let oldest_time = localtime()
  
  for [key, access_time] in items(g:genero_tools_cache_access_times)
    if access_time < oldest_time
      let oldest_time = access_time
      let oldest_key = key
    endif
  endfor
  
  if !empty(oldest_key)
    call genero_tools#cache#delete(oldest_key)
  endif
endfunction

" Clear all cache
function! genero_tools#cache#clear() abort
  let g:genero_tools_cache = {}
  let g:genero_tools_cache_access_times = {}
  call genero_tools#display#echo('Cache cleared')
endfunction

" Get cache statistics
function! genero_tools#cache#stats() abort
  let stats = {
    \ 'size': len(g:genero_tools_cache),
    \ 'max_size': genero_tools#config#get('cache_max_size'),
    \ 'enabled': genero_tools#config#get('cache_enabled'),
    \ 'ttl': genero_tools#config#get('cache_ttl')
    \ }
  return stats
endfunction

" Handle memory pressure by clearing expired entries
function! genero_tools#cache#handle_memory_pressure() abort
  if !genero_tools#config#get('cache_enabled')
    return
  endif
  
  let cache_ttl = genero_tools#config#get('cache_ttl')
  let current_time = localtime()
  let expired_keys = []
  
  " Find all expired entries
  for [key, entry] in items(g:genero_tools_cache)
    if current_time - entry.timestamp > cache_ttl
      call add(expired_keys, key)
    endif
  endfor
  
  " Delete expired entries
  for key in expired_keys
    call genero_tools#cache#delete(key)
  endfor
  
  " If still over capacity, trigger LRU eviction
  let cache_max_size = genero_tools#config#get('cache_max_size')
  while len(g:genero_tools_cache) > cache_max_size
    call genero_tools#cache#evict_lru()
  endwhile
  
  return len(expired_keys)
endfunction

" Estimate cache memory usage (rough estimate in KB)
function! genero_tools#cache#estimate_memory() abort
  let total_size = 0
  
  for [key, entry] in items(g:genero_tools_cache)
    " Rough estimate: key length + entry size
    let total_size += len(key)
    if type(entry) == type({})
      let total_size += len(string(entry))
    endif
  endfor
  
  " Convert to KB (rough estimate)
  return total_size / 1024
endfunction

" Display cache statistics to the user
function! genero_tools#cache#show_stats() abort
  let stats = genero_tools#cache#stats()
  let memory_kb = genero_tools#cache#estimate_memory()
  
  let output = []
  call add(output, '=== Cache Statistics ===')
  call add(output, '')
  call add(output, 'Status:    ' . (stats.enabled ? 'Enabled' : 'Disabled'))
  call add(output, 'Entries:   ' . stats.size . ' / ' . stats.max_size)
  call add(output, 'TTL:       ' . stats.ttl . 's')
  call add(output, 'Memory:    ~' . memory_kb . ' KB')
  
  " SVN cache stats if available
  if exists('g:genero_tools_svn_cache_stats')
    let svn = g:genero_tools_svn_cache_stats
    let total = svn.total_requests
    let hit_rate = total > 0 ? printf('%.0f%%', (svn.hits * 100.0) / total) : 'N/A'
    call add(output, '')
    call add(output, '--- SVN Cache ---')
    call add(output, 'Requests:  ' . total)
    call add(output, 'Hits:      ' . svn.hits)
    call add(output, 'Misses:    ' . svn.misses)
    call add(output, 'Hit rate:  ' . hit_rate)
    call add(output, 'Evictions: ' . svn.evictions)
  endif
  
  echo join(output, "\n")
endfunction
