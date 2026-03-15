" Genero-Tools Plugin - Progress Feedback

let s:progress_shown = v:false
let s:command_start_time = 0

" Show progress indicator
function! genero_tools#progress#show(message) abort
  if s:progress_shown
    return
  endif
  
  echom a:message . ' ...'
  let s:progress_shown = v:true
  let s:command_start_time = localtime()
endfunction

" Hide progress indicator
function! genero_tools#progress#hide() abort
  if s:progress_shown
    echom ''
    let s:progress_shown = v:false
  endif
endfunction

" Show progress with elapsed time (Requirement 17.4, 17.7)
function! genero_tools#progress#show_elapsed(message, start_time) abort
  let elapsed = localtime() - a:start_time
  
  " Only show elapsed time for commands taking >2 seconds
  if elapsed > 2
    echom a:message . ' (' . elapsed . 's elapsed)'
    
    " Recommend async mode for large codebases if command is slow
    if elapsed > 5
      echom 'Tip: For large codebases, enable async mode: let g:genero_tools_config.async_enabled = 1'
    endif
  endif
endfunction

" Get elapsed time since command started
function! genero_tools#progress#get_elapsed() abort
  if s:command_start_time == 0
    return 0
  endif
  return localtime() - s:command_start_time
endfunction
