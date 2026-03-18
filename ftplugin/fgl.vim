" Genero-Tools Plugin - Filetype Plugin for Genero/FGL

" Set omnifunc for fgl files
setlocal omnifunc=genero_tools#complete#omnifunc

" Set other useful options for fgl files
setlocal commentstring=--\ %s

" Enable autocompile for fgl files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Tab-based completion keybindings
" Tab behavior:
" - If completion menu is visible: navigate down
" - If line is empty or only whitespace: insert tab character
" - Otherwise: trigger completion
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
  
  " Otherwise trigger completion
  return "\<C-x>\<C-o>"
endfunction

inoremap <buffer> <expr> <Tab> <SID>handle_tab()
inoremap <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
