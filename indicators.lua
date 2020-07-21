local GetLocalPlayer, IsButtonDown, GetValue, TextShadow, GetScreenSize, GetTextSize = entities.GetLocalPlayer, input.IsButtonDown, gui.GetValue, draw.TextShadow, draw.GetScreenSize, draw.GetTextSize
local air_stuck, pressed = false, false
local x, y
local s = 0

local function air()
	local key = GetValue('msc_airstuck')
	if key == 0 then
		return
	end

	if IsButtonDown(key) then
		if not pressed then
			air_stuck = not air_stuck
			pressed = true
		end
	else
		pressed = false
	end

	local str = 'Airstuck: '.. (air_stuck and 'ON' or 'OFF')
	local tW = GetTextSize(str)
	print(tW.. '-'.. str)

	TextShadow(x-(tW*0.5), y, str)
	s = s + 12
end

local function speed()
	if not GetValue('msc_speedhack_enable') then
		return
	end

	local key = GetValue('msc_speedhack_key')
	if key == 0 then
		return
	end

	local str = 'Speedhack: '.. (IsButtonDown(key) and 'ON' or 'OFF')
	local tW = GetTextSize(str)
	print(tW.. '-'.. str)

	TextShadow(x-(tW*0.5), y+s, str)
	s = s + 12
end

local function lag()
	local key = GetValue('msc_lagexploit')
	if key == 0 then
		return
	end

	local str = 'Lag Exploit: '.. (IsButtonDown(key) and 'ON' or 'OFF')
	local tW = GetTextSize(str)
	print(tW.. '-'.. str)

	TextShadow(x-(tW*0.5), y+s, str)
	s = s + 12
end

callbacks.Register('Draw', function()
    if not GetLocalPlayer() then
        return
    end

	if not x then
		local w, h = GetScreenSize()
		x, y = w * 0.5, (h * 0.5) + 15
	end

	air()
	speed()
	lag()

	s = 0
end)