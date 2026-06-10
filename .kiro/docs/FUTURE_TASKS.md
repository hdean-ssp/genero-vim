# Future Tasks & Enhancements

**Last Updated**: March 22, 2026
**Project Status**: Display Enhancements 100% Complete
**Next Phase**: Future Enhancements (Optional)
**Organization**: See `bug-fixes/` and `enhancements/` directories for detailed documentation

---

## Enhancement Roadmap

### Priority Levels
- **Critical**: Required for core functionality
- **High**: Significant user-facing improvements
- **Medium**: Nice to have, improves UX
- **Low**: Polish, optimization, future-proofing

---

## Bug Fixes

### Bug Fix #001: Snippet Expansion & Autocomplete Integration (High Priority)
**Status**: ✓ Implementation Complete - Ready for Testing
**Location**: `bug-fixes/BF-1/`
**Documentation**: See `bug-fixes/BF-1/README.md` for complete details

**Status**: Open
**Issue ID**: #001
**Effort**: 2-3 days
**Rationale**: Snippets are core feature; broken expansion and selection significantly impact UX

### Tasks
- [x] BF-1.1 Review snippet list floating window implementation
- [x] BF-1.2 Add selection/confirmation mechanism to snippet list
- [x] BF-1.3 Implement keyboard selection (Enter to select)
- [x] BF-1.4 Implement mouse selection (click to select)
- [x] BF-1.5 Review snippet insertion mechanism in `snippets.vim`
- [x] BF-1.6 Check luasnip integration in `lua_bridge.vim`
- [x] BF-1.7 Verify autocomplete menu configuration in `complete.vim`
- [x] BF-1.8 Test snippet expansion with luasnip directly
- [x] BF-1.9 Check if snippet sources registered with autocomplete
- [x] BF-1.10 Fix snippet insertion to use luasnip expansion
- [x] BF-1.11 Add snippets to autocomplete menu sources
- [x] BF-1.12 Implement placeholder navigation
- [x] BF-1.13 Test with all display modes
- [x] BF-1.14 Test Vim and Neovim compatibility
- [x] BF-1.15 Update documentation

### Files to Modify
- `autoload/genero_tools/snippets.vim` - Snippet management and list display
- `autoload/genero_tools/complete.vim` - Autocomplete system
- `autoload/genero_tools/lua_bridge.vim` - Lua integration
- `autoload/genero_tools/config.vim` - Configuration options

### Configuration
```vim
snippets_enabled: 1                    " Enable/disable snippets
snippets_directory: './snippets'       " Snippet directory
autocomplete_include_snippets: 1       " Include snippets in autocomplete
snippet_expansion_mode: 'luasnip'      " Expansion engine (luasnip, vim-snipmate, etc)
snippet_list_selectable: 1             " Enable selection in snippet list
snippet_list_keybindings: {            " Keybindings for snippet list
  \ 'select': '<CR>',                  " Select snippet
  \ 'cancel': '<Esc>',                 " Cancel selection
  \ 'next': '<C-n>',                   " Next snippet
  \ 'prev': '<C-p>',                   " Previous snippet
  \ }
```

### Implementation Steps

#### Part 1: Fix Snippet List Selection
1. **Analyze Current Implementation**
   - Review floating window implementation
   - Identify why selection is not implemented
   - Check keybinding setup

2. **Add Selection Mechanism**
   - Implement Enter key to select snippet
   - Implement mouse click to select snippet
   - Add visual feedback for selection
   - Implement cancel mechanism (Esc)

3. **Test Selection**
   - Test keyboard selection
   - Test mouse selection
   - Test cancel mechanism
   - Test with different display modes

#### Part 2: Fix Snippet Expansion
1. **Analyze Current Implementation**
   - Review how snippets are currently inserted
   - Check luasnip integration points
   - Identify why expansion is bypassed

2. **Fix Snippet Expansion**
   - Modify snippet insertion to use luasnip
   - Ensure placeholder handling works
   - Test navigation between placeholders

3. **Integrate with Autocomplete**
   - Register snippet sources with autocomplete
   - Add snippets to completion menu
   - Ensure proper filtering and sorting

#### Part 3: Testing
- Test snippet list selection (keyboard and mouse)
- Test snippet expansion
- Test placeholder navigation
- Test autocomplete integration
- Test all display modes
- Test Vim and Neovim

#### Part 4: Documentation
- Update snippet documentation
- Add configuration examples
- Document keybindings
- Document troubleshooting

