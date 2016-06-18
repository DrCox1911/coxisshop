--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 													       										#
#########################################################################################################
--]]

require "ISUI/ISPanelJoypad"

ISCoxisShopPlayerUpWindow = ISPanelJoypad:derive("ISCoxisShopPlayerUpWindow");


--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISCoxisShopPlayerUpWindow:initialise()
	ISPanelJoypad.initialise(self);
	self:create();
end

function ISCoxisShopPlayerUpWindow:render()
	local y = 42;

	self:drawText(self.char:getDescriptor():getForename().." "..self.char:getDescriptor():getSurname(), 20, y, 1,1,1,1, UIFont.Medium);
	y = y + 25;
	self:drawText(getText("UI_CoxisShop_Px_Money",  self.playerId, self.char:getModData().playerMoney), 20, y, 1,1,1,1, UIFont.Small);
end

function ISCoxisShopPlayerUpWindow:create()
	local y = 90;

	local label = ISLabel:new(16, y, 20, getText("UI_CoxisShop_Skills"), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);

	y = y + 25;
	button = ISButton:new(16, y, 200, 25, "Blunt Lvl 1 - 0xp", self, ISCoxisShopPlayerUpWindow.onOptionMouseDown);
	button.internal = "skills";
	button.perk = Perks.Blunt;
	button.initialCost = 300;
	button.cost = 30;
	button:initialise();
	button:instantiate();
	button.borderColor = {r=1, g=1, b=1, a=0.1};

	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);

	y = y + 30;
	button = ISButton:new(16, y, 200, 25, "Blade Lvl 1 - 0xp", self, ISCoxisShopPlayerUpWindow.onOptionMouseDown);
	button.internal = "skills";
	button.perk = Perks.Axe;
	button.initialCost = 300;
	button.cost = 30;
	button:initialise();
	button:instantiate();
	button.borderColor = {r=1, g=1, b=1, a=0.1};

	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);

	y = y + 30;
	button = ISButton:new(16, y, 200, 25, "Carpentry - 0xp", self, ISCoxisShopPlayerUpWindow.onOptionMouseDown);
	button.internal = "skills";
	button.perk = Perks.Woodwork;
	button.initialCost = 300;
	button.cost = 30;
	button:initialise();
	button:instantiate();
	button.borderColor = {r=1, g=1, b=1, a=0.1};

	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);

	y = y + 30;

	local label = ISLabel:new(16, y, 20, getText("UI_CoxisShop_PermanentBonus"), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);

	y = y + 25;
	button = ISButton:new(16, y, 200, 25, "5% Gold gain Bonus - 300xp", self, ISCoxisShopPlayerUpWindow.onOptionMouseDown);
	button.internal = "goldBonus";
	button.initialCost = 1000;
	button.cost = 30;
	button.level = 1;
	button:initialise();
	button:instantiate();
	button.borderColor = {r=1, g=1, b=1, a=0.1};

	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);

	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);
	
	self:updateButtonLevel();
	
end

-- update the level of the differents bonus level, depending on your current bonus
function ISCoxisShopPlayerUpWindow:updateButtonLevel()
	for i,v in ipairs(self.buttons) do
		if v.internal == "goldBonus" then
			if tonumber(getSpecificPlayer(self.playerId):getModData()["CoxisShopBoostGoldLevel"]) > 1 then
				v.level = (tonumber(getSpecificPlayer(self.playerId):getModData()["CoxisShopBoostGoldLevel"]) / 5) + 1;
			end
		end
	end
end

function ISCoxisShopPlayerUpWindow:onOptionMouseDown(button, x, y)
	local playerObj = getSpecificPlayer(self.playerId)
	-- manage the item
	playerObj:getModData()["playerMoney"] = playerObj:getModData()["playerMoney"] - button.cost;
	if button.internal == "skills" then
		-- we add the xp for this skill, so the xp panel will be updated
		playerObj:LevelPerk(button.perk);
		luautils.updatePerksXp(button.perk, playerObj);
	end
	if button.internal == "goldBonus" then
		playerObj:getModData()["CoxisShopBoostGoldLevel"] = button.level * 5;
		button.level = button.level + 1;
	end
	self:reloadButtons();
	saveLastStandPlayerInFile(playerObj);
end

function ISCoxisShopPlayerUpWindow:reloadButtons()
	for i,v in ipairs(self.buttons) do
		if v.internal == "skills" then
			-- re-calcul the amount of xp needed to upgrade this skill
			local skillName = string.split(string.split(v:getTitle(), "-")[1], "Lvl")[1];
			v.cost = (getSpecificPlayer(self.playerId):getPerkLevel(v.perk) + 1) * v.initialCost;
			if (getSpecificPlayer(self.playerId):getPerkLevel(v.perk) + 1) <= 5 then
				v:setTitle(skillName .. "Lvl " .. (getSpecificPlayer(self.playerId):getPerkLevel(v.perk) + 1) .. " - " .. v.cost);
			else
				v:setTitle(skillName .. "Lvl max");
			end
			if tonumber(getSpecificPlayer(self.playerId):getModData()["playerMoney"]) < v.cost or getSpecificPlayer(self.playerId):getPerkLevel(v.perk) == 5 then
				v:setEnable(false);
			else
				v:setEnable(true);
			end
		end
		if (v.internal == "goldBonus") and not luautils.stringStarts(v:getTitle(), "Max") then
			-- recalcul the % bonus + the cost of this bonus
			local bonusName = string.split(string.split(v:getTitle(), "%")[2], "-")[1];
			v.cost = v.level * v.initialCost;
			if v.level <= 5 then
				v:setTitle(v.level * 5 .. "%" .. bonusName .. "- " .. v.cost);
			else
				v:setTitle("Max" .. bonusName);
			end
			if tonumber(getSpecificPlayer(self.playerId):getModData()["playerMoney"]) < v.cost or v.level > 5 then
				v:setEnable(false);
			else
				v:setEnable(true);
			end
		end
	end

	self:loadJoypadButtons()
end

function ISCoxisShopPlayerUpWindow:loadJoypadButtons()
	self:clearJoypadFocus()
	self.joypadButtonsY = {}
	for n = 1,#self.buttons do
		self:insertNewLineOfButtons(self.buttons[n])
	end
	if #self.buttons > 0 then
		self.joypadIndex = 1
		self.joypadIndexY = 1
		self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
		self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
	end
end

function ISCoxisShopPlayerUpWindow:onJoypadDown(button, joypadData)
	if button == Joypad.AButton then
		ISPanelJoypad.onJoypadDown(self, button, joypadData)
	end
	if button == Joypad.BButton then
		ISCoxisShopUpgradeTab.instance[self.playerId]:setVisible(false)
		joypadData.focus = nil
	end
	if button == Joypad.LBumper then
		ISCoxisShopUpgradeTab.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
	if button == Joypad.RBumper then
		ISCoxisShopUpgradeTab.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
end

function ISCoxisShopPlayerUpWindow:new(x, y, width, height, player)
	local o = {};
	o = ISPanelJoypad:new(x, y, width, height);
	o:noBackground();
	setmetatable(o, self);
    self.__index = self;
	o.char = getSpecificPlayer(player);
	o.playerId = player;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.buttons = {};
   return o;
end
