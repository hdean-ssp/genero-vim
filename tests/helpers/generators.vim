" tests/helpers/generators.vim — input generators for property-based tests

let s:filenames  = ['foo.4gl', 'bar.4gl', 'module/baz.4gl']
let s:messages   = ['undefined variable', 'type mismatch', 'missing END']
let s:severities = ['error', 'warning', 'info']

" Generate a deterministic compiler line in v3.10 full format from a seed.
" Format: file:line:col:end_line:end_col:severity:(-code) message
function! TestGenCompilerError(seed) abort
  let fname = s:filenames[a:seed % len(s:filenames)]
  let lnum  = (a:seed % 999) + 1
  let col   = (a:seed % 79)  + 1
  let sev   = s:severities[a:seed % len(s:severities)]
  let msg   = s:messages[a:seed % len(s:messages)]
  let code  = (a:seed % 900) + 100
  return fname . ':' . lnum . ':' . col . ':' . lnum . ':' . (col + 1)
    \ . ':' . sev . ':(-' . code . ') ' . msg
endfunction

" Return the expected parsed fields for a seed (mirrors TestGenCompilerError).
function! TestParseExpectedFromSeed(seed) abort
  return {
    \ 'file':     s:filenames[a:seed % len(s:filenames)],
    \ 'line':     (a:seed % 999) + 1,
    \ 'col':      (a:seed % 79)  + 1,
    \ 'severity': s:severities[a:seed % len(s:severities)],
    \ 'message':  s:messages[a:seed % len(s:messages)]
    \ }
endfunction

" Generate a synthetic SVN unified diff with known added/deleted line numbers.
" a:added_lines   — list of line numbers to mark as added   ('+' lines)
" a:deleted_lines — list of line numbers to mark as deleted ('-' lines)
function! TestGenSvnDiff(added_lines, deleted_lines) abort
  let context = max([len(a:added_lines), len(a:deleted_lines)]) + 5
  let lines = [
    \ 'Index: test.4gl',
    \ '===================================================================',
    \ '--- test.4gl	(revision 100)',
    \ '+++ test.4gl	(working copy)',
    \ '@@ -1,' . (len(a:deleted_lines) + context) . ' +1,' . (len(a:added_lines) + context) . ' @@',
    \ ]
  for i in range(1, 3)
    call add(lines, ' context line ' . i)
  endfor
  for lnum in a:deleted_lines
    call add(lines, '-deleted line ' . lnum)
  endfor
  for lnum in a:added_lines
    call add(lines, '+added line ' . lnum)
  endfor
  return join(lines, "\n")
endfunction
