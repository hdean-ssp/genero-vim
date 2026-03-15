-- Genero-Tools Async Operations
-- Provides non-blocking command execution for Neovim
-- Uses Neovim's job control for background operations

local M = {}

-- Initialize async module
function M.init()
  -- Set up any async-specific configuration
end

-- Execute command asynchronously
-- Args:
--   command: Command to execute (e.g., 'find-function')
--   args: Command arguments
--   callback: VimScript function name to call with results
function M.execute_async(command, args, callback)
  if not vim.fn.has('nvim') then
    error('Async operations require Neovim')
  end

  local genero_tools_path = vim.g.genero_tools_config.genero_tools_path or 'query.sh'
  local cmd = { genero_tools_path, command }

  -- Add arguments
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local output = {}
  local error_output = {}

  -- Execute job
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(output, line)
        end
      end
    end,
    on_stderr = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(error_output, line)
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      -- Parse output and call callback
      local result = M.parse_output(output, error_output, exit_code)
      vim.fn[callback](result)
    end,
  })
end

-- Parse command output into result structure
function M.parse_output(output, error_output, exit_code)
  local result = {
    success = exit_code == 0,
    data = {},
    error = table.concat(error_output, '\n'),
    exit_code = exit_code,
  }

  if exit_code == 0 and #output > 0 then
    -- Try to parse as JSON
    local json_str = table.concat(output, '\n')
    local ok, parsed = pcall(vim.fn.json_decode, json_str)
    if ok then
      result.data = parsed
    else
      -- Fallback to raw output
      result.data = output
    end
  end

  return result
end

-- Call AI API asynchronously
-- Args:
--   prompt: Prompt for AI
--   context: Code context
--   callback: VimScript function to call with results
function M.call_ai_api(prompt, context, callback)
  local ai_provider = vim.g.genero_tools_config.ai_provider or 'openai'
  local ai_module = require('genero_tools.ai')

  -- Execute AI call in background
  vim.fn.jobstart({
    'python3',
    '-c',
    string.format(
      [[
import json
import sys
sys.path.insert(0, '%s')
from genero_tools.ai import call_api
result = call_api('%s', '%s', '%s')
print(json.dumps(result))
]],
      vim.fn.getcwd(),
      ai_provider,
      prompt:gsub("'", "\\'"),
      context:gsub("'", "\\'")
    ),
  }, {
    on_stdout = function(_, data, _)
      local output = table.concat(data, '\n')
      if output ~= '' then
        local ok, result = pcall(vim.fn.json_decode, output)
        if ok then
          vim.fn[callback](result)
        end
      end
    end,
    on_stderr = function(_, data, _)
      local error_msg = table.concat(data, '\n')
      vim.notify('AI API error: ' .. error_msg, vim.log.levels.ERROR)
    end,
  })
end

-- Execute multiple commands in parallel
-- Args:
--   commands: List of {command, args} pairs
--   callback: VimScript function to call with all results
function M.execute_parallel(commands, callback)
  local results = {}
  local completed = 0

  for i, cmd_info in ipairs(commands) do
    M.execute_async(cmd_info.command, cmd_info.args, function(result)
      results[i] = result
      completed = completed + 1

      if completed == #commands then
        vim.fn[callback](results)
      end
    end)
  end
end

-- Debounce function execution
-- Args:
--   func: Function to debounce
--   delay: Delay in milliseconds
-- Returns: Debounced function
function M.debounce(func, delay)
  local timer = nil

  return function(...)
    local args = { ... }

    if timer then
      vim.fn.timer_stop(timer)
    end

    timer = vim.fn.timer_start(delay, function()
      func(unpack(args))
      timer = nil
    end)
  end
end

-- Throttle function execution
-- Args:
--   func: Function to throttle
--   interval: Minimum interval between calls in milliseconds
-- Returns: Throttled function
function M.throttle(func, interval)
  local last_call = 0

  return function(...)
    local now = vim.fn.reltimestr(vim.fn.reltime())
    local elapsed = (tonumber(now) - last_call) * 1000

    if elapsed >= interval then
      func(...)
      last_call = tonumber(now)
    end
  end
end

return M
