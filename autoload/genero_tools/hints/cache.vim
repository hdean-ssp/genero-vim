" Genero-Tools Plugin - Hint Cache System
" Caches hint analysis results to improve performance

" Initialize hint cache
if !exists('g:genero_tools_hints_cache')
  let g:genero_tools_hints_cache = {}
  let g:genero_tools_hints_cache_times = {}
endif

" Initialize cache system
function! genero_tools#hints#cache#init() abort
  " Cache is already initialized at script load time
endfunction

" Get cached hints for a buffer
function! genero_tools#hints#cache#get(bufnr) abort
  if !genero_tools#hints#config#get('hints_cache_enabled')
    return []
  endif
  
  let cache_key = genero_tools#hints#cache#make_key(a:bufnr)
  
  if !has_key(g:genero_tools_hints_cache, cache_key)
    return []
  endif
  
  let entry = g:genero_tools_hints_cache[cache_key]
  let cache_ttl = genero_tools#hints#config#get('hints_cache_ttl')
  let current_time = localtime()
  
  " Check if entry has expired
  if current_time - entry.timestamp > cache_ttl
    call genero_tools#hints#cache#invalidate(a:bufnr)
    return []
  endif
  
  " Check if file has been modified
  if genero_tools#hints#cache#file_modified(a:bufnr, entry.file_hash)
    call genero_tools#hints#cache#invalidate(a:bufnr)
    return []
  endif
  
  return entry.hints
endfunction

" Store hints in cache
function! genero_tools#hints#cache#set(bufnr, hints) abort
  if !genero_tools#hints#config#get('hints_cache_enabled')
    return
  endif
  
  let cache_key = genero_tools#hints#cache#make_key(a:bufnr)
  
  " Create cache entry
  let entry = {
    \ 'hints': a:hints,
    \ 'timestamp': localtime(),
    \ 'file_hash': genero_tools#hints#cache#compute_file_hash(a:bufnr)
    \ }
  
  let g:genero_tools_hints_cache[cache_key] = entry
  let g:genero_tools_hints_cache_times[cache_key] = localtime()
endfunction

" Invalidate cache for a buffer
function! genero_tools#hints#cache#invalidate(bufnr) abort
  let cache_key = genero_tools#hints#cache#make_key(a:bufnr)
  
  if has_key(g:genero_tools_hints_cache, cache_key)
    call remove(g:genero_tools_hints_cache, cache_key)
  endif
  
  if has_key(g:genero_tools_hints_cache_times, cache_key)
    call remove(g:genero_tools_hints_cache_times, cache_key)
  endif
endfunction

" Clear all hint cache
function! genero_tools#hints#cache#clear() abort
  let g:genero_tools_hints_cache = {}
  let g:genero_tools_hints_cache_times = {}
endfunction

" Make cache key for a buffer
function! genero_tools#hints#cache#make_key(bufnr) abort
  return 'hints:' . a:bufnr
endfunction

" Compute hash of file content
function! genero_tools#hints#cache#compute_file_hash(bufnr) abort
  if !bufexists(a:bufnr)
    return ''
  endif
  
  let lines = getbufline(a:bufnr, 1, '$')
  let content = join(lines, '\n')
  
  " Simple hash: use length and first/last chars
  " In production, could use more sophisticated hashing
  return len(content) . ':' . (len(content) > 0 ? content[0] . content[-1] : '')
endfunction

" Check if file has been modified since cache entry
function! genero_tools#hints#cache#file_modified(bufnr, old_hash) abort
  let new_hash = genero_tools#hints#cache#compute_file_hash(a:bufnr)
  return new_hash != a:old_hash
endfunction
