-- Genero Tools Help System
-- Displays comprehensive help in a persistent floating window with navigation

local M = {}

-- State
local help_buf = nil
local help_win = nil

-- Help content organized by category
local help_content = {
  {
    category = "COMPILATION",
    items = {
      { key = "F5", cmd = "", desc = "Compile current file" },
      { key = "<Space>ca", cmd = ":GeneroAutocompileEnable", desc = "Enable autocompile on save" },
      { key = "<Space>cd", cmd = ":GeneroAutocompileDisable", desc = "Disable autocompile on save" },
      { key = "<Space>cc", cmd = ":GeneroClearErrors", desc = "Clear error markers" },
      { key = "<Space>ce", cmd = "", desc = "Filter: show errors only" },
      { key = "<Space>cw", cmd = "", desc = "Filter: show warnings only" },
      { key = "<Space>cx", cmd = "", desc = "Filter: show all diagnostics" },
      { key = "<Space>cD", cmd = ":GeneroDiagnostics", desc = "Diagnostics picker (Telescope)" },
    }
  },
  {
    category = "NAVIGATION",
    items = {
      { key = "]d / [d", cmd = "", desc = "Next/previous error or warning" },
      { key = "]h / [h", cmd = "", desc = "Next/previous code hint" },
      { key = "]b / [b", cmd = "", desc = "Next/previous buffer" },
      { key = "]] / [[", cmd = "", desc = "Next/previous temp tag (#TMP<initials>)" },
      { key = "gd", cmd = "", desc = "Go to definition (jump to source)" },
      { key = "gp", cmd = "", desc = "Peek definition (preview in float)" },
      { key = "gr", cmd = "", desc = "Find references (all callers)" },
      { key = "Ctrl+h/j/k/l", cmd = "", desc = "Navigate between windows" },
      { key = "<Space>bd", cmd = ":bdelete", desc = "Delete current buffer" },
    }
  },
  {
    category = "GENERO TOOLS",
    items = {
      { key = "<Space>gl", cmd = ":GeneroLookup", desc = "Lookup function definition" },
      { key = "<Space>gf", cmd = ":GeneroListFunctions", desc = "List functions in file" },
      { key = "<Space>gs", cmd = ":GeneroFunctionSignature", desc = "Get function signature" },
      { key = "<Space>gm", cmd = ":GeneroFileMetadata", desc = "Get file metadata" },
      { key = "<Space>gd", cmd = ":GeneroDebugStreamToggle", desc = "Toggle debug stream" },
      { key = "<Space>gr", cmd = ":GeneroFindReferences", desc = "Find all function callers" },
      { key = "<Space>gF", cmd = ":GeneroFileFunctions", desc = "File functions (Telescope)" },
      { key = "<Space>gM", cmd = ":GeneroModuleFunctions", desc = "Module functions (Telescope)" },
      { key = "<Space>gS", cmd = ":GeneroModuleFiles", desc = "Module sibling files" },
    }
  },
  {
    category = "CODE HINTS",
    items = {
      { key = "<Space>hl", cmd = ":GeneroListHints", desc = "List all hints in file" },
      { key = "<Space>hd", cmd = ":GeneroHintDetails", desc = "Show hint details" },
      { key = "<Space>hf", cmd = ":GeneroHintAutofix", desc = "Apply auto-fix for hint" },
      { key = "<Space>hh", cmd = ":GeneroHintHelp", desc = "Show hint documentation" },
      { key = "]h / [h", cmd = "", desc = "Navigate to next/previous hint" },
    }
  },
  {
    category = "SVN DIFF MARKERS",
    items = {
      { key = "<Space>sv", cmd = ":GeneroSVNToggle", desc = "Toggle SVN markers on/off" },
      { key = "<Space>sr", cmd = ":GeneroSVNRefresh", desc = "Refresh SVN markers" },
      { key = "<Space>ss", cmd = ":GeneroSVNStatus", desc = "Show SVN status and changes" },
      { key = "", cmd = ":GeneroSVNCacheStats", desc = "Show SVN cache statistics" },
      { key = "", cmd = ":GeneroSVNCacheClear", desc = "Clear SVN cache" },
    }
  },
  {
    category = "UNIFIED SIGNS",
    items = {
      { key = "<Space>su", cmd = ":GeneroUnifiedSignsToggle", desc = "Toggle unified signs (compiler + SVN)" },
      { key = "", cmd = ":GeneroUnifiedSignsEnable", desc = "Enable unified sign column" },
      { key = "", cmd = ":GeneroUnifiedSignsDisable", desc = "Disable unified sign column" },
      { key = "", cmd = ":GeneroUnifiedSignsStatus", desc = "Show unified signs status" },
    }
  },
  {
    category = "SNIPPETS",
    items = {
      { key = "<Space>sl", cmd = ":GeneroSnippetList", desc = "List available snippets" },
      { key = "<Space>sh", cmd = ":GeneroSnippetHelp", desc = "Show snippet documentation" },
      { key = "Tab", cmd = "", desc = "Expand snippet or jump to next placeholder" },
      { key = "Shift+Tab", cmd = "", desc = "Jump to previous placeholder" },
    }
  },
  {
    category = "AUTOCOMPLETE",
    items = {
      { key = "Ctrl+Space", cmd = "", desc = "Trigger code completion" },
      { key = "Tab/Shift+Tab", cmd = "", desc = "Navigate suggestions & placeholders" },
      { key = "Enter", cmd = "", desc = "Accept selected suggestion" },
      { key = "Ctrl+e", cmd = "", desc = "Close completion menu" },
      { key = "Ctrl+u/d", cmd = "", desc = "Scroll documentation" },
      { key = "Ctrl+N", cmd = "", desc = "Manual completion (Vim omnifunc)" },
      { key = "", cmd = ":GeneroCompleteEnable", desc = "Enable autocomplete" },
      { key = "", cmd = ":GeneroCompleteDisable", desc = "Disable autocomplete" },
    }
  },
  {
    category = "DEBUG STREAMING",
    items = {
      { key = "<Space>gd", cmd = ":GeneroDebugStreamToggle", desc = "Toggle debug stream on/off" },
      { key = "", cmd = ":GeneroDebugStream", desc = "Start debug streaming" },
      { key = "", cmd = ":GeneroDebugStreamStop", desc = "Stop debug streaming" },
      { key = "", cmd = ":GeneroDebugStreamSelect", desc = "Select different debug file" },
      { key = "", cmd = ":GeneroDebugStreamClear", desc = "Clear debug stream content" },
      { key = "", cmd = ":GeneroDebugStreamStatus", desc = "Show debug stream status" },
      { key = "q/Esc", cmd = "", desc = "Close debug window" },
      { key = "G/gg", cmd = "", desc = "Jump to latest/beginning" },
    }
  },
  {
    category = "WINDOW MANAGEMENT",
    items = {
      { key = "Ctrl+Up/Down", cmd = "", desc = "Navigate to split above/below" },
      { key = "Ctrl+Left/Right", cmd = "", desc = "Navigate to split left/right" },
      { key = "Ctrl+h/j/k/l", cmd = "", desc = "Navigate between windows" },
    }
  },
  {
    category = "TERMINAL",
    items = {
      { key = "Ctrl+\\", cmd = "", desc = "Toggle terminal (horizontal)" },
      { key = "<Space>tf", cmd = "", desc = "Open floating terminal" },
      { key = "<Space>th", cmd = "", desc = "Open horizontal terminal" },
      { key = "<Space>tv", cmd = "", desc = "Open vertical terminal" },
      { key = "<Space>tk", cmd = "", desc = "Open Kiro AI terminal" },
      { key = "Esc", cmd = "", desc = "Exit terminal mode" },
    }
  },
  {
    category = "SEARCH (Telescope)",
    items = {
      { key = "<Space>fw", cmd = "", desc = "Search word under cursor" },
      { key = "<Space>fg", cmd = "", desc = "Live grep (interactive search)" },
      { key = "<Space>ff", cmd = "", desc = "Find files" },
      { key = "<Space>fb", cmd = "", desc = "Search open buffers" },
      { key = "Ctrl+j/k", cmd = "", desc = "Navigate results (in Telescope)" },
      { key = "Ctrl+x", cmd = "", desc = "Open in horizontal split" },
      { key = "Ctrl+v", cmd = "", desc = "Open in vertical split" },
      { key = "Ctrl+u/d", cmd = "", desc = "Scroll preview" },
      { key = "", cmd = ":TodoTelescope", desc = "Search TODO/BUG/FIX/TMP tags" },
    }
  },
  {
    category = "LSP (Python, Java, C, Bash, Lua, JSON, YAML, XML)",
    items = {
      { key = "K", cmd = "", desc = "Hover documentation" },
      { key = "gi", cmd = "", desc = "Go to implementation" },
      { key = "<Space>la", cmd = "", desc = "Code action (fix, refactor)" },
      { key = "<Space>lf", cmd = "", desc = "Format file" },
      { key = "<Space>ld", cmd = "", desc = "Show line diagnostics" },
      { key = "<Space>rn", cmd = "", desc = "Rename symbol" },
      { key = "gd", cmd = "", desc = "Go to definition (non-Genero)" },
      { key = "gr", cmd = "", desc = "Find references (non-Genero)" },
      { key = "", cmd = ":Mason", desc = "Open LSP/tool installer UI" },
      { key = "", cmd = ":MasonUpdate", desc = "Update all installed servers" },
    }
  },
  {
    category = "COMMENTING",
    items = {
      { key = "gcc", cmd = "", desc = "Toggle comment on current line" },
      { key = "gbc", cmd = "", desc = "Toggle block comment" },
      { key = "gc", cmd = "", desc = "Toggle comment (visual mode)" },
      { key = "gb", cmd = "", desc = "Toggle block comment (visual)" },
      { key = "gcO", cmd = "", desc = "Add comment above" },
      { key = "gco", cmd = "", desc = "Add comment below" },
      { key = "gcA", cmd = "", desc = "Add comment at end of line" },
    }
  },
  {
    category = "KEY FEATURES",
    items = {
      { key = "•", cmd = "", desc = "Go to definition (gd) and peek (gp)" },
      { key = "•", cmd = "", desc = "Find references with Telescope preview" },
      { key = "•", cmd = "", desc = "Function signature & type hover" },
      { key = "•", cmd = "", desc = "Schema/table/column lookup" },
      { key = "•", cmd = "", desc = "Block matching highlights (IF/END IF)" },
      { key = "•", cmd = "", desc = "Statusline breadcrumb with ref count" },
      { key = "•", cmd = "", desc = "Module-scoped autocomplete" },
      { key = "•", cmd = "", desc = "TODO/BUG/FIX/TMP highlighting" },
      { key = "•", cmd = "", desc = "Auto-close blocks (IF→END IF)" },
      { key = "•", cmd = "", desc = "Inline diagnostics (errors always visible)" },
      { key = "•", cmd = "", desc = "Code hints with auto-fix" },
      { key = "•", cmd = "", desc = "Autocompile on save (500ms delay)" },
      { key = "•", cmd = "", desc = "SVN diff markers (auto-refresh)" },
      { key = "•", cmd = "", desc = "Bracket navigation: ]d ]h ]b ]]" },
    }
  },
  {
    category = "TIPS & TRICKS",
    items = {
      { key = "•", cmd = "", desc = "Press <Space> to see keybindings (which-key)" },
      { key = "•", cmd = "", desc = "Use ]d/[d for errors, ]h/[h for hints" },
      { key = "•", cmd = "", desc = "Use ]]/[[ to jump between #TMP tags" },
      { key = "•", cmd = "", desc = "gd jumps, gp peeks without moving" },
      { key = "•", cmd = "", desc = "gr shows all callers with preview" },
      { key = "•", cmd = "", desc = "<Space>gF picks functions in file" },
      { key = "•", cmd = "", desc = "<Space>gM picks functions in module" },
      { key = "•", cmd = "", desc = "<Space>gS switches module sibling files" },
      { key = "•", cmd = "", desc = "<Space>cD browses errors with preview" },
      { key = "•", cmd = "", desc = "Hover on function to see signature" },
      { key = "•", cmd = "", desc = "Hover on variable to see type" },
      { key = "•", cmd = "", desc = "Hover on table to see all columns" },
      { key = "•", cmd = "", desc = "Ctrl+\\ for quick terminal access" },
      { key = "•", cmd = "", desc = "<Space>fw searches word in project" },
      { key = "•", cmd = "", desc = ":TodoTelescope finds all TODO tags" },
    }
  },
}

