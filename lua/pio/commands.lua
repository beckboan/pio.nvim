local M = {}

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

M.run_pio_command = function(command)
	local full_command = "pio " .. command
	local output = vim.fn.system(full_command)

	if vim.v.shell_error ~= 0 then
		print("Error running command: " .. full_command)
		print("Output: " .. output)
	end

	for _, line in ipairs(vim.fn.split(output, "\n")) do
		print(line)
	end
end

return M
