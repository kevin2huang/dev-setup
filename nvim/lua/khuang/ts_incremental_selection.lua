-- Treesitter incremental selection.
--
-- The nvim-treesitter `main` branch removed the built-in `incremental_selection`
-- module with no core replacement, so this reimplements it on top of Neovim's
-- `vim.treesitter` API. Maintains a per-window stack of selected nodes so that
-- expand/shrink walk up and down the syntax tree.
--
--   init_selection    select the node under the cursor
--   node_incremental  expand selection to the parent node
--   scope_incremental expand to the nearest enclosing multi-line ("scope") node
--   node_decremental  shrink to the previously selected node
local M = {}

-- Stack of { srow, scol, erow, ecol } ranges, keyed by window id.
local stacks = {}

-- Visually select a 0-indexed, end-exclusive range (treesitter's convention).
local function select_range(range)
	local srow, scol, erow, ecol = range[1], range[2], range[3], range[4]

	-- An end column of 0 means the range ends at the start of `erow`, i.e. it
	-- really covers up to the end of the previous line.
	if ecol == 0 and erow > srow then
		erow = erow - 1
		ecol = #vim.api.nvim_buf_get_lines(0, erow, erow + 1, true)[1]
	end

	-- Leave any current visual mode so the marks are set fresh.
	if vim.fn.mode():match("[vV\22]") then
		vim.cmd("normal! \27")
	end

	vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
	vim.cmd("normal! v")
	-- end is exclusive, so the last selected byte is at ecol - 1.
	vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
end

local function node_range(node)
	local srow, scol, erow, ecol = node:range()
	return { srow, scol, erow, ecol }
end

local function ranges_equal(a, b)
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

function M.init_selection()
	local node = vim.treesitter.get_node()
	if not node then
		return
	end
	stacks[vim.api.nvim_get_current_win()] = { node_range(node) }
	select_range(node_range(node))
end

-- Walk up to the first ancestor whose range is strictly larger than `range`.
local function parent_beyond(node, range)
	local parent = node:parent()
	while parent do
		local prange = node_range(parent)
		if not ranges_equal(prange, range) then
			return parent, prange
		end
		parent = parent:parent()
	end
	return nil
end

function M.node_incremental()
	local win = vim.api.nvim_get_current_win()
	local stack = stacks[win]
	if not stack or #stack == 0 then
		return M.init_selection()
	end

	local top = stack[#stack]
	local node = vim.treesitter.get_node({ pos = { top[1], top[2] } })
	if not node then
		return
	end
	-- Climb to the node matching the current selection, then go one larger.
	while node and not ranges_equal(node_range(node), top) do
		node = node:parent()
	end
	if not node then
		return
	end

	local parent, prange = parent_beyond(node, top)
	if not parent then
		return -- already at the root
	end
	table.insert(stack, prange)
	select_range(prange)
end

function M.scope_incremental()
	local win = vim.api.nvim_get_current_win()
	local stack = stacks[win]
	if not stack or #stack == 0 then
		return M.init_selection()
	end

	local top = stack[#stack]
	local node = vim.treesitter.get_node({ pos = { top[1], top[2] } })
	while node and not ranges_equal(node_range(node), top) do
		node = node:parent()
	end
	if not node then
		return
	end

	-- Expand to the nearest ancestor that spans more lines than the current
	-- selection — a reasonable proxy for an enclosing scope/block.
	local parent = node:parent()
	while parent do
		local prange = node_range(parent)
		if prange[3] > top[3] or prange[1] < top[1] then
			table.insert(stack, prange)
			select_range(prange)
			return
		end
		parent = parent:parent()
	end
end

function M.node_decremental()
	local win = vim.api.nvim_get_current_win()
	local stack = stacks[win]
	if not stack or #stack <= 1 then
		return
	end
	table.remove(stack)
	select_range(stack[#stack])
end

return M
