" Genero-Tools Plugin - Indentation for Genero files
" Prevents # comments from being unindented to column 0

" Only load this indent file when no other was loaded
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" Disable smartindent's special # handling (moves # to column 0)
setlocal nosmartindent

" Use autoindent instead (preserves current indentation)
setlocal autoindent

" Disable cindent's special # handling
setlocal nocindent

" Clear indentkeys to prevent special # handling
setlocal indentkeys=

" Preserve indentation when typing # for comments
setlocal cinkeys-=0#
setlocal indentkeys-=0#
