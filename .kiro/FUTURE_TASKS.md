# Future Tasks & Enhancements

**Last Updated**: March 21, 2026
**Project Status**: Display Enhancements 100% Complete
**Next Phase**: Future Enhancements (Optional)

---

## Enhancement Roadmap

### Priority Levels
- **Critical**: Required for core functionality
- **High**: Significant user-facing improvements
- **Medium**: Nice to have, improves UX
- **Low**: Polish, optimization, future-proofing

---

## Bug Fix: Snippet Expansion & Autocomplete Integration (High Priority)

**Status**: Open
**Issue ID**: #001
**Effort**: 2-3 days
**Rationale**: Snippets are core feature; broken expansion and selection significantly impact UX

### Tasks
- [ ] BF-1.1 Review snippet list floating window implementation
- [ ] BF-1.2 Add selection/confirmation mechanism to snippet list
- [ ] BF-1.3 Implement keyboard selection (Enter to select)
- [ ] BF-1.4 Implement mouse selection (click to select)
- [ ] BF-1.5 Review snippet insertion mechanism in `snippets.vim`
- [ ] BF-1.6 Check luasnip integration in `lua_bridge.vim`
- [ ] BF-1.7 Verify autocomplete menu configuration in `complete.vim`
- [ ] BF-1.8 Test snippet expansion with luasnip directly
- [ ] BF-1.9 Check if snippet sources registered with autocomplete
- [ ] BF-1.10 Fix snippet insertion to use luasnip expansion
- [ ] BF-1.11 Add snippets to autocomplete menu sources
- [ ] BF-1.12 Implement placeholder navigation
- [ ] BF-1.13 Test with all display modes
- [ ] BF-1.14 Test Vim and Neovim compatibility
- [ ] BF-1.15 Update documentation

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

## Phase 8: Progress Display Module (Medium Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Currently uses direct echo; could benefit from display mode support

### Tasks
- [ ] 8.1 Review current progress display implementation
- [ ] 8.2 Add display mode support to progress messages
- [ ] 8.3 Implement `progress_display_mode` configuration
- [ ] 8.4 Test with all display modes
- [ ] 8.5 Update documentation

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

## Phase 9: Custom Display Modes (Low Priority)

**Status**: Planned
**Effort**: 2-3 days
**Rationale**: Allow users to define custom display handlers

### Tasks
- [ ] 9.1 Design custom display mode API
- [ ] 9.2 Implement display mode registration system
- [ ] 9.3 Add documentation and examples
- [ ] 9.4 Test with custom handlers
- [ ] 9.5 Update configuration system

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
- Low priority - current 5 modes cover all use cases
- Only implement if users request custom display handlers
- Requires careful API design for extensibility

---

## Phase 10: Performance Optimization (Low Priority)

**Status**: Planned
**Effort**: 1 day
**Rationale**: Optimize display mode resolution and configuration lookups

### Tasks
- [ ] 10.1 Profile display mode resolution performance
- [ ] 10.2 Implement caching for display mode per feature
- [ ] 10.3 Optimize configuration lookup
- [ ] 10.4 Benchmark improvements
- [ ] 10.5 Document performance characteristics

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

## Phase 11: Enhanced Error Reporting (Medium Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Improve error messages and debugging information

### Tasks
- [ ] 11.1 Add error codes to error messages
- [ ] 11.2 Implement error context tracking
- [ ] 11.3 Add debug logging for errors
- [ ] 11.4 Create error reference documentation
- [ ] 11.5 Test error reporting

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

## Phase 12: Configuration Validation UI (Low Priority)

**Status**: Planned
**Effort**: 1-2 days
**Rationale**: Help users validate and debug their configuration

### Tasks
- [ ] 12.1 Create configuration validator
- [ ] 12.2 Implement validation command
- [ ] 12.3 Add configuration suggestions
- [ ] 12.4 Create validation report
- [ ] 12.5 Document validation process

### Example Command
```vim
:GeneroToolsValidateConfig
```

### Output
```
Configuration Validation Report
================================

✓ display_mode: 'popup' (valid)
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

## Phase 13: Display Mode Presets (Low Priority)

**Status**: Planned
**Effort**: 1 day
**Rationale**: Provide pre-configured display mode profiles

### Tasks
- [ ] 13.1 Define preset profiles
- [ ] 13.2 Implement preset loading
- [ ] 13.3 Add preset selection command
- [ ] 13.4 Document presets
- [ ] 13.5 Test preset switching

### Example Presets
```vim
" Minimal - quickfix only
let g:genero_tools_presets.minimal = {
  \ 'display_mode': 'quickfix',
  \ }

" Popup-heavy - floating windows for everything
let g:genero_tools_presets.popup = {
  \ 'display_mode': 'popup',
  \ 'compiler_display_mode': 'popup',
  \ 'hints_display_mode': 'popup',
  \ }

" Split-friendly - split windows for detailed content
let g:genero_tools_presets.split = {
  \ 'display_mode': 'split',
  \ 'compiler_display_mode': 'split',
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

