# Improvement Roadmap: Vim Genero-Tools Plugin

This document provides a detailed roadmap for implementing the improvements identified in the code review.

---

## Phase 1: Foundation & Documentation (Priority: HIGH)

### Task 1.1: Create Module Architecture Documentation

**File:** `.kiro/steering/MODULE_ARCHITECTURE.md`

**Content to include:**
```markdown
# Module Architecture Guide

## Module Dependency Graph

```
config.vim (no dependencies)
  ↓
cache.vim (depends on config)
  ↓
command.vim (depends on config, cache)
  ↓
display.vim (depends on config)
  ↓
genero_tools.vim (depends on all above)
```

## Initialization Sequence

1. **config#init()** - Load configuration with defaults
2. **cache#init()** - Initialize cache system
3. **command#init()** - Set up command execution
4. **display#init()** - Set up display modes
5. **keybindings#init()** - Register keybindings
6. **compiler#init()** - Initialize compiler integration
7. **snippets#init()** - Initialize snippet system
8. **svn#init()** - Initialize SVN integration

## Module Responsibilities

### config.vim
- Load and validate configuration
- Provide configuration getters/setters
- Handle type conversions (e.g., string to list)

### cache.vim
- Store and retrieve cached results
- Manage TTL expiration
- Implement LRU eviction
- Provide cache statistics

### command.vim
- Execute genero-tools CLI commands
- Handle timeouts and errors
- Parse JSON output
- Support async execution

### display.vim
- Format results for display
- Support multiple display modes (quickfix, popup, split, echo)
- Handle pagination
- Manage display windows

### genero_tools.vim
- Provide public API functions
- Coordinate between modules
- Handle user-facing operations
```

**Effort:** 2-3 hours  
**Acceptance Criteria:**
- [ ] Dependency graph is clear and accurate
- [ ] Initialization sequence is documented
- [ ] Each module's responsibility is explained
- [ ] Cross-module communication patterns are documented

---

### Task 1.2: Create Developer Onboarding Guide

**File:** `.kiro/steering/DEVELOPER_ONBOARDING.md`

**Content to include:**
```markdown
# Developer Onboarding Guide

## Quick Start for New Developers

### Step 1: Understand the Project (30 minutes)
1. Read: README.md (project overview)
2. Read: docs/DEVELOPER_QUICK_REFERENCE.md (commands and keybindings)
3. Read: .kiro/steering/MODULE_ARCHITECTURE.md (module organization)
4. Skim: .kiro/specs/vim-genero-tools-plugin/ (requirements and design)

### Step 2: Set Up Development Environment (15 minutes)
1. Clone repository: `git clone <repo>`
2. Install Vim/Neovim (if not already installed)
3. Copy example config: `cp .vimrc.example ~/.vimrc`
4. Install vim-plug: `curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
5. Start Vim and run `:PlugInstall`

### Step 3: Make Your First Change (1-2 hours)
1. Pick a task from .kiro/specs/vim-genero-tools-plugin/tasks.md
2. Read the requirements and design docs
3. Implement the task
4. Test your changes
5. Submit PR

### Step 4: Common Development Tasks

#### Adding a New Command
1. Define command in autoload/genero_tools/commands.vim
2. Implement command function in autoload/genero_tools/genero_tools.vim
3. Add keybinding in autoload/genero_tools/keybindings.vim
4. Update documentation in docs/
5. Add tests in tests/

#### Adding a New Display Mode
1. Add display function in autoload/genero_tools/display.vim
2. Update display#result() to handle new mode
3. Add configuration option in config.vim
4. Update documentation
5. Add tests

#### Debugging Issues
1. Enable debug mode: `let g:genero_tools_config.debug_mode = 1`
2. Check logs in debug stream (Neovim only)
3. Use `:GeneroConfigShow` to verify configuration
4. Use `:GeneroClearCache` to clear cached results
5. Check genero-tools CLI directly to isolate issues

## Project Structure

```
.
├── autoload/genero_tools/     # VimScript implementation
├── lua/genero_tools/          # Lua layer (Neovim)
├── plugin/                    # Plugin entry points
├── ftplugin/                  # Filetype-specific settings
├── docs/                      # User documentation
├── .kiro/
│   ├── specs/                 # Spec files (requirements, design, tasks)
│   └── steering/              # Development guidance
└── tests/                     # Test suite (to be created)
```

## Key Files to Know

| File | Purpose |
|------|---------|
| autoload/genero_tools.vim | Main API functions |
| autoload/genero_tools/config.vim | Configuration management |
| autoload/genero_tools/command.vim | Command execution |
| autoload/genero_tools/cache.vim | Result caching |
| autoload/genero_tools/display.vim | Display modes |
| autoload/genero_tools/compiler.vim | Compiler integration |
| lua/genero_tools/init.lua | Lua layer entry point |
| .kiro/specs/vim-genero-tools-plugin/ | Main spec files |
| .kiro/steering/ | Development guidance |

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

