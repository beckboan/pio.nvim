local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local commands = require("pio.commands")

local utils = require("pio.utils")

local search_pkg = function(name, args, cmds)
	name = name or ""
	args = args or ""
	cmds = cmds or ""
	local command = "pkg search '" .. args .. " " .. name .. "'" .. " " .. cmds
	local vals = commands.run_pio_command(command)

	if vals == nil then
		return
	end

	return vals
end

local live_lib_search = function(opts, name)
	opts = opts or {}

	if type(name) ~= "string" then
		return
	end

	local vals = search_pkg(name, "type:library", "-s popularity")

	local entries = {}

	for _, group in ipairs(vals) do
		table.insert(entries, group[1])
	end

	if #entries == 0 then
		print("No entries found")
		return
	end

	pickers
		.new(opts, {
			prompt_title = "PIO Command",
			finder = finders.new_table({
				results = entries,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

local test_lib = function()
	local results = {
		"test1",
		"test2",
		"test3",
		"test4",
	}
	live_lib_search({}, results)
end

live_lib_search(require("telescope.themes").get_dropdown({}), "json")

-- test_lib()
