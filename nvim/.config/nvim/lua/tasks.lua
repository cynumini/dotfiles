local function calc_date(date, value, unit)
	if unit == "d" then
		unit = "days"
	elseif unit == "w" then
		unit = "weeks"
	elseif unit == "m" then
		unit = "months"
	elseif unit == "y" then
		unit = "years"
	end
	local handle = io.popen("date -d " .. date .. "+" .. value .. unit .. " --iso-860")
	local result = handle:read("*a")
	handle:close()
	return result:sub(1, #result - 1)
end

local note_done = function()
	local line = vim.api.nvim_get_current_line()

	local update = false

	-- It's task?
	if line:find("- [ ]", 1, true) then
		line = line:gsub("- %[ %]", "- [x]")
		update = true
	elseif line:find("- [x]", 1, true) then
		line = line:gsub("- %[x%]", "- [ ]")
		update = true
	end
	if update == false then
		local start = line:find("-")
		local date = line:sub(start + 2, start + 11)
		local last_space = line:match(".*() ") + 1
		local task = line:sub(start + 13, last_space - 2)
		local recurrence = line:sub(last_space, #line)
		print(date .. task .. recurrence)
		if recurrence then
			local unit = recurrence:sub(#recurrence, #recurrence)
			local current_date = os.date("%Y-%m-%d")
			-- ++ is when we add the recurrence value until the new date is greater than today.
			-- .+ is when we ignore the task's scheduled date and just add the recurrence value.
			-- + is when we add the recurrence value to the scheduled date of the task.
			if recurrence:sub(1, 2) == "++" then
				local value = tonumber(recurrence:sub(3, #recurrence - 1))
				while date <= current_date do
					date = calc_date(date, value, unit)
				end
			elseif recurrence:sub(1, 2) == ".+" then
				local value = tonumber(recurrence:sub(3, #recurrence - 1))
				date = calc_date(current_date, value, unit)
			elseif recurrence:sub(1, 1) == "+" then
				local value = tonumber(recurrence:sub(2, #recurrence - 1))
				date = calc_date(date, value, unit)
			end
			line = ""
			while start > 1 do
				print(start)
				line = line .. " "
				start = start - 1
			end
			line = line .. "- " .. date .. " " .. task .. " " .. recurrence
		end
	end

	vim.api.nvim_set_current_line(line)
end

return note_done
