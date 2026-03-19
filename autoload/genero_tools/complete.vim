" Genero-Tools Plugin - Autocomplete Integration

" Autocomplete state
let s:autocomplete_state = {
  \ 'timer_id': -1,
  \ 'last_col': -1,
  \ 'last_line': -1
  \ }

" Main omnifunc for genero-tools completion
function! genero_tools#complete#omnifunc(findstart, base) abort
  try
    if a:findstart
      " Find the start of the word to complete
      let line = getline('.')
      let col = col('.') - 1
      
      " Find start of identifier (word characters, dots, underscores)
      while col > 0 && line[col - 1] =~# '[a-zA-Z0-9_.]'
        let col -= 1
      endwhile
      
      return col
    else
      " Return list of completions
      return genero_tools#complete#get_completions(a:base)
    endif
  catch
    " Silently handle errors in completion
    return a:findstart ? -1 : []
  endtry
endfunction

" Get completions based on base string
function! genero_tools#complete#get_completions(base) abort
  try
    if empty(a:base)
      return []
    endif
    
    let completions = []
    
    " Search for functions matching the base
    let func_results = genero_tools#complete#search_functions(a:base)
    for func in func_results
      call add(completions, {
        \ 'word': func.name,
        \ 'abbr': func.name,
        \ 'menu': 'Function',
        \ 'info': func.signature,
        \ 'kind': 'f',
        \ 'icase': 1
        \ })
    endfor
    
    " Search for modules matching the base
    let module_results = genero_tools#complete#search_modules(a:base)
    for module in module_results
      call add(completions, {
        \ 'word': module.name,
        \ 'abbr': module.name,
        \ 'menu': 'Module',
        \ 'info': 'Module: ' . module.name,
        \ 'kind': 'm',
        \ 'icase': 1
        \ })
    endfor
    
    return completions
  catch
    " Silently handle errors in completion
    return []
  endtry
endfunction

" Search for functions matching pattern
function! genero_tools#complete#search_functions(pattern) abort
  if len(a:pattern) < 1
    return []
  endif
  
  let cache_key = 'search-functions:' . a:pattern
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    return cached.data
  endif
  
  " search-functions does substring matching, no wildcard needed
  let result = genero_tools#command#execute_shell('search-functions', [a:pattern])
  
  if result.success && type(result.data) == type([])
    call genero_tools#cache#set(cache_key, result)
    return result.data
  endif
  
  return []
endfunction

" Search for modules matching pattern
function! genero_tools#complete#search_modules(pattern) abort
  if len(a:pattern) < 1
    return []
  endif
  
  let cache_key = 'search-modules:' . a:pattern
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    return cached.data
  endif
  
  " search-modules does substring matching, no wildcard needed
  let result = genero_tools#command#execute_shell('search-modules', [a:pattern])
  
  if result.success && type(result.data) == type([])
    call genero_tools#cache#set(cache_key, result)
    return result.data
  endif
  
  return []
endfunction

" Enable genero-tools completion for current buffer
function! genero_tools#complete#enable() abort
  setlocal omnifunc=genero_tools#complete#omnifunc
endfunction

" Disable genero-tools completion for current buffer
function! genero_tools#complete#disable() abort
  setlocal omnifunc=
endfunction

" Setup auto-completion on pause
function! genero_tools#complete#setup_auto() abort
  if !genero_tools#config#get('autocomplete_on_pause')
    return
  endif
  
  " Set omnifunc
  call genero_tools#complete#enable()
  
  " Setup autocmd for text changed
  augroup GeneroAutoComplete
    autocmd!
    autocmd TextChangedI <buffer> call s:on_text_changed()
  augroup END
endfunction

" Handle text changed event
function! s:on_text_changed() abort
  " Cancel existing timer
  if s:autocomplete_state.timer_id != -1
    call timer_stop(s:autocomplete_state.timer_id)
    let s:autocomplete_state.timer_id = -1
  endif
  
  " Get current position
  let current_col = col('.')
  let current_line = line('.')
  
  " Check if we're in an identifier
  let line = getline('.')
  let char_before = current_col > 1 ? line[current_col - 2] : ''
  
  " Only trigger if we're typing an identifier
  if char_before =~# '[a-zA-Z0-9_.]'
    let delay = genero_tools#config#get('autocomplete_delay')
    let s:autocomplete_state.timer_id = timer_start(delay, function('s:trigger_autocomplete'))
    let s:autocomplete_state.last_col = current_col
    let s:autocomplete_state.last_line = current_line
  endif
endfunction

" Trigger autocomplete
function! s:trigger_autocomplete(timer_id) abort
  let s:autocomplete_state.timer_id = -1
  
  " Check if cursor position hasn't changed
  if col('.') == s:autocomplete_state.last_col && line('.') == s:autocomplete_state.last_line
    " Ensure our omnifunc is set
    setlocal omnifunc=genero_tools#complete#omnifunc
    " Trigger completion
    call feedkeys("\<C-x>\<C-o>", 'n')
  endif
endfunction
