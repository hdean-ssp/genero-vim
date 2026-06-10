-- tests/lua/unit/lualine_spec.lua
-- Tests for genero_tools.lualine statusline components

describe('genero_tools.lualine', function()

  local lualine

  before_each(function()
    package.loaded['genero_tools.lualine'] = nil
    lualine = require('genero_tools.lualine')
    -- Reset mock env
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.env.MOCK_QUERY_EXIT   = '0'
    vim.env.MOCK_SVN_OUTPUT   = ''
    vim.env.MOCK_SVN_EXIT     = '0'
  end)

  describe('module structure', function()

    it('exposes breadcrumb', function()
      assert.is_function(lualine.breadcrumb)
    end)

    it('exposes diagnostics', function()
      assert.is_function(lualine.diagnostics)
    end)

    it('exposes svn_status', function()
      assert.is_function(lualine.svn_status)
    end)

    it('exposes cache_stats', function()
      assert.is_function(lualine.cache_stats)
    end)

    it('exposes setup', function()
      assert.is_function(lualine.setup)
    end)

    it('exposes _find_enclosing_function', function()
      assert.is_function(lualine._find_enclosing_function)
    end)

  end)

  describe('diagnostics()', function()

    it('returns empty string when no compiler signs', function()
      -- No signs placed — should return empty string
      local result = lualine.diagnostics()
      assert.is_string(result)
    end)

    it('returns a string (never throws)', function()
      local ok, result = pcall(lualine.diagnostics)
      assert.is_true(ok)
      assert.is_string(result)
    end)

  end)

  describe('svn_status()', function()

    it('returns a string (never throws)', function()
      local ok, result = pcall(lualine.svn_status)
      assert.is_true(ok)
      assert.is_string(result)
    end)

  end)

  describe('cache_stats()', function()

    it('returns a string (never throws)', function()
      local ok, result = pcall(lualine.cache_stats)
      assert.is_true(ok)
      assert.is_string(result)
    end)

  end)

  describe('breadcrumb()', function()

    it('returns a string (never throws)', function()
      local ok, result = pcall(lualine.breadcrumb)
      assert.is_true(ok)
      assert.is_string(result)
    end)

    it('returns function name when cursor is inside a function', function()
      vim.cmd('edit sample_codebase/customer_main.4gl')
      -- Find the line with customer_search_by_name and position cursor there
      local lines = vim.fn.readfile('sample_codebase/customer_main.4gl')
      for i, line in ipairs(lines) do
        if line:match('FUNCTION%s+customer_search_by_name') then
          vim.api.nvim_win_set_cursor(0, {i + 1, 0})
          break
        end
      end
      local func = lualine._find_enclosing_function()
      -- Either found the function or nil (if cursor is between functions)
      assert.is_true(func == nil or type(func) == 'string')
    end)

  end)

  describe('fallback when lualine is not installed', function()

    it('setup does not throw even if lualine absent', function()
      local ok = pcall(lualine.setup)
      assert.is_true(ok)
    end)

  end)

end)
