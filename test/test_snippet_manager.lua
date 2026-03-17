#!/usr/bin/env lua
-- Test script for snippet manager
-- Run with: lua test/test_snippet_manager.lua

-- Mock vim module for testing
_G.vim = {
  fn = {
    fnamemodify = function(path, mod)
      -- Simple mock: return the path as-is
      return path
    end,
    stdpath = function(name)
      return os.getenv('HOME') .. '/.config/nvim'
    end,
    expand = function(path)
      if path:match('^~') then
        return os.getenv('HOME') .. path:sub(2)
      end
      return path
    end,
    isdirectory = function(dir)
      local f = io.open(dir, 'r')
      if f then
        f:close()
        return 1
      end
      return 0
    end,
    mkdir = function(dir, mode)
      os.execute('mkdir -p ' .. dir)
    end,
    glob = function(pattern, nosort, list)
      -- Simple glob implementation
      local files = {}
      local cmd = 'find ' .. pattern:gsub('/*.lua', '') .. ' -maxdepth 1 -name "*.lua" 2>/dev/null'
      local handle = io.popen(cmd)
      if handle then
        for line in handle:lines() do
          table.insert(files, line)
        end
        handle:close()
      end
      return files
    end,
  },
  tbl_count = function(t)
    local count = 0
    for _ in pairs(t) do
      count = count + 1
    end
    return count
  end,
  notify = function(msg, level, opts)
    print('[NOTIFY] ' .. msg)
  end,
  log = {
    levels = {
      WARN = 1,
      INFO = 2,
      ERROR = 3,
    }
  },
  api = {
    nvim_create_augroup = function(name, opts)
      return 1
    end,
    nvim_create_autocmd = function(event, opts)
      return 1
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

-- Mock debug module
_G.debug = {
  getinfo = function(level)
    return {
      source = '@lua/genero_tools/snippets/manager.lua'
    }
  end
}

-- Load the manager module
local Manager = require('lua.genero_tools.snippets.manager')

-- Test 1: Load built-in snippets
print('Test 1: Load built-in snippets')
local builtin = Manager.load_builtin()
print('  Loaded ' .. vim.tbl_count(builtin) .. ' built-in snippets')
for trigger, snippet in pairs(builtin) do
  print('    - ' .. trigger .. ': ' .. (snippet.name or 'unnamed'))
end

-- Test 2: Load custom snippets (should be empty initially)
print('\nTest 2: Load custom snippets')
local custom = Manager.load_custom()
print('  Loaded ' .. vim.tbl_count(custom) .. ' custom snippets')

-- Test 3: Get snippet by trigger
print('\nTest 3: Get snippet by trigger')
local fn_snippet = Manager.get_snippet('fn')
if fn_snippet then
  print('  Found snippet: ' .. fn_snippet.name)
  print('  Description: ' .. fn_snippet.description)
else
  print('  ERROR: Could not find "fn" snippet')
end

-- Test 4: List all snippets
print('\nTest 4: List all snippets')
local all_snippets = Manager.list_snippets()
print('  Total snippets: ' .. vim.tbl_count(all_snippets))

-- Test 5: Verify snippet structure
print('\nTest 5: Verify snippet structure')
local test_snippet = Manager.get_snippet('if')
if test_snippet then
  print('  Snippet "if":')
  print('    - trigger: ' .. (test_snippet.trigger or 'missing'))
  print('    - name: ' .. (test_snippet.name or 'missing'))
  print('    - description: ' .. (test_snippet.description or 'missing'))
  print('    - body: ' .. (test_snippet.body and 'present' or 'missing'))
else
  print('  ERROR: Could not find "if" snippet')
end

print('\n✓ All tests completed')
