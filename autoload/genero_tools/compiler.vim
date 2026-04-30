" Genero-Tools Plugin - Compiler Integration

" Detect file type based on extension
function! genero_tools#compiler#detect_file_type(file_path) abort
  if a:file_path =~? '\.per$'
    return 'per'
  elseif a:file_path =~? '\.\(4gl\|m3\|m4\)$'
    return 'fgl'
  else
    return 'unknown'
  endif
endfunction

" Get compiler command for file type
function! genero_tools#compiler#get_compiler_command(file_type) abort
  if a:file_type == 'per'
    return genero_tools#config#get('compiler_form_command')
  else
    return genero_tools#config#get('compiler_command')
  endif
endfunction

" Get compiler arguments for file type
function! genero_tools#compiler#get_compiler_args(file_type) abort
  if a:file_type == 'per'
    return genero_tools#config#get('compiler_form_args')
  else
    return genero_tools#config#get('compiler_args')
  endif
endfunction

" Initialize compiler configuration
function! genero_tools#compiler#init() abort
  " Ensure main config is initialized
  call genero_tools#config#init()
  
  " Initialize compiler-specific configuration
  if !exists('g:genero_tools_compiler_config')
    let g:genero_tools_compiler_config = {}
  endif
  
  " Load compiler configuration from main config
  let g:genero_tools_compiler_config.enabled = genero_tools#config#get('compiler_enabled')
  let g:genero_tools_compiler_config.command = genero_tools#config#get('compiler_command')
  let g:genero_tools_compiler_config.source_dir = genero_tools#config#get('compiler_source_dir')
  let g:genero_tools_compiler_config.compiler_version = genero_tools#config#get('compiler_version')
  let g:genero_tools_compiler_config.show_warnings = genero_tools#config#get('compiler_show_warnings')
  let g:genero_tools_compiler_config.show_errors = genero_tools#config#get('compiler_show_errors')
  let g:genero_tools_compiler_config.highlight_unused = genero_tools#config#get('compiler_highlight_unused')
  let g:genero_tools_compiler_config.sign_column = genero_tools#config#get('compiler_sign_column')
  
  " Initialize detected version (will be set by detect_version)
  let g:genero_tools_compiler_config.detected_version = ''
  
  return g:genero_tools_compiler_config
endfunction

" Detect compiler version by running 'fglcomp -V'
function! genero_tools#compiler#detect_version() abort
  let compiler_cmd = genero_tools#config#get('compiler_command')
  let version_cmd = compiler_cmd . ' -V'
  
  try
    let output = system(version_cmd)
    let exit_code = v:shell_error
    
    if exit_code != 0
      return {
        \ 'success': 0,
        \ 'version': '',
        \ 'error': 'Failed to detect compiler version. Command: ' . version_cmd
        \ }
    endif
    
    " Parse version from output (e.g., "fglcomp 3.10.0" or "Genero Compiler 3.20")
    let version_match = matchstr(output, '\v\d+\.\d+')
    
    if empty(version_match)
      return {
        \ 'success': 0,
        \ 'version': '',
        \ 'error': 'Could not parse version from compiler output: ' . output
        \ }
    endif
    
    " Store detected version in config
    let g:genero_tools_compiler_config.detected_version = version_match
    
    return {
      \ 'success': 1,
      \ 'version': version_match,
      \ 'error': ''
      \ }
    
  catch
    return {
      \ 'success': 0,
      \ 'version': '',
      \ 'error': 'Exception during version detection: ' . v:exception
      \ }
  endtry
endfunction

" Get effective compiler version (auto-detect if needed)
function! genero_tools#compiler#get_version() abort
  let config_version = genero_tools#config#get('compiler_version')
  
  " If version is 'auto', detect it
  if config_version == 'auto'
    let detection = genero_tools#compiler#detect_version()
    if detection.success
      return detection.version
    else
      " Fall back to default if detection fails
      return '3.10'
    endif
  endif
  
  " Return configured version
  return config_version
endfunction

" Execute compiler command on file or directory
function! genero_tools#compiler#execute(source_path) abort
  let file_type = genero_tools#compiler#detect_file_type(a:source_path)
  let compiler_cmd = genero_tools#compiler#get_compiler_command(file_type)
  let compiler_args = genero_tools#compiler#get_compiler_args(file_type)
  
  " Build command: compiler [args] <source_path>
  let args_str = join(compiler_args, ' ')
  let cmd = compiler_cmd . ' ' . args_str . ' ' . genero_tools#command#escape_arg(a:source_path)
  
  let result = {
    \ 'success': 0,
    \ 'output': '',
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': [],
    \ 'error': '',
    \ 'file_type': file_type
    \ }
  
  try
    let output = system(cmd)
    let exit_code = v:shell_error
    
    " Store raw output
    let result.output = output
    
    " Parse output based on file type and compiler version
    let compiler_ver = genero_tools#compiler#get_version()
    let parsed = genero_tools#compiler#parse_output(output, compiler_ver, file_type)
    
    if parsed.success
      " Parsing succeeded — we have structured results even if compiler
      " exited non-zero (which is normal when there are errors/warnings)
      let result.success = 1
      let result.errors = parsed.errors
      let result.warnings = parsed.warnings
      let result.info = parsed.info
    elseif exit_code != 0 && !empty(output)
      " Parser failed but compiler produced output — treat raw lines as errors
      " so the user still sees something in quickfix
      let result.success = 1
      for raw_line in split(output, "\n")
        if !empty(raw_line)
          call add(result.errors, {
            \ 'file': a:source_path,
            \ 'line': 1,
            \ 'col': 1,
            \ 'end_line': 1,
            \ 'end_col': 1,
            \ 'severity': 'error',
            \ 'message': raw_line,
            \ 'code': ''
            \ })
        endif
      endfor
    else
      let result.error = parsed.error
    endif
    
  catch
    let result.error = 'Exception during compiler execution: ' . v:exception
  endtry
  
  return result
