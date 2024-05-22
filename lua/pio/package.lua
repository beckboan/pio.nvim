local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
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
			previewer = previewers.new_buffer_previewer({
				title = "Library Preview",
				define_preview = function(self, entry)
					local package_name = entry.value
					local command = { "pio", "pkg", "show", package_name } -- Command to get package details

					--TODO: ADD LOG STATEMENTS FOR COMMAND RUN

					local function on_output(job_id, data, event)
						if event == "stdout" and #data > 0 then
							--Removing empty lines from data

							local non_empty_lines = {}
							for _, line in ipairs(data) do
								if line ~= "" then
									table.insert(non_empty_lines, line)
								end
							end

							if vim.api.nvim_buf_is_valid(self.state.bufnr) then
								vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, non_empty_lines)
								require("telescope.previewers.utils").highlighter(self.state.bufnr, "plaintext")
							end
						elseif event == "stderr" and #data > 0 then
							--TODO: ADD LOG STATEMENTS FOR STD ERR
						end
					end

					local job_id = vim.fn.jobstart(command, {
						stdout_buffered = true,
						on_stdout = on_output,
						on_stderr = on_output,
						on_exit = function(job_id, exit_code, event)
							if exit_code ~= 0 then
								if vim.api.nvim_buf_is_valid(self.state.bufnr) then
									vim.api.nvim_buf_set_lines(
										self.state.bufnr,
										0,
										-1,
										false,
										{ "Error: failed to retrieve package details" }
										--TODO: ADD LOG STATEMENTS FOR DETAIL FAILURE
									)
								end
							end
						end,
					})

					--TODO: ADD LOG STATEMENTS FOR JOB
				end,
			}),
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