-- Format help content into lines
local function format_help_lines()
  local lines = {}
  
  -- Header
  table.insert(lines, "╔══════════════════════════════════════════════════════════════════════════════╗")
  table.insert(lines, "║                    Genero Tools - Comprehensive Help                        ║")
  table.insert(lines, "╚══════════════════════════════════════════════════════════════════════════════╝")
  table.insert(lines, "")
  
  -- Content by category
  for _, section in ipairs(help_content) do
    table.insert(lines, section.category .. ":")
    table.insert(lines, string.rep("─", 80))
    
    for _, item in ipairs(section.items) do
      local key_part = item.key ~= "" and string.format("  %-20s", item.key) or "  " .. string.rep(" ", 20)
      local cmd_part = item.cmd ~= "" and string.format("%-30s", item.cmd) or string.rep(" ", 30)
      local desc_part = item.desc
      
      -- Format line based on what's available
      if item.key ~= "" and item.cmd ~= "" then
        table.insert(lines, string.format("%s %s %s", key_part, cmd_part, desc_part))
      elseif item.key ~= "" then
        table.insert(lines, string.format("%s %s", key_part, desc_part))
      elseif item.cmd ~= "" then
        table.insert(lines, string.format("  %-30s %s", item.cmd, desc_part))
      else
        table.insert(lines, string.format("  %s", desc_part))
      end
    end
    
    table.insert(lines, "")
  end
  
  -- Footer with navigation help
  table.insert(lines, "╔══════════════════════════════════════════════════════════════════════════════╗")
  table.insert(lines, "║  Navigation: j/k or ↑/↓ to scroll  •  q or Esc to close  •  / to search     ║")
  table.insert(lines, "║  Press ? for command mode  •  :GeneroHelp to reopen  •  <Space> for which-key║")
  table.insert(lines, "╚══════════════════════════════════════════════════════════════════════════════╝")
  
  return lines
