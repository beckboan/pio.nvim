local utils = require("pio.utils")

local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event
local Tree = require("nui.tree")
local Line = require("nui.line")
local Text = require("nui.text")

Pio_popup = nil

local M = {}

local menuitems = {
	Boards = {
		"List",
		"Add",
	},
	Libraries = {
		"Install",
		"Uninstall",
		"Update",
	},
	Platforms = {
		"Install",
		"Uninstall",
		"Update",
	},
	Devices = {
		"List",
		"Monitor",
	},
	Inspect = {
		"Environment",
		"Inspect Memory",
		"Check Code",
	},
}

local get_menu_nodes = function(menu_items)
	local nodes = {}

	if menu_items == nil then
		return nodes
	end

	for category, items in pairs(menu_items) do
		local subnodes = {}
		for _, item in ipairs(items) do
			table.insert(subnodes, Tree.Node({ text = item }))
		end
		table.insert(nodes, Tree.Node({ text = category }, subnodes))
	end
	return nodes
end
--
local create_menu = function()
	local popup = Popup({
		enter = true,
		position = "50%",
		size = {
			width = "30%",
			height = "30%",
		},
		border = {
			style = "rounded",
			text = {
				top = "PIO NVIM Menu",
			},
		},
		buf_options = {
			readonly = true,
			modifiable = false,
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	})
	popup:mount()

	popup:on({ event.BufWinLeave }, function()
		vim.schedule(function()
			popup:unmount()
		end)
	end, { once = true })

	local tree = Tree({
		winid = popup.winid,
		nodes = get_menu_nodes(menuitems),

		prepare_node = function(node)
			local line = Line()
			if node:has_children() then
				line:append(node:is_expanded() and "˅" or "˃", "SpecialChar")
				line:append(node.text)

				return line
			end

			line:append("  ")
			line:append(node.text)

			return line
		end,
	})

	local map_options = { remap = false, nowait = true }

	popup:map("n", { "q", "<esc>" }, function()
		popup:unmount()
	end, map_options)

	-- collpase
	popup:map("n", "h", function()
		local node, linenr = tree:get_node()
		if not node:has_children() then
			node, linenr = tree:get_node(node:get_parent_id())
		end
		if node and node:collapse() then
			vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
			tree:render()
		end
	end, map_options)

	-- expand
	popup:map("n", "l", function()
		local node, linenr = tree:get_node()
		if not node:has_children() then
			node, linenr = tree:get_node(node:get_parent_id())
		end
		if node and node:expand() then
			if not node.checked then
				node.checked = true

				vim.schedule(function()
					for _, n in ipairs(tree:get_nodes(node:get_id())) do
					end
					tree:render()
				end)
			end

			vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
			tree:render()
		end
	end, map_options)

	popup:map("n", "<Enter>", function()
		local node, linenr = tree:get_node()
		if node and node:has_children() then
			if node:is_expanded() then
				node:collapse()
				print("Closing")
				vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
				tree:render()
			else
				node:expand()
				print("Opening")
				if not node.checked then
					node.checked = true

					vim.schedule(function()
						tree:render()
					end)
				end

				vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
				tree:render()
			end
		end
	end, map_options)

	tree:render()

	return popup
end

local close_menu = function()
	if Pio_popup == nil then
		return
	end

	Pio_popup:unmount()
	Pio_popup = nil
end

--
M.toggle_menu = function()
	if Pio_popup ~= nil then
		close_menu()
		return
	end

	Pio_popup = create_menu()
end

return M
