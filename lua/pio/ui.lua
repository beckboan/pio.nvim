local utils = require("pio.utils")
local plenary = require("plenary")
local popup = require("plenary.popup")
local states = require("pio.states")
local nuipoup = require("nui.popup")
local layout = require("nui.layout")
local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event
local Tree = require("nui.tree")
local Line = require("nui.line")
local Text = require("nui.text")

-- mount the component

Pio_popup = nil

local M = {}

--
local create_menu = function()
	local poup = Menu({
		position = "50%",
		size = {
			width = 25,
			height = 10,
		},
		border = {
			style = "rounded",
			text = {
				top = "PIO NVIM Menu",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
		buf_options = {
			modifiable = false,
			readonly = true,
		},
	}, {
		lines = {
			Menu.separator("Commands", {
				char = "-",
				text_align = "center",
			}),
			Menu.item("Build"),
			Menu.item("Upload"),
			Menu.item("Clean"),
			Menu.separator("Libraries", {
				char = "-",
				text_align = "center",
			}),
			Menu.item("Install Library"),
			Menu.item("Uninstall Library"),
			Menu.item("Update library"),
			Menu.item("Platforms"),
			Menu.item("Devices"),
			Menu.item("Inspect"),
		},
		max_width = 30,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>" },
			submit = { "<CR>", "<Space>" },
		},
		on_close = function()
			print("Menu Closed!")
		end,
		on_submit = function(item)
			print("Menu Submitted: ", item.text)
		end,
	})

	poup:mount()

	local tree = Tree({
		winid = poup.winid,
	})

	-- popup:on({ event.BufWinLeave }, function()
	-- 	vim.schedule(function()
	-- 		popup:unmount()
	-- 	end)
	-- end, { once = true })

	return poup
end

local close_menu = function()
	if Pio_popup == nil then
		return
	end

	Pio_popup:unmount()
	Pio_popup = nil
end

--
M.toggle_menu = function()
	if Pio_popup ~= nil then
		close_menu()
		return
	end

	Pio_popup = create_menu()
end

return M
