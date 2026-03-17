# Implementation Plan: Genero Code Snippets

## Overview

This implementation plan breaks down the Genero Code Snippets feature into discrete, actionable coding tasks. Rather than building a custom snippet engine, we leverage **LuaSnip** as a dependency and focus on creating Genero-specific snippets and smart integration with function signatures. Tasks are organized from core infrastructure through integration and testing.

## Tasks

- [x] 1. Set up Lua module structure and initialization
  - Create `lua/genero_tools/snippets/` directory structure
  - Create `lua/genero_tools/snippets/init.lua` with module initialization
  - Create `lua/genero_tools/snippets/manager.lua` for snippet loading and registration
  - Create `lua/genero_tools/snippets/async_params.lua` for async parameter population
  - Set up module exports and dependencies
  - Verify LuaSnip is available as dependency
  - _Requirements: 3.1, 3.2_

- [-] 2. Implement built-in snippet library
  - [x] 2.1 Create snippet template files for all Genero patterns
    - Create `lua/genero_tools/snippets/templates/builtin/function.lua` with function definition snippets
    - Create `lua/genero_tools/snippets/templates/builtin/if_else.lua` with conditional snippets
    - Create `lua/genero_tools/snippets/templates/builtin/for_loop.lua` with for loop snippets
    - Create `lua/genero_tools/snippets/templates/builtin/while_loop.lua` with while loop snippets
    - Create `lua/genero_tools/snippets/templates/builtin/case_statement.lua` with case/when snippets
    - Create `lua/genero_tools/snippets/templates/builtin/try_catch.lua` with error handling snippets
    - Create `lua/genero_tools/snippets/templates/builtin/record.lua` with record definition snippets
    - Create `lua/genero_tools/snippets/templates/builtin/array.lua` with array declaration snippets
    - Format snippets for LuaSnip (using LuaSnip snippet format)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8_

  - [ ]* 2.2 Write property test for snippet library completeness
    - **Property 1: All required patterns have snippets**
    - **Validates: Requirements 1.1-1.8**

- [-] 3. Implement snippet library manager
  - [x] 3.1 Implement built-in snippet loading
    - Implement `Manager.load_builtin()` to load all built-in snippets
    - Load snippets from `lua/genero_tools/snippets/templates/builtin/`
    - Convert to LuaSnip format
    - Return snippet table
    - _Requirements: 5.1_

  - [x] 3.2 Implement custom snippet loading
    - Implement `Manager.load_custom()` to load user-defined snippets
    - Load from user config directory (`~/.config/nvim/genero-snippets/`)
    - Handle missing directory gracefully
    - Convert to LuaSnip format
    - _Requirements: 5.1, 5.2_

  - [x] 3.3 Implement LuaSnip registration
    - Implement `Manager.register_with_luasnip(snippets)` to register snippets
    - Add snippets to LuaSnip registry
    - Make available for expansion
    - _Requirements: 3.1, 3.2_

  - [ ]* 3.4 Write property test for snippet merging
    - **Property 16: Custom snippets merged with built-in snippets**
    - **Validates: Requirements 5.3**

  - [ ]* 3.5 Write property test for custom precedence
    - **Property 17: Custom snippets take precedence over built-in**
    - **Validates: Requirements 5.4**

  - [x] 3.6 Implement snippet lookup by trigger
    - Implement `Manager.get_snippet(trigger)` to retrieve snippet by trigger
    - Return snippet definition or nil
    - _Requirements: 4.1_

  - [x] 3.7 Implement snippet listing
    - Implement `Manager.list_snippets()` to return all available snippets
    - Include trigger, name, and description
    - _Requirements: 6.1_

- [-] 4. Implement async parameter population
  - [x] 4.1 Implement async function signature querying
    - Implement `AsyncParams.query_signature(function_name, callback)` using genero_tools.async
    - Query genero-tools API for function signatures
    - Handle async execution without blocking editor
    - _Requirements: 2.1, 3.3_

  - [ ]* 4.2 Write property test for async queries
    - **Property 8: Async queries don't block editor**
    - **Validates: Requirements 3.3**

  - [x] 4.3 Implement parameter population from signatures
    - Implement `AsyncParams.populate_from_signature(snippet, signature)` to extract parameters
    - Update LuaSnip placeholder defaults with parameter names and types
    - Handle optional parameters with special marking
    - _Requirements: 2.2, 2.5_

  - [ ]* 4.4 Write property test for parameter population
    - **Property 3: Function signature query populates parameters**
    - **Validates: Requirements 2.1, 2.2**

  - [x] 4.5 Implement return type handling
    - Add return value placeholder for functions with return types
    - Include return type in placeholder
    - _Requirements: 2.3_

  - [ ]* 4.6 Write property test for return type handling
    - **Property 4: Return type placeholder included for functions with return types**
    - **Validates: Requirements 2.3**

  - [x] 4.7 Implement fallback to generic parameters
    - Implement `AsyncParams.fallback_parameters(snippet)` for signature not found
    - Use generic parameter placeholders
    - _Requirements: 2.4_

  - [ ]* 4.8 Write property test for fallback behavior
    - **Property 5: Fallback to generic parameters when signature not found**
    - **Validates: Requirements 2.4**