## Code Style

### VimScript Conventions
- Use `a:` prefix for arguments
- Use `l:` prefix for local variables
- Use `g:` prefix for global variables
- Use `s:` prefix for script-local variables
- Use `abort` in function definitions
- Use `v:true` and `v:false` instead of 1 and 0

### Function Documentation
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

## Getting Help

- **Architecture questions:** See .kiro/steering/MODULE_ARCHITECTURE.md
- **Code style questions:** See .kiro/steering/vimscript-conventions.md
- **Compiler questions:** See .kiro/steering/COMPILER_DEVELOPMENT.md
- **Lua layer questions:** See .kiro/steering/lua-layer-architecture.md
- **General questions:** Ask in project discussions or create an issue
```

**Effort:** 2-3 hours  
**Acceptance Criteria:**
- [ ] New developers can set up environment in 15 minutes
- [ ] New developers can make first change in 1-2 hours
- [ ] All common development tasks are documented
- [ ] Debugging guide is clear and helpful

---

### Task 1.3: Add Configuration Validation

**File:** `autoload/genero_tools/config.vim`

**Changes needed:**
```vim
" Add validation function
function! genero_tools#config#validate() abort
  " Validate timeout is positive
  let timeout = genero_tools#config#get('timeout')
  if timeout <= 0
    call genero_tools#error#warn('timeout must be positive, using default 10000')
    let g:genero_tools_config.timeout = 10000
  endif
  
  " Validate display_mode is supported
  let display_mode = genero_tools#config#get('display_mode')
  let valid_modes = ['quickfix', 'popup', 'split', 'echo', 'inline']
  if index(valid_modes, display_mode) == -1
    call genero_tools#error#warn('invalid display_mode "' . display_mode . '", using quickfix')
    let g:genero_tools_config.display_mode = 'quickfix'
  endif
  
  " Validate cache settings
  let cache_ttl = genero_tools#config#get('cache_ttl')
  if cache_ttl <= 0
    call genero_tools#error#warn('cache_ttl must be positive, using default 3600')
    let g:genero_tools_config.cache_ttl = 3600
  endif
  
  let cache_max_size = genero_tools#config#get('cache_max_size')
  if cache_max_size <= 0
    call genero_tools#error#warn('cache_max_size must be positive, using default 100')
    let g:genero_tools_config.cache_max_size = 100
  endif
  
  " Validate result_limit
  let result_limit = genero_tools#config#get('result_limit')
  if result_limit <= 0
    call genero_tools#error#warn('result_limit must be positive, using default 1000')
    let g:genero_tools_config.result_limit = 1000
  endif
endfunction

" Call validation in init()
function! genero_tools#config#init() abort
  " ... existing code ...
  call genero_tools#config#validate()
