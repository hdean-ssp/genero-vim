" Genero-Tools Plugin - User-Facing Commands

" GeneroLookup command - lookup function definition
function! genero_tools#commands#lookup(args) abort
  let function_name = empty(a:args) ? expand('<cword>') : a:args
  call genero_tools#lookup_function(function_name)
endfunction

" GeneroListModuleFiles command - list files in module
function! genero_tools#commands#list_module_files(args) abort
  let module_name = empty(a:args) ? genero_tools#get_current_module() : a:args
  call genero_tools#list_module_files(module_name)
endfunction

" GeneroListFunctions command - list functions in file
function! genero_tools#commands#list_functions(args) abort
  let file_path = empty(a:args) ? expand('%') : a:args
  call genero_tools#list_functions_in_file(file_path)
endfunction

" GeneroFunctionSignature command - get function signature
function! genero_tools#commands#function_signature(args) abort
  let function_name = empty(a:args) ? expand('<cword>') : a:args
  call genero_tools#get_function_signature(function_name)
endfunction

" GeneroFileMetadata command - get file metadata
function! genero_tools#commands#file_metadata(args) abort
  let file_path = empty(a:args) ? expand('%') : a:args
  call genero_tools#get_file_metadata(file_path)
endfunction

" GeneroConfigShow command - display current configuration
function! genero_tools#commands#config_show() abort
  let config = genero_tools#config#get_all()
  let lines = ['=== Genero-Tools Configuration ===', '']
  
  for [key, value] in items(config)
    if type(value) == type(v:true)
      let value_str = value ? 'true' : 'false'
    else
      let value_str = string(value)
    endif
    call add(lines, key . ': ' . value_str)
  endfor
  
  call add(lines, '')
  let cache_stats = genero_tools#cache#stats()
  call add(lines, '=== Cache Statistics ===')
  call add(lines, 'Cache size: ' . cache_stats.size . ' / ' . cache_stats.max_size)
  call add(lines, 'Cache enabled: ' . (cache_stats.enabled ? 'true' : 'false'))
  call add(lines, 'Cache TTL: ' . cache_stats.ttl . 'ms')
  
  let memory_usage = genero_tools#cache#estimate_memory()
  call add(lines, 'Estimated memory: ' . memory_usage . 'KB')
  
  call add(lines, '')
  call add(lines, '=== Supported Display Modes ===')
  let supported_modes = genero_tools#compat#get_supported_display_modes()
  call add(lines, 'Available: ' . join(supported_modes, ', '))
  
  call genero_tools#display#echo(join(lines, "\n"))
endfunction

" GeneroClearCache command - clear cache
function! genero_tools#commands#clear_cache() abort
  call genero_tools#cache#clear()
  let stats = genero_tools#cache#stats()
  call genero_tools#display#echo('Cache cleared. Current size: ' . stats.size)
endfunction

" GeneroHandleMemoryPressure command - handle memory pressure
function! genero_tools#commands#handle_memory_pressure() abort
  let cleared = genero_tools#cache#handle_memory_pressure()
  call genero_tools#display#echo('Memory pressure handled. Cleared ' . cleared . ' expired entries.')
endfunction
