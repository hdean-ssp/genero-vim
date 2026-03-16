---
inclusion: manual
---

# Compiler Integration - Development Guide

This guide is for developers working on the compiler integration system.

## Architecture Overview

### Module Structure

```
autoload/genero_tools/
├── compiler.vim                 # Main compiler module
├── compiler/
│   ├── autocompile.vim         # Autocompile on save
│   ├── commands.vim            # User commands
│   ├── highlight.vim           # Syntax highlighting
│   ├── quickfix.vim            # Quickfix integration
│   └── signs.vim               # Sign column display
```

### Data Flow

```
File Save
    ↓
BufWritePost Event
    ↓
on_save() - Schedule delayed compilation
    ↓
Timer (1000ms delay)
    ↓
compile_delayed() - Verify file unchanged
    ↓
compile_silent() - Execute compiler
    ↓
system('fglcomp -M -W all <file>')
    ↓
Capture stdout
    ↓
parse_v310() - Parse output
    ↓
├─ signs#update() - Place signs
├─ highlight#unused_vars() - Highlight unused vars
└─ quickfix#populate() - Populate quickfix
    ↓
All updates complete (silent)
```

## Key Components

### 1. Parser Module (`compiler.vim`)

**Function:** `genero_tools#compiler#execute(source_path)`

Builds and executes compiler command:
```vim
let cmd = compiler_cmd . ' -M -W all ' . genero_tools#command#escape_arg(a:source_path)
let output = system(cmd)
```

**Parser:** `genero_tools#compiler#parse_v310(output)`

Regex pattern:
```vim
'^\([^:]*\):\(\d\+\):\(\d\+\):\(\d\+\):\(\d\+\):\(error\|warning\|info\):(-\d\+) \(.*\)$'
```

Extracts:
- file, line, col, end_line, end_col
- severity (error/warning/info)
- code (-6615, -4369, -8059, etc.)
- message

### 2. Autocompile Module (`compiler/autocompile.vim`)

**Enable:** `genero_tools#compiler#autocompile#enable()`
- Sets up `BufWritePost` autocommand
- Scoped to current buffer

**On Save:** `genero_tools#compiler#autocompile#on_save()`
- Triggered by `BufWritePost` event
- Schedules delayed compilation
- Cancels previous timer if pending

**Delayed Compile:** `genero_tools#compiler#autocompile#compile_delayed(file, timer_id)`
- Waits for configured delay (default 1000ms)
- Verifies file hasn't changed
- Calls `compile_silent()`

**Silent Compile:** `genero_tools#compiler#autocompile#compile_silent(file)`
- Executes compiler
- Updates signs (if enabled)
- Updates highlighting (if enabled)
- Updates quickfix (if errors/warnings)

### 3. Highlighting Module (`compiler/highlight.vim`)

**Unused Variable Highlighting:**

```vim
function! genero_tools#compiler#highlight#unused_vars(warnings) abort
  " Filter warnings for code -6615
  let unused_warnings = filter(copy(a:warnings), 
    \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
  
  " Extract variable names and highlight
  for warning in unused_warnings
    let var_match = matchstr(warning.message, "symbol '\\zs[^']*\\ze'")
    if !empty(var_match)
      let pattern = '\<' . var_match . '\>'
      call matchadd(s:unused_var_group, pattern, 11)
    endif
  endfor
endfunction
```

### 4. Sign Column Module (`compiler/signs.vim`)

**Signs Defined:**
```vim
sign define GeneroCompilerError text=✕ texthl=ErrorMsg
sign define GeneroCompilerWarning text=⚠ texthl=WarningMsg
sign define GeneroCompilerInfo text=ℹ texthl=InfoMsg
```

**Placement:**
```vim
execute 'sign place ' . sign_id . ' line=' . error.line . 
      \ ' name=' . s:sign_error . 
      \ ' file=' . error.file
```

### 5. Quickfix Module (`compiler/quickfix.vim`)

**Format Entry:**
```vim
{
  \ 'filename': entry.file,
  \ 'lnum': entry.line,
  \ 'col': entry.col,
  \ 'text': entry.message,
  \ 'type': 'E'  " or 'W' for warning
  \ }
```

**Populate:**
```vim
call setqflist(qf_list)
```

