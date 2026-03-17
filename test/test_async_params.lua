#!/usr/bin/env lua
-- Test script for async parameter population
-- Run with: lua test/test_async_params.lua

-- Mock vim module for testing
_G.vim = {
  fn = {
    json_decode = function(str)
      -- Simple JSON decoder for testing
      if str:match('"parameters"') then
        return {
          parameters = {
            { name = 'param1', type = 'STRING', optional = false },
            { name = 'param2', type = 'INTEGER', optional = true },
          },
          return_type = 'STRING'
        }
      end
      return {}
    end,
  },
  deepcopy = function(t)
    local copy = {}
    for k, v in pairs(t) do
      if type(v) == 'table' then
        copy[k] = vim.deepcopy(v)
      else
        copy[k] = v
      end
    end
    return copy
  end,
}

-- Load the async_params module
local AsyncParams = require('lua.genero_tools.snippets.async_params')

-- Test counter
local tests_passed = 0
local tests_failed = 0

-- Helper function to assert
local function assert_equal(actual, expected, test_name)
  if actual == expected then
    print('✓ ' .. test_name)
    tests_passed = tests_passed + 1
  else
    print('✗ ' .. test_name)
    print('  Expected: ' .. tostring(expected))
    print('  Actual: ' .. tostring(actual))
    tests_failed = tests_failed + 1
  end
end