- [x] 6. Implement snippet commands and discovery
  - [x] 6.1 Implement snippet list command
    - Create `:GeneroSnippetList` command to list all snippets
    - Display trigger, name, and description
    - Make searchable and filterable
    - _Requirements: 6.1_

  - [ ]* 6.2 Write property test for list command
    - **Property 18: List command shows all available snippets**
    - **Validates: Requirements 6.1**

  - [x] 6.3 Implement snippet help display
    - Create `:GeneroSnippetHelp` command to display snippet documentation
    - Show trigger keys and placeholder descriptions
    - Display in floating window or quickfix
    - _Requirements: 6.2, 6.4_

  - [ ]* 6.4 Write property test for help display
    - **Property 19: Help command displays snippet documentation**
    - **Validates: Requirements 6.2**

  - [x] 6.5 Implement snippet command trigger
    - Create `:GeneroSnippet` command to expand snippets by name
    - Support `:GeneroSnippet function` syntax
    - Programmatically trigger LuaSnip expansion
    - _Requirements: 4.1_

  - [x] 6.6 Implement error messages and guidance
    - Display clear error messages for expansion failures
    - Suggest corrective actions
    - Link to documentation
    - _Requirements: 8.4_

- [x] 7. Ensure Vim compatibility (disable Neovim-only features)
  - [x] 7.1 Implement Vim feature detection
    - Detect if running in Vim or Neovim
    - Disable snippet commands in Vim
    - _Requirements: 7.2_

  - [x] 7.2 Disable snippet commands in Vim
    - Prevent `:GeneroSnippetList` command registration in Vim
    - Prevent `:GeneroSnippetHelp` command registration in Vim
    - Prevent `:GeneroSnippet` command registration in Vim
    - Provide informative message that snippets are Neovim-only
    - _Requirements: 7.3_

  - [x] 7.3 Verify no errors in Vim
    - Ensure plugin loads without errors in Vim
    - Verify existing genero-tools features work in Vim
    - Verify no Lua calls attempted in Vim
    - _Requirements: 7.1_

  - [ ]* 7.4 Write property test for Vim compatibility
    - **Property 22: Neovim-only features disabled in Vim**
    - **Validates: Requirements 7.2, 7.3**

- [x] 8. Integrate with existing genero-tools features
  - [x] 8.1 Integrate with GeneroLookup
    - Offer snippet expansion option after GeneroLookup
    - Populate function call snippet with looked-up function
    - Use async parameter population
    - _Requirements: 9.1_

  - [x] 8.2 Integrate with autocomplete
    - Offer snippet expansion option in autocomplete menu
    - Populate function call snippet with suggested function
    - Use async parameter population
    - _Requirements: 9.2_

  - [x] 8.3 Implement snippet configuration in genero-tools config
    - Store snippet settings in `g:genero_tools_config`
    - Support enable/disable, trigger configuration, custom directory
    - _Requirements: 9.5_

  - [ ]* 8.4 Write property test for keybinding preservation
    - **Property 30: Existing keybindings not disrupted**
    - **Validates: Requirements 9.3**

  - [ ]* 8.5 Write property test for feature choice
    - **Property 31: User can choose between snippets and autocomplete**
    - **Validates: Requirements 9.4**

- [x] 9. VimScript bridge layer (already completed in Task 6)
  - [x] 9.1 Create `autoload/genero_tools/snippets.vim` bridge
    - Implement VimScript functions to call Lua snippet manager
    - Use existing `lua_bridge.vim` for Lua calls
    - Expose snippet commands and keybindings
    - _Requirements: 3.1_

  - [x] 9.2 Implement snippet commands in VimScript
    - Create `:GeneroSnippet` command wrapper
    - Create `:GeneroSnippetList` command wrapper
    - Create `:GeneroSnippetHelp` command wrapper
    - Create `:GeneroSnippetInsert` command wrapper
    - _Requirements: 4.1, 6.1, 6.2, 7.4_

  - [x] 9.3 Set up snippet keybindings in VimScript
    - Register abbreviation triggers via LuaSnip
    - Register keybinding triggers
    - Handle trigger conflicts
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 10. Checkpoint - Ensure all core functionality works
  - ✓ Verify snippet expansion works correctly with LuaSnip
  - ✓ Verify placeholder navigation works (LuaSnip default)
  - ✓ Verify function signature integration works
  - ✓ Verify custom snippets load and merge correctly
  - ✓ Verify triggers work as expected
  - ✓ All checkpoint tests passed

