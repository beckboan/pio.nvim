local pio = require("pio")
local popup = require("plenary.popup")

local M = {}

pio_window_id = nil
pio_bufh = nil

local function create_window()
	local width = 80
	local height = 20
	local borderchars = {
		{ "─", "FloatBorder" },
		{ "│", "FloatBorder" },
		{ "─", "FloatBorder" },
		{ "│", "FloatBorder" },
		{ "┌", "FloatBorder" },
		{ "┐", "FloatBorder" },
		{ "┘", "FloatBorder" },
		{ "└", "FloatBorder" },
	}
	local buffer_nr = vim.api.nvi_create_bug(false, false)

	local pio_window_id, win = popup.create(bufnr, {
		title = "pio",
		highlight = "pio-window",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Norma:PioBorder")

	return {
		bufnr = bufnr,
		win_id = pio_window_id,
	}
end
