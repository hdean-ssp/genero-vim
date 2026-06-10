-- tests/init.lua — minimal Neovim config for plenary.nvim test execution
--
-- This file is passed to nvim via -u tests/init.lua when running Lua tests.
-- It appends the plugin root and plenary.nvim to runtimepath so that both
-- the plugin under test and the test framework are available.
--
-- Neovim only.

-- ── Plugin root (the repo itself) ─────────────────────────────────────────────
-- Adds lua/, autoload/, plugin/, ftdetect/, etc. to runtimepath.
vim.opt.runtimepath:append(vim.fn.getcwd())

-- ── plenary.nvim ──────────────────────────────────────────────────────────────
-- Support common installation locations. The first one found wins.
-- Users can override by setting $PLENARY_PATH before running the runner.

local function find_plenary()
  local candidates = {
    vim.env.PLENARY_PATH,
    vim.fn.expand('~/.local/share/nvim/lazy/plenary.nvim'),
    vim.fn.stdpath('data') .. '/site/pack/test/start/plenary.nvim',
    vim.fn.stdpath('data') .. '/lazy/plenary.nvim',
    vim.fn.expand('~/.local/share/nvim/site/pack/test/start/plenary.nvim'),
    vim.fn.expand('~/.vim/plugged/plenary.nvim'),
    vim.fn.expand('~/.config/nvim/plugged/plenary.nvim'),
  }
  for _, path in ipairs(candidates) do
    if path and path ~= '' and vim.fn.isdirectory(path) == 1 then
      return path
    end
  end
  return nil
end

local plenary_path = find_plenary()
if plenary_path then
  vim.opt.runtimepath:append(plenary_path)
else
  vim.api.nvim_err_writeln(
    'plenary.nvim not found. Set $PLENARY_PATH or install plenary.nvim.\n'
    .. 'See tests/README.md for setup instructions.'
  )
  vim.cmd('cquit 1')
end

-- ── Filetype detection ────────────────────────────────────────────────────────
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')
