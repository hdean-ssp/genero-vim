" Genero-Tools Plugin - Per-specific Compiler Logic

" Per-specific compiler initialization
function! genero_tools#compiler#per#init() abort
  " Per files use the same compilation approach as fgl files
  " but with the fglform compiler instead of fglcomp
endfunction

" Compile a per file
function! genero_tools#compiler#per#compile(file_path) abort
  " Use the standard compiler execute function
  " which now handles per files via file type detection
  return genero_tools#compiler#execute(a:file_path)
endfunction
