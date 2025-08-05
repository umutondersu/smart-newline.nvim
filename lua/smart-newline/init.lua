local config = require("smart-newline.config")
local util = require("smart-newline.util")

---@class smart-newline
local M = {}

M.setup = config.setup

M.setup()

M.newline = function()
	local inside_tag = util.is_inside_tag() and config.options.html_tags.enabled
	local inside_brackets = util.is_inside_brackets() and config.options.brackets.enabled

	if not (inside_brackets or inside_tag) then
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
		local lines = { before_cursor, inner_indent .. " ", indent .. after_cursor }
		vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
		vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
	elseif inside_tag then
		local function in_range(pos, start_pos, end_pos)
			return start_pos and end_pos and pos >= start_pos and pos <= end_pos
		end

		local open_tag_start, open_tag_end = line:find("<[^>]->")
		local close_tag_start, close_tag_end = line:find("</[^>]->")

		local cursor_pos = col + 1

		if in_range(cursor_pos, open_tag_start, open_tag_end) then
			-- Cursor inside opening tag: move cursor just after '>'
			vim.api.nvim_win_set_cursor(0, { row, open_tag_end })
			col = open_tag_end or 0
		elseif in_range(cursor_pos, close_tag_start, close_tag_end) then
			-- Cursor inside closing tag: move cursor just before '<'
			vim.api.nvim_win_set_cursor(0, { row, close_tag_start - 1 })
			col = close_tag_start - 1
		end

		-- Re-fetch line and cursor position after possibly moving cursor
		line = vim.api.nvim_get_current_line()
		row, col = unpack(vim.api.nvim_win_get_cursor(0))

		local before_cursor = line:sub(1, col):gsub("%s*$", "")
		local after_cursor = line:sub(col + 1):gsub("^%s*", "")

		local after_cursor_trimmed = after_cursor:gsub("^%s*", "")
		local closing_tag_line = indent .. after_cursor_trimmed

		local lines = {
			before_cursor,
			inner_indent .. " ",
			closing_tag_line,
		}

		vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
		vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
		vim.cmd("startinsert")
	end
end

return M
