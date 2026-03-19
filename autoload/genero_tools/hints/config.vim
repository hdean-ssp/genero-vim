" Genero-Tools Plugin - Hint Configuration System
" Manages hint configuration from multiple sources with proper merging

" Initialize hint configuration with defaults
function! genero_tools#hints#config#init() abort
  if !exists('g:genero_tools_config')
    let g:genero_tools_config = {}
  endif
  
  " System-level options
  call genero_tools#hints#config#init_key('hints_enabled', 1)
  call genero_tools#hints#config#init_key('hints_display', 'signs')
  call genero_tools#hints#config#init_key('hints_highlight_columns', 1)
  call genero_tools#hints#config#init_key('hints_severity', 'warning')
  call genero_tools#hints#config#init_key('hints_realtime', 0)
  call genero_tools#hints#config#init_key('hints_cache_enabled', 1)
  call genero_tools#hints#config#init_key('hints_cache_ttl', 300)
  call genero_tools#hints#config#init_key('auto_fix_enabled', 1)
  call genero_tools#hints#config#init_key('hints_delay', 500)
  
  " Individual hint checks (1 = enabled, 0 = disabled)
  call genero_tools#hints#config#init_key('trailing_whitespace', 1)
  call genero_tools#hints#config#init_key('mixed_indentation', 0)
  call genero_tools#hints#config#init_key('indentation_consistency', 1)
  call genero_tools#hints#config#init_key('multiple_blank_lines', 1)
  call genero_tools#hints#config#init_key('lowercase_keywords', 0)
  call genero_tools#hints#config#init_key('lowercase_functions', 0)
  call genero_tools#hints#config#init_key('keyword_consistency', 0)
  call genero_tools#hints#config#init_key('naming_convention', 0)
  call genero_tools#hints#config#init_key('unclosed_blocks', 1)
  call genero_tools#hints#config#init_key('nesting_depth', 1)
  call genero_tools#hints#config#init_key('line_length', 1)
  call genero_tools#hints#config#init_key('missing_comments', 0)
  call genero_tools#hints#config#init_key('missing_error_handling', 0)
  call genero_tools#hints#config#init_key('deprecated_functions', 0)
  
  " Threshold options
  call genero_tools#hints#config#init_key('max_line_length', 100)
  call genero_tools#hints#config#init_key('max_nesting_depth', 5)
  call genero_tools#hints#config#init_key('max_blank_lines', 2)
  call genero_tools#hints#config#init_key('naming_convention_style', 'camelCase')
endfunction

" Initialize a single config key with default value
function! genero_tools#hints#config#init_key(key, default_value) abort
  if !has_key(g:genero_tools_config, a:key)
    let g:genero_tools_config[a:key] = a:default_value
  endif
endfunction

" Get configuration value
function! genero_tools#hints#config#get(key) abort
  if !exists('g:genero_tools_config')
    call genero_tools#hints#config#init()
  endif
  
  if has_key(g:genero_tools_config, a:key)
    return g:genero_tools_config[a:key]
  endif
  
  " Return sensible defaults if key not found
  return genero_tools#hints#config#get_default(a:key)
endfunction

" Get default value for a configuration key
function! genero_tools#hints#config#get_default(key) abort
  let defaults = {
    \ 'hints_enabled': 1,
    \ 'hints_display': 'signs',
    \ 'hints_highlight_columns': 1,
    \ 'hints_severity': 'warning',
    \ 'hints_realtime': 0,
    \ 'hints_cache_enabled': 1,
    \ 'hints_cache_ttl': 300,
    \ 'auto_fix_enabled': 1,
    \ 'hints_delay': 500,
    \ 'trailing_whitespace': 1,
    \ 'mixed_indentation': 0,
    \ 'indentation_consistency': 1,
    \ 'multiple_blank_lines': 1,
    \ 'lowercase_keywords': 0,
    \ 'lowercase_functions': 0,
    \ 'keyword_consistency': 0,
    \ 'naming_convention': 0,
    \ 'unclosed_blocks': 1,
    \ 'nesting_depth': 1,
    \ 'line_length': 1,
    \ 'missing_comments': 0,
    \ 'missing_error_handling': 0,
    \ 'deprecated_functions': 0,
    \ 'max_line_length': 100,
    \ 'max_nesting_depth': 5,
    \ 'max_blank_lines': 2,
    \ 'naming_convention_style': 'camelCase'
    \ }
  
  if has_key(defaults, a:key)
    return defaults[a:key]
  endif
  
  return ''
endfunction

" Get effective configuration for a buffer
" Merges per-file config with project-wide config
function! genero_tools#hints#config#get_for_buffer(bufnr) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  let file_path = bufname(bufnr)
  
  return genero_tools#hints#config#get_for_file(file_path)
