# Implementation Tasks: Error Navigation Keybindings

## Phase 1: Fix Keybinding Registration

- [-] 1.1 Add error navigation keybindings to `autoload/genero_tools/keybindings.vim`
  - [x] 1.1.1 Add `nnoremap <C-,> :GeneroPrevError<CR>` mapping
  - [x] 1.1.2 Add `nnoremap <C-.> :GeneroNextError<CR>` mapping
  - [x] 1.1.3 Ensure mappings are registered in `genero_tools#keybindings#register()` function

- [-] 1.2 Verify keybindings are called during plugin initialization
  - [x] 1.2.1 Check `plugin/genero_tools.vim` calls keybinding registration
  - [x] 1.2.2 Ensure registration respects `keybindings_enabled` config option

- [-] 1.3 Test keybindings in Vim 8+
  - [x] 1.3.1 Verify `Ctrl+.` triggers next error navigation
  - [x] 1.3.2 Verify `Ctrl+,` triggers previous error navigation
  - [x] 1.3.3 Test with empty quickfix list
  - [x] 1.3.4 Test at boundaries (first/last error)

- [-] 1.4 Test keybindings in Neovim
  - [x] 1.4.1 Verify `Ctrl+.` triggers next error navigation
  - [x] 1.4.2 Verify `Ctrl+,` triggers previous error navigation
  - [x] 1.4.3 Test with empty quickfix list
  - [ ] 1.4.4 Test at boundaries (first/last error)

## Phase 2: Configure Autocomplete Keybinding

- [ ] 2.1 Add `Ctrl+N` as autocomplete keybinding
  - [ ] 2.1.1 Add `inoremap <C-n> <C-x><C-o>` mapping to `autoload/genero_tools/keybindings.vim`
  - [ ] 2.1.2 Ensure mapping is registered in `genero_tools#keybindings#register()` function
  - [ ] 2.1.3 Test `Ctrl+N` triggers autocomplete in insert mode

- [ ] 2.2 Update documentation with new autocomplete keybinding
  - [ ] 2.2.1 Update `.vimrc.example` with `Ctrl+N` autocomplete keybinding
  - [ ] 2.2.2 Add comment explaining `Ctrl+N` replaces `Ctrl+Space` for terminal compatibility
  - [ ] 2.2.3 Document that `Ctrl+N` is the standard Vim omnifunc keybinding

## Phase 3: Verify Backward Compatibility

- [ ] 3.1 Test that user-defined keybindings are not overridden
  - [ ] 3.1.1 Create test vimrc with custom `Ctrl+.` mapping
  - [ ] 3.1.2 Verify plugin respects user's mapping

- [ ] 3.2 Test that `keybindings_enabled = 0` prevents registration
  - [ ] 3.2.1 Set `keybindings_enabled` to 0 in config
  - [ ] 3.2.2 Verify keybindings are not registered

- [ ] 3.3 Test upgrade path
  - [ ] 3.3.1 Verify existing configurations still work after update

## Phase 4: Documentation Updates

- [ ] 4.1 Update `.vimrc.example` with error navigation keybindings
  - [ ] 4.1.1 Add `Ctrl+.` and `Ctrl+,` keybindings to example
  - [ ] 4.1.2 Add comments explaining what they do

- [ ] 4.2 Update help documentation
  - [ ] 4.2.1 Add keybindings to `:GeneroHelp` command output
  - [ ] 4.2.2 Include alternative keybinding options

- [ ] 4.3 Update README if needed
  - [ ] 4.3.1 Add error navigation keybindings to feature list
  - [ ] 4.3.2 Document terminal compatibility considerations

## Phase 5: Final Verification

- [ ] 5.1 Run full test suite
  - [ ] 5.1.1 Verify all keybinding tests pass
  - [ ] 5.1.2 Verify no regressions in other features

- [ ] 5.2 Manual testing in different environments
  - [ ] 5.2.1 Test in Vim 8+
  - [ ] 5.2.2 Test in Neovim 0.5+
  - [ ] 5.2.3 Test in different terminal emulators if possible

- [ ] 5.3 Verify error messages are clear
  - [ ] 5.3.1 Test empty quickfix list message
  - [ ] 5.3.2 Test boundary condition messages
