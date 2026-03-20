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
  " Analyze on buffer read, write, and when entering a buffer
  augroup GeneroToolsHints
    autocmd!
    autocmd BufRead *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_buffer_read()
    autocmd BufWrite *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_buffer_write()
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#hints#on_buffer_enter()
  augroup END
  
  let g:genero_tools_hints_state.initialized = 1
  
  " Analyze current buffer if it's a Genero file
  if &filetype =~ '4gl\|m3\|m4\|per' || expand('%:e') =~ '4gl\|m3\|m4\|per'
    call genero_tools#hints#on_buffer_enter()
  endif
endfunction

" Register a hint detector module
" Detectors are functions that analyze code and return hints
function! genero_tools#hints#register_detector(name, Detector_Func) abort
  let g:genero_tools_hints_state.detectors[a:name] = a:Detector_Func
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
  for [detector_name, Detector_Func] in items(g:genero_tools_hints_state.detectors)
    try
      let hints = Detector_Func(bufnr, config)
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

" Autocommand handler: buffer enter
function! genero_tools#hints#on_buffer_enter() abort
  let bufnr = bufnr('%')
  
  " Check if hints are enabled
  if !genero_tools#hints#config#get('hints_enabled')
    return
  endif
  
  " Get hints (from cache or analyze)
  let hints = genero_tools#hints#get_hints(bufnr)
  
  " If no cached hints, analyze now
  if empty(hints)
    let hints = genero_tools#hints#analyze(bufnr)
  endif
  
  " Display hints
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


" Show help for a specific hint or all hints
function! genero_tools#hints#help(hint_name) abort
  if empty(a:hint_name)
    " Show help for all hints
    let help_text = [
      \ 'Available Hints:',
      \ '================',
      \ '',
      \ 'Whitespace Hints:',
      \ '  trailing_whitespace - Detects trailing whitespace at end of lines',
      \ '  mixed_indentation - Detects mixed tabs and spaces in indentation',
      \ '  multiple_blank_lines - Detects excessive consecutive blank lines',
      \ '',
      \ 'Keyword Hints:',
      \ '  lowercase_keywords - Detects lowercase Genero keywords',
      \ '  lowercase_functions - Detects lowercase function names',
      \ '  keyword_consistency - Detects inconsistent keyword casing',
      \ '',
      \ 'Structure Hints:',
      \ '  unclosed_blocks - Detects unclosed code blocks',
      \ '  nesting_depth - Detects excessive nesting depth',
      \ '  line_length - Detects lines exceeding maximum length',
      \ '',
      \ 'Genero-Specific Hints:',
      \ '  deprecated_functions - Detects use of deprecated functions',
      \ '  missing_error_handling - Detects missing error handling',
      \ '',
      \ 'Use :GeneroHintHelp <hint_name> for details on a specific hint'
      \ ]
  else
    " Show help for specific hint
    let help_text = genero_tools#hints#get_help_for_hint(a:hint_name)
  endif
  
  " Use configured display mode
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result({'success': 1, 'data': help_text}, display_mode)
endfunction

" Get help text for a specific hint
function! genero_tools#hints#get_help_for_hint(hint_name) abort
  let hints_help = {
    \ 'trailing_whitespace': [
    \   'Trailing Whitespace',
    \   '===================',
    \   'Detects whitespace characters at the end of lines.',
    \   '',
    \   'Why it matters:',
    \   '  - Trailing whitespace can cause issues with version control',
    \   '  - It increases file size unnecessarily',
    \   '  - Many coding standards prohibit trailing whitespace',
    \   '',
    \   'Auto-fix: Removes trailing whitespace from the line'
    \ ],
    \ 'mixed_indentation': [
    \   'Mixed Indentation',
    \   '=================',
    \   'Detects lines that mix tabs and spaces for indentation.',
    \   '',
    \   'Why it matters:',
    \   '  - Mixed indentation can cause display issues',
    \   '  - It makes code harder to read and maintain',
    \   '  - Most projects enforce consistent indentation',
    \   '',
    \   'Auto-fix: Converts tabs to spaces'
    \ ],
    \ 'lowercase_keywords': [
    \   'Lowercase Keywords',
    \   '==================',
    \   'Detects Genero keywords that are not uppercase.',
    \   '',
    \   'Why it matters:',
    \   '  - Genero convention is to use uppercase keywords',
    \   '  - Consistent keyword casing improves readability',
    \   '  - Many projects enforce this standard',
    \   '',
    \   'Auto-fix: Converts keywords to uppercase'
    \ ],
    \ 'unclosed_blocks': [
    \   'Unclosed Blocks',
    \   '===============',
    \   'Detects code blocks that are not properly closed.',
    \   '',
    \   'Why it matters:',
    \   '  - Unclosed blocks cause compilation errors',
    \   '  - They indicate incomplete or malformed code',
    \   '  - This is a critical code quality issue',
    \   '',
    \   'Auto-fix: Not available (requires manual review)'
    \ ],
    \ 'line_length': [
    \   'Line Length',
    \   '===========',
    \   'Detects lines that exceed the maximum configured length.',
    \   '',
    \   'Why it matters:',
    \   '  - Long lines are harder to read and maintain',
    \   '  - Many editors and terminals have line length limits',
    \   '  - Most projects enforce a maximum line length',
    \   '',
    \   'Auto-fix: Not available (requires manual refactoring)'
    \ ],
    \ 'nesting_depth': [
    \   'Excessive Nesting',
    \   '=================',
    \   'Detects code with nesting depth exceeding the configured maximum.',
    \   '',
    \   'Why it matters:',
    \   '  - Deep nesting makes code harder to understand',
    \   '  - It increases cognitive complexity',
    \   '  - Refactoring can improve code quality',
    \   '',
    \   'Auto-fix: Not available (requires manual refactoring)'
    \ ],
    \ 'deprecated_functions': [
    \   'Deprecated Functions',
    \   '====================',
    \   'Detects use of functions that are deprecated in Genero.',
    \   '',
    \   'Why it matters:',
    \   '  - Deprecated functions may be removed in future versions',
    \   '  - They may have performance or security issues',
    \   '  - Using current functions ensures compatibility',
    \   '',
    \   'Auto-fix: Not available (requires manual code review)'
    \ ]
    \ }
  
  if has_key(hints_help, a:hint_name)
    return hints_help[a:hint_name]
  else
    return ['Unknown hint: ' . a:hint_name, 'Use :GeneroHintHelp to see all available hints']
  endif
endfunction
