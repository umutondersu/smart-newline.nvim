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

		-- Find the last opening bracket before cursor
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
					return true
				end
			end
		end
	end

	return false
end

M.is_inside_tag = function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local before = line:sub(1, col)
	local after = line:sub(col + 1)

	-- Case 1: Check if cursor is inside a tag (like <div class="|">)
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
				return true
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

return M
