-- Genero-Tools Async Parameter Population
-- Handles asynchronous function signature queries and parameter population

local M = {}

-- Reference to async module
local async_module = nil

-- Initialize async module reference
function M.init()
  local ok, async = pcall(require, 'genero_tools.async')
  if ok then
    async_module = async
  end
end

-- Query function signature asynchronously
-- Args:
--   function_name: Name of the function to query
--   callback: Function to call with signature data
function M.query_signature(function_name, callback)
  if not async_module then
    M.init()
  end

  if not async_module then
    -- Fallback: call callback with nil if async not available
    callback(nil)
    return
  end

  if not function_name or function_name == '' then
    callback(nil)
    return
  end

  -- Execute async query using genero_tools.async
  -- The callback receives the result from the async operation
  async_module.execute_async('get-function-signature', { function_name }, function(result)
    if result and result.success and result.data then
      -- Parse the signature data
      local signature = M.parse_signature_data(result.data)
      callback(signature)
    else
      callback(nil)
    end
  end)
end

-- Parse signature data from API response
-- Args:
--   data: Raw data from API
-- Returns: Parsed signature object or nil
function M.parse_signature_data(data)
  if not data then
    return nil
  end

  -- If data is already a table with expected structure, return it
  if type(data) == 'table' then
    if data.parameters or data.return_type then
      return data
    end
  end

  -- If data is a string, try to parse as JSON
  if type(data) == 'string' then
    local ok, parsed = pcall(vim.fn.json_decode, data)
    if ok and type(parsed) == 'table' then
      return parsed
    end
  end

  return nil
end

-- Populate snippet parameters from function signature
-- Args:
--   snippet: Snippet object (can be nil)
--   signature: Function signature data
-- Returns: Updated snippet context with populated parameters
function M.populate_from_signature(snippet, signature)
  if not signature then
    return nil
  end

  local context = {
    parameters = {},
    return_type = nil,
    optional_params = {},
    placeholder_index = 1,
  }

  -- Extract parameters from signature
  if signature.parameters and type(signature.parameters) == 'table' then
    for _, param in ipairs(signature.parameters) do
      if param and param.name then
        table.insert(context.parameters, {
          name = param.name or 'param',
          type = param.type or 'any',
          optional = param.optional or false,
        })

        -- Track optional parameters
        if param.optional then
          table.insert(context.optional_params, param.name)
        end
      end
    end
  end

  -- Extract return type
  if signature.return_type then
    context.return_type = signature.return_type
  end

  return context
end

-- Fallback to generic parameters when signature not found
-- Args:
--   snippet: Snippet object (can be nil)
--   num_params: Number of generic parameters to create (default: 2)
-- Returns: Generic parameter context
function M.fallback_parameters(snippet, num_params)
  num_params = num_params or 2

  local parameters = {}
  for i = 1, num_params do
    table.insert(parameters, {
      name = 'param' .. i,
      type = 'any',
      optional = false,
    })
  end

  return {
    parameters = parameters,
    return_type = nil,
    optional_params = {},
  }
end

-- Format parameter list for display
-- Args:
--   parameters: List of parameter objects
-- Returns: Formatted parameter string
function M.format_parameters(parameters)
  if not parameters or #parameters == 0 then
    return ''
  end

  local formatted = {}
  for _, param in ipairs(parameters) do
    local param_str = param.name
    if param.type then
      param_str = param_str .. ' ' .. param.type
    end
    if param.optional then
      param_str = '[' .. param_str .. ']'
    end
    table.insert(formatted, param_str)
  end

  return table.concat(formatted, ', ')
end

-- Create placeholder text for parameters
-- Args:
--   parameters: List of parameter objects
--   start_index: Starting placeholder index
-- Returns: Placeholder text and next index
function M.create_parameter_placeholders(parameters, start_index)
  if not parameters or #parameters == 0 then
    return '', start_index
  end

  start_index = start_index or 1
  local placeholders = {}

  for i, param in ipairs(parameters) do
    local placeholder_idx = start_index + i - 1
    -- Create placeholder with parameter name as default
    -- Format: ${index:default_text}
    local default_text = param.name
    if param.type then
      default_text = default_text .. ' -- ' .. param.type
    end
    local placeholder = '${' .. placeholder_idx .. ':' .. default_text .. '}'
    table.insert(placeholders, placeholder)
  end

  return table.concat(placeholders, ', '), start_index + #parameters
end

-- Create return type placeholder
-- Args:
--   return_type: Return type string
--   placeholder_index: Placeholder index
-- Returns: Placeholder text
function M.create_return_placeholder(return_type, placeholder_index)
  if not return_type or return_type == '' then
    return nil
  end

  placeholder_index = placeholder_index or 1
  -- Create placeholder for return value with type information
  return '${' .. placeholder_index .. ':return_value -- ' .. return_type .. '}'
end

-- Check if parameter is optional
-- Args:
--   param_name: Parameter name
--   optional_params: List of optional parameter names
-- Returns: Boolean indicating if parameter is optional
function M.is_optional(param_name, optional_params)
  if not optional_params then
    return false
  end

  for _, opt_param in ipairs(optional_params) do
    if opt_param == param_name then
      return true
    end
  end

  return false
end

-- Build a complete function call snippet with populated parameters
-- Args:
--   function_name: Name of the function
--   signature: Function signature data
-- Returns: Complete snippet body with populated parameters
function M.build_function_call_snippet(function_name, signature)
  if not function_name then
    return nil
  end

  local param_context = M.populate_from_signature(nil, signature)
  if not param_context then
    param_context = M.fallback_parameters(nil, 2)
  end

  -- Generate parameter placeholders
  local param_placeholders, next_idx = M.create_parameter_placeholders(param_context.parameters, 1)

  -- Build the function call
  local snippet_body = function_name .. '(' .. param_placeholders .. ')'

  -- If there's a return type, add return value placeholder
  if param_context.return_type then
    local return_placeholder = M.create_return_placeholder(param_context.return_type, next_idx)
    snippet_body = 'DEFINE result ' .. param_context.return_type .. '\nLET result = ' .. snippet_body .. '\nRETURN result'
  end

  return snippet_body
end

-- Merge parameter context into snippet
-- Args:
--   snippet: Snippet object
--   param_context: Parameter context from populate_from_signature
-- Returns: Updated snippet with populated parameters
function M.merge_into_snippet(snippet, param_context)
  if not snippet or not param_context then
    return snippet
  end

  -- Create a copy of the snippet
  local updated = vim.deepcopy(snippet)

  -- Update snippet metadata with parameter information
  updated.param_context = param_context
  updated.parameters = param_context.parameters
  updated.return_type = param_context.return_type
  updated.optional_params = param_context.optional_params

  -- Update the body with populated parameters if it contains placeholders
  if updated.body and param_context.parameters and #param_context.parameters > 0 then
    -- Generate parameter placeholders
    local param_placeholders, next_idx = M.create_parameter_placeholders(param_context.parameters, 1)
    
    -- If there's a return type, create return placeholder
    local return_placeholder = nil
    if param_context.return_type then
      return_placeholder = M.create_return_placeholder(param_context.return_type, next_idx)
    end

    -- Store these for later use by the snippet engine
    updated.populated_params = param_placeholders
    updated.populated_return = return_placeholder
  end

  return updated
end

return M
