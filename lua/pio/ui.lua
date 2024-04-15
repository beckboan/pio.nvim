local utils = require("pio.utils")
local popup = require("plenary.popup")

local M = {}

-- Generate a popup window when function is called

M.generate_popup = function()
	local popup_config = {
		title = "PlatformIO NVIM",
		line = 10,
		col = 10,
		max_width = 500,
		max_height = 100,
		border = {},
	}

	local popup_win = popup.create("TEST", popup_config)
end

return M
