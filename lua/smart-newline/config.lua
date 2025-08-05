---@class Config
local M = {}

---@class options
---@field bracket_pairs table<string, string> Pairs of brackets to consider for smart newline behavior
---@field trigger string Key to trigger the smart newline behavior
M.options = {}

---@type options
local defaults = {
	bracket_pairs = {
		{ "{", "}" },
		{ "[", "]" },
		{ "(", ")" }
	},
	trigger = "o"
}

---@param options options|nil
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
