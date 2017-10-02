--[[
# Element Warrior Ignore Pain Bar
Handles the visibility and updating Ignore Pain bar.

TODO: Rest of comment section
]]--

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF IgnorePain was unable to locate oUF install")

if(select(2,UnitClass("player") ~= "WARRIOR")) then return end

-- Functions
local function GetIgnorePainMax()
	--[[
	-- Colect all data necessary to calculate Ignore Pain correctly.
	]]--
	-- Attack Power
	local atkBase, atkPos, atkNeg = UnitAttackPower("player")

	-- Versatility
	local versa = (GetCombatRatingBonus(29) + GetVersatilityBonus(30)) / 100

	-- Get Dragon Skin
	local skinRank = C_ArtifactUI.GetPowerInfo(100).currentRank * 0.02 + 1
	
	-- Get Dragon Scales Rank
	local scales = UnitBuff("player", GetSpellInfo(203581)) and 1.4 or 1

	-- Indomitable
	local indomitable = select(4, GetTalentInfo(5, 3, 1)) and 1.2 or 1

	-- Ignore Pain max pool.
	if(not select(4, GetTalentInfo(5, 2, 1))) then
		return ((atkBase + atkPos + atkNeg) * 22.3 * (versa + 1) * scales * indomitable) * 0.9 * 3
	else
		return ((atkBase + atkPos + atkNeg) * 22.3 * (versa + 1) * scales * indomitable) * 0.9 * 3 * 2
	end
end

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

-- Tags
for tag, func in next, {
	["ignorepain:cur"] = function(unit)
		return ShortNumber(select(17, UnitBuff(unit, GetSpellInfo(190456))) or 0)
	end,
	["ignorepain:max"] = function()
		return ShortNumber(GetIgnorePainMax())
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = "UNIT_ABSORB_AMOUNT_CHANGED"
end

-- Index of Protection Warrior
local SPEC_WARRIOR_PROTECTION = 3

local function Update(self, event, unit)
	if(unit and unit ~= self.unit) then return end

	local element = self.IgnorePain
	
	-- Callback: IgnorePain:PreUpdate()
	-- Called before update.
	-- * self - the IgnorePain element
	if(element.PreUpdate) then element.PreUpdate() end

	-- Current Ignore Pain.
	local curIP = select(17, UnitBuff("player", GetSpellInfo(190456))) or 0

	-- Ignore Pain max pool.
	local maxIP = GetIgnorePainMax()

	-- Set MinMax values and current Ignore Pain
	element:SetMinMaxValues(0, maxIP)
	element:SetValue(curIP)

	element.current = curIP
	element.max = maxIP

	--[[ Callback: PostUpdate(curIP, maxIP)
	Used to completely override the internal Update function.

	* self - the parent object
	* curIP - the current amount of Ignore Pain.
	* maxIP - Ignore Pain's max pool.
	]]--
	if(element.PostUpdate) then
		element.PostUpdate(curIP, maxIP)
	end
end

local function Path(self, ...)
	--[[ Override: IgnorePain.Override(self, event, unit)
	Used to completely override the internal Update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.IgnorePain.Override or Update)(self, ...)
end

local function Visibility(self, event, unit)
	if(SPEC_WARRIOR_PROTECTION ~= GetSpecialization() or UnitHasVehiclePlayerFrameUI("player")) then
		if(self.IgnorePain:IsShown()) then
			self.IgnorePain:Hide()
			self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)
		end
	else
		if(not self.IgnorePain:IsShown()) then
			self.IgnorePain:Show()
			self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)
		end

		return Path(self, event, unit)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: IgnorePain.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility toggling function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.IgnorePain.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, "ForceUpdate", element._owner.unit)
end

local function Enable(self)
	local element = self.IgnorePain
	if(element) then
		element._owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath, true)

		if(element:IsObjectType("StatusBar") and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		end

		element.GetIgnorePainMax = GetIgnorePainMax

		return true
	end
end

local function Disable(self)
	local element = self.IgnorePain
	if(element) then
		element:Hide()

		self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath)
	end
end

oUF:AddElement("IgnorePain", VisibilityPath, Enable, Disable)

