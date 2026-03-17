-- Test Task 8: Integrate with existing genero-tools features
-- Tests for GeneroLookup and autocomplete integration

local M = {}

-- Test 8.1: GeneroLookup integration
function M.test_genero_lookup_integration()
  local integration = require('genero_tools.snippets.integration')
  
  -- Verify offer_snippet_after_lookup function exists
  assert(type(integration.offer_snippet_after_lookup) == 'function', 'offer_snippet_after_lookup not a function')
  
  -- Verify expand_function_call_snippet function exists
  assert(type(integration.expand_function_call_snippet) == 'function', 'expand_function_call_snippet not a function')
  
  print('✓ Test 8.1: GeneroLookup integration functions available')
end

-- Test 8.2: Autocomplete integration
function M.test_autocomplete_integration()
  local integration = require('genero_tools.snippets.integration')
  
  -- Verify offer_snippet_in_autocomplete function exists
  assert(type(integration.offer_snippet_in_autocomplete) == 'function', 'offer_snippet_in_autocomplete not a function')
  
  -- Test offering snippet in autocomplete
  local result = integration.offer_snippet_in_autocomplete('test_function')
  assert(result ~= nil, 'offer_snippet_in_autocomplete should return a result')
  assert(result.action == 'expand_snippet', 'result should have expand_snippet action')
  assert(result.function_name == 'test_function', 'result should have function_name')
  
  print('✓ Test 8.2: Autocomplete integration works')
end

-- Test 8.3: Snippet configuration
function M.test_snippet_configuration()
  local integration = require('genero_tools.snippets.integration')
  
  -- Verify get_snippet_config function exists
  assert(type(integration.get_snippet_config) == 'function', 'get_snippet_config not a function')
  
  -- Get configuration
  local config = integration.get_snippet_config()
  assert(type(config) == 'table', 'config should be a table')
  assert(config.enabled ~= nil, 'config should have enabled field')
  assert(config.engine ~= nil, 'config should have engine field')
  assert(config.smart_expansion ~= nil, 'config should have smart_expansion field')
  assert(config.custom_dir ~= nil, 'config should have custom_dir field')
  
  print('✓ Test 8.3: Snippet configuration available')
  print('  - Enabled: ' .. tostring(config.enabled))
  print('  - Engine: ' .. config.engine)
  print('  - Smart expansion: ' .. tostring(config.smart_expansion))
end

-- Test 8.4: Snippet availability check
function M.test_snippet_availability()
  local integration = require('genero_tools.snippets.integration')
  
  -- Verify snippets_available function exists
  assert(type(integration.snippets_available) == 'function', 'snippets_available not a function')
  
  -- Check availability
  local available = integration.snippets_available()
  assert(type(available) == 'boolean', 'snippets_available should return a boolean')
  
  print('✓ Test 8.4: Snippet availability check works')
  print('  - Snippets available: ' .. tostring(available))
end

-- Test generic function call snippet building
function M.test_generic_function_call_snippet()
  local integration = require('genero_tools.snippets.integration')
  
  -- Verify build_generic_function_call_snippet function exists
  assert(type(integration.build_generic_function_call_snippet) == 'function', 'build_generic_function_call_snippet not a function')
  
  -- Build a generic snippet
  local snippet = integration.build_generic_function_call_snippet('my_function')
  assert(snippet ~= nil, 'snippet should not be nil')
  assert(snippet:find('my_function') ~= nil, 'snippet should contain function name')
  assert(snippet:find('CALL') ~= nil, 'snippet should contain CALL keyword')
  assert(snippet:find('${1:param1}') ~= nil, 'snippet should contain placeholder')
  
  print('✓ Test 8.5: Generic function call snippet building works')
  print('  - Generated snippet: ' .. snippet)
end

-- Test configuration in genero_tools_config
function M.test_config_integration()
  -- Verify snippet configuration is in genero_tools_config
  local config = vim.g.genero_tools_config or {}
  
  assert(config.snippets_enabled ~= nil, 'snippets_enabled should be in config')
  assert(config.snippet_engine ~= nil, 'snippet_engine should be in config')
  assert(config.snippet_smart_expansion ~= nil, 'snippet_smart_expansion should be in config')
  assert(config.snippet_custom_dir ~= nil, 'snippet_custom_dir should be in config')
  
  print('✓ Test 8.6: Configuration integration works')
  print('  - Snippets enabled: ' .. tostring(config.snippets_enabled))
  print('  - Snippet engine: ' .. config.snippet_engine)
  print('  - Smart expansion: ' .. tostring(config.snippet_smart_expansion))
end

-- Run all tests
function M.run_all()
  print('Running Task 8 integration tests...')
  print('')
  
  M.test_genero_lookup_integration()
  print('')
  
  M.test_autocomplete_integration()
  print('')
  
  M.test_snippet_configuration()
  print('')
  
  M.test_snippet_availability()
  print('')
  
  M.test_generic_function_call_snippet()
  print('')
  
  M.test_config_integration()
  
  print('')
  print('✓ All Task 8 integration tests passed!')
end

return M
