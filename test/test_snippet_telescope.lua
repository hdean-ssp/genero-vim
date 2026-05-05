-- Test Telescope integration for snippets
-- Verifies that snippet picker works with Telescope

local Telescope = require('genero_tools.telescope')
local Snippets = require('genero_tools.snippets')

-- Test 1: Verify snippets() function exists
local function test_snippets_function_exists()
  if type(Telescope.snippets) == 'function' then
    print('✓ Telescope.snippets() function exists')
    return true
  else
    print('✗ Telescope.snippets() function not found')
    return false
  end
end

-- Test 2: Verify snippet data is available
local function test_snippet_data_available()
  local snippets = Snippets.get_all_snippets()
  if snippets and #snippets > 0 then
    print('✓ Snippet data available (' .. #snippets .. ' snippets)')
    return true
  else
    print('✗ No snippet data available')
    return false
  end
end

-- Test 3: Verify snippet structure
local function test_snippet_structure()
  local snippets = Snippets.get_all_snippets()
  if not snippets or #snippets == 0 then
    print('✗ No snippets to test structure')
    return false
  end
  
  local snippet = snippets[1]
  local has_trigger = snippet.trigger ~= nil
  local has_description = snippet.description ~= nil
  local has_body = snippet.body ~= nil
  
  if has_trigger and has_description and has_body then
    print('✓ Snippet structure valid (trigger, description, body)')
    return true
  else
    print('✗ Snippet structure incomplete')
    print('  trigger: ' .. tostring(has_trigger))
    print('  description: ' .. tostring(has_description))
    print('  body: ' .. tostring(has_body))
    return false
  end
end

-- Test 4: Check Telescope availability
local function test_telescope_available()
  local ok_pickers = pcall(require, "telescope.pickers")
  local ok_finders = pcall(require, "telescope.finders")
  local ok_conf = pcall(require, "telescope.config")
  
  if ok_pickers and ok_finders and ok_conf then
    print('✓ Telescope is available')
    return true
  else
    print('⚠ Telescope not available (will fall back to floating window)')
    return false
  end
end

-- Run all tests
local function run_tests()
  print('=== Snippet Telescope Integration Tests ===')
  print('')
  
  local results = {
    test_snippets_function_exists(),
    test_snippet_data_available(),
    test_snippet_structure(),
    test_telescope_available(),
  }
  
  print('')
  print('=== Test Summary ===')
  local passed = 0
  for _, result in ipairs(results) do
    if result then
      passed = passed + 1
    end
  end
  
  print(string.format('Passed: %d/%d', passed, #results))
  
  if passed == #results then
    print('✓ All tests passed!')
  else
    print('✗ Some tests failed')
  end
end

-- Run tests
run_tests()
