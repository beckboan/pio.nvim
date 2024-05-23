local M = {}

M.titles = {
	"Build",
	"Upload",
	"Clean",
	"Libraries",
	"Platforms",
	"Devices",
	"Inspect",
}

local pio_commands = {
	["access"] = { "grant", "list", "private", "public", "revoke", "-h", "--help" },
	["account"] = { "destroy", "forgot", "login", "logout", "password", "register", "show", "token", "-h", "--help" },
	["boards"] = { "--installed", "--json-output", "-h", "--help" },
	["check"] = {
		"--environment",
		"--project-dir",
		"--project-conf",
		"--pattern",
		"--flags",
		"--severity",
		"--silent",
		"--json-output",
		"--fail-on-defect",
		"--skip-packages",
		"-h",
		"--help",
	},
	["ci"] = {
		"--lib",
		"--exclude",
		"--board",
		"--build-dir",
		"--keep-build-dir",
		"--project-conf",
		"project-option",
		"--verbose",
		"-h",
		"--help",
	},
	["debug"] = {
		"--project-dir",
		"--project-conf",
		"--environment",
		"--load-mode",
		"--verbose",
		"--interface",
		"-h",
		"--help",
	},
	["device"] = { "list", "monitor", "-h", "--help" },
	["home"] = { "--port", "--host", "--no-open", "--shutdown-timeout", "--session-id", "-h", "--help" },
	["lib"] = {
		"builtin",
		"install",
		"list",
		"register",
		"search",
		"show",
		"stats",
		"uninstall",
		"update",
		"-h",
		"--help",
	},
	["org"] = { "add", "create", "destroy", "list", "remove", "update", "-h", "--help" },
	["pkg"] = {
		"exec",
		"install",
		"list",
		"outdated",
		"pack",
		"publish",
		"search",
		"show",
		"stats",
		"uninstall",
		"unpublish",
		"update",
		"-h",
		"--help",
	},
	["platform"] = { "frameworks", "install", "list", "search", "show", "uninstall", "update", "-h", "--help" },
	["project"] = { "config", "data", "init", "-h", "--help" },
	["remote"] = { "agent", "device", "run", "test", "update", "-h", "--help" },
	["run"] = {
		"--environment",
		"--target",
		"--upload-port",
		"--project-dir",
		"--project-conf",
		"--jobs",
		"--silent",
		"--verbose",
		"--disable-auto-clean",
		"--list-targets",
		"-h",
		"--help",
	},
	["settings"] = { "get", "reset", "set", "-h", "--help" },
	["system"] = { "info", "prune", "-h", "--help" },
	["team"] = { "add", "create", "destroy", "list", "remove", "update", "-h", "--help" },
	["test"] = {
		"-e",
		"-f",
		"-i",
		"--upload-port",
		"-d",
		"-c",
		"--without-building",
		"--without-uploading",
		"--without-testing",
		"--no-reset",
		"--monitor-rts",
		"--monitor-dtr",
		"-v",
		"-h",
		"--help",
	},
	["update"] = { "--core-packages", "--only-check", "--dry-run", "-h", "--help" },
	["upgrade"] = { "-h", "--help" },
}

local test =
	"Found 714 packages (page 1 of 72)\n\nmbed-phoenixunicamp/oJSON\nLibrary • 0.0.0+sha.ac1512fd0d1e • Published on Sat Nov 24 17:09:28 2012\nBasic Implementation of JSON.Capable of create a JSON string and parse a JSON string.Uses the lazy JSON implementation.Incapable of modify and delete variables from the objects.Contains 2 objects: JSONArray and JSONObject.Inspired in Java-Android implementation of JSON.Version 0.5.\n\nredhat2410/VhJson\nLibrary • 1.1.2 • Published on Wed May 31 07:41:45 2023\nVhJson is the easiest JSON manipulation library to parse or deserialize complex or nested JSON object and arrays."

M.parse_command = function(output)
	local data = {}
	local current_group = {}
	local empty_line_count = 0

	if output == nil then
		return
	end

	local output_string = ""
	if type(output) == "string" then
		output_string = output
	elseif type(output) == "table" then
		output_string = table.concat(output, "\n")
	else
		--TODO: Need to log here
	end

	-- for line in output:gmatch("([^\r\n]*[\r\n]?)") do
	for line in output_string:gmatch("([^\r\n]*[\r\n]?)") do
		if line == "\n" or line == "\r\n" then
			-- If an empty line is encountered, increment the empty line count
			empty_line_count = empty_line_count + 1
		else
			if empty_line_count > 0 then
				-- If there were empty lines before this line, add the current group to the data table
				table.insert(data, current_group)
				current_group = {} -- Reset the current group for the next set of lines
				empty_line_count = 0 -- Reset the empty line count
			end
			-- Add the line to the current group
			table.insert(current_group, line)
		end
	end

	-- Add the last group to the data table
	if #current_group > 0 then
		table.insert(data, current_group)
	end

	return data
end

M.run_pio_command = function(command)
	local full_command = "pio " .. command

	local file = io.popen(full_command)

	if not file then
		return nil
	end
	local output = file:read("*a")
	if not output then
		return nil
	end
	file:close()
	local lines = M.parse_command(output)

	return lines
end

return M
