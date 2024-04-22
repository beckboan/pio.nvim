local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local menu = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "PIO Command",
			finder = finders.new_table({
				results = {
					"Install Library",
					"Uninstall Library",
					"Update library",
				},
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

menu(require("telescope.themes").get_dropdown({}))

M = {}

return M
