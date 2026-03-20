" Genero-Tools Plugin - Autocomplete Integration

" Autocomplete state
let s:autocomplete_state = {
  \ 'timer_id': -1,
  \ 'last_col': -1,
  \ 'last_line': -1,
  \ 'external_query_timer': -1,
  \ 'last_base': '',
  \ 'external_results': []
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
    if len(a:base) < 2
      return []
    endif
    
    let completions = []
    
    " Get functions from current file
    let current_file = expand('%:p')
    let file_path = genero_tools#normalize_file_path(current_file)
    
    let cache_key = 'list-file-functions:' . file_path
    let cached = genero_tools#cache#get(cache_key)
    
    if empty(cached)
      let result = genero_tools#command#execute_shell('list-file-functions', [file_path])
      if result.success
        call genero_tools#cache#set(cache_key, result)
        let file_functions = result.data
      else
        return []
      endif
    else
      let file_functions = cached.data
    endif
    
    " Filter current file functions matching the base
    if type(file_functions) == type([])
      for func in file_functions
        if type(func) == type({}) && has_key(func, 'name')
          if func.name =~? '^' . a:base
            " Format complete info for hover/selection
            let complete_info = genero_tools#signature#format_complete_info(func)
            let param_count = genero_tools#signature#param_count(func)
            let return_count = genero_tools#signature#return_count(func)
            
            " Format menu label with parameter count
            let menu_label = func.name . '(' . param_count . ' params)'
            if return_count > 0
              let menu_label .= ' -> ' . return_count . ' return'
              if return_count != 1
                let menu_label .= 's'
              endif
            endif
            
            call add(completions, {
              \ 'word': func.name,
              \ 'abbr': func.name,
              \ 'menu': menu_label,
              \ 'info': complete_info,
              \ 'kind': 'f',
              \ 'icase': 1,
              \ 'dup': 1
              \ })
          endif
        endif
      endfor
    endif
    
    " If no current file matches, query external files
    if empty(completions)
      let external = genero_tools#complete#get_external_completions(a:base)
      let completions = external
    else
      " Store base for potential external query
      let s:autocomplete_state.last_base = a:base
    endif
    
    return completions
  catch
    return []
  endtry
endfunction

" Get completions from external files (project-wide)
function! genero_tools#complete#get_external_completions(base) abort
  try
    if len(a:base) < 2
      return []
    endif
    
    " Check if we have cached external results for this base
    if s:autocomplete_state.last_base == a:base && !empty(s:autocomplete_state.external_results)
      return s:autocomplete_state.external_results
    endif
    
    let completions = []
    
    " Search project-wide functions
    let cache_key = 'search-functions:' . a:base
    let cached = genero_tools#cache#get(cache_key)
    
    if empty(cached)
      let result = genero_tools#command#execute_shell('search-functions', [a:base . '*'])
      if result.success
        call genero_tools#cache#set(cache_key, result)
        let search_results = result.data
      else
        return []
      endif
    else
      let search_results = cached.data
    endif
    
    " Filter and limit to top 10-20 closest matches
    let current_file = expand('%:p')
    let matches = []
    
    if type(search_results) == type([])
      for func in search_results
        if type(func) == type({}) && has_key(func, 'name')
          " Skip functions from current file (already shown)
          let func_file = get(func, 'file', '')
          if func_file != current_file
            if func.name =~? '^' . a:base
              call add(matches, func)
            endif
          endif
        endif
      endfor
    endif
    
    " Sort by relevance (exact prefix match first, then substring)
    let exact_matches = filter(copy(matches), 'v:val.name =~? "^' . a:base . '$"')
    let prefix_matches = filter(copy(matches), 'v:val.name =~? "^' . a:base . '" && v:val.name !=? "' . a:base . '"')
    let other_matches = filter(copy(matches), 'v:val.name !~? "^' . a:base . '"')
    
    let sorted_matches = exact_matches + prefix_matches + other_matches
    
    " Limit to 20 results
    let limited_matches = sorted_matches[0:19]
    
    " Format completions
    for func in limited_matches
      " Format complete info for hover/selection
      let complete_info = genero_tools#signature#format_complete_info(func)
      let param_count = genero_tools#signature#param_count(func)
      let return_count = genero_tools#signature#return_count(func)
      
      " Format menu label with parameter count
      let menu_label = func.name . '(' . param_count . ' params)'
      if return_count > 0
        let menu_label .= ' -> ' . return_count . ' return'
        if return_count != 1
          let menu_label .= 's'
        endif
      endif
      
      call add(completions, {
        \ 'word': func.name,
        \ 'abbr': func.name,
        \ 'menu': menu_label,
        \ 'info': complete_info,
        \ 'kind': 'f',
        \ 'icase': 1,
        \ 'dup': 1
        \ })
    endfor
    
    " Cache external results
    let s:autocomplete_state.external_results = completions
    
    return completions
  catch
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
    autocmd InsertLeave <buffer> call s:close_completion()
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
  
  " Only trigger if we're typing an identifier (at least 2 chars)
  if char_before =~# '[a-zA-Z0-9_.]'
    let word_start = current_col - 1
    while word_start > 0 && line[word_start - 1] =~# '[a-zA-Z0-9_.]'
      let word_start -= 1
    endwhile
    let word_len = current_col - word_start - 1
    
    " Only trigger if we have at least 2 characters
    if word_len >= 2
      let delay = genero_tools#config#get('autocomplete_delay')
      let s:autocomplete_state.timer_id = timer_start(delay, function('s:trigger_autocomplete'))
      let s:autocomplete_state.last_col = current_col
      let s:autocomplete_state.last_line = current_line
    endif
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

" Close completion menu
function! s:close_completion() abort
  if pumvisible()
    call feedkeys("\<C-e>", 'n')
  endif
endfunction