### Notes
- High priority - affects core functionality
- Snippet list selection is critical for usability
- Requires careful integration with existing systems
- May need new configuration options
- Consider creating dedicated snippet phase after fix

---

## Enhancement Phases

### Phase 8: Display Mode Simplification (High Priority)

**Status**: Planned
**Effort**: 2-3 days
**Rationale**: Current display modes are confusing and overlapping. Simplify to 3 core modes.
**Location**: `enhancements/PHASE_8_DISPLAY_MODE_SIMPLIFICATION.md`

### Problem Statement
Current implementation has 5 display modes with unclear distinctions:
- `echo` - Command line output
- `quickfix` - Quickfix list
- `popup` - Floating window (Neovim)
- `inline` - Inline display (Neovim)
- `split` - Split window

**Issues**:
1. **Confusing Distinction**: `popup` vs `inline` vs `split` have negligible differences
2. **Overlapping Functionality**: Multiple modes do similar things
3. **Configuration Complexity**: Users unsure which mode to choose
4. **Implementation Overhead**: Maintaining 5 modes increases code complexity
5. **Inconsistent Behavior**: Different modes have different capabilities

### Proposed Solution
Simplify to 3 core display modes:

1. **`echo`** - Command line (status line)
   - Pops up in status line
   - Requires Enter to dismiss
   - Best for: Quick notifications, brief messages
   - Vim & Neovim compatible

2. **`floating`** - Floating window
   - Floating window with border
   - Configurable size and position
   - Supports scrolling for large content
   - Best for: Detailed results, code listings
   - Neovim only (fallback to echo in Vim)

3. **`quickfix`** - Quickfix list
   - Standard Vim quickfix window
   - Navigable list of results
   - Integrates with error navigation
   - Best for: Error lists, search results
   - Vim & Neovim compatible

### Tasks
- [ ] 8.1 Audit current display mode usage
- [ ] 8.2 Design migration strategy
- [ ] 8.3 Consolidate popup/inline/split into floating
- [ ] 8.4 Update configuration system
- [ ] 8.5 Update all display calls
- [ ] 8.6 Add backward compatibility layer
- [ ] 8.7 Update documentation
- [ ] 8.8 Test all features with new modes
- [ ] 8.9 Update configuration examples

### Files to Modify
- `autoload/genero_tools/display.vim` - Core display logic
- `autoload/genero_tools/config.vim` - Configuration validation
- `autoload/genero_tools/compat.vim` - Compatibility layer
- `docs/CONFIGURATION.md` - User documentation
- All feature modules using display modes

### Configuration Changes
```vim
" Old (5 modes)
display_mode: 'quickfix|popup|inline|split|echo'

" New (3 modes)
display_mode: 'echo|floating|quickfix'

" Feature-specific overrides (simplified)
compiler_display_mode: ''      " empty = inherit from global
hints_display_mode: ''
signatures_display_mode: ''
progress_display_mode: ''
debug_display_mode: ''
error_display_mode: ''
```

### Migration Path
1. **Phase 1**: Add new 3-mode system alongside existing 5-mode system
2. **Phase 2**: Map old modes to new modes (popup→floating, inline→floating, split→floating)
3. **Phase 3**: Deprecate old modes with warnings
4. **Phase 4**: Remove old modes in next major version

### Backward Compatibility
```vim
" Old mode → New mode mapping
popup → floating
inline → floating
split → floating
echo → echo
quickfix → quickfix
```

### Benefits
- **Simpler Configuration**: Users choose between 3 clear options
- **Reduced Complexity**: Less code to maintain
- **Better UX**: Clear purpose for each mode
- **Easier Documentation**: Fewer options to explain
- **Consistent Behavior**: Each mode has well-defined behavior

### Notes
- High priority - improves user experience significantly
- Requires careful migration to maintain backward compatibility
- Consider deprecation warnings in intermediate version
- Update all documentation and examples
- Test thoroughly with all features

---

## Phase 9: Progress Display Module (Medium Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Currently uses direct echo; could benefit from display mode support
**Location**: `enhancements/PHASE_9_PROGRESS_DISPLAY.md`

### Tasks
- [ ] 9.1 Review current progress display implementation
- [ ] 9.2 Add display mode support to progress messages
- [ ] 9.3 Implement `progress_display_mode` configuration
- [ ] 9.4 Test with all display modes
- [ ] 9.5 Update documentation

### Files to Modify
- `autoload/genero_tools/progress.vim`
- `autoload/genero_tools/config.vim`

### Configuration
```vim
progress_display_mode: ''  " empty = inherit from global display_mode
```

