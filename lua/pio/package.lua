local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local commands = require("pio.commands")

local utils = require("pio.utils")

local live_lib_search = function(opts, results)
	opts = opts or {}
	results = results or {}

	if type(results) ~= "table" then
		results = {}
	end

	pickers
		.new(opts, {
			prompt_title = "PIO Command",
			finder = finders.new_table({
				results = results,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

local search_library = function(name)
	local command = "pkg search 'type:library " .. name .. "'"
	local vals = commands.run_pio_command(command)

	print(vals[1][1])

	local entries = {}

	for i, group in ipairs(vals) do
		table.insert(entries, group[1])
	end

	live_lib_search(require("telescope.themes").get_dropdown({}), entries)
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

search_library("json")
-- test_lib()
