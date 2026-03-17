" Test script for async parameter population
" Run with: nvim -u NONE -N -S test/test_async_params.vim

" Set up test environment
set nocompatible
set runtimepath=.

" Initialize test counter
let s:tests_passed = 0
let s:tests_failed = 0

" Helper function to assert
function! s:assert_equal(actual, expected, test_name)
  if a:actual == a:expected
    echo '✓ ' . a:test_name
    let s:tests_passed += 1
  else
    echo '✗ ' . a:test_name
    echo '  Expected: ' . string(a:expected)
    echo '  Actual: ' . string(a:actual)
    let s:tests_failed += 1
  endif
endfunction

" Helper function to assert not nil
function! s:assert_not_nil(actual, test_name)
  if a:actual != v:null && a:actual != ''
    echo '✓ ' . a:test_name
    let s:tests_passed += 1
  else
    echo '✗ ' . a:test_name
    echo '  Expected: not nil'
    echo '  Actual: ' . string(a:actual)
    let s:tests_failed += 1
  endif
endfunction

" Load the async_params module
lua << EOF
local AsyncParams = require('lua.genero_tools.snippets.async_params')

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
assert(parsed ~= nil, 'Parsed signature is not nil')
assert(parsed.return_type == 'STRING', 'Return type parsed correctly')

-- Test 2: Parse signature data - nil input
print('Test 2: Parse signature data - nil input')
local parsed_nil = AsyncParams.parse_signature_data(nil)
assert(parsed_nil == nil, 'Nil input returns nil')

-- Test 3: Populate from signature
print('Test 3: Populate from signature')
local context = AsyncParams.populate_from_signature(nil, sig_data)
assert(context ~= nil, 'Context is not nil')
assert(#context.parameters == 2, 'Two parameters extracted')
assert(context.parameters[1].name == 'param1', 'First parameter name correct')
assert(context.parameters[1].type == 'STRING', 'First parameter type correct')
assert(context.return_type == 'STRING', 'Return type extracted')

-- Test 4: Populate from signature with optional parameters
print('Test 4: Populate from signature with optional parameters')
local sig_with_optional = {
  parameters = {
    { name = 'required_param', type = 'STRING', optional = false },
    { name = 'optional_param', type = 'INTEGER', optional = true },
  },
  return_type = 'BOOLEAN'
}
local context_opt = AsyncParams.populate_from_signature(nil, sig_with_optional)
assert(#context_opt.optional_params == 1, 'One optional parameter tracked')
assert(context_opt.optional_params[1] == 'optional_param', 'Optional parameter name correct')

-- Test 5: Fallback parameters
print('Test 5: Fallback parameters')
local fallback = AsyncParams.fallback_parameters(nil, 3)
assert(#fallback.parameters == 3, 'Three fallback parameters created')
assert(fallback.parameters[1].name == 'param1', 'First fallback param named correctly')
assert(fallback.parameters[2].name == 'param2', 'Second fallback param named correctly')
assert(fallback.parameters[3].name == 'param3', 'Third fallback param named correctly')

-- Test 6: Create parameter placeholders
print('Test 6: Create parameter placeholders')
local params = {
  { name = 'name', type = 'STRING' },
  { name = 'age', type = 'INTEGER' },
}
local placeholders, next_idx = AsyncParams.create_parameter_placeholders(params, 1)
assert(placeholders:match('${1:'), 'First placeholder starts correctly')
assert(next_idx == 3, 'Next index is correct')

-- Test 7: Create return placeholder
print('Test 7: Create return placeholder')
local return_ph = AsyncParams.create_return_placeholder('STRING', 3)
assert(return_ph ~= nil, 'Return placeholder created')
assert(return_ph:match('${3:'), 'Return placeholder index correct')

-- Test 8: Create return placeholder with nil type
print('Test 8: Create return placeholder with nil type')
local return_ph_nil = AsyncParams.create_return_placeholder(nil, 3)
assert(return_ph_nil == nil, 'Nil return type returns nil')

-- Test 9: Is optional parameter
print('Test 9: Is optional parameter')
local optional_list = { 'param2', 'param3' }
assert(AsyncParams.is_optional('param2', optional_list) == true, 'param2 is optional')
assert(AsyncParams.is_optional('param1', optional_list) == false, 'param1 is not optional')

-- Test 10: Format parameters
print('Test 10: Format parameters')
local format_params = {
  { name = 'name', type = 'STRING', optional = false },
  { name = 'age', type = 'INTEGER', optional = true },
}
local formatted = AsyncParams.format_parameters(format_params)
assert(formatted:match('name STRING'), 'First param formatted')
assert(formatted:match('%[age INTEGER%]'), 'Optional param marked with brackets')

-- Test 11: Build function call snippet
print('Test 11: Build function call snippet')
local func_sig = {
  parameters = {
    { name = 'input', type = 'STRING' },
  },
  return_type = 'INTEGER'
}
local snippet = AsyncParams.build_function_call_snippet('my_function', func_sig)
assert(snippet ~= nil, 'Snippet created')
assert(snippet:match('my_function'), 'Function name in snippet')

-- Test 12: Build function call snippet without return type
print('Test 12: Build function call snippet without return type')
local func_sig_no_return = {
  parameters = {
    { name = 'input', type = 'STRING' },
  },
}
local snippet_no_return = AsyncParams.build_function_call_snippet('my_function', func_sig_no_return)
assert(snippet_no_return ~= nil, 'Snippet created without return type')
assert(snippet_no_return:match('my_function'), 'Function name in snippet')

-- Test 13: Merge into snippet
print('Test 13: Merge into snippet')
local base_snippet = {
  trigger = 'fn',
  name = 'Function',
  body = 'FUNCTION ${1:name}(${2:params})\nEND FUNCTION'
}
local param_ctx = AsyncParams.populate_from_signature(nil, sig_data)
local merged = AsyncParams.merge_into_snippet(base_snippet, param_ctx)
assert(merged.trigger == 'fn', 'Trigger preserved')
assert(merged.return_type == 'STRING', 'Return type added')
assert(#merged.parameters == 2, 'Parameters added')

-- Test 14: Empty parameters list
print('Test 14: Empty parameters list')
local empty_params = {}
local empty_placeholders, empty_idx = AsyncParams.create_parameter_placeholders(empty_params, 1)
assert(empty_placeholders == '', 'Empty parameters returns empty string')
assert(empty_idx == 1, 'Index unchanged for empty parameters')

-- Test 15: Populate from signature with nil parameters
print('Test 15: Populate from signature with nil parameters')
local sig_no_params = {
  return_type = 'STRING'
}
local ctx_no_params = AsyncParams.populate_from_signature(nil, sig_no_params)
assert(#ctx_no_params.parameters == 0, 'No parameters extracted')
assert(ctx_no_params.return_type == 'STRING', 'Return type still extracted')

print('\n' .. string.rep('=', 50))
print('✓ All Lua tests passed!')
print(string.rep('=', 50))
EOF

" Print summary
echo ''
echo '=========================================='
echo 'Async Parameters Tests Complete'
echo '=========================================='

" Exit
quit!
