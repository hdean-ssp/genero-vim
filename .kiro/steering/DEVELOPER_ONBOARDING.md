---
inclusion: manual
---

# Developer Onboarding Guide

Welcome to the Vim Genero-Tools Plugin project! This guide will help you get up to speed quickly and make your first contribution.

## Quick Start for New Developers

### Step 1: Understand the Project (30 minutes)

1. **Read the project overview**
   - File: `README.md`
   - What: Project purpose, features, and requirements
   - Time: 10 minutes

2. **Learn the commands and keybindings**
   - File: `docs/DEVELOPER_QUICK_REFERENCE.md`
   - What: All available commands and default keybindings
   - Time: 10 minutes

3. **Understand the module organization**
   - File: `.kiro/steering/MODULE_ARCHITECTURE.md`
   - What: How modules interact and initialize
   - Time: 10 minutes

### Step 2: Set Up Development Environment (15 minutes)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vim-genero-tools
   ```

2. **Install Vim or Neovim** (if not already installed)
   ```bash
   # macOS
   brew install vim
   # or
   brew install neovim
   
   # Linux
   sudo apt-get install vim
   # or
   sudo apt-get install neovim
   ```

3. **Copy example configuration**
   ```bash
   cp .vimrc.example ~/.vimrc
   ```

4. **Install vim-plug** (plugin manager)
   ```bash
   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

5. **Start Vim and install plugins**
   ```bash
   vim
   :PlugInstall
   :q
   ```

### Step 3: Make Your First Change (1-2 hours)

1. **Pick a task**
   - File: `.kiro/specs/vim-genero-tools-plugin/tasks.md`
   - Look for tasks marked as `[ ]` (not started)
   - Start with a task marked as optional (`*`) for easier first contribution

2. **Read the requirements**
   - File: `.kiro/specs/vim-genero-tools-plugin/requirements.md`
   - Understand what the task should accomplish

3. **Read the design**
   - File: `.kiro/specs/vim-genero-tools-plugin/design.md`
   - Understand how to implement the task

4. **Implement the task**
   - Follow the code style guide (see below)
   - Reference IMPLEMENTATION_EXAMPLES.md for patterns
   - Add comments explaining complex logic

5. **Test your changes**
   - Start Vim: `vim`
   - Test the functionality manually
   - Check for errors: `:messages`

6. **Update the task status**
   - Mark task as completed in tasks.md
   - Update the spec file

## Project Structure

```
.
├── autoload/genero_tools/     # VimScript implementation
│   ├── genero_tools.vim       # Main API functions
│   ├── config.vim             # Configuration management
│   ├── cache.vim              # Result caching
│   ├── command.vim            # Command execution
│   ├── display.vim            # Display modes
│   ├── error.vim              # Error handling
│   ├── metrics.vim            # Performance metrics
│   ├── compiler.vim           # Compiler integration
│   ├── snippets.vim           # Snippet integration
│   ├── svn.vim                # SVN integration
│   └── compiler/              # Compiler submodules
│       ├── autocompile.vim
│       ├── commands.vim
│       ├── highlight.vim
│       ├── quickfix.vim
│       └── signs.vim
├── lua/genero_tools/          # Lua layer (Neovim)
│   ├── init.lua               # Lua entry point
│   ├── async.lua              # Async operations
│   └── snippets/              # Snippet templates
├── plugin/                    # Plugin entry points
│   └── genero_tools.vim       # Main plugin file
├── ftplugin/                  # Filetype-specific settings
│   ├── fgl.vim
│   └── genero.vim
├── docs/                      # User documentation
├── .kiro/
│   ├── specs/                 # Spec files
│   │   └── vim-genero-tools-plugin/
│   │       ├── requirements.md
│   │       ├── design.md
│   │       └── tasks.md
│   └── steering/              # Development guidance
│       ├── MODULE_ARCHITECTURE.md
│       ├── DEVELOPER_ONBOARDING.md
│       ├── vimscript-conventions.md
│       └── COMPILER_DEVELOPMENT.md
└── tests/                     # Test suite (to be created)
```

## Key Files to Know