### Notes
- Phase 5 was skipped because progress module is rarely used
- This enhancement is optional and low user-facing benefit
- Only implement if user feedback indicates need

---

## Phase 10: Custom Display Modes (Low Priority)

**Status**: Planned
**Effort**: 2-3 days
**Rationale**: Allow users to define custom display handlers
**Location**: `enhancements/PHASE_9_CUSTOM_DISPLAY_MODES.md`

### Tasks
- [ ] 10.1 Design custom display mode API
- [ ] 10.2 Implement display mode registration system
- [ ] 10.3 Add documentation and examples
- [ ] 10.4 Test with custom handlers
- [ ] 10.5 Update configuration system

### Files to Modify
- `autoload/genero_tools/display.vim`
- `autoload/genero_tools/config.vim`

### Example Use Case
```vim
" User-defined custom display mode
function! MyCustomDisplay(content, options)
  " Custom display logic
endfunction

call genero_tools#display#register_mode('custom', function('MyCustomDisplay'))

let g:genero_tools_config = {
  \ 'display_mode': 'custom',
  \ }
```

### Notes
- Low priority - current 3 modes cover all use cases
- Only implement if users request custom display handlers
- Requires careful API design for extensibility

---

## Phase 11: Performance Optimization (Low Priority)

**Status**: Planned
**Effort**: 1 day
**Rationale**: Optimize display mode resolution and configuration lookups
**Location**: `enhancements/PHASE_10_PERFORMANCE_OPTIMIZATION.md`

### Tasks
- [ ] 11.1 Profile display mode resolution performance
- [ ] 11.2 Implement caching for display mode per feature
- [ ] 11.3 Optimize configuration lookup
- [ ] 11.4 Benchmark improvements
- [ ] 11.5 Document performance characteristics

### Optimization Opportunities
1. **Display Mode Caching**
   - Cache resolved display mode per feature
   - Invalidate on configuration change
   - Expected improvement: Negligible (already O(1))

2. **Configuration Lookup Optimization**
   - Batch lookups for related configs
   - Cache frequently accessed values
   - Expected improvement: Minimal (already fast)

3. **File Watching Optimization**
   - Reduce timer interval for small files
   - Increase interval for large files
   - Expected improvement: Better responsiveness

### Notes
- Current performance is already excellent
- Only implement if profiling shows bottlenecks
- Measure before and after optimization

---

## Phase 12: Enhanced Error Reporting (Medium Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Improve error messages and debugging information
**Location**: `enhancements/PHASE_11_ENHANCED_ERROR_REPORTING.md`

### Tasks
- [ ] 12.1 Add error codes to error messages
- [ ] 12.2 Implement error context tracking
- [ ] 12.3 Add debug logging for errors
- [ ] 12.4 Create error reference documentation
- [ ] 12.5 Test error reporting

### Files to Modify
- `autoload/genero_tools/error.vim`
- `autoload/genero_tools/display.vim`

### Error Code Format
```
[GENERO-XXXX] Error message
  Context: Additional information
  Suggestion: How to fix
```

### Notes
- Would help users troubleshoot issues
- Requires error code registry
- Consider integration with help system

---

## Phase 13: Configuration Validation UI (Low Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Help users validate and debug their configuration
**Location**: `enhancements/PHASE_12_CONFIGURATION_VALIDATION.md`

### Tasks
- [ ] 13.1 Create configuration validator
- [ ] 13.2 Implement validation command
- [ ] 13.3 Add configuration suggestions
- [ ] 13.4 Create validation report
- [ ] 13.5 Document validation process

### Example Command
```vim
:GeneroToolsValidateConfig
```

### Output
```
Configuration Validation Report
================================

✓ display_mode: 'floating' (valid)
✓ compiler_display_mode: '' (inherits from global)
⚠ floating_window_width: 200 (exceeds screen width)
✗ unknown_option: 'value' (not recognized)

Suggestions:
- floating_window_width should be <= 180
- Remove unknown_option or check spelling
```

### Notes
- Would help users debug configuration issues
- Could prevent misconfiguration errors
- Nice to have, not critical

---

## Phase 14: Display Mode Presets (Low Priority)

**Status**: Planned
**Effort**: 1 day
**Rationale**: Provide pre-configured display mode profiles
**Location**: `enhancements/PHASE_13_DISPLAY_MODE_PRESETS.md`

### Tasks
- [ ] 14.1 Define preset profiles
- [ ] 14.2 Implement preset loading
- [ ] 14.3 Add preset selection command
- [ ] 14.4 Document presets
- [ ] 14.5 Test preset switching

