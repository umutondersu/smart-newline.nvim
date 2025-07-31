---@class Config
local M = {}

---@class options
---@field enabled boolean Enable or disable the plugin
M.options = {}

---@type options
local defaults = {
	enabled = false,
}

---@param options options|nil
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
