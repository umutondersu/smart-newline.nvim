local config = require("smart-newline.config")
local util = require("smart-newline.util")

---@class smart-newline
local M = {}

M.setup = config.setup

M.setup()

M.newline = function()
	local inside_tag = util.is_inside_tag()
	local inside_brackets = util.is_inside_brackets()
	if not (inside_brackets or (inside_tag and config.options.html_tags)) then
		vim.notify('outside brackets')
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(config.options.trigger, true, false, true),
			'n',
			false
		)
		return
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local indent = line:match("^%s*")
	local tab_size = vim.bo.shiftwidth or vim.bo.tabstop or 4
	local use_tabs = vim.bo.expandtab == false
	local inner_indent = indent .. (use_tabs and "\t" or string.rep(" ", tab_size))

	if inside_brackets then
		local before_cursor = line:sub(1, col):gsub("%s*$", "")
		local after_cursor = line:sub(col + 1):gsub("^%s*", "")
		vim.cmd("startinsert")
		local lines = { before_cursor, inner_indent .. " ", after_cursor }
		vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
		vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
	end
end


return M
