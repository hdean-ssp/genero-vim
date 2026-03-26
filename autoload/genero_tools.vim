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
    call genero_tools#error#error('Lookup', 'No function name provided')
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
    " Check if result is empty
    if (type(result.data) == type([]) && empty(result.data)) || (type(result.data) == type({}) && empty(result.data))
      call genero_tools#error#warn('Lookup', 'Function not found: ' . function_name)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
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
    call genero_tools#error#error('Module', 'No module name provided')
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
    " Check if result is empty
    if (type(result.data) == type([]) && empty(result.data)) ||
       \ (type(result.data) == type({}) && empty(result.data))
      call genero_tools#error#warn('Module', 'No files found in module: ' . module_name)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
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
    call genero_tools#error#error('File', 'No file path provided')
    return {}
  endif
  
  " Convert to relative path if absolute
  let file_path = genero_tools#normalize_file_path(file_path)
  
  let cache_key = 'list-file-functions:' . file_path
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('list-file-functions', [file_path])
  
  if result.success
    " Check if result is empty
    if (type(result.data) == type([]) && empty(result.data)) || (type(result.data) == type({}) && empty(result.data))
      call genero_tools#error#warn('File', 'No functions found in file: ' . file_path)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
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
    call genero_tools#error#error('Signature', 'No function name provided')
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
    " Check if result is empty
    if (type(result.data) == type([]) && empty(result.data)) || (type(result.data) == type({}) && empty(result.data))
      call genero_tools#error#warn('Signature', 'Function not found: ' . function_name)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" Get function hover information with formatted output
" Returns three-line format: signature, file location, complexity metrics
function! genero_tools#get_function_hover(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  if empty(function_name)
    call genero_tools#error#error('Hover', 'No function name provided')
    return {}
  endif
  
  let cache_key = 'find-function-hover:' . function_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    return cached
  endif
  
  let format = genero_tools#format#get_hover_format()
  let result = genero_tools#format#execute_with_format('find-function', [function_name], format)
  
  if result.success
    " Check if result is empty
    if (type(result.data) == type('') && empty(result.data))
      call genero_tools#error#warn('Hover', 'Function not found: ' . function_name)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
  endif
  
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
    call genero_tools#error#error('Metadata', 'No file path provided')
    return {}
  endif
  
  " Convert to relative path if absolute
  let file_path = genero_tools#normalize_file_path(file_path)
  
  let cache_key = 'file-references:' . file_path
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    call genero_tools#display_result(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('file-references', [file_path])
  
  if result.success
    " Check if result is empty
    if (type(result.data) == type([]) && empty(result.data)) || (type(result.data) == type({}) && empty(result.data))
      call genero_tools#error#warn('Metadata', 'No metadata found for file: ' . file_path)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
  endif
  
  call genero_tools#display_result(result)
  return result
endfunction

" Get function signature in concise format
" Returns single-line format: function_name(params) -> return_type
function! genero_tools#get_function_concise(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  if empty(function_name)
    call genero_tools#error#error('Concise', 'No function name provided')
    return {}
  endif
  
  let cache_key = 'find-function-concise:' . function_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    return cached
  endif
  
  let format = genero_tools#format#get_concise_format()
  let result = genero_tools#format#execute_with_format('find-function', [function_name], format)
  
  if result.success
    " Check if result is empty
    if (type(result.data) == type('') && empty(result.data))
      call genero_tools#error#warn('Concise', 'Function not found: ' . function_name)
    else
      call genero_tools#cache#set(cache_key, result)
    endif
  endif
  
  return result
endfunction

" Display result using configured display mode
function! genero_tools#display_result(result) abort
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result(a:result, display_mode)
endfunction

" Get codebase path (detect project root)
function! genero_tools#get_codebase_path() abort
  return genero_tools#codebase#get_root()
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

" Normalize file path to relative format for genero-tools
" Converts absolute paths to relative paths based on codebase root
function! genero_tools#normalize_file_path(file_path) abort
  let path = a:file_path
  
  " If path is already relative, add ./ prefix if needed
  if path[0] != '/'
    if path[0:1] != './'
      let path = './' . path
    endif
    return path
  endif
  
  " For absolute paths, try to make them relative to codebase root
  let codebase_path = genero_tools#get_codebase_path()
  
  " If codebase path is found and path starts with it, make it relative
  if !empty(codebase_path) && path[0:len(codebase_path)-1] == codebase_path
    let relative = path[len(codebase_path):]
    " Remove leading slash
    if relative[0] == '/'
      let relative = relative[1:]
    endif
    return './' . relative
  endif
  
  " Fallback: just use the filename with ./ prefix
  let filename = fnamemodify(path, ':t')
  return './' . filename
endfunction
