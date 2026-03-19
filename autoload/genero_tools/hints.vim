" Genero-Tools Plugin - Hint Engine Core Module
" Orchestrates the hint system for code quality analysis

" Initialize hint engine state
if !exists('g:genero_tools_hints_state')
  let g:genero_tools_hints_state = {
    \ 'initialized': 0,
    \ 'detectors': {},
    \ 'buffer_hints': {},
    \ 'debounce_timers': {}
    \ }
endif

" Initialize the hint system
" Sets up configuration, detectors, and autocommands
function! genero_tools#hints#init() abort
  if g:genero_tools_hints_state.initialized
    return
  endif
  
  " Initialize hint configuration with defaults
  call genero_tools#hints#config#init()
  
  " Initialize cache system for hints
  call genero_tools#hints#cache#init()
  
  " Initialize display system
  call genero_tools#hints#display#init()
  
  " Register built-in detectors
  call genero_tools#hints#register_detector('whitespace', function('genero_tools#hints#whitespace#detect'))
  call genero_tools#hints#register_detector('keyword', function('genero_tools#hints#keyword#detect'))
  call genero_tools#hints#register_detector('structure', function('genero_tools#hints#structure#detect'))
  call genero_tools#hints#register_detector('genero', function('genero_tools#hints#genero#detect'))
  
  " Set up autocommands for hint analysis
  augroup GeneroToolsHints
    autocmd!
    autocmd BufRead *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_buffer_read()
    autocmd BufWrite *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_buffer_write()
    autocmd TextChanged *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_text_changed()
    autocmd TextChangedI *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_text_changed()
  augroup END
  
  let g:genero_tools_hints_state.initialized = 1
endfunction

" Register a hint detector module
" Detectors are functions that analyze code and return hints
function! genero_tools#hints#register_detector(name, detector_func) abort
  let g:genero_tools_hints_state.detectors[a:name] = a:detector_func
endfunction

" Analyze a buffer and return all hints
" Checks cache first, then runs all enabled detectors
function! genero_tools#hints#analyze(bufnr) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  " Check if hints are enabled
  if !genero_tools#hints#config#get('hints_enabled')
    return []
  endif
  
  " Try to get cached hints
  let cached_hints = genero_tools#hints#cache#get(bufnr)
  if !empty(cached_hints)
    return cached_hints
  endif
  
  " Get effective configuration for this buffer
  let config = genero_tools#hints#config#get_for_buffer(bufnr)
  
  " Run all enabled detectors
  let all_hints = []
  for [detector_name, detector_func] in items(g:genero_tools_hints_state.detectors)
    try
      let hints = detector_func(bufnr, config)
      if !empty(hints)
        let all_hints = all_hints + hints
      endif
    catch
      " Log error but continue with other detectors
      call genero_tools#error#debug('hints', 'Detector ' . detector_name . ' failed: ' . v:exception)
    endtry
  endfor
  
  " Store in cache
  call genero_tools#hints#cache#set(bufnr, all_hints)
  
  " Store in buffer state
  let g:genero_tools_hints_state.buffer_hints[bufnr] = all_hints
  
  return all_hints
endfunction

" Get cached hints for a buffer without re-analyzing
function! genero_tools#hints#get_hints(bufnr) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  " Return from buffer state if available
  if has_key(g:genero_tools_hints_state.buffer_hints, bufnr)
    return g:genero_tools_hints_state.buffer_hints[bufnr]
  endif
  
  " Try cache
  let cached = genero_tools#hints#cache#get(bufnr)
  if !empty(cached)
    let g:genero_tools_hints_state.buffer_hints[bufnr] = cached
    return cached
  endif
  
  return []
endfunction

" Clear all hints for a buffer
function! genero_tools#hints#clear(bufnr) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  " Clear from display
  call genero_tools#hints#display#clear(bufnr)
  
  " Clear from cache
  call genero_tools#hints#cache#invalidate(bufnr)
  
  " Clear from buffer state
  if has_key(g:genero_tools_hints_state.buffer_hints, bufnr)
    call remove(g:genero_tools_hints_state.buffer_hints, bufnr)
  endif
endfunction

" Autocommand handler: buffer read
function! genero_tools#hints#on_buffer_read() abort
  let bufnr = bufnr('%')
  
  " Analyze buffer and display hints
  let hints = genero_tools#hints#analyze(bufnr)
  call genero_tools#hints#display#show(bufnr, hints)
endfunction

" Autocommand handler: buffer write
function! genero_tools#hints#on_buffer_write() abort
  let bufnr = bufnr('%')
  
  " Invalidate cache for this buffer
  call genero_tools#hints#cache#invalidate(bufnr)
  
  " Re-analyze and display
  let hints = genero_tools#hints#analyze(bufnr)
  call genero_tools#hints#display#show(bufnr, hints)
endfunction

" Autocommand handler: text changed (with debouncing)
function! genero_tools#hints#on_text_changed() abort
  if !genero_tools#hints#config#get('hints_realtime')
    return
  endif
  
  let bufnr = bufnr('%')
  let delay = genero_tools#hints#config#get('hints_delay')
  
  " Cancel existing timer if any
  if has_key(g:genero_tools_hints_state.debounce_timers, bufnr)
    call timer_stop(g:genero_tools_hints_state.debounce_timers[bufnr])
  endif
  
  " Set new debounced timer
  let timer_id = timer_start(delay, function('genero_tools#hints#debounce_callback', [bufnr]))
  let g:genero_tools_hints_state.debounce_timers[bufnr] = timer_id
endfunction

" Debounce callback for text changed events
function! genero_tools#hints#debounce_callback(bufnr, timer_id) abort
  " Remove timer from tracking
  if has_key(g:genero_tools_hints_state.debounce_timers, a:bufnr)
    call remove(g:genero_tools_hints_state.debounce_timers, a:bufnr)
  endif
  
  " Check if buffer still exists
  if !bufexists(a:bufnr)
    return
  endif
  
  " Invalidate cache and re-analyze
  call genero_tools#hints#cache#invalidate(a:bufnr)
  let hints = genero_tools#hints#analyze(a:bufnr)
  call genero_tools#hints#display#show(a:bufnr, hints)
endfunction

" Create a hint dictionary
" Helper function for detectors to create properly formatted hints
function! genero_tools#hints#create_hint(line, col, message, category, check, severity) abort
  return {
    \ 'line': a:line,
    \ 'column': a:col,
    \ 'message': a:message,
    \ 'category': a:category,
    \ 'check': a:check,
    \ 'severity': a:severity,
    \ 'auto_fix': {}
    \ }
endfunction
