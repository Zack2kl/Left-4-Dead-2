local MENU = gui.Reference('MENU')
local window = gui.Window('lua_window', '', 300, 100, 300, 242)
local revive = gui.Keybox(window, 'lua_revbutton', 'Revive Button', 0)
local heal_others = gui.Keybox(window, 'lua_healobutton', 'Heal Others Button', 0)
local heal_yourself = gui.Keybox(window, 'lua_healubutton', 'Heal Yourself Button', 0)
local mult = gui.Multibox(window, 'Check for:')
local actual_surv = gui.Checkbox(mult, 'lua_check_players', 'Players', 0)
local all_surv = gui.Checkbox(mult, 'lua_check_bots', 'Bots', 0)
local show_keys = gui.Checkbox(window, 'lua_show_keys', 'Show hotkeys', 0)
local instant_switch = gui.Checkbox(window, 'lua_instant_swap', 'Instant Swap', 0)

local IN_ATTACK, IN_ATTACK2, IN_USE, IN_RELOAD = (1 << 0), (1 << 11), (1 << 5), (1 << 13)
local items, SeqNr, x, y = { revive, heal_others, heal_yourself }

local distance = function(a,b,c, d,e,f)local x,y,z=(a-d)*(a-d),(e-b)*(e-b),(f-c)*(f-c)return math.sqrt(x+y+z)end
local vector_angles = function(x1, y1, z1, x2, y2, z2) --https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/mathlib/mathlib_base.cpp#L535-L563
    local delta_x, delta_y, delta_z = x2-x1, y2-y1, z2-z1
    if delta_x == 0 and delta_y == 0 then
        return (delta_z > 0 and 270 or 90), 0
    else
		local y = math.atan( delta_y, delta_x ) * ( 180 / math.pi )
		local yaw = y < 0 and y + 360 or y
        local hyp = math.sqrt( (delta_x*delta_x) + (delta_y*delta_y) )
        local pitch = math.deg( math.atan(-delta_z / hyp) )
        return pitch, yaw
    end
end

local function able_to(mode)
	if mode ~= 'rev' and mode ~= 'def' and mode ~= 'ho' then return end

	local pX, pY, pZ = entities.GetLocalPlayer():GetHitboxPosition(2)
	local closest = {110, 999, nil, nil}
	local class = { actual_surv:GetValue() and 'CTerroPlayer', all_surv:GetValue() and 'SurvivorBot' }
	for i=1, 2 do if not class[i] then table.remove(class, i) end end

	for a=1, #class do
		local players = entities.FindByClass( class[a] )

		for i=1, #players do
			local player = players[i]
			local x, y, z = player:GetHitboxPosition(2)
			local dist = distance(pX, pY, pZ, x, y, z)
			local hp = player:GetHealth()
			if mode == 'rev' and ( dist < 110 and (dist < closest[1] or hp < closest[2]) and player:GetPropInt('m_isIncapacitated') == 1 ) or
			   mode == 'def' and ( not player:IsAlive() and dist < 100 and dist < closest[1] ) or
			   mode == 'ho' and ( player:IsAlive() and dist < 110 and hp < 99 and (dist < closest[1] or hp < closest[2]) )
			then
				closest = {dist, hp, vector_angles(pX, pY, pZ, x, y, z)}
			end
		end

		if closest[3] then
			return closest[3], closest[4]
		end
	end
end

local function do_thing(c, b, p, y, v)
	if p then
		c:SetViewAngles( p, y )
	end

	c:SetSendPacket( true )
	if not SeqNr then
		engine.AddOutSeqNr( v and v or 160 ) -- 625
		SeqNr = true
	end

	c:SetButtons( b )
end

callbacks.Register('CreateMove', function(cmd)
	local speed_key = gui.GetValue('msc_speedhack_key')
	if gui.GetValue('msc_speedhack_enable') and speed_key ~= 0 and input.IsButtonDown(speed_key) then
		return
	end

	local revive_key = revive:GetValue()
	local heal_others_key = heal_others:GetValue()
	local heal_yourself_key = heal_yourself:GetValue()

	if revive_key ~= 0 and input.IsButtonDown(revive_key) then
		local weapon = entities.GetLocalPlayer():GetPropEntity('m_hActiveWeapon')
		local A = weapon and (weapon:GetName() == 'Defibrillator' and {'def', IN_ATTACK2} or {'rev', IN_USE}) or {}
		local pitch, yaw = able_to(A[1])
		if pitch then
			do_thing(cmd, A[2], pitch, yaw)
		end
		return
	end

	if heal_others_key ~= 0 and input.IsButtonDown(heal_others_key) then
		local weapon = entities.GetLocalPlayer():GetPropEntity('m_hActiveWeapon')
		if weapon and weapon:GetName() == 'First Aid Kit' then
			local pitch, yaw = able_to('ho')
			if pitch then
				do_thing(cmd, IN_ATTACK2, pitch, yaw)
			end
		end
		return
	end

	if heal_yourself_key ~= 0 and input.IsButtonDown(heal_yourself_key) then
		local lp = entities.GetLocalPlayer()
		local weapon = lp:GetPropEntity('m_hActiveWeapon')
		if lp:GetHealth() < 99 and weapon and weapon:GetName() == 'First Aid Kit' then
			do_thing(cmd, IN_ATTACK)
		end
		return
	end

	if instant_switch:GetValue() then
		local t; for i=49,53 do if input.IsButtonDown(i)then t=1 break end end
		if input.IsButtonDown( 81 ) or t then
			engine.AddOutSeqNr( 150 )
			return
		end
	end

	SeqNr = nil
end)

callbacks.Register('Draw', function()
	window:SetActive( MENU:IsActive() )

	if not show_keys:GetValue() then
		return
	end

	if not x then
		local w,h = draw.GetScreenSize()
		x, y = w * 0.5, h * 0.75
	end

	if not entities.GetLocalPlayer() then
		return
	end

	local N = 0
	for i=1, #items do
		local item = items[i]
		local val = item:GetValue()
		if val ~= 0 then
			local str = item:GetName():gsub(' Button', '').. ': '.. string.char(val)
			local tW = draw.GetTextSize(str)
			draw.Text(x-(tW*0.5), y + N, str)
			N = N + 12
		end
	end
end)