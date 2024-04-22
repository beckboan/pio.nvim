M = {}

M.menustates = {
	["Build"] = -1, -- Build
	["Upload"] = -1, -- Upload
	["Clean"] = -1, -- Clean
	["Libraries"] = 0, -- Libraries
	["Platforms"] = 0, -- Plaforms
	["Devices"] = 0, -- Devices
	["Inspect"] = 0, -- Inspect
}

M.update_state = function(key)
	if M.menustates[key] == 0 then
		M.menustates[key] = 1
	elseif M.menustates[key] == 1 then
		M.menustates[key] = 0
	else
		M.menustates[key] = -1
	end
end

return M
