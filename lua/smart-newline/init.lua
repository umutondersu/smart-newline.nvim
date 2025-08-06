local config = require("smart-newline.config")
local util = require("smart-newline.util")

---@class smart-newline
local M = {}

M.setup = config.setup

M.newline = function()
    local inside_tag = util.is_inside_tag() and config.options.html_tags.enabled
    local inside_brackets = util.is_inside_brackets()
        and config.options.brackets.enabled

    if not (inside_brackets or inside_tag) then
        util.handle_fallback_trigger()
        return
    end

    local row, col, line = util.get_cursor_info()

    if inside_brackets then
        util.handle_bracket_newline(row, col, line)
    elseif inside_tag then
        util.handle_tag_newline(row, col, line)
    end
end

return M
