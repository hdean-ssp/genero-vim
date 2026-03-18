" Genero-Tools Plugin - Configuration Management

" Initialize configuration with defaults
function! genero_tools#config#init() abort
  if !exists('g:genero_tools_config')
    let g:genero_tools_config = {}
  endif
  
  " Initialize each config key individually to avoid type mismatches
  call genero_tools#config#init_key('genero_tools_path', 'query.sh')
  call genero_tools#config#init_key('cache_enabled', 1)
  call genero_tools#config#init_key('cache_ttl', 3600)
  call genero_tools#config#init_key('cache_max_size', 100)
  call genero_tools#config#init_key('display_mode', 'quickfix')
  call genero_tools#config#init_key('keybindings_enabled', 1)
  call genero_tools#config#init_key('timeout', 10000)
  call genero_tools#config#init_key('async_enabled', 1)
  call genero_tools#config#init_key('result_limit', 1000)
  call genero_tools#config#init_key('pagination_size', 50)
  call genero_tools#config#init_key('codebase_markers', ['castle.sch', 'genero.conf', '.genero', '.git'])
  call genero_tools#config#init_key('compiler_enabled', 0)
  call genero_tools#config#init_key('compiler_command', 'fglcomp')
  call genero_tools#config#init_key('compiler_source_dir', '.')
  call genero_tools#config#init_key('compiler_version', 'auto')
  call genero_tools#config#init_key('compiler_show_warnings', 1)
  call genero_tools#config#init_key('compiler_show_errors', 1)
  call genero_tools#config#init_key('compiler_highlight_unused', 1)
  call genero_tools#config#init_key('compiler_sign_column', 1)
  call genero_tools#config#init_key('compiler_sign_column_always_visible', 1)
  call genero_tools#config#init_key('compiler_autocompile', 0)
  call genero_tools#config#init_key('compiler_autocompile_delay', 1000)
  call genero_tools#config#init_key('snippets_enabled', 1)
  call genero_tools#config#init_key('snippet_engine', 'luasnip')
  call genero_tools#config#init_key('snippet_smart_expansion', 1)
  call genero_tools#config#init_key('snippet_custom_dir', expand('~/.config/nvim/genero-snippets'))
  call genero_tools#config#init_key('startup_messages', 'silent')
  call genero_tools#config#init_key('svn_enabled', 1)
  call genero_tools#config#init_key('svn_show_added', 1)
  call genero_tools#config#init_key('svn_show_modified', 1)
  call genero_tools#config#init_key('svn_show_deleted', 1)
  call genero_tools#config#init_key('svn_cache_ttl', 300)
  call genero_tools#config#init_key('svn_auto_update', 1)
  call genero_tools#config#init_key('floating_window_border', 'rounded')
  call genero_tools#config#init_key('floating_window_width', 80)
  call genero_tools#config#init_key('floating_window_height', 20)
  call genero_tools#config#init_key('floating_window_position', 'center')
  call genero_tools#config#init_key('floating_window_title', 'Genero-Tools')
  call genero_tools#config#init_key('popup_auto_close_delay', 5000)
  call genero_tools#config#init_key('debug_stream_enabled', 0)
  call genero_tools#config#init_key('debug_stream_width', 33)
  call genero_tools#config#init_key('debug_stream_max_lines', 1000)
  call genero_tools#config#init_key('debug_stream_auto_scroll', 1)
  call genero_tools#config#init_key('debug_stream_directory', './debug')
endfunction

" Initialize a single config key with type safety
function! genero_tools#config#init_key(key, default_value) abort
  if !has_key(g:genero_tools_config, a:key)
    let g:genero_tools_config[a:key] = a:default_value
  else
    " Type checking and conversion for list values
    if a:key == 'codebase_markers'
      if type(g:genero_tools_config[a:key]) != type([])
        " Convert string to list if needed
        if type(g:genero_tools_config[a:key]) == type('')
          let g:genero_tools_config[a:key] = [g:genero_tools_config[a:key]]
        else
          " If it's neither string nor list, use default
          let g:genero_tools_config[a:key] = a:default_value
        endif
      endif
    endif
  endif
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
  if a:key == 'genero_tools_path'
    return 'query.sh'
  elseif a:key == 'cache_enabled'
    return 1
  elseif a:key == 'cache_ttl'
    return 3600
  elseif a:key == 'cache_max_size'
    return 100
  elseif a:key == 'display_mode'
    return 'quickfix'
  elseif a:key == 'keybindings_enabled'
    return 1
  elseif a:key == 'timeout'
    return 10000
  elseif a:key == 'async_enabled'
    return 1
  elseif a:key == 'result_limit'
    return 1000
  elseif a:key == 'pagination_size'
    return 50
  elseif a:key == 'codebase_markers'
    return ['castle.sch', 'genero.conf', '.genero', '.git']
  elseif a:key == 'compiler_enabled'
    return 0
  elseif a:key == 'compiler_command'
    return 'fglcomp'
  elseif a:key == 'compiler_source_dir'
    return '.'
  elseif a:key == 'compiler_version'
    return 'auto'
  elseif a:key == 'compiler_show_warnings'
    return 1
  elseif a:key == 'compiler_show_errors'
    return 1
  elseif a:key == 'compiler_highlight_unused'
    return 1
  elseif a:key == 'compiler_sign_column'
    return 1
  elseif a:key == 'compiler_sign_column_always_visible'
    return 1
  elseif a:key == 'compiler_autocompile'
    return 0
  elseif a:key == 'compiler_autocompile_delay'
    return 1000
  elseif a:key == 'snippets_enabled'
    return 1
  elseif a:key == 'snippet_engine'
    return 'luasnip'
  elseif a:key == 'snippet_smart_expansion'
    return 1
  elseif a:key == 'snippet_custom_dir'
    return expand('~/.config/nvim/genero-snippets')
  elseif a:key == 'startup_messages'
    return 'silent'
  elseif a:key == 'svn_enabled'
    return 1
  elseif a:key == 'svn_show_added'
    return 1
  elseif a:key == 'svn_show_modified'
    return 1
  elseif a:key == 'svn_show_deleted'
    return 1
  elseif a:key == 'svn_cache_ttl'
    return 300
  elseif a:key == 'svn_auto_update'
    return 1
  elseif a:key == 'floating_window_border'
    return 'rounded'
  elseif a:key == 'floating_window_width'
    return 80
  elseif a:key == 'floating_window_height'
    return 20
  elseif a:key == 'floating_window_position'
    return 'center'
  elseif a:key == 'floating_window_title'
    return 'Genero-Tools'
  elseif a:key == 'popup_auto_close_delay'
    return 5000
  elseif a:key == 'debug_stream_enabled'
    return 0
  elseif a:key == 'debug_stream_width'
    return 33
  elseif a:key == 'debug_stream_max_lines'
    return 1000
  elseif a:key == 'debug_stream_auto_scroll'
    return 1
  elseif a:key == 'debug_stream_directory'
    return './debug'
  else
    return ''
  endif
endfunction

" Display current configuration
function! genero_tools#config#show() abort
  let config = g:genero_tools_config
  let output = []
  
  call add(output, '=== Genero-Tools Configuration ===')
  call add(output, '')
  
  for [key, value] in items(config)
    " Check if value is a boolean (type 0 = number, and value is 0 or 1)
    if type(value) == 0 && (value == 0 || value == 1)
      if value
        let value_str = 'true'
      else
        let value_str = 'false'
      endif
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
  let cache_enabled_str = cache_stats.enabled ? 'true' : 'false'
  call add(output, '  Cache enabled: ' . cache_enabled_str)
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
