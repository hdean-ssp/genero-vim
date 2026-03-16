# Quick Enhancements Roadmap for Vim-Genero-Tools

Quick wins to implement using existing genero-tools capabilities.

## Phase 1: Dead Code Detection (1-2 hours)

### New Command
```vim
:GeneroDead  " Find all dead code in workspace
```

### Implementation
```vim
" In autoload/genero_tools.vim
function! genero_tools#find_dead_code() abort
  let result = genero_tools#command#execute_shell('find-dead-code', [])
  
  if result.success
    call genero_tools#display_result(result)
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
endfunction
```

### In plugin/genero_tools.vim
```vim
command! GeneroDead call genero_tools#find_dead_code()
```

### Keybinding
```vim
nnoremap <leader>gd :GeneroDead<CR>
```

---

## Phase 2: Function Dependencies (2-3 hours)

### New Commands
```vim
:GeneroDependencies myFunc    " Show functions called BY myFunc
:GeneroDependents myFunc      " Show functions that CALL myFunc
```

### Implementation
```vim
" In autoload/genero_tools.vim
function! genero_tools#find_dependencies(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  let result = genero_tools#command#execute_shell('find-function-dependencies', [function_name])
  
  if result.success
    call genero_tools#display_result(result)
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
endfunction

function! genero_tools#find_dependents(function_name) abort
  if empty(a:function_name)
    let function_name = expand('<cword>')
  else
    let function_name = a:function_name
  endif
  
  let result = genero_tools#command#execute_shell('find-function-dependents', [function_name])
  
  if result.success
    call genero_tools#display_result(result)
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
endfunction
```

### In plugin/genero_tools.vim
```vim
command! -nargs=? GeneroDependencies call genero_tools#find_dependencies(<q-args>)
command! -nargs=? GeneroDependents call genero_tools#find_dependents(<q-args>)
```

### Keybindings
```vim
nnoremap <leader>gdc :GeneroDependencies<CR>  " Dependencies called
nnoremap <leader>gdd :GeneroDependents<CR>    " Dependents (who calls this)
```

---

## Phase 3: Reference Lookup (1-2 hours)

### New Command
```vim
:GeneroReference PRB-299    " Find all files modified for this reference
```

### Implementation
```vim
" In autoload/genero_tools.vim
function! genero_tools#find_reference(reference) abort
  if empty(a:reference)
    call genero_tools#display#echo('Error: Reference required')
    return {}
  endif
  
  let result = genero_tools#command#execute_shell('find-reference', [a:reference])
  
  if result.success
    call genero_tools#display_result(result)
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
endfunction
```

### In plugin/genero_tools.vim
```vim
command! -nargs=1 GeneroReference call genero_tools#find_reference(<q-args>)
```

---

## Phase 4: Module Dependencies (2-3 hours)

### New Commands
```vim
:GeneroModuleDeps mymodule   " Show modules that mymodule depends on
:GeneroModuleGraph           " Show module dependency graph
```

### Implementation
```vim
" In autoload/genero_tools.vim
function! genero_tools#find_module_dependencies(module_name) abort
  if empty(a:module_name)
    let module_name = genero_tools#get_current_module()
  else
    let module_name = a:module_name
  endif
  
  if empty(module_name)
    call genero_tools#display#echo('Error: No module name provided')
    return {}
  endif
  
  let result = genero_tools#command#execute_shell('find-module-dependencies', [module_name])
  
  if result.success
    call genero_tools#display_result(result)
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
endfunction
```

### In plugin/genero_tools.vim
```vim
command! -nargs=? GeneroModuleDeps call genero_tools#find_module_dependencies(<q-args>)
```

---

## Phase 5: Enhanced Metadata (1-2 hours)

### Enhancement to Existing Command
Enhance `:GeneroFileMetadata` to show:
- Authors who modified the file
- Recent changes
- References/tickets

### Implementation
```vim
" In autoload/genero_tools.vim
function! genero_tools#get_file_metadata(file_path) abort
  if empty(a:file_path)
    let file_path = expand('%')
  else
    let file_path = a:file_path
  endif
  
  " Get references
  let refs = genero_tools#command#execute_shell('file-references', [file_path])
  
  " Get authors
  let authors = genero_tools#command#execute_shell('file-authors', [file_path])
  
  " Combine results
  let combined = {
    \ 'success': v:true,
    \ 'data': {
    \   'references': refs.data,
    \   'authors': authors.data,
    \ }
  \ }
  
  call genero_tools#display_result(combined)
endfunction
```

---

## Implementation Order

### Week 1: Foundation
1. Dead Code Detection (Phase 1)
2. Reference Lookup (Phase 3)

### Week 2: Dependencies
1. Function Dependencies (Phase 2)
2. Module Dependencies (Phase 4)

### Week 3: Polish
1. Enhanced Metadata (Phase 5)
2. Testing and documentation

---

## Testing Strategy

### For Each Feature
1. Test with small codebase (verify correctness)
2. Test with large codebase (verify performance)
3. Test error cases (missing functions, invalid references)
4. Test display modes (floating window, quickfix, split)

### Example Test Cases
```vim
" Dead code
:GeneroDead

" Dependencies
:GeneroDependencies validate_input
:GeneroDependents log_message

" References
:GeneroReference PRB-299
:GeneroReference EH100

" Module dependencies
:GeneroModuleDeps core
```

---

## Documentation Updates

### New Commands Section in README
```markdown
## Advanced Commands

- `:GeneroDead` - Find unused functions in workspace
- `:GeneroDependencies <func>` - Show functions called by a function
- `:GeneroDependents <func>` - Show functions that call a function
- `:GeneroReference <ref>` - Find files modified for a reference/ticket
- `:GeneroModuleDeps <module>` - Show module dependencies
```

### New Keybindings Section
```markdown
## Advanced Keybindings

| Keybinding | Action |
|-----------|--------|
| `<leader>gd` | Find dead code |
| `<leader>gdc` | Show function dependencies |
| `<leader>gdd` | Show function dependents |
```

---

## Estimated Effort

| Feature | Effort | Complexity |
|---------|--------|-----------|
| Dead Code Detection | 1-2h | Low |
| Reference Lookup | 1-2h | Low |
| Function Dependencies | 2-3h | Medium |
| Module Dependencies | 2-3h | Medium |
| Enhanced Metadata | 1-2h | Low |
| **Total** | **7-12h** | **Low-Medium** |

---

## Benefits

### For Users
- Better code understanding
- Safer refactoring
- Improved code quality
- Better team collaboration

### For Project
- Demonstrates advanced genero-tools usage
- Provides value-add features
- Encourages genero-tools adoption
- Positions plugin as comprehensive solution

---

## Next Steps

1. **Review** this roadmap with team
2. **Prioritize** features based on user needs
3. **Implement** Phase 1 (Dead Code + References)
4. **Test** thoroughly
5. **Document** new features
6. **Release** as minor version update
7. **Gather feedback** from users
8. **Iterate** on Phase 2+

---

## Notes

- All features use existing genero-tools commands
- No changes needed to genero-tools project
- Can be implemented incrementally
- Each feature is independent
- Backward compatible with existing functionality
