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
    \ 'pagination_size': 50
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
    \ 'pagination_size': 50
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
  call add(output, '=== Large Codebase Recommendations ===')
  call add(output, '  For codebases with thousands of files and 6M+ LOC:')
  call add(output, '  - timeout: 10000ms (10 seconds)')
  call add(output, '  - async_enabled: true (keep editor responsive)')
  call add(output, '  - cache_enabled: true (reduce redundant queries)')
  call add(output, '  - result_limit: 1000 (prevent overwhelming results)')
  call add(output, '  - pagination_size: 50 (manageable page sizes)')
  
  call genero_tools#display#echo(join(output, "\n"))
endfunction

" Get all configuration values
function! genero_tools#config#get_all() abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  return g:genero_tools_config
endfunction
