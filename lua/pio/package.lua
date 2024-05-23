local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values

local commands = require("pio.commands")

-- Function to search for packages
local search_pkg = function(name, args, cmds, page)
	name = name or ""
	args = args or ""
	cmds = cmds or ""
	page = page or 1
	local command = "pkg search '" .. args .. " " .. name .. "' " .. cmds .. " -p " .. page
	local vals = commands.run_pio_command(command)

	if vals == nil or #vals == 0 then
		return {}, 0, 0
	end

	local first_line = vals[1][1]
	local total_packages, current_page, total_pages = first_line:match("Found (%d+) packages %(page (%d+) of (%d+)%)")

	total_packages = tonumber(total_packages)
	current_page = tonumber(current_page)
	total_pages = tonumber(total_pages)

	local packages = {}
	for i = 2, #vals do -- Start from the second entry
		table.insert(packages, vals[i][1])
	end

	return packages, total_packages, total_pages
end

-- Function to fetch packages asynchronously and update picker
local live_lib_search = function(opts, name)
	opts = opts or {}

	if type(name) ~= "string" then
		return
	end

	local packages, total_packages, total_pages = search_pkg(name, "type:library", "-s popularity", 1)

	if #packages == 0 then
		print("No entries found")
		return
	end

	-- Picker setup
	local entries = {}
	local picker = pickers.new(opts, {
		prompt_title = "PIO Command",
		finder = finders.new_table({
			results = { "Loading..." },
		}),
		sorter = conf.generic_sorter(opts),
		previewer = previewers.new_buffer_previewer({
			title = "Library Preview",
			define_preview = function(self, entry, status)
				local package_name = entry.value
				local command = { "pio", "pkg", "show", package_name }

				-- Run the command asynchronously
				local function on_output(job_id, data, event)
					if package_name == "Loading..." then
						if vim.api.nvim_buf_is_valid(self.state.bufnr) then
							vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Loading..." })
						end
					else
						if event == "stdout" and #data > 0 then
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
							--TODO: Log error
						end
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
								)
							end
						end
					end,
				})

				--TODO: Log job
			end,
		}),
	})

	local function fetch_page(page)
		local command = "pio pkg search 'type:library " .. name .. "' -s popularity -p " .. page
		vim.fn.jobstart(command, {
			stdout_buffered = true,
			on_stdout = function(_, data, _)
				local parsed_data = commands.parse_command(data)

				if #parsed_data > 0 then
					local new_packages = {}
					for i = 2, #parsed_data do -- Start from the second entry
						if parsed_data[i][1] ~= "" or nil then
							table.insert(new_packages, parsed_data[i][1])
						end
					end
					--TODO: Log package  results
					for _, pkg in ipairs(new_packages) do
						if not vim.tbl_contains(entries, pkg) then
							table.insert(entries, pkg)
						end
					end

					picker:refresh(
						finders.new_table({
							results = entries,
						}),
						{
							reset_prompt = false,
						}
					)
				end
			end,
			on_stderr = function(job_id, data, event)
				if #data > 0 then
					-- TODO: Log error
				end
			end,
		})
	end
	local function fetch_remaining_pages()
		local max_coroutines = 10
		local active_coroutines = 0
		local page = 1
		while page <= total_pages do
			while active_coroutines >= max_coroutines do
				coroutine.yield()
			end
			coroutine.wrap(function()
				active_coroutines = active_coroutines + 1
				fetch_page(page)
				active_coroutines = active_coroutines - 1
			end)()
			page = page + 1
		end
	end
	picker:find()
	-- Fetch remaining pages
	fetch_remaining_pages()
end
-- Function to fetch remaining pages asynchronously

local test_lib = function()
	local results = { "test1", "test2", "test3", "test4" }
	live_lib_search({}, results)
end

live_lib_search(require("telescope.themes").get_dropdown({}), "json")

-- test_lib()
