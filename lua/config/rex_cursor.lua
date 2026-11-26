-- Rex draws the cursor in its theme's colour and ignores the colour Neovim asks
-- for. Hide the terminal cursor and draw a block in the mode's colour instead,
-- blinking in insert mode. The command line and terminal mode keep Rex's cursor.
local ns = vim.api.nvim_create_namespace("rex_cursor")
local group = vim.api.nvim_create_augroup("rex_cursor", { clear = true })
local timer = assert(vim.uv.new_timer())
local marked_buf

-- Cursor highlight by the first character of the mode name
local highlights = {
  n = "nCursor",
  i = "iCursor",
  R = "rCursor",
  v = "vCursor",
  V = "vCursor",
  ["\22"] = "vCursor", -- visual block
  s = "vCursor",
  S = "vCursor",
  ["\19"] = "vCursor", -- select block
}

local function mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1)
end

local function clear()
  if marked_buf and vim.api.nvim_buf_is_valid(marked_buf) then
    vim.api.nvim_buf_clear_namespace(marked_buf, ns, 0, -1)
  end
  marked_buf = nil
end

local function draw()
  clear()
  local highlight = highlights[mode()]
  if not highlight then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local char = vim.fn.strcharpart(line:sub(col + 1), 0, 1)
  if char == "" or char == "\t" then
    char = " "
  end
  vim.api.nvim_buf_set_extmark(buf, ns, row - 1, col, {
    virt_text = { { char, highlight } },
    virt_text_pos = "overlay",
    priority = 10000,
  })
  marked_buf = buf
end

-- Draw the block and, in insert mode, alternate it off and on. Restarted
-- whenever the cursor moves, so it stays solid while typing.
local function refresh()
  timer:stop()
  draw()
  if mode() ~= "i" then
    return
  end
  local visible = true
  local function step(delay)
    timer:start(
      delay,
      0,
      vim.schedule_wrap(function()
        if mode() ~= "i" then
          return
        end
        visible = not visible
        if visible then
          draw()
        else
          clear()
        end
        step(visible and 400 or 250)
      end)
    )
  end
  step(700)
end

local function stop()
  timer:stop()
  clear()
end

-- A cursor highlight with blend=100 hides the terminal cursor
local function set_hidden_highlight()
  vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })
end

set_hidden_highlight()
vim.opt.guicursor:append("n-v-ve-i-r-o-sm:block-HiddenCursor")

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_hidden_highlight })
vim.api.nvim_create_autocmd({
  "ModeChanged",
  "CursorMoved",
  "CursorMovedI",
  "TextChanged",
  "TextChangedI",
  "TextChangedP",
  "BufEnter",
  "WinEnter",
}, {
  group = group,
  -- Scheduled so the cursor is at its final position
  callback = function()
    vim.schedule(refresh)
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "CmdlineEnter", "TermEnter", "VimLeavePre" }, {
  group = group,
  callback = stop,
})
vim.schedule(refresh)