end

-- Close help window
function M.close()
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    vim.api.nvim_win_close(help_win, true)
  end
  help_win = nil
  help_buf = nil
end

-- Toggle help window
function M.toggle()
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    M.close()
  else
    M.show()
  end
end

-- Show help in floating window
function M.show()
  -- Close existing window if open
  M.close()
  
  -- Create buffer
  help_buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(help_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(help_buf, 'filetype', 'genero-help')
  vim.api.nvim_buf_set_option(help_buf, 'modifiable', false)
  
  -- Get help content
  local lines = format_help_lines()
  
  -- Set buffer content
  vim.api.nvim_buf_set_option(help_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(help_buf, 'modifiable', false)
  
  -- Calculate window size (80% of screen)
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  
  -- Calculate position (centered)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Window options
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Genero Tools Help ',
    title_pos = 'center',
  }
  
  -- Create window
  help_win = vim.api.nvim_open_win(help_buf, true, opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(help_win, 'cursorline', true)
  vim.api.nvim_win_set_option(help_win, 'wrap', false)
  vim.api.nvim_win_set_option(help_win, 'number', false)
  vim.api.nvim_win_set_option(help_win, 'relativenumber', false)
  
  -- Set up keybindings for the help window
  local opts_map = { noremap = true, silent = true, buffer = help_buf }
  vim.keymap.set('n', 'q', function() M.close() end, opts_map)
  vim.keymap.set('n', '<Esc>', function() M.close() end, opts_map)
  vim.keymap.set('n', '/', '/', opts_map)  -- Allow search
  vim.keymap.set('n', 'n', 'n', opts_map)  -- Next search result
  vim.keymap.set('n', 'N', 'N', opts_map)  -- Previous search result
  vim.keymap.set('n', 'j', 'j', opts_map)  -- Scroll down
  vim.keymap.set('n', 'k', 'k', opts_map)  -- Scroll up
  vim.keymap.set('n', '<Down>', 'j', opts_map)
  vim.keymap.set('n', '<Up>', 'k', opts_map)
  vim.keymap.set('n', 'G', 'G', opts_map)  -- Go to end
  vim.keymap.set('n', 'gg', 'gg', opts_map)  -- Go to beginning
  vim.keymap.set('n', '<C-d>', '<C-d>', opts_map)  -- Page down
  vim.keymap.set('n', '<C-u>', '<C-u>', opts_map)  -- Page up
  
  -- Set up syntax highlighting
  vim.cmd([[
    syntax match GeneroHelpHeader /^╔.*╗$/
    syntax match GeneroHelpHeader /^║.*║$/
    syntax match GeneroHelpHeader /^╚.*╝$/
    syntax match GeneroHelpCategory /^[A-Z][A-Z &/(),:]*:$/
    syntax match GeneroHelpSeparator /^─\+$/
    syntax match GeneroHelpKey /^\s\s\S\+\s\+/
    syntax match GeneroHelpCommand /:\w\+/
    syntax match GeneroHelpBullet /^\s\s•/
    
    highlight link GeneroHelpHeader Title
    highlight link GeneroHelpCategory Function
    highlight link GeneroHelpSeparator Comment
    highlight link GeneroHelpKey Identifier
    highlight link GeneroHelpCommand Keyword
    highlight link GeneroHelpBullet Special
  ]])
end

return M
