local M = {}

M.run_pio_command = function(command)
	local full_command = "pio " .. command
	local output = vim.fn.system(full_command)

	if vim.v.shell_error ~= 0 then
		print("Error running command: " .. full_command)
		print("Output: " .. output)
	end

	for _, line in ipairs(vim.fn.split(output, "\n")) do
		print(line)
	end
end

print("Ok, loaded from pio.nvim")

return M
