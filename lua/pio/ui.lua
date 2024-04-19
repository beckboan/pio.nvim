local utils = require("pio.utils")
local popup = require("plenary.popup")

local M = {}

Pio_menu_id = nil
Pio_buf_id = nil

-- Generate a popup window when function is called

local create_menu = function()
	local height = 30
	local width = 100

	local popup_config = {
		relative = "editor",
		title = "PlatformIO NVIM",
		width = 30,
		height = 30,
		row = vim.o.lines / 2 - height / 2,
		col = vim.o.columns / 2 - width / 2,
		border = "single",
	}

	local buf_num = vim.api.nvim_create_buf(false, false)
	local win_id = vim.api.nvim_open_win(buf_num, true, popup_config)

	-- local Pio_menu_id = popup.create(buf_num, popup_config)

	return {
		buf_num = buf_num,
		menu_id = win_id,
	}
end

local close_menu = function()
	vim.api.nvim_win_close(Pio_menu_id, true)
end

M.toggle_menu = function()
	if Pio_menu_id ~= nil and vim.api.nvim_win_is_valid(Pio_menu_id) then
		close_menu()
		return
	end

	local menu_window = create_menu()
	Pio_menu_id = menu_window.menu_id
	Pio_buf_id = menu_window.buf_num
end

return M
