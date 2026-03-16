" Genero-Tools Plugin - Compiler Autocompile on Save

let s:autocompile_timer = -1
let s:last_compiled_file = ''

" Enable autocompile for current buffer
function! genero_tools#compiler#autocompile#enable() abort
  if !genero_tools#config#get('compiler_enabled')
    echom 'Compiler integration is disabled. Enable with: let g:genero_tools_config.compiler_enabled = v:true'
    return
  endif
  
  " Set up autocommand for current buffer
  augroup genero_compiler_autocompile
    autocmd!
    autocmd BufWritePost <buffer> call genero_tools#compiler#autocompile#on_save()
  augroup END
  
  echom 'Autocompile enabled for current buffer'
endfunction

" Disable autocompile for current buffer
function! genero_tools#compiler#autocompile#disable() abort
  augroup genero_compiler_autocompile
    autocmd! BufWritePost <buffer>
  augroup END
  
  echom 'Autocompile disabled for current buffer'
endfunction

" Handle file save event
function! genero_tools#compiler#autocompile#on_save() abort
  if !genero_tools#config#get('compiler_enabled')
    return
  endif
  
  if !genero_tools#config#get('compiler_autocompile')
    return
  endif
  
  let current_file = expand('%')
  
  if empty(current_file)
    return
  endif
  
  " Cancel previous timer if still pending
  if s:autocompile_timer != -1
    call timer_stop(s:autocompile_timer)
  endif
  
  " Schedule compilation with delay to avoid multiple compilations
  let delay = genero_tools#config#get('compiler_autocompile_delay')
  let s:autocompile_timer = timer_start(delay, function('genero_tools#compiler#autocompile#compile_delayed', [current_file]))
endfunction

" Delayed compilation callback
function! genero_tools#compiler#autocompile#compile_delayed(file, timer_id) abort
  let s:autocompile_timer = -1
  
  " Only compile if file hasn't changed
  if expand('%') != a:file
    return
  endif
  
  " Compile silently (no messages)
  call genero_tools#compiler#autocompile#compile_silent(a:file)
endfunction

" Compile file silently and update markers
function! genero_tools#compiler#autocompile#compile_silent(file) abort
  try
    let result = genero_tools#compiler#execute(a:file)
    
    if result.success
      " Update signs if enabled
      if genero_tools#config#get('compiler_sign_column')
        call genero_tools#compiler#signs#update(result)
      endif
      
      " Update highlighting if enabled
      if genero_tools#config#get('compiler_highlight_unused')
        call genero_tools#compiler#highlight#unused_vars(result.warnings)
      endif
      
      " Update quickfix if there are errors/warnings
      let error_count = len(result.errors)
      let warning_count = len(result.warnings)
      
      if error_count > 0 || warning_count > 0
        " Populate quickfix with all results
        call genero_tools#compiler#quickfix#populate(result, 'all')
      else
        " Clear quickfix if no errors
        call genero_tools#compiler#quickfix#clear()
      endif
    endif
  catch
    " Silently ignore compilation errors during autocompile
  endtry
endfunction

" Get autocompile status
function! genero_tools#compiler#autocompile#status() abort
  let enabled = genero_tools#config#get('compiler_autocompile')
  let delay = genero_tools#config#get('compiler_autocompile_delay')
  
  if enabled
    echom 'Autocompile is enabled (delay: ' . delay . 'ms)'
  else
    echom 'Autocompile is disabled'
  endif
endfunction
