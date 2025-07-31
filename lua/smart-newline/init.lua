local config = require("smart-newline.config")

---@class buffer-vacuum
local M = {}

M.config = config
M.setup = M.config.setup

function M.is_enabled()
	return config.options.enabled
end

M.setup()

return M
