" Genero-Tools Plugin - Tests for .per File Compilation

" Test file type detection for .per files
function! Test_per_file_type_detection() abort
  let file_type = genero_tools#compiler#detect_file_type('form.per')
  call assert_equal('per', file_type, 'Should detect .per files as per type')
  
  let file_type = genero_tools#compiler#detect_file_type('main.4gl')
  call assert_equal('fgl', file_type, 'Should detect .4gl files as fgl type')
  
  let file_type = genero_tools#compiler#detect_file_type('module.m3')
  call assert_equal('fgl', file_type, 'Should detect .m3 files as fgl type')
  
  let file_type = genero_tools#compiler#detect_file_type('module.m4')
  call assert_equal('fgl', file_type, 'Should detect .m4 files as fgl type')
  
  let file_type = genero_tools#compiler#detect_file_type('unknown.txt')
  call assert_equal('unknown', file_type, 'Should return unknown for unrecognized files')
endfunction

" Test compiler command selection
function! Test_per_compiler_command_selection() abort
  let cmd = genero_tools#compiler#get_compiler_command('per')
  call assert_equal('fglform', cmd, 'Should use fglform for per files')
  
  let cmd = genero_tools#compiler#get_compiler_command('fgl')
  call assert_equal('fglcomp', cmd, 'Should use fglcomp for fgl files')
endfunction

" Test compiler arguments selection
function! Test_per_compiler_args_selection() abort
  let args = genero_tools#compiler#get_compiler_args('per')
  call assert_equal(['-M', '-W', 'all'], args, 'Should use default args for per files')
  
  let args = genero_tools#compiler#get_compiler_args('fgl')
  call assert_equal(['-M', '-W', 'all'], args, 'Should use default args for fgl files')
endfunction

" Test per file type plugin setup
function! Test_per_filetype_plugin() abort
  " Create a temporary per file
  let temp_file = tempname() . '.per'
  call writefile(['FORM form1'], temp_file)
  
  try
    " Open the file
    execute 'edit ' . temp_file
    
    " Check that filetype is set to per
    call assert_equal('per', &filetype, 'Filetype should be set to per')
    
    " Check comment string
    call assert_equal('#\ %s', &commentstring, 'Comment string should be set correctly')
    
    " Close the file
    execute 'bdelete'
  finally
    " Clean up
    call delete(temp_file)
  endtry
endfunction

" Test per file detection in ftdetect
function! Test_per_ftdetect() abort
  " Create a temporary per file
  let temp_file = tempname() . '.per'
  call writefile(['FORM form1'], temp_file)
  
  try
    " Open the file
    execute 'edit ' . temp_file
    
    " Check that filetype is set to per
    call assert_equal('per', &filetype, 'Filetype should be detected as per')
    
    " Close the file
    execute 'bdelete'
  finally
    " Clean up
    call delete(temp_file)
  endtry
endfunction

" Test mixed project with .4gl and .per files
function! Test_per_mixed_project_compilation() abort
  " This test verifies that both .4gl and .per files can be compiled
  " in the same project without conflicts
  
  let fgl_type = genero_tools#compiler#detect_file_type('main.4gl')
  let per_type = genero_tools#compiler#detect_file_type('form.per')
  
  call assert_equal('fgl', fgl_type, 'Should detect .4gl files')
  call assert_equal('per', per_type, 'Should detect .per files')
  
  let fgl_cmd = genero_tools#compiler#get_compiler_command(fgl_type)
  let per_cmd = genero_tools#compiler#get_compiler_command(per_type)
  
  call assert_equal('fglcomp', fgl_cmd, 'Should use fglcomp for .4gl')
  call assert_equal('fglform', per_cmd, 'Should use fglform for .per')
endfunction
