-- Test suite for help system
-- Tests the help module functionality

local M = {}

-- Test 1: Module loads successfully
function M.test_module_loads()
  local ok, help = pcall(require, 'genero_tools.help')
  assert(ok, 'Help module should load without errors')
  assert(type(help) == 'table', 'Help module should return a table')
  print('✓ Test 1 passed: Module loads successfully')
  return true
end

-- Test 2: Module has required functions
function M.test_module_functions()
  local help = require('genero_tools.help')
  
  assert(type(help.show) == 'function', 'show() function should exist')
  assert(type(help.toggle) == 'function', 'toggle() function should exist')
  assert(type(help.close) == 'function', 'close() function should exist')
  
  print('✓ Test 2 passed: Module has required functions')
  return true
end

-- Test 3: Commands are registered
function M.test_commands_registered()
  -- Check if commands exist
  local commands = vim.api.nvim_get_commands({})
  
  assert(commands['GeneroHelp'] ~= nil, 'GeneroHelp command should be registered')
  assert(commands['GeneroHelpToggle'] ~= nil, 'GeneroHelpToggle command should be registered')
  assert(commands['GeneroHelpClose'] ~= nil, 'GeneroHelpClose command should be registered')
  
  print('✓ Test 3 passed: Commands are registered')
  return true
end

-- Test 4: Help window can be opened
function M.test_help_window_opens()
  local help = require('genero_tools.help')
  
  -- Open help window
  help.show()
  
  -- Check if window was created
  local wins = vim.api.nvim_list_wins()
  local help_win_found = false
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_win_found = true
      break
    end
  end
  
  assert(help_win_found, 'Help window should be created')
  
  -- Close help window
  help.close()
  
  print('✓ Test 4 passed: Help window can be opened')
  return true
end

-- Test 5: Help window can be closed
function M.test_help_window_closes()
  local help = require('genero_tools.help')
  
  -- Open help window
  help.show()
  
  -- Close help window
  help.close()
  
  -- Check if window was closed
  local wins = vim.api.nvim_list_wins()
  local help_win_found = false
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_win_found = true
      break
    end
  end
  
  assert(not help_win_found, 'Help window should be closed')
  
  print('✓ Test 5 passed: Help window can be closed')
  return true
end

-- Test 6: Help window can be toggled
function M.test_help_window_toggles()
  local help = require('genero_tools.help')
  
  -- Toggle on
  help.toggle()
  
  -- Check if window exists
  local wins = vim.api.nvim_list_wins()
  local help_win_found = false
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_win_found = true
      break
    end
  end
  
  assert(help_win_found, 'Help window should be open after first toggle')
  
  -- Toggle off
  help.toggle()
  
  -- Check if window is closed
  wins = vim.api.nvim_list_wins()
  help_win_found = false
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_win_found = true
      break
    end
  end
  
  assert(not help_win_found, 'Help window should be closed after second toggle')
  
  print('✓ Test 6 passed: Help window can be toggled')
  return true
end

-- Test 7: Help content is not empty
function M.test_help_content_not_empty()
  local help = require('genero_tools.help')
  
  -- Open help window
  help.show()
  
  -- Get help buffer
  local wins = vim.api.nvim_list_wins()
  local help_buf = nil
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_buf = buf
      break
    end
  end
  
  assert(help_buf ~= nil, 'Help buffer should exist')
  
  -- Check buffer content
  local lines = vim.api.nvim_buf_get_lines(help_buf, 0, -1, false)
  assert(#lines > 0, 'Help content should not be empty')
  assert(#lines > 50, 'Help content should be substantial (>50 lines)')
  
  -- Close help window
  help.close()
  
  print('✓ Test 7 passed: Help content is not empty')
  return true
end

-- Test 8: Help content has expected categories
function M.test_help_content_categories()
  local help = require('genero_tools.help')
  
  -- Open help window
  help.show()
  
  -- Get help buffer
  local wins = vim.api.nvim_list_wins()
  local help_buf = nil
  
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == 'genero-help' then
      help_buf = buf
      break
    end
  end
  
  assert(help_buf ~= nil, 'Help buffer should exist')
  
  -- Check for expected categories
  local content = table.concat(vim.api.nvim_buf_get_lines(help_buf, 0, -1, false), '\n')
  
  local expected_categories = {
    'COMPILATION',
    'NAVIGATION',
    'GENERO TOOLS',
    'CODE HINTS',
    'SVN DIFF MARKERS',
    'SNIPPETS',
    'AUTOCOMPLETE',
    'TERMINAL',
    'SEARCH',
    'TIPS & TRICKS'
  }
  
  for _, category in ipairs(expected_categories) do
    assert(content:find(category), 'Help should contain category: ' .. category)
  end
  
  -- Close help window
  help.close()
  
  print('✓ Test 8 passed: Help content has expected categories')
  return true
end

-- Run all tests
function M.run_all_tests()
  print('\n=== Running Help System Tests ===\n')
  
  local tests = {
    M.test_module_loads,
    M.test_module_functions,
    M.test_commands_registered,
    M.test_help_window_opens,
    M.test_help_window_closes,
    M.test_help_window_toggles,
    M.test_help_content_not_empty,
    M.test_help_content_categories,
  }
  
  local passed = 0
  local failed = 0
  
  for i, test in ipairs(tests) do
    local ok, err = pcall(test)
    if ok then
      passed = passed + 1
    else
      failed = failed + 1
      print('✗ Test ' .. i .. ' failed: ' .. tostring(err))
    end
  end
  
  print('\n=== Test Results ===')
  print('Passed: ' .. passed)
  print('Failed: ' .. failed)
  print('Total:  ' .. (passed + failed))
  
  if failed == 0 then
    print('\n✓ All tests passed!')
  else
    print('\n✗ Some tests failed')
  end
  
  return failed == 0
end

return M