endfunction
```

**Effort:** 1-2 hours  
**Acceptance Criteria:**
- [ ] Invalid timeout values are caught and corrected
- [ ] Invalid display_mode values are caught and corrected
- [ ] Invalid cache settings are caught and corrected
- [ ] Users see helpful warning messages
- [ ] Validation runs on plugin initialization

---

## Phase 2: Code Quality & Testing (Priority: HIGH)

### Task 2.1: Implement Property-Based Testing Infrastructure

**Files to create:**
- `tests/` - Test directory
- `tests/unit/` - Unit tests
- `tests/integration/` - Integration tests
- `tests/properties/` - Property-based tests
- `tests/fixtures/` - Test data and mocks
- `tests/run_tests.vim` - Test runner
- `scripts/test.sh` - Test script

**Example test structure:**
```vim
" tests/unit/test_config.vim
function! test_config_init() abort
  " Given: Default configuration
  call genero_tools#config#init()
  
  " Then: Configuration is loaded with defaults
  assert_equal(genero_tools#config#get('cache_enabled'), v:true)
  assert_equal(genero_tools#config#get('timeout'), 10000)
  assert_equal(genero_tools#config#get('display_mode'), 'quickfix')
endfunction

function! test_config_get_returns_default() abort
  " Given: Configuration is initialized
  call genero_tools#config#init()
  
  " When: Getting a non-existent key
  let result = genero_tools#config#get('nonexistent_key')
  
  " Then: Default value is returned
  assert_equal(result, v:false)
endfunction

function! test_config_validation_fixes_invalid_timeout() abort
  " Given: Configuration with invalid timeout
  let g:genero_tools_config.timeout = -1000
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Timeout is corrected to default
  assert_equal(genero_tools#config#get('timeout'), 10000)
endfunction
```

**Effort:** 4-6 hours  
**Acceptance Criteria:**
- [ ] Test infrastructure is set up
- [ ] Unit tests for core modules exist
- [ ] Integration tests for module interactions exist
- [ ] Property-based tests for correctness properties exist
- [ ] Test runner works and reports results
- [ ] Tests can be run with `./scripts/test.sh`

---

### Task 2.2: Complete Lua Layer Implementation

**Files to update:**
- `lua/genero_tools/init.lua` - Main entry point
- `lua/genero_tools/async.lua` - Async operations
- `lua/genero_tools/ui.lua` - UI components (create if needed)

**Changes needed:**
```lua
-- lua/genero_tools/async.lua
local M = {}

-- Execute command asynchronously
function M.execute_command(cmd, args, callback)
  -- Implementation using vim.fn.jobstart or similar
  -- Call callback with results when done
end

-- Execute with progress indicator
function M.execute_with_progress(cmd, args, callback)
  -- Show progress indicator
  -- Execute command asynchronously
  -- Update progress as command runs
  -- Call callback with results
end

-- Cancel running command
function M.cancel(job_id)
  -- Implementation to cancel job
end

return M
```

**Effort:** 4-6 hours  
**Acceptance Criteria:**
- [ ] Async operations are implemented (not stubs)
- [ ] Progress indicators work
- [ ] Commands can be cancelled
- [ ] Error handling is robust
- [ ] Lua/VimScript communication works correctly

---

## Phase 3: Enhancement & Polish (Priority: MEDIUM)

### Task 3.1: Standardize Error Messages

**File:** `autoload/genero_tools/error.vim`

**Implementation:**
```vim
" Error message format: [MODULE] Error description
function! genero_tools#error#format(module, message) abort
  return '[' . a:module . '] ' . a:message
endfunction

function! genero_tools#error#echo(module, message) abort
  call genero_tools#display#echo(genero_tools#error#format(a:module, a:message))
endfunction

function! genero_tools#error#warn(module, message) abort
  echohl WarningMsg
  echo genero_tools#error#format(a:module, a:message)
  echohl None
endfunction
```

**Effort:** 2-3 hours  
**Acceptance Criteria:**
- [ ] Error message format is consistent
- [ ] All modules use standard error functions
- [ ] Error messages are helpful and actionable

---

## Implementation Timeline

### Week 1: Foundation
- [ ] Task 1.1: Module Architecture Documentation (2-3 hours)
- [ ] Task 1.2: Developer Onboarding Guide (2-3 hours)
- [ ] Task 1.3: Configuration Validation (1-2 hours)
- [ ] Task 2.1: Testing Infrastructure (4-6 hours)

**Total: 9-14 hours**

### Week 2: Enhancement
- [ ] Task 2.2: Complete Lua Layer (4-6 hours)
- [ ] Task 3.1: Performance Metrics (2-3 hours)
- [ ] Task 3.2: Standardize Error Messages (2-3 hours)

**Total: 8-12 hours**

### Week 3: Polish
- [ ] Task 3.3: Cache Statistics (1-2 hours)
- [ ] Task 3.4: Query Optimization Guide (1-2 hours)
- [ ] Code review and testing (2-3 hours)

**Total: 4-7 hours**

---

## Success Criteria

### Phase 1 Complete When:
- [ ] New developers can set up environment in 15 minutes
- [ ] New developers can make first change in 1-2 hours
- [ ] Configuration validation prevents common errors
- [ ] All modules have clear responsibilities documented

### Phase 2 Complete When:
- [ ] Test infrastructure is in place
- [ ] Core modules have unit tests
- [ ] Property-based tests validate correctness
- [ ] Lua layer is fully implemented

### Phase 3 Complete When:
- [ ] Performance metrics are tracked and visible
- [ ] Error messages are consistent and helpful
- [ ] Cache statistics are available
- [ ] Query optimization guide is comprehensive

---

## Notes for Implementation

1. **Start with Phase 1** - Documentation and validation are quick wins that improve developer experience immediately

2. **Test as you go** - Write tests for each new feature as you implement it

3. **Update specs** - Update `.kiro/specs/vim-genero-tools-plugin/tasks.md` as you complete tasks

4. **Get feedback** - Share improvements with team and gather feedback

5. **Iterate** - Use feedback to refine implementations

---

## Related Documents

- `CODE_REVIEW.md` - Detailed code review with analysis
- `REVIEW_SUMMARY.md` - Summary of key findings
- `.kiro/specs/vim-genero-tools-plugin/` - Project specifications
- `.kiro/steering/` - Development guidance

