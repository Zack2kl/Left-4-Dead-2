local GetLocalPlayer, SetConVar, GetScreenSize, Line = entities.GetLocalPlayer, client.SetConVar, draw.GetScreenSize, draw.Line
local draw_crosshair = gui.Checkbox(gui.Reference('SETTINGS', 'Miscellaneous'), 'lua_crosshair', 'Crosshair', false)
local w, h

local function crosshair()
	if not draw_crosshair:GetValue() then
		if w then
			SetConVar('crosshair', 1, true)
			w = nil
		end
		return 
	end

	if not GetLocalPlayer() then
		return
	end

	if not w then
		local x, y = GetScreenSize()
		w, h = x * 0.5, y * 0.5
		SetConVar('crosshair', 0, true)
	end

	Line(w - 5, h, w + 5, h)
	Line(w, h - 5, w, h + 5)
end

callbacks.Register('Draw', crosshair)