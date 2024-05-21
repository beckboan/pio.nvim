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
local parse_command = function(output)
	local data = {}
	local current_group = {}

	for line in output:gmatch("[^\r\n]+") do
		if line == "" then
			if #current_group > 0 then
				table.insert(data, current_group)
				current_group = {} -- Reset the current group for the next set of lines
			end
		else
			table.insert(current_group, line)
		end
	end

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
	local lines = parse_command(output)

	return lines
end

return M