### Example Presets
```vim
" Minimal - quickfix only
let g:genero_tools_presets.minimal = {
  \ 'display_mode': 'quickfix',
  \ }

" Floating-heavy - floating windows for everything
let g:genero_tools_presets.floating = {
  \ 'display_mode': 'floating',
  \ 'compiler_display_mode': 'floating',
  \ 'hints_display_mode': 'floating',
  \ }

" Echo-friendly - command line for quick feedback
let g:genero_tools_presets.echo = {
  \ 'display_mode': 'echo',
  \ 'compiler_display_mode': 'echo',
  \ }
```

### Notes
- Would help new users get started quickly
- Could include community-contributed presets
- Low priority - users can configure manually

---

## Maintenance Tasks

### Regular Tasks
- [ ] Monitor user feedback for issues
- [ ] Update documentation as needed
- [ ] Test with new Vim/Neovim versions
- [ ] Review and update dependencies
- [ ] Performance profiling

### Quarterly Tasks
- [ ] Review and prioritize enhancement requests
- [ ] Update compatibility matrix
- [ ] Audit code for technical debt
- [ ] Plan next phase of development

### Annual Tasks
- [ ] Major version planning
- [ ] Architecture review
- [ ] User survey and feedback
- [ ] Roadmap update

---

## How to Implement Future Tasks

### For New Agents
1. **Choose a Task**
   - Select from roadmap above
   - Check priority and effort
   - Review related documentation

2. **Understand Context**
   - Read [.kiro/AGENT_CONTEXT.md](.kiro/AGENT_CONTEXT.md)
   - Review [.kiro/specs/display-enhancements/](.kiro/specs/display-enhancements/)
   - Check [FUTURE_BUGS.md](FUTURE_BUGS.md) for known issues

3. **Create Implementation Plan**
   - Break down into subtasks
   - Estimate effort
   - Identify files to modify

4. **Implement**
   - Follow existing patterns
   - Maintain backward compatibility
   - Add tests and documentation

5. **Verify**
   - Run syntax validation
   - Test all display modes
   - Test Vim and Neovim
   - Update documentation

6. **Commit and Push**
   - Clear commit message
   - Reference task ID
   - Update this file

---

## Task Template

When implementing a new task, use this template:

```markdown
## Phase X: [Task Name]

**Status**: In Progress
**Effort**: X days
**Rationale**: Why this task is important

### Tasks
- [ ] X.1 Subtask 1
- [ ] X.2 Subtask 2
- [ ] X.3 Subtask 3

### Files to Modify
- `file1.vim`
- `file2.vim`

### Configuration
```vim
new_option: 'value'
```

### Notes
- Important considerations
- Potential challenges
- Related tasks

### Testing Checklist
- [ ] Syntax validation
- [ ] Backward compatibility
- [ ] All display modes
- [ ] Vim and Neovim
- [ ] Documentation updated
```

---

## Resources for Implementation

### Documentation
- [.kiro/AGENT_CONTEXT.md](.kiro/AGENT_CONTEXT.md) - Project overview
- [.kiro/specs/display-enhancements/README.md](.kiro/specs/display-enhancements/README.md) - Quick start
- [.kiro/specs/display-enhancements/design.md](.kiro/specs/display-enhancements/design.md) - Architecture
- [.kiro/specs/display-enhancements/tasks.md](.kiro/specs/display-enhancements/tasks.md) - Completed tasks

### Code Examples
- Phase 1: Core infrastructure patterns
- Phase 2: Compiler integration patterns
- Phase 4: Signature display patterns
- Phase 6: Debug streaming patterns
- Phase 7: Error display patterns

### Testing
- Use `getDiagnostics` for syntax validation
- Test with both Vim and Neovim
- Verify backward compatibility
- Check all display modes

---

## Success Criteria for Future Tasks

All future tasks should meet these criteria:
- ✓ 0 syntax errors
- ✓ 100% backward compatible
- ✓ All display modes tested
- ✓ Both Vim and Neovim tested
- ✓ Documentation updated
- ✓ Configuration options validated
- ✓ Error handling verified

---

## Contact & Support

For questions about future tasks:
1. Review this file for task details
2. Check [.kiro/AGENT_CONTEXT.md](.kiro/AGENT_CONTEXT.md) for project context
3. Review [.kiro/specs/display-enhancements/](.kiro/specs/display-enhancements/) for detailed documentation
4. Check [FUTURE_BUGS.md](FUTURE_BUGS.md) for known issues

