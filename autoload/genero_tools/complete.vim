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
    if len(a:base) < 2
      return []
    endif
    
    let completions = []
    
    " Add snippets to completions if enabled
    if genero_tools#config#get('autocomplete_include_snippets')
      let snippet_completions = genero_tools#complete#get_snippet_completions(a:base)
      let completions = extend(completions, snippet_completions)
    endif
    
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
        let file_functions = []
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
            
            " Format menu label with parameter count only
            let menu_label = '(' . param_count . ' params)'
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
    
    " Only query external files if no matches found in current file
    if empty(completions)
      let external = genero_tools#complete#get_external_completions(a:base)
      let completions = external
    endif
    
    return completions
  catch
    return []
  endtry
endfunction

" Get snippet completions for autocomplete menu
function! genero_tools#complete#get_snippet_completions(base) abort
  if !has('nvim') || !genero_tools#lua_bridge#available()
    return []
  endif
  
  try
    if !genero_tools#config#get('snippets_enabled')
      return []
    endif
    
    " Get all snippets from Lua
    let snippets = luaeval('require("genero_tools.snippets").get_all_snippets()')
    
    if empty(snippets) || type(snippets) != type([])
      return []
    endif
    
    let completions = []
    
    " Filter snippets matching the base
    for snippet in snippets
      let trigger = get(snippet, 'trigger', '')
      let description = get(snippet, 'description', '')
      
      if !empty(trigger) && trigger =~? '^' . a:base
        call add(completions, {
          \ 'word': trigger,
          \ 'abbr': trigger,
          \ 'menu': '[snippet] ' . description,
          \ 'kind': 's',
          \ 'icase': 1,
          \ 'dup': 0,
          \ 'user_data': json_encode({'type': 'snippet', 'trigger': trigger})
          \ })
      endif
    endfor
    
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
    
    let completions = []
    let current_file = expand('%:p')
    
    " Search project-wide functions using query.sh
    let result = genero_tools#command#execute_shell('search-functions', [a:base])
    
    if !result.success
      return []
    endif
    
    let search_results = result.data
    
    if type(search_results) != type([])
      return []
    endif
    
    " Filter results: only include functions from other files that match the base
    let matches = []
    for func in search_results
      if type(func) == type({}) && has_key(func, 'name')
        let func_file = get(func, 'file', '')
        " Include functions from other files that start with the base
        if func_file != current_file && func.name =~? '^' . a:base
          call add(matches, func)
        endif
      endif
    endfor
    
    " Limit to 20 results
    let limited_matches = matches[0:19]
    
    " Format completions
    for func in limited_matches
      let complete_info = genero_tools#signature#format_complete_info(func)
      let param_count = genero_tools#signature#param_count(func)
      let return_count = genero_tools#signature#return_count(func)
      
      " Format menu label with parameter count only (no duplicate function name)
      let menu_label = '(' . param_count . ' params)'
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
  " Always set omnifunc for Ctrl+N to work
  call genero_tools#complete#enable()
  
  " Clear any existing autocmds for this buffer
  augroup GeneroAutoComplete
    autocmd! * <buffer>
  augroup END
  
  " Only setup pause-based autocomplete if explicitly enabled
  if !genero_tools#config#get('autocomplete_on_pause')
    return
  endif
  
  " Setup autocmd for text changed
  augroup GeneroAutoComplete
    autocmd!
    autocmd TextChangedI <buffer> call s:on_text_changed()
    autocmd InsertLeave <buffer> call s:close_completion()
  augroup END
endfunction

" Setup completion preview window
function! genero_tools#complete#setup_preview() abort
  " Enable preview window for completion info (buffer-local)
  " menu: show completion menu
  " menuone: show menu even with single match
  " preview: show preview window with info
  " noinsert: don't insert text until selection
  " noselect: don't auto-select first item
  setlocal completeopt=menu,menuone,preview,noinsert,noselect
  
  " Ensure preview window is visible and properly sized
  set previewheight=10
endfunction

" Handle text changed event
function! s:on_text_changed() abort
  " Guard: only run if pause-based autocomplete is enabled
  if !genero_tools#config#get('autocomplete_on_pause')
    return
  endif
  
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

" Handle snippet selection from autocomplete menu
function! genero_tools#complete#on_snippet_selected(snippet_trigger) abort
  if !has('nvim') || !genero_tools#lua_bridge#available()
    return
  endif
  
  try
    " Close the completion menu
    call feedkeys("\<C-e>", 'n')
    
    " Delete the trigger text that was inserted
    let trigger_len = len(a:snippet_trigger)
    call feedkeys("\<C-w>", 'n')
    
    " Expand the snippet using luasnip
    call genero_tools#snippets#expand(a:snippet_trigger)
  catch
    call genero_tools#error#error('Snippets', 'Error selecting snippet: ' . v:exception)
  endtry
endfunction

" Setup completion callback for snippet expansion
function! genero_tools#complete#setup_completion_callback() abort
  if !has('nvim')
    return
  endif
  
  " Setup CompleteDone autocommand to handle snippet expansion
  augroup GeneroSnippetCompletion
    autocmd!
    autocmd CompleteDone * call genero_tools#complete#handle_completion_done()
  augroup END
endfunction

" Handle completion done event - expand snippets if selected
function! genero_tools#complete#handle_completion_done() abort
  if !has('nvim') || !genero_tools#lua_bridge#available()
    return
  endif
  
  try
    " Get the completed item info
    let completed_item = v:completed_item
    
    if empty(completed_item)
      return
    endif
    
    " Check if this is a snippet completion
    let user_data = get(completed_item, 'user_data', '')
    if empty(user_data)
      return
    endif
    
    " Parse user_data to check if it's a snippet
    try
      let data = json_decode(user_data)
      if get(data, 'type', '') == 'snippet'
        let trigger = get(data, 'trigger', '')
        if !empty(trigger)
          " Get current position after completion inserted the trigger
          let row = line('.')
          let col = col('.')
          
          " Get the line content
          let line = getline('.')
          
          " The trigger was just inserted, so it ends at col-1
          " We need to delete it and then expand the snippet
          let trigger_len = len(trigger)
          let word_start = col - trigger_len - 1
          
          " Validate position
          if word_start >= 0 && word_start + trigger_len <= len(line)
            " Delete the trigger text by selecting it and deleting
            call cursor(row, word_start + 1)
            " Use 'x' command to delete characters
            for i in range(trigger_len)
              execute 'normal! x'
            endfor
            
            " Now expand the snippet at the correct position
            call genero_tools#snippets#expand(trigger)
          endif
        endif
      endif
    catch
      " Silently ignore JSON parse errors
    endtry
  catch
    " Silently handle errors
  endtry
endfunction