## Configuration

**File:** `autoload/genero_tools/config.vim`

Default values:
```vim
'compiler_enabled': v:false,
'compiler_command': 'fglcomp',
'compiler_autocompile': v:false,
'compiler_autocompile_delay': 1000,
'compiler_sign_column': v:true,
'compiler_highlight_unused': v:true,
```

## Testing

### Test Files

- `test/compiler_output_examples.txt` - Real compiler output
- `test/test_compiler_parser.vim` - Parser tests
- `test/full_parser_test.vim` - Full workflow test
- `test/verify_autocompile.vim` - Configuration verification

### Running Tests

```bash
vim -u NONE -N -es -c "source test/full_parser_test.vim"
```

### Test Coverage

- Parser initialization
- Warning parsing
- Error parsing
- Field extraction
- Variable name extraction
- Code categorization
- Severity classification
- Sign placement
- Highlighting application
- Quickfix population

## Adding Support for New Compiler Versions

### 1. Create Parser Function

```vim
function! genero_tools#compiler#parse_v320(output) abort
  " Implement parsing for version 3.20 format
  " Return same structure as parse_v310
endfunction
```

### 2. Update Router

```vim
function! genero_tools#compiler#parse_output(output, version) abort
  if a:version =~? '^3\.2'
    return genero_tools#compiler#parse_v320(a:output)
  endif
endfunction
```

### 3. Test

Add test cases for new format in `test/test_compiler_parser.vim`

## Adding Support for New Error Codes

### 1. Update Documentation

Add to `docs/COMPILER_INTEGRATION.md`:
```markdown
| -XXXX | Type | Description |
```

### 2. Add Highlighting (if needed)

```vim
" In highlight#unused_vars or similar
let code_warnings = filter(copy(a:warnings), 
  \ "v:val.code == '(-XXXX)'")
```

### 3. Test

Add test case to verify parsing and highlighting

## Performance Optimization

### Autocompile Delay

Prevents excessive compilation during rapid saves:
```vim
let g:genero_tools_config.compiler_autocompile_delay = 1000
```

### Sign Placement

Uses unique sign IDs to avoid conflicts:
```vim
let sign_id = 1
for error in a:errors
  execute 'sign place ' . sign_id . ' ...'
  let sign_id += 1
endfor
```

### Highlighting

Uses regex-based matching for efficiency:
```vim
let pattern = '\<' . var_match . '\>'
call matchadd(group, pattern, priority)
```

## Debugging

### Enable Verbose Output

```vim
set verbose=9
```

### Check Configuration

```vim
echo g:genero_tools_config
```

### Test Parser Directly

```vim
let result = genero_tools#compiler#parse_v310(test_output)
echo result
```

### Check Signs

```vim
:sign list
```

### Check Highlights

```vim
:highlight GeneroUnusedVariable
```

## Common Issues

### Parser Not Matching Output

1. Check regex pattern in `parse_v310()`
2. Verify output format matches expected format
3. Add test case with actual output

### Signs Not Showing

1. Verify signs are defined: `:sign list`
2. Check sign column width: `:set signcolumn?`
3. Verify file is open in buffer

### Highlighting Not Working

1. Check highlight group: `:highlight GeneroUnusedVariable`
2. Verify variable names are extracted correctly
3. Check for conflicting plugins

### Autocompile Not Triggering

1. Verify autocommand: `:autocmd BufWritePost`
2. Check if compiler is enabled
3. Verify file type is correct

## Future Enhancements

1. **Error Recovery Suggestions** - Parse compiler suggestions
2. **Warning Filtering** - Filter by code or message pattern
3. **Performance Metrics** - Track compilation time
4. **Batch Compilation** - Compile multiple files
5. **Custom Error Handlers** - User-defined error processing
6. **LSP Integration** - Publish diagnostics to LSP
7. **Incremental Compilation** - Only compile changed files

## References

- [Compiler Integration Guide](../docs/COMPILER_INTEGRATION.md) - User guide
- [Vim system() function](https://vim.fandom.com/wiki/Execute_external_programs_asynchronously_using_timers_and_system())
- [Vim sign column](https://vim.fandom.com/wiki/Using_signs)
- [Vim quickfix](https://vim.fandom.com/wiki/Quickfix_window)
