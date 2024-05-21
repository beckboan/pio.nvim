local M = {}

M.get_pio_ini = function(path)
	local target = "platformio.ini"
	-- Check if the target exists in the path directory
	local targetPath = path .. "/" .. target
	local exists = vim.fn.filereadable(targetPath)

	if exists == 1 then
		return targetPath
	else
		return nil
	end
end

M.is_pio_project = function()
	local cwd = vim.fn.getcwd()
	if M.get_pio_ini(cwd) then
		print("PlatformIO project detected")
		return true
	else
		print("Not a PlatformIO project")
		return false
	end
end

M.dump = function(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

return M