- [x] 11. Create comprehensive documentation
  - [x] 11.1 Create user documentation
    - Create `docs/SNIPPETS.md` with snippet reference
    - Document all available snippets with examples
    - Include configuration guide
    - Keep documentation brief and practical
    - _Requirements: 10.1, 10.2, 10.3_

  - [x] 11.2 Create developer documentation
    - Document snippet format and structure (LuaSnip format)
    - Document manager API
    - Document integration points
    - Include testing guide
    - _Requirements: 5.5_

- [ ] 12. Write comprehensive test suite
  - [ ] 12.1 Write unit tests for snippet library
    - Test all built-in snippets exist with correct structure
    - Test LuaSnip format is valid
    - Test snippet merging works correctly
    - Test custom snippets override built-in
    - _Requirements: 1.1-1.8, 5.3, 5.4_

  - [ ] 12.2 Write unit tests for parameter population
    - Test function signature queries work
    - Test parameters populated correctly
    - Test fallback to generic parameters
    - Test optional parameters marked correctly
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ] 12.3 Write unit tests for trigger mechanism
    - Test abbreviation triggers work
    - Test keybinding triggers work
    - Test command triggers work
    - Test trigger conflicts handled
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ] 12.4 Write unit tests for customization system
    - Test custom snippets load correctly
    - Test hot-reload works
    - Test snippet merging with custom snippets
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ] 12.5 Write integration tests
    - Test snippets work with genero-tools API
    - Test snippets work with existing keybindings
    - Test snippets work with autocomplete
    - Test snippets work with GeneroLookup
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 13. Final checkpoint - Ensure all tests pass
  - Run all unit tests and verify they pass
  - Run all integration tests and verify they pass
  - Verify all properties hold across test cases
  - Ask the user if questions arise.

- [ ] DEFERRED: 5. Implement customization system (User snippets - lower priority)
  - [ ] 5.1 Create custom snippet directory structure
    - Create user snippet directory if not exists
    - Set up directory monitoring for hot-reload
    - _Requirements: 5.1, 5.2_

  - [ ] 5.2 Implement file watcher for hot-reload
    - Implement `Manager.watch_files()` to monitor custom snippet files
    - Reload snippets on file changes
    - Re-register with LuaSnip
    - No plugin restart required
    - _Requirements: 5.2_

  - [ ]* 5.3 Write property test for hot-reload
    - **Property 15: Snippet file changes reloaded without restart**
    - **Validates: Requirements 5.2**

  - [ ] 5.4 Create custom snippet documentation
    - Document snippet syntax and placeholder conventions (LuaSnip format)
    - Provide example custom snippet file
    - Include best practices
    - _Requirements: 5.5_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Checkpoints ensure incremental validation
- Lua implementation is Neovim-focused; Vim compatibility is handled separately
- All async operations use existing `genero_tools.async` layer
- All UI elements use existing `genero_tools.ui` layer
- **LuaSnip is a required dependency** for Neovim users
- Vim users can use vim-snipmate or vim-vsnip with basic support

## Enhancement Tasks (Post-MVP)

These tasks improve UI/UX, fix bugs, and add integrations discovered after MVP completion.

- [ ] E1. Improve UI/UX and Configuration
  - [ ] E1.1 Modernize default configuration
    - Update default theme to modern, clean aesthetic
    - Implement floating window displays for results
    - Improve visual hierarchy and spacing
    - _Files: autoload/genero_tools/config.vim, autoload/genero_tools/display.vim_

  - [ ] E1.2 Reduce startup noise
    - Remove duplicate autocompile notifications on file load
    - Implement silent loading with optional popup notifications
    - Consolidate startup messages
    - _Files: autoload/genero_tools/compiler/autocompile.vim, plugin/genero_tools.vim_

- [ ] E2. Improve Compiler Integration
  - [ ] E2.1 Enhance error highlighting
    - Implement line/text highlighting for errors (not just signs)
    - Use proper highlight groups for visual distinction
    - Support different colors for errors vs warnings
    - _Files: autoload/genero_tools/compiler/highlight.vim_

  - [ ] E2.2 Fix sign column behavior
    - Keep sign column always visible (don't toggle on/off)
    - Show empty signs when no errors/warnings
    - Prevent column from popping in and out
    - _Files: autoload/genero_tools/compiler/signs.vim_

  - [ ] E2.3 Fix statusline navigation bug
    - Fix "no previous error" message appearing without user action
    - Ensure navigation functions only called when appropriate
    - Add proper state tracking for error navigation
    - _Files: autoload/genero_tools/compiler/quickfix.vim_

- [ ] E3. Integration with which-key
  - [ ] E3.1 Add which-key integration
    - Register custom keybindings with which-key
    - Provide descriptive labels for all commands
    - Organize keybindings by category
    - _Files: autoload/genero_tools/keybindings.vim, new: autoload/genero_tools/which_key.vim_

  - [ ] E3.2 Create which-key configuration
    - Define keybinding groups and descriptions
    - Support user customization
    - Document which-key integration
    - _Files: docs/KEYBINDINGS.md_
