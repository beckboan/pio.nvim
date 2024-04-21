local utils = require("pio.utils")
local popup = require("plenary.popup")

local M = {}

Pio_win_id = nil
Pio_buf_id = nil

-- Generate a popup window when function is called

local create_window = function(opts)
	local height = 10
	local width = 60
	local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

	local popup_config = {
		title = "PIO-NVIM",
		highlight = false,
		-- highlight = "PIO-NVIMWindow",
		line = math.floor((vim.o.lines - height) / 2 - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
		enter = true,
	}

	local buf_num = vim.api.nvim_create_buf(false, false)
	-- local win_id = vim.api.nvim_open_win(buf_num, true, popup_config)

	local win_id, win = popup.create(buf_num, popup_config)

	return {
		buf_num = buf_num,
		menu_id = win_id,
	}
end

local close_window = function()
	vim.api.nvim_win_close(Pio_win_id, true)
	Pio_win_id = nil
	Pio_buf_id = nil
end

M.toggle_menu = function()
	if Pio_win_id ~= nil and vim.api.nvim_win_is_valid(Pio_win_id) then
		close_window()
		return
	end

	local menu_window = create_window()
	Pio_win_id = menu_window.menu_id
	Pio_buf_id = menu_window.buf_num
end

return M
