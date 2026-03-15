" Genero-Tools Plugin - Configuration Management

" Initialize configuration with defaults
function! genero_tools#config#init() abort
  if !exists('g:genero_tools_config')
    let g:genero_tools_config = {}
  endif
  
  " Set defaults for missing keys
  let defaults = {
    \ 'genero_tools_path': 'query.sh',
    \ 'cache_enabled': v:true,
    \ 'cache_ttl': 3600,
    \ 'cache_max_size': 100,
    \ 'display_mode': 'quickfix',
    \ 'keybindings_enabled': v:true,
    \ 'timeout': 10000,
    \ 'async_enabled': v:true,
    \ 'result_limit': 1000,
    \ 'pagination_size': 50,
    \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
    \ 'compiler_enabled': v:false,
    \ 'compiler_command': 'fglcomp',
    \ 'compiler_source_dir': '.',
    \ 'compiler_version': 'auto',
    \ 'compiler_show_warnings': v:true,
    \ 'compiler_show_errors': v:true,
    \ 'compiler_highlight_unused': v:true,
    \ 'compiler_sign_column': v:true
    \ }
  
  for [key, value] in items(defaults)
    if !has_key(g:genero_tools_config, key)
      let g:genero_tools_config[key] = value
    endif
  endfor
endfunction

" Get configuration value
function! genero_tools#config#get(key) abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  
  if has_key(g:genero_tools_config, a:key)
    return g:genero_tools_config[a:key]
  endif
  
  " Return sensible defaults if key not found
  let defaults = {
    \ 'genero_tools_path': 'query.sh',
    \ 'cache_enabled': v:true,
    \ 'cache_ttl': 3600,
    \ 'cache_max_size': 100,
    \ 'display_mode': 'quickfix',
    \ 'keybindings_enabled': v:true,
    \ 'timeout': 10000,
    \ 'async_enabled': v:true,
    \ 'result_limit': 1000,
    \ 'pagination_size': 50,
    \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
    \ 'compiler_enabled': v:false,
    \ 'compiler_command': 'fglcomp',
    \ 'compiler_source_dir': '.',
    \ 'compiler_version': 'auto',
    \ 'compiler_show_warnings': v:true,
    \ 'compiler_show_errors': v:true,
    \ 'compiler_highlight_unused': v:true,
    \ 'compiler_sign_column': v:true
    \ }
  
  return get(defaults, a:key, '')
endfunction

" Display current configuration
function! genero_tools#config#show() abort
  let config = g:genero_tools_config
  let output = []
  
  call add(output, '=== Genero-Tools Configuration ===')
  call add(output, '')
  
  for [key, value] in items(config)
    if type(value) == type(v:true)
      let value_str = value ? 'true' : 'false'
    else
      let value_str = string(value)
    endif
    call add(output, printf('  %s: %s', key, value_str))
  endfor
  
  call add(output, '')
  
  " Add cache efficiency messaging (Requirement 17.5)
  let cache_stats = genero_tools#cache#stats()
  call add(output, '=== Cache Statistics ===')
  call add(output, '  Cache size: ' . cache_stats.size . ' / ' . cache_stats.max_size)
  call add(output, '  Cache enabled: ' . (cache_stats.enabled ? 'true' : 'false'))
  call add(output, '  Cache TTL: ' . cache_stats.ttl . 's')
  
  let memory_usage = genero_tools#cache#estimate_memory()
  call add(output, '  Estimated memory: ' . memory_usage . 'KB')
  
  " Calculate cache utilization percentage
  if cache_stats.max_size > 0
    let utilization = (cache_stats.size * 100) / cache_stats.max_size
    call add(output, '  Cache utilization: ' . utilization . '%')
  endif
  
  call add(output, '')
  call add(output, '=== Large Codebase Recommendations ===')
  call add(output, '  For codebases with thousands of files and 6M+ LOC:')
  call add(output, '  - timeout: 10000ms (10 seconds) - increase to 20000ms for very large codebases')
  call add(output, '  - async_enabled: true (keep editor responsive)')
  call add(output, '  - cache_enabled: true (reduce redundant queries)')
  call add(output, '  - cache_ttl: 3600s (1 hour) - adjust based on code change frequency')
  call add(output, '  - cache_max_size: 100 - increase to 200+ for frequently accessed functions')
  call add(output, '  - result_limit: 1000 (prevent overwhelming results)')
  call add(output, '  - pagination_size: 50 (manageable page sizes)')
  
  call add(output, '')
  call add(output, '=== Cache Efficiency Tips ===')
  if cache_stats.enabled
    if utilization > 80
      call add(output, '  WARNING: Cache is nearly full (' . utilization . '%). Consider:')
      call add(output, '    - Increasing cache_max_size')
      call add(output, '    - Reducing cache_ttl to clear stale entries faster')
      call add(output, '    - Running :GeneroClearCache to free memory')
    elseif utilization > 50
      call add(output, '  INFO: Cache is ' . utilization . '% full. Monitor memory usage.')
    else
      call add(output, '  INFO: Cache is ' . utilization . '% full. Good cache efficiency.')
    endif
  else
    call add(output, '  Cache is disabled. Enable for better performance on repeated lookups.')
  endif
  
  call genero_tools#display#echo(join(output, "\n"))
endfunction

" Get all configuration values
function! genero_tools#config#get_all() abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  return g:genero_tools_config
endfunction