endfunction

" Get effective configuration for a file
" Merges per-file config with project-wide config
function! genero_tools#hints#config#get_for_file(file_path) abort
  " Start with project-wide configuration
  let config = {}
  
  " Copy all hint configuration keys
  for key in keys(g:genero_tools_config)
    if key =~ '^hints_\|^trailing_\|^mixed_\|^indentation_\|^multiple_\|^lowercase_\|^keyword_\|^naming_\|^unclosed_\|^nesting_\|^line_\|^missing_\|^unused_\|^deprecated_\|^max_\|^auto_fix'
      let config[key] = g:genero_tools_config[key]
    endif
  endfor
  
  " Load and merge per-file configuration if it exists
  let per_file_config = genero_tools#hints#config#load_per_file()
  if !empty(per_file_config)
    let config = genero_tools#hints#config#merge_configs(config, per_file_config, a:file_path)
  endif
  
  return config
endfunction

" Load per-file configuration from .genero-hints
function! genero_tools#hints#config#load_per_file() abort
  " Find project root
  let project_root = genero_tools#codebase#get_root()
  if empty(project_root)
    return {}
  endif
  
  let config_file = project_root . '/.genero-hints'
  
  " Check if .genero-hints exists
  if !filereadable(config_file)
    return {}
  endif
  
  try
    " Read and parse JSON configuration
    let content = readfile(config_file)
    let json_str = join(content, '')
    
    " Use json_decode if available (Vim 7.4.1304+)
    if exists('*json_decode')
      let config_data = json_decode(json_str)
      return config_data
    endif
  catch
    " Log error but continue with defaults
    call genero_tools#error#debug('hints', 'Failed to load .genero-hints: ' . v:exception)
  endtry
  
  return {}
endfunction

" Merge per-file config with project-wide config
function! genero_tools#hints#config#merge_configs(base_config, per_file_config, file_path) abort
  let merged = copy(a:base_config)
  
  " If per-file config has rules array, find matching rules
  if has_key(a:per_file_config, 'rules') && type(a:per_file_config.rules) == type([])
    for rule in a:per_file_config.rules
      if has_key(rule, 'pattern') && has_key(rule, 'config')
        " Check if file matches pattern
        if genero_tools#hints#config#pattern_matches(a:file_path, rule.pattern)
          " Merge rule config into merged config
          for [key, value] in items(rule.config)
            let merged[key] = value
          endfor
        endif
      endif
    endfor
  endif
  
  return merged
endfunction

" Check if file path matches a glob pattern
function! genero_tools#hints#config#pattern_matches(file_path, pattern) abort
  " Simple glob pattern matching
  " Supports ** for recursive, * for any chars, ? for single char
  
  " Convert glob pattern to regex
  let regex = a:pattern
  let regex = substitute(regex, '\*\*', '.*', 'g')
  let regex = substitute(regex, '\*', '[^/]*', 'g')
  let regex = substitute(regex, '?', '.', 'g')
  let regex = '^' . regex . '$'
  
  return a:file_path =~ regex
endfunction

" Validate configuration
function! genero_tools#hints#config#validate(config) abort
  let errors = []
  
  " Validate hints_display
  if has_key(a:config, 'hints_display')
    if index(['signs', 'virtual_text', 'both'], a:config.hints_display) == -1
      call add(errors, 'Invalid hints_display: ' . a:config.hints_display)
    endif
  endif
  
  " Validate hints_severity
  if has_key(a:config, 'hints_severity')
    if index(['info', 'warning', 'style'], a:config.hints_severity) == -1
      call add(errors, 'Invalid hints_severity: ' . a:config.hints_severity)
    endif
  endif
  
  " Validate naming_convention_style
  if has_key(a:config, 'naming_convention_style')
    if index(['camelCase', 'snake_case'], a:config.naming_convention_style) == -1
      call add(errors, 'Invalid naming_convention_style: ' . a:config.naming_convention_style)
    endif
  endif
  
  " Validate numeric thresholds
  if has_key(a:config, 'max_line_length') && a:config.max_line_length < 1
    call add(errors, 'max_line_length must be >= 1')
  endif
  
  if has_key(a:config, 'max_nesting_depth') && a:config.max_nesting_depth < 1
    call add(errors, 'max_nesting_depth must be >= 1')
  endif
  
  if has_key(a:config, 'max_blank_lines') && a:config.max_blank_lines < 0
    call add(errors, 'max_blank_lines must be >= 0')
  endif
  
  if has_key(a:config, 'hints_delay') && a:config.hints_delay < 0
    call add(errors, 'hints_delay must be >= 0')
  endif
  
  return errors
endfunction
