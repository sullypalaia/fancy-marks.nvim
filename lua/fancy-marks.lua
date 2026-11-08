local M = {}

local defaults = {
  use_default_mappings = true,
  width = "80%",
  height = "60%"
}

local config = vim.deepcopy(defaults)

---open a new popup with the global and local marks
function M.open_window()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()

  local global_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("^'[A-Z]$") ~= nil
  end, vim.fn.getmarklist())

  local buf = vim.api.nvim_get_current_buf()

  local local_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("^'[a-z]$") ~= nil
  end, vim.fn.getmarklist(buf))

  local Popup = require("nui.popup")
  local Layout = require("nui.layout")

  ---columns are created for both local and global marks separately
  ---@param title string
  ---@return NuiPopup
  local function create_column(title)
    return Popup({
      enter = false,
      buf_options = {
        modifiable = false
      },
      focusable = true,
      border = {
        style = "rounded",
        text = {
          top = " " .. title .. " ",
          top_align = "center",
        },
      },
    })
  end

  local left = create_column("Global marks")
  local right = create_column("Local marks")

  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = config.width,
      height = config.height,
    },
  }, Layout.Box({
    Layout.Box(left, { size = "50%" }),
    Layout.Box(right, { size = "50%" }),
  }, { dir = "row" }))

  local function buf_draw_marks(bufnr, marks)
    for _, mark in ipairs(marks) do
      vim.api.nvim_buf_set_lines(bufnr, _ - 1, _, false,
        { string.format("name: %s | row: %d | col: %d | filename: %s", mark.mark, mark.pos[2], mark.pos[3],
          mark.file or "(global)") })
    end
  end

  --draw local marks
  buf_draw_marks(left.bufnr, global_marks)

  --draw global marks
  buf_draw_marks(right.bufnr, local_marks)

  --mount the layout
  layout:mount()

  --focus the window
  vim.api.nvim_set_current_win(left.winid)

  --quit the window with q
  for _, win in ipairs({ left, right }) do
    vim.keymap.set("n", "q", function()
      layout:unmount()
    end, { buffer = win.bufnr, desc = "close fancy marks window" })
  end

  --disable <C-w> + kjlh
  for _, key in ipairs({ "k", "j", "l", "h" }) do
    vim.keymap.set("n", "<C-w>" .. key, function() end, { buffer = left.bufnr })
    vim.keymap.set("n", "<C-w>" .. key, function() end, { buffer = right.bufnr })
  end

  --use <C-w> + h to switch to the left window
  vim.keymap.set("n", "<C-w>h", function()
    vim.api.nvim_set_current_win(left.winid)
  end, { buffer = right.bufnr })

  --use <C-w> + l to switch to the right window
  vim.keymap.set("n", "<C-w>l", function()
    vim.api.nvim_set_current_win(right.winid)
  end, { buffer = left.bufnr })

  ---use <CR> to jump to a specific mark
  for _, win in ipairs({ left, right }) do
    vim.keymap.set("n", "<CR>", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(win.winid)
      local mark_line = vim.api.nvim_buf_get_lines(win.bufnr, cursor_pos[1] - 1, cursor_pos[1], false)[1]
      local mark_name = mark_line:match("name: '([A-Za-z])")

      --unmount layout and jump to the mark if it exists
      if mark_name and vim.api.nvim_win_is_valid(source_win) then
        layout:unmount()
        vim.api.nvim_set_current_win(source_win)
        vim.api.nvim_set_current_buf(source_buf)
        vim.cmd("normal! m'")
        vim.cmd("normal! `" .. mark_name)
      end
    end, { buffer = win.bufnr })
  end

  --use x to delete a mark
  for _, win in ipairs({ left, right }) do
    vim.keymap.set("n", "x", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(win.winid)
      local mark_line = vim.api.nvim_buf_get_lines(win.bufnr, cursor_pos[1] - 1, cursor_pos[1], false)[1]
      local mark_name = mark_line:match("name: '([A-Za-z])")

      if mark_name then
        vim.api.nvim_set_current_buf(source_buf)
        vim.cmd("delmarks " .. mark_name)
        vim.api.nvim_set_current_buf(win.bufnr)

        --temporary set the buffer to modifiable to remove the line
        vim.bo[win.bufnr].modifiable = true

        --remove the line
        vim.api.nvim_buf_set_lines(win.bufnr, cursor_pos[1] - 1, cursor_pos[1], false, {})

        vim.bo[win.bufnr].modifiable = false

        vim.notify("removed mark " .. mark_name .. " in buffer " .. source_buf, vim.log.levels.INFO,
          { title = "fancy-marks" })
      end
    end, { buf = win.bufnr })
  end
end

---@param opts {use_default_mappings: boolean, width: number, height: number} options
function M.setup(opts)
  --merge  user-defined opts with defaults
  config = vim.tbl_deep_extend("force", defaults, opts or {})

  --default keymaps
  if config.use_default_mappings == true then
    vim.keymap.set("n", "<Leader>mo", function() M.open_window() end,
      { desc = "open fancy marks window" })
  end
end

return M
