local GetLocalPlayer, CurTime, FilledRect, Color, max = entities.GetLocalPlayer, globals.CurTime, draw.FilledRect, draw.Color, math.max
local max_time, next_attack, gotten = 0, 0, false

callbacks.Register('Draw', function()
	local local_player = GetLocalPlayer()
	if not local_player then
		return
	end

	local weapon = local_player:GetPropEntity('m_hActiveWeapon')
	if not weapon then
		return
	end

	if not weapon:GetPropBool('m_bInReload') then
		gotten = false
		return
	end

	if not gotten then
		next_attack = weapon:GetPropFloat('LocalActiveWeaponData', 'm_flNextPrimaryAttack')
		max_time = next_attack - CurTime()
		gotten = true
	end

	local time_left = next_attack - CurTime()
	local perc = max(time_left / max_time, 0)

	Color(33, 33, 33, 220)
	FilledRect(930, 600, 990, 610)

	Color(22, 230, 88, 245)
	FilledRect(932, 602, 988 - ( 56 * perc ), 608)
end)