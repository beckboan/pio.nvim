local utils = require("pio.utils")
local plenary = require("plenary")
local popup = require("plenary.popup")
local states = require("pio.states")

local M = {}

local items = {
	"Build",
	"Upload",
	"Clean",
	"Libraries",
	"Platforms",
	"Devices",
	"Inspect",
}

Pio_win_id = nil
Pio_buf_id = nil

-- Generate a popup window when function is called
--

local function update_popup_buffer()
	vim.api.nvim_buf_set_lines(Pio_buf_id, 0, -1, true, items)
	plenary.nvim.async_call(function()
		popup.move(Pio_win_id, { contents = items, bufnr = Pio_buf_id })
	end)
end

local buildCallback = function()
	print("Build called")
end

local libCallback = function(line_num)
	states.update_state("Libraries")
	local val = states.menustates["Libraries"]
	local lib_items = {
		"Install Library",
		"Uninstall Library",
		"Update library",
	}
	if val == 1 then
		for _, item in ipairs(lib_items) do
			table.insert(items, line_num + 1, item)
			line_num = line_num + 1
		end
	else
		for _, item in ipairs(lib_items) do
			for i, v in ipairs(items) do
				if v == item then
					table.remove(items, i)
				end
			end
		end
	end
	update_popup_buffer()
end

local get_menu_item = function()
	local lines = vim.api.nvim_buf_get_lines(Pio_buf_id, 0, -1, true)

	local content = {}

	for _, line in pairs(lines) do
		table.insert(content, line)
	end

	return content
end

local menu_callback = function(sel)
	local line_con = get_menu_item()
	local cursor_pos = vim.api.nvim_win_get_cursor(sel)
	local line_number = cursor_pos[1]

	local text = line_con[line_number]

	if text == "Build" then
		buildCallback()
	elseif text == "Libraries" then
		libCallback(line_number)
	else
		print(text .. "option selected")
	end
end

local create_window = function(opts, cb)
	local height = 20
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
		callback = cb,
	}

	local win_id, win = popup.create(opts, popup_config)
	local buf_num = vim.api.nvim_win_get_buf(win_id)

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

	local menu_window = create_window(items, menu_callback)
	Pio_win_id = menu_window.menu_id
	Pio_buf_id = menu_window.buf_num
end

return M
