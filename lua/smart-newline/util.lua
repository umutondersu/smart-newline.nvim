local config = require('smart-newline.config')

---@class util
local M = {}

M.is_inside_brackets = function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local before = line:sub(1, col)
	local after = line:sub(col + 1)

	-- Check for each bracket type
	local bracket_pairs = config.options.bracket_pairs

	for _, pair in ipairs(bracket_pairs) do
		local open_char, close_char = pair[1], pair[2]

		-- Find the last opening bracket before cursor (including at cursor position)
		local last_open = before:match(".*()%" .. open_char)
		if last_open then
			-- Find the first closing bracket after cursor
			local first_close = after:match("()%" .. close_char)
			if first_close then
				-- Check if there's a closing bracket between the opening bracket and cursor
				local between = before:sub(last_open + 1)
				local has_close_between = between:match("%" .. close_char)

				-- If no closing bracket between, we're inside this bracket pair
				if not has_close_between then
					-- Check if content between opening bracket and closing bracket is only whitespace
					local content_from_open = before:sub(last_open + 1)
					local content_to_close = after:sub(1, first_close - 1)
					local total_content = content_from_open .. content_to_close
					if total_content:match("^%s*$") then
						return true
					end
				end
			end
		end
	end

	return false, nil
end

M.is_inside_tag = function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local before = line:sub(1, col)
	local after = line:sub(col + 1)

	-- Case 1: Check if cursor is inside a tag (like <div class="|">)
	-- Only return true if there's a corresponding closing tag on the same line
	-- Find the last < before cursor
	local last_open = before:match(".*()<")
	if last_open then
		-- Find the first > after cursor
		local first_close = after:match("()>")
		if first_close then
			-- Check if there's a closing > between the < and cursor
			local between = before:sub(last_open + 1)
			local has_close_between = between:match(">")

			-- If no closing > between, we're inside a tag
			if not has_close_between then
				-- Check if this is a self-closing tag by looking for /> pattern
				local tag_content = before:sub(last_open + 1) .. after:sub(1, first_close - 1)
				if tag_content:match("/%s*$") then
					-- This is a self-closing tag, return false
					return false
				end

				-- Extract the tag name to check for corresponding closing tag
				local tag_name = tag_content:match("^%s*([%w%-]+)")
				if tag_name then
					-- Look for the closing tag after this opening tag on the same line
					local after_opening_tag = after:sub(first_close + 1)
					local closing_pattern = "</%s*" .. tag_name .. "%s*>"
					if after_opening_tag:match(closing_pattern) then
						return true
					end
				end

				-- No corresponding closing tag found, return false
				return false
			end
		end
	end

	-- Case 2: Check if cursor is between opening and closing tags (like <button>|</button>)
	-- Find the last > before cursor (end of opening tag)
	local last_tag_end = before:match(".*()>")
	if last_tag_end then
		-- Find the first < after cursor (start of closing tag)
		local first_tag_start = after:match("()<")
		if first_tag_start then
			-- Check if there's a < between the > and cursor
			local between_tags = before:sub(last_tag_end + 1)
			local has_tag_between = between_tags:match("<")

			-- If no < between, we might be between tags
			if not has_tag_between then
				-- Extract the opening tag name from before the last >
				local tag_section = before:sub(1, last_tag_end)
				local opening_tag = tag_section:match("<([%w%-]+)[^>]*>$")

				if opening_tag then
					-- Check if the next tag is a closing tag for the same element
					-- Allow optional whitespace before the closing tag
					local closing_tag = after:match("^%s*</" .. opening_tag .. "%s*>")
					if closing_tag then
						return true
					end
				end
			end
		end
	end

	return false
end

---Calculate indentation strings for the current buffer
---@return string, string # base_indent, inner_indent
M.calculate_indentation = function()
	local line = vim.api.nvim_get_current_line()
	local indent = line:match("^%s*")
	local tab_size = vim.bo.shiftwidth or vim.bo.tabstop or 4
	local use_tabs = vim.bo.expandtab == false
	local inner_indent = indent .. (use_tabs and "\t" or string.rep(" ", tab_size))

	return indent, inner_indent
end

---Get cursor position and line content
---@return number, number, string # row, col, line
M.get_cursor_info = function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	return row, col, line
end

---Split line content around cursor position
---@param line string
---@param col number
---@return string, string # before_cursor, after_cursor
M.split_line_at_cursor = function(line, col)
	local before_cursor = line:sub(1, col):gsub("%s*$", "")
	local after_cursor = line:sub(col + 1):gsub("^%s*", "")
	return before_cursor, after_cursor
end

---Check if position is within a range
---@param pos number
---@param start_pos number|nil
---@param end_pos number|nil
---@return boolean
M.in_range = function(pos, start_pos, end_pos)
	if not start_pos or not end_pos then
		return false
	end
	return pos >= start_pos and pos <= end_pos
end

---Position cursor relative to HTML tags if needed
---@param row number
---@param col number
---@param line string
---@return number, number, string # updated row, col, line
M.position_cursor_for_tags = function(row, col, line)
	local open_tag_start, open_tag_end = line:find("<[^>]->")
	local close_tag_start, close_tag_end = line:find("</[^>]->")
	local cursor_pos = col + 1

	if M.in_range(cursor_pos, open_tag_start, open_tag_end) then
		-- Cursor inside opening tag: move cursor just after '>'
		vim.api.nvim_win_set_cursor(0, { row, open_tag_end })
		col = open_tag_end or 0
	elseif M.in_range(cursor_pos, close_tag_start, close_tag_end) then
		-- Cursor inside closing tag: move cursor just before '<'
		vim.api.nvim_win_set_cursor(0, { row, close_tag_start - 1 })
		col = close_tag_start - 1
	end

	-- Re-fetch line and cursor position after possibly moving cursor
	line = vim.api.nvim_get_current_line()
	row, col = unpack(vim.api.nvim_win_get_cursor(0))

	return row, col, line
end

---Handle newline insertion for brackets
---@param row number
---@param col number
---@param line string
M.handle_bracket_newline = function(row, col, line)
	local indent, inner_indent = M.calculate_indentation()
	local before_cursor, after_cursor = M.split_line_at_cursor(line, col)

	vim.cmd("startinsert")
	local lines = { before_cursor, inner_indent .. " ", indent .. after_cursor }
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
end

---Handle newline insertion for HTML tags
---@param row number
---@param col number
---@param line string
M.handle_tag_newline = function(row, col, line)
	local indent, inner_indent = M.calculate_indentation()

	-- Position cursor appropriately relative to tags
	row, col, line = M.position_cursor_for_tags(row, col, line)

	local before_cursor, after_cursor = M.split_line_at_cursor(line, col)
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

---Handle fallback trigger when not inside brackets or tags
M.handle_fallback_trigger = function()
	if config.options.trigger then
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(config.options.trigger, true, false, true),
			'n',
			false
		)
	end
end

return M