| File | Purpose | When to Read |
|------|---------|--------------|
| README.md | Project overview | First |
| docs/DEVELOPER_QUICK_REFERENCE.md | Command reference | First |
| .kiro/steering/MODULE_ARCHITECTURE.md | Module organization | Before coding |
| .kiro/steering/vimscript-conventions.md | Code style | Before coding |
| .kiro/specs/vim-genero-tools-plugin/requirements.md | Feature requirements | When implementing |
| .kiro/specs/vim-genero-tools-plugin/design.md | Technical design | When implementing |
| .kiro/specs/vim-genero-tools-plugin/tasks.md | Implementation tasks | To pick a task |
| IMPLEMENTATION_EXAMPLES.md | Code examples | When coding |

## Common Development Tasks

### Adding a New Command

1. **Define the command function**
   - File: `autoload/genero_tools/genero_tools.vim`
   - Pattern: `function! genero_tools#command_name(args) abort`
   - Return: Result dictionary with success, data, error, timestamp

2. **Register the command**
   - File: `plugin/genero_tools.vim`
   - Pattern: `command! GeneroCommandName call genero_tools#command_name(...)`

3. **Add keybinding** (optional)
   - File: `autoload/genero_tools/keybindings.vim`
   - Pattern: `nnoremap <leader>gx :GeneroCommandName<CR>`

4. **Update documentation**
   - File: `README.md` or relevant docs file
   - Add command to Commands section

5. **Add tests**
   - File: `tests/unit/test_genero_tools.vim`
   - Test the function with various inputs

### Adding a New Display Mode

1. **Create display function**
   - File: `autoload/genero_tools/display.vim`
   - Pattern: `function! genero_tools#display#newmode(results) abort`

2. **Update display router**
   - File: `autoload/genero_tools/display.vim`
   - Add case to `display#result()` function

3. **Add configuration option**
   - File: `autoload/genero_tools/config.vim`
   - Add to defaults: `'display_mode': 'newmode'`

4. **Update documentation**
   - File: `README.md`
   - Add to Display Modes section

5. **Add tests**
   - File: `tests/unit/test_display.vim`
   - Test display formatting and window handling

### Adding a New Configuration Option

1. **Add to defaults**
   - File: `autoload/genero_tools/config.vim`
   - Add to `defaults` dictionary in `config#init()`

2. **Add validation** (if needed)
   - File: `autoload/genero_tools/config.vim`
   - Add to `config#validate()` function

3. **Update documentation**
   - File: `README.md`
   - Add to Configuration section

4. **Update example config**
   - File: `.vimrc.example`
   - Add commented example

5. **Add tests**
   - File: `tests/unit/test_config.vim`
   - Test default value and validation

## Code Style Guide

### VimScript Conventions

**Variable Prefixes:**
- `a:` for arguments
- `l:` for local variables
- `g:` for global variables
- `s:` for script-local variables

**Example:**
```vim
function! genero_tools#lookup_function(function_name) abort
  let l:cache_key = 'lookup:' . a:function_name
  let l:cached = genero_tools#cache#get(l:cache_key)
  if !empty(l:cached)
    return l:cached
  endif
endfunction
```

**Function Documentation:**
```vim
" genero_tools#lookup_function(function_name)
"
" Find a function definition in the codebase.
"
" Args:
"   function_name (string): Name of function to find. If empty, uses word under cursor.
"
" Returns:
"   dict: {success: bool, data: dict, error: string, timestamp: number}
"
" Raises:
"   - Error if genero-tools is not found
"   - Error if codebase path is invalid
"
function! genero_tools#lookup_function(function_name) abort
```

**Error Handling:**
```vim
function! genero_tools#some_operation() abort
  if empty(some_param)
    return genero_tools#error#result('module', 'Parameter is required')
  endif
  
  try
    " ... operation ...
  catch
    return genero_tools#error#result('module', 'Operation failed: ' . v:exception)
  endtry
endfunction
```

**Consistent Formatting:**
- Use 2-space indentation
- Use `abort` in all function definitions
- Use `v:true` and `v:false` instead of 1 and 0
- Use `==` for comparison, not `=`

See `.kiro/steering/vimscript-conventions.md` for complete style guide.

