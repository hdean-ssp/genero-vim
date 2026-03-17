-- Test Task 6: Implement snippet commands and discovery
-- Tests for snippet list, help, and expansion commands

local M = {}

-- Test 6.1: Snippet list command
function M.test_snippet_list_command()
  local snippets = require('genero_tools.snippets')
  
  -- Verify list_snippets_display function exists
  assert(type(snippets.list_snippets_display) == 'function', 'list_snippets_display not a function')
  
  -- Verify it can be called without errors
  local ok = pcall(function()
    -- Mock vim.notify to avoid UI calls
    local original_notify = vim.notify
    vim.notify = function() end
    
    snippets.list_snippets_display()
    
    vim.notify = original_notify
  end)
  
  assert(ok, 'list_snippets_display failed')
  print('✓ Test 6.1: Snippet list command works')
end

-- Test 6.3: Snippet help display
function M.test_snippet_help_display()
  local snippets = require('genero_tools.snippets')
  
  -- Verify show_help function exists
  assert(type(snippets.show_help) == 'function', 'show_help not a function')
  
  -- Verify it can be called with a trigger
  local ok = pcall(function()
    -- Mock vim.notify to avoid UI calls
    local original_notify = vim.notify
    vim.notify = function() end
    
    snippets.show_help('fn')
    
    vim.notify = original_notify
  end)
  
  assert(ok, 'show_help failed')
  print('✓ Test 6.3: Snippet help display works')
end

-- Test 6.5: Snippet command trigger
function M.test_snippet_expand_command()
  local snippets = require('genero_tools.snippets')
  
  -- Verify expand_by_name function exists
  assert(type(snippets.expand_by_name) == 'function', 'expand_by_name not a function')
  
  -- Verify it can be called with a trigger
  local ok = pcall(function()
    -- Mock vim.notify to avoid UI calls
    local original_notify = vim.notify
    vim.notify = function() end
    
    snippets.expand_by_name('fn')
    
    vim.notify = original_notify
  end)
  
  assert(ok, 'expand_by_name failed')
  print('✓ Test 6.5: Snippet expand command works')
end

-- Test 6.6: Error handling for non-existent snippet
function M.test_error_handling()
  local snippets = require('genero_tools.snippets')
  
  -- Verify error handling for non-existent snippet
  local ok = pcall(function()
    -- Mock vim.notify to avoid UI calls
    local original_notify = vim.notify
    vim.notify = function() end
    
    snippets.expand_by_name('nonexistent_trigger_xyz')
    
    vim.notify = original_notify
  end)
  
  -- Should handle gracefully (not crash)
  assert(ok, 'Error handling failed')
  print('✓ Test 6.6: Error handling works')
end

-- Test snippet availability check
function M.test_snippet_availability()
  local snippets = require('genero_tools.snippets')
  
  -- Verify health_check function exists
  assert(type(snippets.health_check) == 'function', 'health_check not a function')
  
  local health = snippets.health_check()
  assert(health.luasnip_available ~= nil, 'luasnip_available not in health check')
  assert(health.snippet_count ~= nil, 'snippet_count not in health check')
  
  print('✓ Snippet availability check works')
  print('  - LuaSnip available: ' .. tostring(health.luasnip_available))
  print('  - Snippet count: ' .. health.snippet_count)
end

-- Test snippet list retrieval
function M.test_snippet_list_retrieval()
  local snippets = require('genero_tools.snippets')
  
  -- Verify list_snippets function exists
  assert(type(snippets.list_snippets) == 'function', 'list_snippets not a function')
  
  local all_snippets = snippets.list_snippets()
  assert(type(all_snippets) == 'table', 'list_snippets should return a table')
  
  -- Verify we have some snippets
  local count = 0
  for _, _ in pairs(all_snippets) do
    count = count + 1
  end
  
  assert(count > 0, 'No snippets found')
  print('✓ Snippet list retrieval works')
  print('  - Total snippets: ' .. count)
end

-- Test snippet retrieval by trigger
function M.test_snippet_retrieval()
  local snippets = require('genero_tools.snippets')
  
  -- Verify get_snippet function exists
  assert(type(snippets.get_snippet) == 'function', 'get_snippet not a function')
  
  -- Get a known snippet
  local fn_snippet = snippets.get_snippet('fn')
  assert(fn_snippet ~= nil, 'fn snippet not found')
  assert(fn_snippet.trigger == 'fn', 'fn snippet has wrong trigger')
  assert(fn_snippet.body ~= nil, 'fn snippet has no body')
  
  print('✓ Snippet retrieval by trigger works')
  print('  - Retrieved snippet: ' .. fn_snippet.name)
end

-- Test command integration
function M.test_command_integration()
  local snippets = require('genero_tools.snippets')
  
  -- Verify all command functions exist
  assert(type(snippets.list_snippets_display) == 'function', 'list_snippets_display missing')
  assert(type(snippets.show_help) == 'function', 'show_help missing')
  assert(type(snippets.expand_by_name) == 'function', 'expand_by_name missing')
  
  print('✓ Command integration verified')
  print('  - All command functions present')
end

-- Run all tests
function M.run_all()
  print('Running Task 6 snippet command tests...')
  print('')
  
  M.test_snippet_availability()
  print('')
  
  M.test_snippet_list_retrieval()
  print('')
  
  M.test_snippet_retrieval()
  print('')
  
  M.test_command_integration()
  print('')
  
  M.test_snippet_list_command()
  M.test_snippet_help_display()
  M.test_snippet_expand_command()
  M.test_error_handling()
  
  print('')
  print('✓ All Task 6 tests passed!')
end

return M
