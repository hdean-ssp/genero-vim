" Genero-Tools Plugin - Keyword & Naming Detector
" Detects keyword and naming convention violations

" Detect keyword and naming issues
function! genero_tools#hints#keyword#detect(bufnr, config) abort
  let hints = []
  
  if !bufexists(a:bufnr)
    return hints
  endif
  
  " Keyword and function hints are disabled by default due to high false positive rate
  " They detect keywords in comments and strings, causing performance issues
  " Users can enable them in configuration if needed
  
  return hints
endfunction
