" Genero-Tools Plugin - Progress Feedback

let s:progress_shown = v:false

" Show progress indicator
function! genero_tools#progress#show(message) abort
  if s:progress_shown
    return
  endif
  
  echom a:message . ' ...'
  let s:progress_shown = v:true
endfunction

" Hide progress indicator
function! genero_tools#progress#hide() abort
  if s:progress_shown
    echom ''
    let s:progress_shown = v:false
  endif
endfunction

" Show progress with elapsed time
function! genero_tools#progress#show_elapsed(message, start_time) abort
  let elapsed = localtime() - a:start_time
  echom a:message . ' (' . elapsed . 's elapsed)'
endfunction
