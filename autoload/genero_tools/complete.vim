" Genero-Tools Plugin - Autocomplete Integration

" Main omnifunc for genero-tools completion
function! genero_tools#complete#omnifunc(findstart, base) abort
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
endfunction

" Get completions based on base string
function! genero_tools#complete#get_completions(base) abort
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
  
  " Use search-functions with wildcard pattern
  let search_pattern = a:pattern . '*'
  let result = genero_tools#command#execute_shell('search-functions', [search_pattern])
  
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
  
  " Use search-modules with wildcard pattern
  let search_pattern = a:pattern . '*'
  let result = genero_tools#command#execute_shell('search-modules', [search_pattern])
  
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
