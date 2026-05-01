" Genero-Tools Plugin - Reference Count Virtual Text
" Shows how many callers a function has on its FUNCTION definition line
" Neovim only — uses virtual text extmarks

let s:ns_id = -1
let s:timer_id = -1
let s:processed_lines = {}

function! genero_tools#refcount#init() abort
  if !has('nvim')
    return
  endif

  let s:ns_id = nvim_create_namespace('genero_refcount')

  if !hlexists('GeneroRefCount')
    highlight GeneroRefCount guifg=#606060 guibg=NONE gui=italic ctermfg=DarkGray ctermbg=NONE
  endif

  augroup GeneroRefCount
    autocmd!
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#refcount#schedule_update()
    autocmd BufWritePost *.4gl,*.m3,*.m4,*.per call genero_tools#refcount#schedule_update()
  augroup END
endfunction

" Schedule an update with a short delay to avoid blocking on buffer enter
function! genero_tools#refcount#schedule_update() abort
  if s:timer_id != -1
    call timer_stop(s:timer_id)
  endif
  let s:timer_id = timer_start(1000, function('genero_tools#refcount#update_buffer'))
endfunction

" Update reference counts for all FUNCTION lines in the current buffer
function! genero_tools#refcount#update_buffer(...) abort
  let s:timer_id = -1

  if !has('nvim') || s:ns_id == -1
    return
  endif

  let bufnr = bufnr('%')

  " Clear existing
  try
    call nvim_buf_clear_namespace(bufnr, s:ns_id, 0, -1)
  catch
  endtry

  " Find all FUNCTION lines
  let total = line('$')
  let i = 1

  while i <= total
    let line = getline(i)
    let trimmed = substitute(line, '^\s*', '', '')
    let upper = toupper(trimmed)

    if upper =~# '^FUNCTION\>'
      let func_name = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
      if !empty(func_name)
        " Look up dependents (callers) — use cache, don't block
        call s:show_refcount_for_line(bufnr, i, func_name)
      endif
    endif

    let i += 1
  endwhile
endfunction

" Show reference count for a single function line
function! s:show_refcount_for_line(bufnr, line_nr, func_name) abort
  " Check cache first
  let cache_key = 'find-function:' . a:func_name
  let cached = genero_tools#cache#get(cache_key)

  let call_count = -1

  if !empty(cached) && has_key(cached, 'success') && cached.success
    let func = s:pick_func(cached.data, a:func_name)
    if !empty(func)
      let calls = get(func, 'calls', [])
      " 'calls' is what this function calls, not who calls it
      " We need dependents — skip if not available in cache
    endif
  endif

  " Try dependents cache
  let dep_key = 'find-function-dependents:' . a:func_name
  let dep_cached = genero_tools#cache#get(dep_key)

  if !empty(dep_cached) && has_key(dep_cached, 'success') && dep_cached.success
    if type(dep_cached.data) == type([])
      let call_count = len(dep_cached.data)
    endif
  endif

  " If not in cache, do a silent lookup (only for visible functions)
  if call_count == -1
    let tool_path = genero_tools#config#get('genero_tools_path')
    let escaped = genero_tools#command#escape_arg(a:func_name)
    let cmd = tool_path . ' find-function-dependents ' . escaped

    try
      silent let output = system(cmd)
      if v:shell_error == 0
        let data = json_decode(output)
        if type(data) == type([])
          let call_count = len(data)
          " Cache it
          call genero_tools#cache#set(dep_key, {'success': 1, 'data': data, 'timestamp': localtime()})
        endif
      endif
    catch
    endtry
  endif

  if call_count < 0
    return
  endif

  let text = call_count == 0 ? '0 references' :
    \ call_count == 1 ? '1 reference' :
    \ call_count . ' references'

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line_nr - 1, 0, {
      \ 'virt_text': [['  ' . text, 'GeneroRefCount']],
      \ 'virt_text_pos': 'eol',
      \ 'priority': 10
      \ })
  catch
  endtry
endfunction

function! s:pick_func(data, word) abort
  if type(a:data) == type([])
    for item in a:data
      if type(item) == type({}) && get(item, 'name', '') ==? a:word
        return item
      endif
    endfor
  elseif type(a:data) == type({})
    return a:data
  endif
  return {}
endfunction
