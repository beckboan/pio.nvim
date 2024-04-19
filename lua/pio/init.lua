local utils = require("pio.utils")
local ui = require("pio.ui")

local M = {}

M.setup = function()
	vim.keymap.set("n", "<C-p>", '<Cmd>lua require("pio.ui").toggle_menu()<CR>')
end

return M
