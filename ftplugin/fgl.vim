" Genero-Tools Plugin - Filetype Plugin for Genero/FGL

" Set omnifunc for fgl files (only if the function exists)
if exists('*genero_tools#complete#omnifunc')
  setlocal omnifunc=genero_tools#complete#omnifunc
endif

" Set comment string for fgl files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for fgl files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Tab-based completion keybindings
" Tab behavior:
" - If completion menu is visible: navigate down
" - If line is empty or only whitespace: insert tab character
" - If cursor is at end of an identifier: trigger completion
" - Otherwise: insert tab character
function! s:handle_tab() abort
  if pumvisible()
    return "\<C-n>"
  endif
  
  " Check if line before cursor is empty or only whitespace
  let line_before = getline('.')[:col('.')-2]
  if line_before =~# '^\s*$'
    " Line is empty or only whitespace, insert tab
    return "\<Tab>"
  endif
  
  " Check if cursor is at end of an identifier (word characters, dots, underscores)
  " Only trigger completion if there's an identifier to complete
  let char_before = getline('.')[col('.')-2]
  if char_before =~# '[a-zA-Z0-9_.]'
    " Cursor is at end of identifier, trigger completion
    return "\<C-x>\<C-o>"
  endif
  
  " Otherwise insert tab
  return "\<Tab>"
endfunction

inoremap <buffer> <expr> <Tab> <SID>handle_tab()
inoremap <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
