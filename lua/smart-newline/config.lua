---@class Config
local M = {}

---@class options
---@field bracket_pairs table<string, string> Pairs of brackets to consider for smart newline behavior
---@field trigger string Key to trigger the smart newline behavior
---@field html_tags table<string, boolean> Whether to consider HTML tags for smart newline behavior
---@field brackets table<string, boolean> Pairs of brackets to consider for smart newline behavior
M.options = {}

---@type options
local defaults = {
	bracket_pairs = {
		{ "{", "}" },
		{ "[", "]" },
		{ "(", ")" }
	},
	trigger = "W",
	html_tags = { enabled = true },
	brackets = { enabled = true }
}

---@param options options|nil
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
	vim.keymap.set(
		"n",
		M.options.trigger,
		function() require("smart-newline").newline() end,
		{ noremap = true, silent = true }
	)
end

return M
