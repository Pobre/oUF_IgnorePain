-- Tags
-- ShortNumber
local function ShortNumber(value)
	if(value >= 1e6) then
		return gsub(format('%.2fm', value / 1e6), '%.?0+([km])$', '%1')
	elseif(value >= 1e4) then
		return gsub(format('%.1fk', value / 1e3), '%.?0+([km])$', '%1')
	else
		return value
	end
end

for tag, func in next, {
	["ignorepain:cur"] = function(unit)
		return ShortNumber(select(17, UnitBuff(unit, GetSpellInfo(190456))) or 0)
	end,
	["ignorepain:max"] = function(IgnorePain)
		return ShortNumber(IgnorePain.GetIgnorePainMax())
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = "UNIT_ABSORB_AMOUNT_CHANGED"
end