-- Helper function to assert table equality
local function assert_table_equal(actual, expected, test_name)
  local function tables_equal(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= 'table' then return t1 == t2 end
    
    for k, v in pairs(t1) do
      if not tables_equal(v, t2[k]) then return false end
    end
    for k, v in pairs(t2) do
      if not tables_equal(v, t1[k]) then return false end
    end
    return true
  end
  
  if tables_equal(actual, expected) then
    print('✓ ' .. test_name)
    tests_passed = tests_passed + 1
  else
    print('✗ ' .. test_name)
    print('  Expected: ' .. vim.inspect(expected))
    print('  Actual: ' .. vim.inspect(actual))
    tests_failed = tests_failed + 1
  end
end

-- Test 1: Parse signature data - table input
print('Test 1: Parse signature data - table input')
local sig_data = {
  parameters = {
    { name = 'param1', type = 'STRING' },
    { name = 'param2', type = 'INTEGER' },
  },
  return_type = 'STRING'
}
local parsed = AsyncParams.parse_signature_data(sig_data)
assert_equal(parsed ~= nil, true, 'Parsed signature is not nil')
assert_equal(parsed.return_type, 'STRING', 'Return type parsed correctly')

-- Test 2: Parse signature data - nil input
print('\nTest 2: Parse signature data - nil input')
local parsed_nil = AsyncParams.parse_signature_data(nil)
assert_equal(parsed_nil, nil, 'Nil input returns nil')

-- Test 3: Populate from signature
print('\nTest 3: Populate from signature')
local context = AsyncParams.populate_from_signature(nil, sig_data)
assert_equal(context ~= nil, true, 'Context is not nil')
assert_equal(#context.parameters, 2, 'Two parameters extracted')
assert_equal(context.parameters[1].name, 'param1', 'First parameter name correct')
assert_equal(context.parameters[1].type, 'STRING', 'First parameter type correct')
assert_equal(context.return_type, 'STRING', 'Return type extracted')

-- Test 4: Populate from signature with optional parameters
print('\nTest 4: Populate from signature with optional parameters')
local sig_with_optional = {
  parameters = {
    { name = 'required_param', type = 'STRING', optional = false },
    { name = 'optional_param', type = 'INTEGER', optional = true },
  },
  return_type = 'BOOLEAN'
}
local context_opt = AsyncParams.populate_from_signature(nil, sig_with_optional)
assert_equal(#context_opt.optional_params, 1, 'One optional parameter tracked')
assert_equal(context_opt.optional_params[1], 'optional_param', 'Optional parameter name correct')

-- Test 5: Fallback parameters
print('\nTest 5: Fallback parameters')
local fallback = AsyncParams.fallback_parameters(nil, 3)
assert_equal(#fallback.parameters, 3, 'Three fallback parameters created')
assert_equal(fallback.parameters[1].name, 'param1', 'First fallback param named correctly')
assert_equal(fallback.parameters[2].name, 'param2', 'Second fallback param named correctly')
assert_equal(fallback.parameters[3].name, 'param3', 'Third fallback param named correctly')

-- Test 6: Create parameter placeholders
print('\nTest 6: Create parameter placeholders')
local params = {
  { name = 'name', type = 'STRING' },
  { name = 'age', type = 'INTEGER' },
}
local placeholders, next_idx = AsyncParams.create_parameter_placeholders(params, 1)
assert_equal(placeholders:match('${1:'), '${1:', 'First placeholder starts correctly')
assert_equal(next_idx, 3, 'Next index is correct')

-- Test 7: Create return placeholder
print('\nTest 7: Create return placeholder')
local return_ph = AsyncParams.create_return_placeholder('STRING', 3)
assert_equal(return_ph ~= nil, true, 'Return placeholder created')
assert_equal(return_ph:match('${3:'), '${3:', 'Return placeholder index correct')

-- Test 8: Create return placeholder with nil type
print('\nTest 8: Create return placeholder with nil type')
local return_ph_nil = AsyncParams.create_return_placeholder(nil, 3)
assert_equal(return_ph_nil, nil, 'Nil return type returns nil')

-- Test 9: Is optional parameter
print('\nTest 9: Is optional parameter')
local optional_list = { 'param2', 'param3' }
assert_equal(AsyncParams.is_optional('param2', optional_list), true, 'param2 is optional')
assert_equal(AsyncParams.is_optional('param1', optional_list), false, 'param1 is not optional')

-- Test 10: Format parameters
print('\nTest 10: Format parameters')
local format_params = {
  { name = 'name', type = 'STRING', optional = false },
  { name = 'age', type = 'INTEGER', optional = true },
}
local formatted = AsyncParams.format_parameters(format_params)
assert_equal(formatted:match('name STRING'), 'name STRING', 'First param formatted')
assert_equal(formatted:match('%[age INTEGER%]'), '[age INTEGER]', 'Optional param marked with brackets')

-- Test 11: Build function call snippet
print('\nTest 11: Build function call snippet')
local func_sig = {
  parameters = {
    { name = 'input', type = 'STRING' },
  },
  return_type = 'INTEGER'
}
local snippet = AsyncParams.build_function_call_snippet('my_function', func_sig)
assert_equal(snippet ~= nil, true, 'Snippet created')
assert_equal(snippet:match('my_function'), 'my_function', 'Function name in snippet')

-- Test 12: Build function call snippet without return type
print('\nTest 12: Build function call snippet without return type')
local func_sig_no_return = {
  parameters = {
    { name = 'input', type = 'STRING' },
  },
}
local snippet_no_return = AsyncParams.build_function_call_snippet('my_function', func_sig_no_return)
assert_equal(snippet_no_return ~= nil, true, 'Snippet created without return type')
assert_equal(snippet_no_return:match('my_function'), 'my_function', 'Function name in snippet')

-- Test 13: Merge into snippet
print('\nTest 13: Merge into snippet')
local base_snippet = {
  trigger = 'fn',
  name = 'Function',
  body = 'FUNCTION ${1:name}(${2:params})\nEND FUNCTION'
}
local param_ctx = AsyncParams.populate_from_signature(nil, sig_data)
local merged = AsyncParams.merge_into_snippet(base_snippet, param_ctx)
assert_equal(merged.trigger, 'fn', 'Trigger preserved')
assert_equal(merged.return_type, 'STRING', 'Return type added')
assert_equal(#merged.parameters, 2, 'Parameters added')

-- Test 14: Empty parameters list
print('\nTest 14: Empty parameters list')
local empty_params = {}
local empty_placeholders, empty_idx = AsyncParams.create_parameter_placeholders(empty_params, 1)
assert_equal(empty_placeholders, '', 'Empty parameters returns empty string')
assert_equal(empty_idx, 1, 'Index unchanged for empty parameters')

-- Test 15: Populate from signature with nil parameters
print('\nTest 15: Populate from signature with nil parameters')
local sig_no_params = {
  return_type = 'STRING'
}
local ctx_no_params = AsyncParams.populate_from_signature(nil, sig_no_params)
assert_equal(#ctx_no_params.parameters, 0, 'No parameters extracted')
assert_equal(ctx_no_params.return_type, 'STRING', 'Return type still extracted')

print('\n' .. string.rep('=', 50))
print('Tests passed: ' .. tests_passed)
print('Tests failed: ' .. tests_failed)
print(string.rep('=', 50))

if tests_failed > 0 then
  os.exit(1)
else
  print('✓ All tests passed!')
  os.exit(0)
end
