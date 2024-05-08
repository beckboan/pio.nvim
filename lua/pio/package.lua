local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local commands = require("pio.commands")

local menu = function(opts, results)
	opts = opts or {}
	-- local vals = commands.run_pio_command("pkg search 'type:library'")
	results = results or {}
	-- for _, val in ipairs(vals) do
	-- 	table.insert(results, { value = val })
	-- end

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

menu(require("telescope.themes").get_dropdown({}))

local search_library = function(name)
	local vals = commands.run_pio_command("pkg search 'type:library .. name'")

	menu({}, vals)
end

local test_lib = function()
	local results = {
		"test1",
		"test2",
		"test3",
		"test4",
	}
	menu({}, results)
end

search_library("json")
