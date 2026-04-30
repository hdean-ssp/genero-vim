" Genero-Tools Plugin - Compiler Commands

" GeneroCompile command - compile file or project
function! genero_tools#compiler#commands#compile(file_path) abort
  " Ensure compiler is initialized
  call genero_tools#compiler#init()
  
  let compiler_enabled = genero_tools#config#get('compiler_enabled')
  if !compiler_enabled
    echom 'Compiler integration is disabled. Enable with: let g:genero_tools_config.compiler_enabled = 1'
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
    " Even on failure, try to show any raw output in quickfix
    if !empty(result.output)
      let raw_entries = []
      for raw_line in split(result.output, "\n")
        if !empty(raw_line)
          call add(raw_entries, {'filename': target, 'lnum': 1, 'text': raw_line, 'type': 'E'})
        endif
      endfor
      if !empty(raw_entries)
        call setqflist(raw_entries)
        silent! copen
      endif
    endif
    call genero_tools#error#display('Compilation Failed', result.error)
    return
  endif
  
  " Count results
  let error_count = len(result.errors)
  let warning_count = len(result.warnings)
  let info_count = len(result.info)
  
  " Store result for later filtering
  let g:genero_tools_last_compile_result = result
  
  " Populate quickfix with results (respects compiler_show_errors/warnings config)
  let qf_result = genero_tools#compiler#quickfix#populate(result, 'all')
  
  " Always open quickfix window so users can navigate errors
  if qf_result.count > 0
    call genero_tools#compiler#quickfix#open()
    " Jump to first error
    silent! cfirst
  else
    " Close quickfix if no results
    silent! cclose
  endif
  
  " Show summary
  echom 'Compilation complete (' . elapsed . 's): ' . 
        \ error_count . ' errors, ' . 
        \ warning_count . ' warnings, ' . 
        \ info_count . ' info'
  
  " Place signs if enabled
  if genero_tools#config#get('compiler_sign_column')
    call genero_tools#compiler#signs#update(result)
  endif
  
  " Apply error/warning highlighting
  call genero_tools#compiler#highlight#apply(result.errors, result.warnings)
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
    call genero_tools#error#display('Navigation Error', result.error)
  endif
endfunction

" GeneroPrevError command - jump to previous error
function! genero_tools#compiler#commands#prev_error() abort
  let result = genero_tools#compiler#quickfix#prev()
  
  if !result.success
    call genero_tools#error#display('Navigation Error', result.error)
  endif
endfunction

" GeneroFirstError command - jump to first error
function! genero_tools#compiler#commands#first_error() abort
  let result = genero_tools#compiler#quickfix#first()
  
  if !result.success
    call genero_tools#error#display('Navigation Error', result.error)
  endif
endfunction

" GeneroLastError command - jump to last error
function! genero_tools#compiler#commands#last_error() abort
  let result = genero_tools#compiler#quickfix#last()
  
  if !result.success
    call genero_tools#error#display('Navigation Error', result.error)
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

" GeneroFilterErrors command - show only errors in quickfix
function! genero_tools#compiler#commands#filter_errors() abort
  if !exists('g:genero_tools_last_compile_result')
    call genero_tools#error#warn('compiler', 'No compilation results. Run :GeneroCompile first.')
    return
  endif
  call genero_tools#compiler#quickfix#populate(g:genero_tools_last_compile_result, 'errors')
  let count = len(get(g:genero_tools_last_compile_result, 'errors', []))
  if count > 0
    call genero_tools#compiler#quickfix#open()
    silent! cfirst
  else
    silent! cclose
  endif
  echom 'Showing ' . count . ' errors'
endfunction

" GeneroFilterWarnings command - show only warnings in quickfix
function! genero_tools#compiler#commands#filter_warnings() abort
  if !exists('g:genero_tools_last_compile_result')
    call genero_tools#error#warn('compiler', 'No compilation results. Run :GeneroCompile first.')
    return
  endif
  call genero_tools#compiler#quickfix#populate(g:genero_tools_last_compile_result, 'warnings')
  let count = len(get(g:genero_tools_last_compile_result, 'warnings', []))
  if count > 0
    call genero_tools#compiler#quickfix#open()
    silent! cfirst
  else
    silent! cclose
  endif
  echom 'Showing ' . count . ' warnings'
endfunction

" GeneroFilterAll command - show all errors and warnings in quickfix
function! genero_tools#compiler#commands#filter_all() abort
  if !exists('g:genero_tools_last_compile_result')
    call genero_tools#error#warn('compiler', 'No compilation results. Run :GeneroCompile first.')
    return
  endif
  call genero_tools#compiler#quickfix#populate(g:genero_tools_last_compile_result, 'all')
  let count = len(getqflist())
  if count > 0
    call genero_tools#compiler#quickfix#open()
    silent! cfirst
  else
    silent! cclose
  endif
  echom 'Showing all ' . count . ' diagnostics'
endfunction
