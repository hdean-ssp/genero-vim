" Genero-Tools Plugin - Compiler Sign Column Integration

" Define sign groups for different severity levels
let s:sign_error = 'GeneroCompilerError'
let s:sign_warning = 'GeneroCompilerWarning'
let s:sign_info = 'GeneroCompilerInfo'

" Initialize signs (define them once)
function! genero_tools#compiler#signs#init() abort
  " Define error sign (✕)
  execute 'sign define ' . s:sign_error . ' text=✕ texthl=ErrorMsg'
  
  " Define warning sign (⚠)
  execute 'sign define ' . s:sign_warning . ' text=⚠ texthl=WarningMsg'
  
  " Define info sign (ℹ)
  execute 'sign define ' . s:sign_info . ' text=ℹ texthl=InfoMsg'
  
  " Set persistent sign column if enabled
  call genero_tools#compiler#signs#set_persistent_column()
endfunction

" Set persistent sign column for current buffer
function! genero_tools#compiler#signs#set_persistent_column() abort
  if genero_tools#config#get('compiler_sign_column_always_visible')
    setlocal signcolumn=yes
  endif
endfunction

" Place signs for compiler errors/warnings
function! genero_tools#compiler#signs#place(errors, warnings, info) abort
  " Initialize signs if not already done
  if !exists('s:signs_initialized')
    call genero_tools#compiler#signs#init()
    let s:signs_initialized = v:true
  endif
  
  " Clear existing signs first
  call genero_tools#compiler#signs#clear()
  
  let sign_id = 1
  
  " Place error signs
  for error in a:errors
    if has_key(error, 'file') && has_key(error, 'line')
      try
        execute 'sign place ' . sign_id . ' group=genero_compiler line=' . error.line . 
              \ ' name=' . s:sign_error . 
              \ ' file=' . error.file
        let sign_id += 1
      catch
        " Silently ignore if sign placement fails (file may not be open)
      endtry
    endif
  endfor
  
  " Place warning signs
  for warning in a:warnings
    if has_key(warning, 'file') && has_key(warning, 'line')
      try
        execute 'sign place ' . sign_id . ' group=genero_compiler line=' . warning.line . 
              \ ' name=' . s:sign_warning . 
              \ ' file=' . warning.file
        let sign_id += 1
      catch
        " Silently ignore if sign placement fails
      endtry
    endif
  endfor
  
  " Place info signs
  for info_item in a:info
    if has_key(info_item, 'file') && has_key(info_item, 'line')
      try
        execute 'sign place ' . sign_id . ' group=genero_compiler line=' . info_item.line . 
              \ ' name=' . s:sign_info . 
              \ ' file=' . info_item.file
        let sign_id += 1
      catch
        " Silently ignore if sign placement fails
      endtry
    endif
  endfor
endfunction

" Clear all compiler signs
function! genero_tools#compiler#signs#clear() abort
  try
    execute 'sign unplace * group=genero_compiler'
  catch
    " Silently ignore if no signs to clear
  endtry
endfunction

" Update signs when compilation results change
function! genero_tools#compiler#signs#update(result) abort
  if a:result.success
    let errors = get(a:result, 'errors', [])
    let warnings = get(a:result, 'warnings', [])
    let info = get(a:result, 'info', [])
    
    call genero_tools#compiler#signs#place(errors, warnings, info)
  else
    call genero_tools#compiler#signs#clear()
  endif
endfunction
