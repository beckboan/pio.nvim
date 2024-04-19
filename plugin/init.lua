print("Hello from pio.nvim plugin")
local pio = require("pio.init")

if vim.g.loaded_pio_nvim then
	return
end

pio.setup()

vim.g.loaded_pio_nvim = true