## Debugging Issues

### Enable Debug Mode
```vim
let g:genero_tools_config.debug_mode = 1
```

### Check Configuration
```vim
:GeneroConfigShow
```

### Clear Cache
```vim
:GeneroClearCache
```

### View Error Messages
```vim
:messages
```

### Check genero-tools CLI Directly
```bash
query.sh find-function myFunction
```

### Enable Verbose Output
```vim
set verbose=9
```

## Testing

### Running Tests
```bash
# Run all tests
./scripts/test.sh

# Run specific test file
./scripts/test.sh tests/unit/test_config.vim

# Run with coverage
./scripts/test.sh --coverage
```

### Writing Tests
```vim
" tests/unit/test_config.vim
function! test_config_init() abort
  " Given: Default configuration
  call genero_tools#config#init()
  
  " Then: Configuration is loaded
  assert_equal(genero_tools#config#get('cache_enabled'), v:true)
  assert_equal(genero_tools#config#get('timeout'), 10000)
endfunction
```

## Getting Help

### Architecture Questions
- See: `.kiro/steering/MODULE_ARCHITECTURE.md`
- Explains: Module organization and interactions

### Code Style Questions
- See: `.kiro/steering/vimscript-conventions.md`
- Explains: VimScript conventions and patterns

### Compiler Questions
- See: `.kiro/steering/COMPILER_DEVELOPMENT.md`
- Explains: Compiler integration architecture

### Lua Layer Questions
- See: `.kiro/steering/lua-layer-architecture.md`
- Explains: Lua layer design and patterns

### General Questions
- Ask in project discussions
- Create an issue with your question
- Check existing issues for similar questions

## Workflow

### 1. Pick a Task
- Open: `.kiro/specs/vim-genero-tools-plugin/tasks.md`
- Find: A task marked as `[ ]` (not started)
- Read: Requirements and design for the task

### 2. Create a Branch
```bash
git checkout -b feature/task-name
```

### 3. Implement the Task
- Follow code style guide
- Reference IMPLEMENTATION_EXAMPLES.md
- Add comments for complex logic
- Test manually in Vim

### 4. Update Task Status
- Mark task as completed in tasks.md
- Update spec file with any changes

### 5. Commit and Push
```bash
git add .
git commit -m "Implement: task description"
git push origin feature/task-name
```

### 6. Create Pull Request
- Describe changes
- Reference task number
- Request review

## First Task Recommendations

### For VimScript Beginners
1. Task 2.4: Write property test for configuration consistency
2. Task 3.4: Write property test for result structure consistency
3. Task 14.1: Add result limit guidance messages

### For Experienced Developers
1. Task 2.2: Complete Lua Layer Implementation
2. Task 3.1: Implement Property-Based Testing
3. Task 4.1: Add Performance Metrics

### For Documentation Lovers
1. Task 1.1: Create Module Architecture Documentation (DONE)
2. Task 1.2: Create Developer Onboarding Guide (DONE)
3. Task 3.4: Create Query Optimization Guide

## Checklist for First Contribution

- [ ] Read README.md
- [ ] Read docs/DEVELOPER_QUICK_REFERENCE.md
- [ ] Read .kiro/steering/MODULE_ARCHITECTURE.md
- [ ] Set up development environment
- [ ] Pick a task from tasks.md
- [ ] Read requirements and design for task
- [ ] Implement the task
- [ ] Test manually in Vim
- [ ] Update task status
- [ ] Commit and push changes
- [ ] Create pull request

## Success Criteria

You've successfully onboarded when you can:
- [ ] Explain the project's purpose and features
- [ ] Navigate the codebase and find relevant files
- [ ] Understand how modules interact
- [ ] Write VimScript following project conventions
- [ ] Implement a simple task from the roadmap
- [ ] Test your changes manually
- [ ] Update documentation and specs

## Next Steps

1. **Complete this guide** - You're reading it now!
2. **Set up environment** - Follow Step 2 above
3. **Pick a task** - Choose from tasks.md
4. **Make your first contribution** - Follow the workflow
5. **Get feedback** - Submit PR and iterate

Welcome to the team! 🎉

