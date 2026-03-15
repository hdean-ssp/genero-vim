" Genero-Tools Plugin - Compiler Commands

" GeneroCompile command - compile file or project
function! genero_tools#compiler#commands#compile(file_path) abort
  " Ensure compiler is initialized
  call genero_tools#compiler#init()
  
  let compiler_enabled = genero_tools#config#get('compiler_enabled')
  if !compiler_enabled
    echom 'Compiler integration is disabled. Enable with: let g:genero_tools_config.compiler_enabled = v:true'
    return
  endif
  
  " Use current file if no argument provided
  let target = empty(a:file_path) ? expand('%') : a:file_path
  
  if empty(target)
    echom 'No file to compile. Please specify a file or open a file in the editor.'
    return
  endif
  
  " Show progress
  echom 'Compiling: ' . target
  let start_time = localtime()
  
  " Execute compiler
  let result = genero_tools#compiler#execute(target)
  let elapsed = localtime() - start_time
  
  if !result.success
    echom 'Compilation failed: ' . result.error
    return
  endif
  
  " Count results
  let error_count = len(result.errors)
  let warning_count = len(result.warnings)
  let info_count = len(result.info)
  
  " Populate quickfix with all results
  let qf_result = genero_tools#compiler#quickfix#populate(result, 'all')
  
  if qf_result.success
    " Open quickfix window
    call genero_tools#compiler#quickfix#open()
    
    " Show summary
    echom 'Compilation complete (' . elapsed . 's): ' . 
          \ error_count . ' errors, ' . 
          \ warning_count . ' warnings, ' . 
          \ info_count . ' info'
  else
    echom 'Failed to populate quickfix: ' . qf_result.error
  endif
  
  " Place signs if enabled
  if genero_tools#config#get('compiler_sign_column')
    call genero_tools#compiler#signs#update(result)
  endif
endfunction

" GeneroClearErrors command - clear error markers
function! genero_tools#compiler#commands#clear_errors() abort
  " Clear quickfix list
  call genero_tools#compiler#quickfix#clear()
  
  " Clear signs
  call genero_tools#compiler#signs#clear()
  
  echom 'Compiler errors and warnings cleared'
endfunction

" GeneroNextError command - jump to next error
function! genero_tools#compiler#commands#next_error() abort
  let result = genero_tools#compiler#quickfix#next()
  
  if !result.success
    echom result.error
  endif
endfunction

" GeneroPrevError command - jump to previous error
function! genero_tools#compiler#commands#prev_error() abort
  let result = genero_tools#compiler#quickfix#prev()
  
  if !result.success
    echom result.error
  endif
endfunction

" GeneroAutocompileEnable command - enable autocompile on save
function! genero_tools#compiler#commands#autocompile_enable() abort
  call genero_tools#compiler#autocompile#enable()
endfunction

" GeneroAutocompileDisable command - disable autocompile on save
function! genero_tools#compiler#commands#autocompile_disable() abort
  call genero_tools#compiler#autocompile#disable()
endfunction

" GeneroAutocompileStatus command - show autocompile status
function! genero_tools#compiler#commands#autocompile_status() abort
  call genero_tools#compiler#autocompile#status()
endfunction
