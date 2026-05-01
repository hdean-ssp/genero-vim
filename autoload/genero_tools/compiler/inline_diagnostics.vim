" Genero-Tools Plugin - Inline Diagnostics Virtual Text
" Shows error/warning messages as virtual text on the current cursor line
" Neovim only — silently does nothing in Vim

" Namespace for inline diagnostic extmarks
let s:ns_id = -1

" Initialize the inline diagnostics system
function! genero_tools#compiler#inline_diagnostics#init() abort
  if !has('nvim')
    return
  endif

  " Create namespace
  let s:ns_id = nvim_create_namespace('genero_compiler_inline_diag')

  " Define subtle highlight groups — dim italic text, no background
  if !hlexists('GeneroInlineError')
    highlight GeneroInlineError guifg=#b05050 guibg=NONE gui=italic ctermfg=DarkRed ctermbg=NONE
  endif

  if !hlexists('GeneroInlineWarning')
    highlight GeneroInlineWarning guifg=#a08050 guibg=NONE gui=italic ctermfg=DarkYellow ctermbg=NONE
  endif

  if !hlexists('GeneroInlineInfo')
    highlight GeneroInlineInfo guifg=#5080a0 guibg=NONE gui=italic ctermfg=DarkCyan ctermbg=NONE
  endif

  " Autocommands are handled by the unified cursor dispatcher (cursor.vim)
endfunction

" Called by cursor dispatcher when line changes
function! genero_tools#compiler#inline_diagnostics#on_line_changed(bufnr, current_line) abort
  if !genero_tools#config#get('compiler_inline_diagnostics')
    return
  endif
  call genero_tools#compiler#inline_diagnostics#update()
endfunction

" Update the virtual text for the current cursor line
function! genero_tools#compiler#inline_diagnostics#update() abort
  if !has('nvim')
    return
  endif

  if !genero_tools#config#get('compiler_inline_diagnostics')
    call genero_tools#compiler#inline_diagnostics#clear()
    return
  endif

  " Ensure namespace exists
  if s:ns_id == -1
    let s:ns_id = nvim_create_namespace('genero_compiler_inline_diag')
  endif

  let bufnr = bufnr('%')
  let current_line = line('.')

  " Clear previous virtual text
  call nvim_buf_clear_namespace(bufnr, s:ns_id, 0, -1)

  " Get compile result for this buffer
  let result = genero_tools#compiler#get_buffer_result(bufnr)
  if empty(result)
    return
  endif

  " Collect all diagnostics for the current line
  let messages = []

  for error in get(result, 'errors', [])
    if get(error, 'line', 0) == current_line
      call add(messages, {'text': error.message, 'type': 'E'})
    endif
  endfor

  for warning in get(result, 'warnings', [])
    if get(warning, 'line', 0) == current_line
      call add(messages, {'text': warning.message, 'type': 'W'})
    endif
  endfor

  for info_item in get(result, 'info', [])
    if get(info_item, 'line', 0) == current_line
      call add(messages, {'text': info_item.message, 'type': 'I'})
    endif
  endfor

  if empty(messages)
    return
  endif

  " Build virtual text chunks — multiple diagnostics on one line get joined
  let virt_text = []
  for msg in messages
    if msg.type == 'E'
      let hl = 'GeneroInlineError'
      let prefix = '✕ '
    elseif msg.type == 'W'
      let hl = 'GeneroInlineWarning'
      let prefix = '▸ '
    else
      let hl = 'GeneroInlineInfo'
      let prefix = 'ℹ '
    endif

    " Add separator between multiple diagnostics
    if !empty(virt_text)
      call add(virt_text, ['  │  ', 'Comment'])
    endif

    call add(virt_text, ['  ' . prefix . msg.text, hl])
  endfor

  try
    call nvim_buf_set_extmark(bufnr, s:ns_id, current_line - 1, 0, {
      \ 'virt_text': virt_text,
      \ 'virt_text_pos': 'eol',
      \ 'priority': 100
      \ })
  catch
    " Silently ignore
  endtry
endfunction

" Clear all inline diagnostic virtual text
function! genero_tools#compiler#inline_diagnostics#clear() abort
  if !has('nvim')
    return
  endif

  if s:ns_id == -1
    return
  endif

  try
    call nvim_buf_clear_namespace(bufnr('%'), s:ns_id, 0, -1)
  catch
  endtry
endfunction
