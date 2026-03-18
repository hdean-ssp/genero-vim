" Genero-Tools Plugin - Compiler Integration

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
  let compiler_cmd = genero_tools#config#get('compiler_command')
  let source_dir = genero_tools#config#get('compiler_source_dir')
  
  " Build command: fglcomp -M -W all <source_path>
  let cmd = compiler_cmd . ' -M -W all ' . genero_tools#command#escape_arg(a:source_path)
  
  let result = {
    \ 'success': 0,
    \ 'output': '',
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': [],
    \ 'error': ''
    \ }
  
  try
    let output = system(cmd)
    let exit_code = v:shell_error
    
    " Store raw output
    let result.output = output
    
    " Parse output based on compiler version
    let compiler_ver = genero_tools#compiler#get_version()
    let parsed = genero_tools#compiler#parse_output(output, compiler_ver)
    
    if parsed.success
      let result.success = 1
      let result.errors = parsed.errors
      let result.warnings = parsed.warnings
      let result.info = parsed.info
    else
      let result.error = parsed.error
    endif
    
  catch
    let result.error = 'Exception during compiler execution: ' . v:exception
  endtry
  
  return result
endfunction

" Parse compiler output based on version
function! genero_tools#compiler#parse_output(output, version) abort
  " Route to version-specific parser
  if a:version =~? '^3\.1'
    return genero_tools#compiler#parse_v310(a:output)
  elseif a:version =~? '^3\.2'
    return genero_tools#compiler#parse_v320(a:output)
  else
    " Default to 3.10 format for unknown versions
    return genero_tools#compiler#parse_v310(a:output)
  endif
endfunction

" Parse fglcomp 3.10+ output format
" Format: filename:start_line:start_col:end_line:end_col:severity:(-code) message
function! genero_tools#compiler#parse_v310(output) abort
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
    
    " Parse line: filename:line:col:end_line:end_col:severity:(-code) message
    let match = matchlist(line, '^\([^:]*\):\(\d\+\):\(\d\+\):\(\d\+\):\(\d\+\):\(error\|warning\|info\):(-\d\+) \(.*\)$')
    
    if empty(match)
      continue
    endif
    
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

" Parse fglcomp 3.20+ output format (stub for future use)
function! genero_tools#compiler#parse_v320(output) abort
  " For now, use same format as 3.10
  " This can be updated when 3.20 format is known
  return genero_tools#compiler#parse_v310(a:output)
endfunction
