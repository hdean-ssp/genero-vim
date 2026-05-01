" Genero-Tools Plugin - Reference Count Virtual Text
" Shows how many callers a function has on its FUNCTION definition line
" Fetches lazily: only looks up the function the cursor is currently on
" Neovim only — uses virtual text extmarks

let s:ns_id = -1
let s:timer_id = -1
let s:last_func = ''
let s:last_line = -1

" Dedicated cache for refcounts — doesn't pollute the main query cache
if !exists('g:genero_tools_refcount_cache')
  let g:genero_tools_refcount_cache = {}
endif

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
    " Autocommands handled by unified cursor dispatcher (cursor.vim)
  augroup END
endfunction

" Called by cursor dispatcher when line changes
function! genero_tools#refcount#on_line_changed(bufnr, current_line) abort
  if a:current_line == s:last_line
    return
  endif

  call genero_tools#refcount#clear_extmarks()
  let s:last_line = a:current_line

  " Check if cursor is on a FUNCTION line
  let line_text = getline(a:current_line)
  let trimmed = substitute(line_text, '^\s*', '', '')
  let upper = toupper(trimmed)

  if upper !~# '^FUNCTION\>'
    let s:last_func = ''
    return
  endif

  let func_name = matchstr(trimmed, '\c^FUNCTION\s\+\zs\w\+')
  if empty(func_name)
    let s:last_func = ''
    return
  endif

  let s:last_func = func_name

  " Check local refcount cache
  if has_key(g:genero_tools_refcount_cache, func_name)
    call s:show_count(a:bufnr, a:current_line, g:genero_tools_refcount_cache[func_name])
    return
  endif

  " Schedule a lookup with debounce
  if s:timer_id != -1
    call timer_stop(s:timer_id)
  endif
  let s:timer_id = timer_start(500, function('s:fetch_refcount', [func_name, a:bufnr, a:current_line]))
endfunction

function! s:fetch_refcount(func_name, bufnr, line_nr, timer_id) abort
  let s:timer_id = -1

  " Verify cursor is still on the same line
  if line('.') != a:line_nr || bufnr('%') != a:bufnr
    return
  endif

  let tool_path = genero_tools#config#get('genero_tools_path')
  let escaped = genero_tools#command#escape_arg(a:func_name)
  let cmd = tool_path . ' find-function-dependents ' . escaped

  try
    silent let output = system(cmd)
    if v:shell_error == 0
      let data = json_decode(output)
      if type(data) == type([])
        let count = len(data)
        " Store in dedicated refcount cache
        let g:genero_tools_refcount_cache[a:func_name] = count

        " Verify cursor hasn't moved during the shell call
        if line('.') == a:line_nr && bufnr('%') == a:bufnr
          call s:show_count(a:bufnr, a:line_nr, count)
        endif
      endif
    endif
  catch
  endtry
endfunction

function! s:show_count(bufnr, line_nr, count) abort
  call genero_tools#refcount#clear_extmarks()

  let text = a:count == 0 ? '0 references' :
    \ a:count == 1 ? '1 reference' :
    \ a:count . ' references'

  try
    call nvim_buf_set_extmark(a:bufnr, s:ns_id, a:line_nr - 1, 0, {
      \ 'virt_text': [['  ' . text, 'GeneroRefCount']],
      \ 'virt_text_pos': 'eol',
      \ 'priority': 10
      \ })
  catch
  endtry
endfunction

function! genero_tools#refcount#clear_extmarks() abort
  if !has('nvim') || s:ns_id == -1
    return
  endif
  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction

function! genero_tools#refcount#clear() abort
  if s:timer_id != -1
    call timer_stop(s:timer_id)
    let s:timer_id = -1
  endif
  call genero_tools#refcount#clear_extmarks()
  let s:last_func = ''
  let s:last_line = -1
endfunction
