local M = {}

local function getPIOIni(path)
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

function M.isPIOProject()
	local cwd = vim.fn.getcwd()
	if getPIOIni(cwd) then
		print("PlatformIO project detected")
		return true
	else
		print("Not a PlatformIO project")
		return false
	end
end

return M
