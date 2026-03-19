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
  call genero_tools#config#show()
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

" GeneroCompile command - compile file or project
function! genero_tools#commands#compile(args) abort
  let file_path = empty(a:args) ? expand('%') : a:args
  
  " Initialize compiler
  call genero_tools#compiler#init()
  
  " Execute compiler
  let result = genero_tools#compiler#execute(file_path)
  
  if result.success
    " Place signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#place(result.errors, result.warnings, result.info)
    endif
    
    " Populate quickfix list
    call genero_tools#compiler#quickfix#populate(result, 'all')
    
    " Display result
    let message = 'Compilation complete: ' . len(result.errors) . ' errors, ' . 
                \ len(result.warnings) . ' warnings'
    call genero_tools#display#echo(message)
    
    " Open quickfix window if there are errors or warnings
    if len(result.errors) > 0 || len(result.warnings) > 0
      copen
    endif
  else
    echohl ErrorMsg | echo 'Compilation failed: ' . result.error | echohl None
  endif
endfunction

" GeneroClearErrors command - clear error markers
function! genero_tools#commands#clear_errors() abort
  " Clear signs
  call genero_tools#compiler#signs#clear()
  
  " Clear highlighting
  call genero_tools#compiler#highlight#clear()
  
  " Clear quickfix list
  call genero_tools#compiler#quickfix#clear()
  
  call genero_tools#display#echo('Error markers cleared.')
endfunction

" GeneroNextError command - jump to next error
function! genero_tools#commands#next_error() abort
  call genero_tools#compiler#quickfix#next()
endfunction

" GeneroPrevError command - jump to previous error
function! genero_tools#commands#prev_error() abort
  call genero_tools#compiler#quickfix#prev()
endfunction

" GeneroDebugStreamSelect command - select and open debug file
function! genero_tools#commands#debug_stream_select() abort
  call genero_tools#debug_stream#select_file()
endfunction

" GeneroDebugStreamToggle command - toggle debug streaming
function! genero_tools#commands#debug_stream_toggle(args) abort
  let file_path = empty(a:args) ? '' : a:args
  
  if empty(file_path)
    " If no file specified, show selection menu
    call genero_tools#commands#debug_stream_select()
  else
    " Use specified file
    call genero_tools#debug_stream#toggle(file_path)
  endif
endfunction
