" Genero-Tools Plugin - Core Module
" Provides main API functions for code lookup and navigation

" Lookup a function definition
function! genero_tools#lookup_function(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  if empty(function_name)
    call genero_tools#display#echo('Error: No function name provided')
    return {}
  endif
  
  let cache_key = 'find-function:' . function_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('find-function', [function_name])
  
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" List all files in a module
function! genero_tools#list_module_files(module_name) abort
  if empty(a:module_name)
    let module_name = genero_tools#get_current_module()
  else
    let module_name = a:module_name
  endif
  
  if empty(module_name)
    call genero_tools#display#echo('Error: No module name provided')
    return {}
  endif
  
  let cache_key = 'find-functions-in-module:' . module_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('find-functions-in-module', [module_name])
  
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" List all functions in a file
function! genero_tools#list_functions_in_file(file_path) abort
  if empty(a:file_path)
    let file_path = expand('%')
  else
    let file_path = a:file_path
  endif
  
  if empty(file_path)
    call genero_tools#display#echo('Error: No file path provided')
    return {}
  endif
  
  let cache_key = 'list-file-functions:' . file_path
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('list-file-functions', [file_path])
  
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" Get function signature
function! genero_tools#get_function_signature(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  if empty(function_name)
    call genero_tools#display#echo('Error: No function name provided')
    return {}
  endif
  
  let cache_key = 'find-function:' . function_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('find-function', [function_name])
  
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" Get file metadata
function! genero_tools#get_file_metadata(file_path) abort
  if empty(a:file_path)
    let file_path = expand('%')
  else
    let file_path = a:file_path
  endif
  
  if empty(file_path)
    call genero_tools#display#echo('Error: No file path provided')
    return {}
  endif
  
  let cache_key = 'file-references:' . file_path
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('file-references', [file_path])
  
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" Display result using configured display mode
function! genero_tools#display_result(result) abort
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result(a:result, display_mode)
endfunction

" Get codebase path (detect project root)
function! genero_tools#get_codebase_path() abort
  " Search for genero project markers
  let markers = ['genero.conf', '.genero', '.git']
  let current_dir = expand('%:p:h')
  
  for marker in markers
    let marker_path = finddir(marker, current_dir . ';')
    if !empty(marker_path)
      return fnamemodify(marker_path, ':h')
    endif
  endfor
  
  " Fall back to current working directory
  return getcwd()
endfunction

" Get current module from file path
function! genero_tools#get_current_module() abort
  let file_path = expand('%')
  if empty(file_path)
    return ''
  endif
  
  " Extract module name from file path (e.g., mymodule.m3)
  let parts = split(file_path, '/')
  if len(parts) > 0
    return parts[-1]
  endif
  
  return ''
endfunction
