-- tests/lua/unit/ui_spec.lua
-- Tests for genero_tools.ui floating window and display helpers

describe('genero_tools.ui', function()

  local ui

  before_each(function()
    package.loaded['genero_tools.ui'] = nil
    ui = require('genero_tools.ui')
  end)

  describe('module structure', function()

    it('exposes show_floating_window', function()
      assert.is_function(ui.show_floating_window)
    end)

    it('exposes show_popup_menu', function()
      assert.is_function(ui.show_popup_menu)
    end)

    it('exposes notify', function()
      assert.is_function(ui.notify)
    end)

    it('exposes show_progress', function()
      assert.is_function(ui.show_progress)
    end)

    it('exposes highlight_pattern', function()
      assert.is_function(ui.highlight_pattern)
    end)

  end)

  describe('show_floating_window', function()

    it('opens a floating window with string content', function()
      local result = ui.show_floating_window('Hello from test', { title = 'Test' })
      assert.is_not_nil(result)
      assert.is_not_nil(result.buf)
      assert.is_not_nil(result.win)
      -- Clean up
      if vim.api.nvim_win_is_valid(result.win) then
        vim.api.nvim_win_close(result.win, true)
      end
    end)

    it('opens a floating window with list content', function()
      local result = ui.show_floating_window({'line 1', 'line 2', 'line 3'})
      assert.is_not_nil(result)
      assert.is_not_nil(result.buf)
      -- Clean up
      if vim.api.nvim_win_is_valid(result.win) then
        vim.api.nvim_win_close(result.win, true)
      end
    end)

    it('buffer contains the provided content', function()
      local result = ui.show_floating_window({'test content line'})
      local lines = vim.api.nvim_buf_get_lines(result.buf, 0, -1, false)
      assert.is_true(vim.tbl_contains(lines, 'test content line'))
      if vim.api.nvim_win_is_valid(result.win) then
        vim.api.nvim_win_close(result.win, true)
      end
    end)

  end)

  describe('notify', function()

    it('does not throw', function()
      local ok = pcall(ui.notify, 'test notification', vim.log.levels.INFO)
      assert.is_true(ok)
    end)

  end)

  describe('show_progress', function()

    it('does not throw for 0%', function()
      local ok = pcall(ui.show_progress, 'loading', 0)
      assert.is_true(ok)
    end)

    it('does not throw for 100%', function()
      local ok = pcall(ui.show_progress, 'done', 100)
      assert.is_true(ok)
    end)

  end)

  describe('highlight_pattern', function()

    it('does not throw on a valid buffer', function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'hello world', 'foo bar'})
      local ok = pcall(ui.highlight_pattern, buf, 'hello', 'Search')
      assert.is_true(ok)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

  end)

end)