endfunction

" Parse compiler output based on version and file type
function! genero_tools#compiler#parse_output(output, version, file_type) abort
  " Route to version-specific parser
  if a:version =~? '^3\.1'
    return genero_tools#compiler#parse_v310(a:output, a:file_type)
  elseif a:version =~? '^3\.2'
    return genero_tools#compiler#parse_v320(a:output, a:file_type)
  else
    " Default to 3.10 format for unknown versions
    return genero_tools#compiler#parse_v310(a:output, a:file_type)
  endif
endfunction

" Parse fglcomp/fglform 3.10+ output format
" Format: filename:start_line:start_col:end_line:end_col:severity:(-code) message
" Also handles simpler formats like: filename:line:col:severity:message
function! genero_tools#compiler#parse_v310(output, file_type) abort
  let result = {
    \ 'success': 1,
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': [],
    \ 'error': ''
    \ }
  
  let lines = split(a:output, "\n")
  
  for line in lines
    if empty(line)
      continue
    endif
    
    " Try full format: filename:line:col:end_line:end_col:severity:(-code) message
    let match = matchlist(line, '^\([^:]*\):\(\d\+\):\(\d\+\):\(\d\+\):\(\d\+\):\(error\|warning\|info\):(-\d\+) \(.*\)$')
    
    if !empty(match)
      let entry = {
        \ 'file': match[1],
        \ 'line': str2nr(match[2]),
        \ 'col': str2nr(match[3]),
        \ 'end_line': str2nr(match[4]),
        \ 'end_col': str2nr(match[5]),
        \ 'severity': match[6],
        \ 'message': match[7],
        \ 'code': matchstr(line, '(-\d\+)')
        \ }
    else
      " Try simpler format: filename:line:col:severity:message
      let match = matchlist(line, '^\([^:]*\):\(\d\+\):\(\d\+\):\(error\|warning\|info\):\s*\(.*\)$')
      
      if !empty(match)
        let entry = {
          \ 'file': match[1],
          \ 'line': str2nr(match[2]),
          \ 'col': str2nr(match[3]),
          \ 'end_line': str2nr(match[2]),
          \ 'end_col': str2nr(match[3]),
          \ 'severity': match[4],
          \ 'message': match[5],
          \ 'code': ''
          \ }
      else
        " Try minimal format: filename:line:message (treat as error)
        let match = matchlist(line, '^\([^:]*\):\(\d\+\):\s*\(.*\)$')
        
        if !empty(match) && match[3] !~# '^\d\+:'
          let entry = {
            \ 'file': match[1],
            \ 'line': str2nr(match[2]),
            \ 'col': 1,
            \ 'end_line': str2nr(match[2]),
            \ 'end_col': 1,
            \ 'severity': 'error',
            \ 'message': match[3],
            \ 'code': ''
            \ }
        else
          continue
        endif
      endif
    endif
    
    " Categorize by severity
    if entry.severity == 'error'
      call add(result.errors, entry)
    elseif entry.severity == 'warning'
      call add(result.warnings, entry)
    else
      call add(result.info, entry)
    endif
  endfor
  
  return result
endfunction

" Parse fglcomp/fglform 3.20+ output format (stub for future use)
function! genero_tools#compiler#parse_v320(output, file_type) abort
  " For now, use same format as 3.10
  " This can be updated when 3.20 format is known
  return genero_tools#compiler#parse_v310(a:output, a:file_type)
endfunction

" Per-buffer compile result storage for inline diagnostics
if !exists('g:genero_tools_buffer_compile_results')
  let g:genero_tools_buffer_compile_results = {}
endif

" Store compile result for a buffer
function! genero_tools#compiler#store_buffer_result(bufnr, result) abort
  let g:genero_tools_buffer_compile_results[a:bufnr] = a:result
endfunction

" Get compile result for a buffer
function! genero_tools#compiler#get_buffer_result(bufnr) abort
  return get(g:genero_tools_buffer_compile_results, a:bufnr, {})
endfunction

" Clear compile result for a buffer
function! genero_tools#compiler#clear_buffer_result(bufnr) abort
  if has_key(g:genero_tools_buffer_compile_results, a:bufnr)
    call remove(g:genero_tools_buffer_compile_results, a:bufnr)
  endif
endfunction
