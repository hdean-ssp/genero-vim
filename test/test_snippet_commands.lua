-- Test snippet commands and discovery
-- Tests for :GeneroSnippetList, :GeneroSnippetHelp, and :GeneroSnippet commands

local Snippets = require('genero_tools.snippets')
local Manager = require('genero_tools.snippets.manager')

-- Test 1: List snippets display
print('Test 1: List snippets display')
local snippets = Manager.load_builtin()
print('Loaded ' .. vim.tbl_count(snippets) .. ' built-in snippets')

-- Verify snippets have required fields
for trigger, snippet in pairs(snippets) do
  assert(snippet.trigger, 'Snippet missing trigger: ' .. trigger)
  assert(snippet.name, 'Snippet missing name: ' .. trigger)
  assert(snippet.body, 'Snippet missing body: ' .. trigger)
  print('  ✓ ' .. trigger .. ': ' .. snippet.name)
end

-- Test 2: Show help for a snippet
print('\nTest 2: Show help for a snippet')
local fn_snippet = snippets['fn']
assert(fn_snippet, 'Function snippet not found')
print('  ✓ Found function snippet: ' .. fn_snippet.name)
print('  ✓ Description: ' .. (fn_snippet.description or 'N/A'))

-- Test 3: Verify snippet body format
print('\nTest 3: Verify snippet body format')
for trigger, snippet in pairs(snippets) do
  assert(type(snippet.body) == 'string', 'Snippet body must be string: ' .. trigger)
  assert(#snippet.body > 0, 'Snippet body cannot be empty: ' .. trigger)
  print('  ✓ ' .. trigger .. ' has valid body')
end

-- Test 4: Verify snippet triggers are unique
print('\nTest 4: Verify snippet triggers are unique')
local seen_triggers = {}
for trigger, _ in pairs(snippets) do
  assert(not seen_triggers[trigger], 'Duplicate trigger: ' .. trigger)
  seen_triggers[trigger] = true
end
print('  ✓ All ' .. vim.tbl_count(snippets) .. ' triggers are unique')

-- Test 5: Verify custom snippets can be loaded
print('\nTest 5: Verify custom snippets can be loaded')
local custom = Manager.load_custom()
print('  ✓ Loaded ' .. vim.tbl_count(custom) .. ' custom snippets')

-- Test 6: Verify snippet merging
print('\nTest 6: Verify snippet merging')
local merged = Snippets.merge_snippets(snippets, custom)
local expected_count = vim.tbl_count(snippets) + vim.tbl_count(custom)
assert(vim.tbl_count(merged) >= vim.tbl_count(snippets), 'Merged snippets should include all built-in')
print('  ✓ Merged ' .. vim.tbl_count(merged) .. ' snippets (built-in + custom)')

-- Test 7: Verify snippet retrieval
print('\nTest 7: Verify snippet retrieval')
local retrieved = Snippets.get_snippet('fn')
assert(retrieved, 'Should retrieve function snippet')
assert(retrieved.trigger == 'fn', 'Retrieved snippet should have correct trigger')
print('  ✓ Retrieved snippet: ' .. retrieved.name)

-- Test 8: Verify list_snippets function
print('\nTest 8: Verify list_snippets function')
local all_snippets = Snippets.list_snippets()
assert(all_snippets, 'list_snippets should return table')
assert(vim.tbl_count(all_snippets) > 0, 'Should have at least one snippet')
print('  ✓ list_snippets returned ' .. vim.tbl_count(all_snippets) .. ' snippets')

-- Test 9: Verify health check
print('\nTest 9: Verify health check')
local health = Snippets.health_check()
assert(health.version, 'Health check should have version')
assert(health.snippet_count, 'Health check should have snippet count')
print('  ✓ Health check: version=' .. health.version .. ', snippets=' .. health.snippet_count)

print('\n✅ All tests passed!')
