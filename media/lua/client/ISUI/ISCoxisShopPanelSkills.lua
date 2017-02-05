--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 		https://theindiestone.com/forums/index.php?/topic/20228-coxis-shop/											       										#
#########################################################################################################
--]]

require "ISUI/ISPanelJoypad"
require "ISUI/ISLayoutManager"

ISCoxisShopPanelSkills = ISPanelJoypad:derive("ISCoxisShopPanelSkills");
ISCoxisShopList = ISScrollingListBox:derive("ISCoxisShopList");
ISCoxisScrollbar = ISScrollBar:derive("ISCoxisScrollbar");

CoxisShopUI = {};
CoxisShopUI.items = {};

CoxisShopUI.checkPrice = function(_target, _onmousedown, _self)
	local splitstring = luautils.split(_onmousedown, "|");

	if _self.char:getModData().playerMoney < tonumber(splitstring[2]) then
		_self.parent.buttons[1]:setEnable(false);
	else
		_self.parent.buttons[1]:setEnable(true);
	end
end

function ISCoxisShopPanelSkills:initialise()
	ISPanelJoypad.initialise(self);
	self:create();
end

function ISCoxisShopPanelSkills:render()
	local y = 42;

	self:drawText(self.char:getDescriptor():getForename().." "..self.char:getDescriptor():getSurname(), 20, y, 1,1,1,1, UIFont.Medium);
	y = y + 25;
	self:drawText(getText('UI_CoxisShop_Px_Money', self.playerId, self.char:getModData().playerMoney), 20, y, 1,1,1,1, UIFont.Small);
end

function ISCoxisShopPanelSkills:create()
	local y = 90;

	local label = ISLabel:new(16, y, 20, getText('UI_CoxisShop_AvailSkills'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);
	
	self.CoxisShopList = ISCoxisShopList:new(16, y + 30, 390, 200, self.char, self.playerId, self);
    self.CoxisShopList:initialise()
    self.CoxisShopList:instantiate()
    self.CoxisShopList.itemheight = 22
	self.CoxisShopList.onmousedown = CoxisShopUI.checkPrice;
    self.CoxisShopList.font = UIFont.NewSmall
    self.CoxisShopList.drawBorder = true
    self:addChild(self.CoxisShopList)
	
	for perkString,value in pairs(self.items) do
		local perkName = nil;
		local perkType = nil;
			for k=0, PerkFactory.PerkList:size()-1, 1 do
				if tostring(PerkFactory.PerkList:get(k):getType()) == perkString then
					perkName = PerkFactory.PerkList:get(k):getName();
					perkType = PerkFactory.PerkList:get(k):getType();
				end
			end
			if perkName ~= nil and perkType ~= nil then
				local lvlacquire = self.char:getPerkLevel(Perks.FromString(perkString))+1;
				--print("lvl from char: " .. tostring(self.char:getPerkLevel(Perks.FromString(perkString))));
				--print("lvlacquire: " .. tostring(lvlacquire));
				if lvlacquire <= 10 then
					self.CoxisShopList:addItem(perkName .. " - Lvl. " .. tostring(lvlacquire) .. " (" .. tostring(luautils.round(value*(lvlacquire/1.2),0)) .. ")", tostring(perkType) .. "|" .. tostring(luautils.round(value*(lvlacquire/1.2),0)));
				end
			end
	end
	self.CoxisShopBuyButton = self:createButton(290, y-15, self.onBuyMouseDown, self.char, self.playerId);
end

function ISCoxisShopPanelSkills:createItemButton(x, y, itemType, cost)
	local item = ScriptManager.instance:getItem(itemType)
	local label = nil
	if item:getCount() > 1 then
		label = getText('UI_CoxisShop_ItemButton2', item:getDisplayName(), item:getCount(), cost)
	else
		label = getText('UI_CoxisShop_ItemButton', item:getDisplayName(), cost)
	end
	local button = ISButton:new(x, y, 100, 25, label, self, ISCoxisShopPanelSkills.onOptionMouseDown);
	button:initialise();
	button.internal = "item";
	button.item = itemType;
	button.cost = cost;
	button.borderColor = {r=1, g=1, b=1, a=0.1};
	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);
end

function ISCoxisShopPanelSkills:createButton(x, y, _function, player, playerId)
	local label = nil;
	label = getText('UI_CoxisShop_BuyButton')
	local button = ISButton:new(x, y, 100, 25, label, self, _function);
	button:initialise();
	button.internal = "buy";
	button.borderColor = {r=1, g=1, b=1, a=0.1};
	button.playerId = playerId;
	button.char = player;
	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	table.insert(self.buttons, button);
end

function ISCoxisShopPanelSkills:onBuyMouseDown(button, x, y)
	-- manage the item
	if button.internal == "buy" then
		local selectedPerk = self.CoxisShopList.items[self.CoxisShopList.selected].item
		--print("selected: " .. tostring(selectedPerk));
		if selectedPerk ~= nil then
			local splitstring = luautils.split(selectedPerk, "|")
			--print("cost: " .. tostring(splitstring[2]));
			self.char:getModData().playerMoney = self.char:getModData().playerMoney - tonumber(splitstring[2]);
			self.char:LevelPerk(Perks.FromString(splitstring[1]));
			luautils.updatePerksXp(Perks.FromString(splitstring[1]), self.char);
		end
	end
	self:reloadButtons()
end

function ISCoxisShopPanelSkills:reloadButtons()
	local index = 1;
	if self.CoxisShopList.selected > 0 then
		index = self.CoxisShopList.selected;
	end

	if #self.CoxisShopList.items > 0 then
		local selectedItem = self.CoxisShopList.items[index].item;
		local splitstring = luautils.split(selectedItem, "|");

		if self.char:getModData().playerMoney < tonumber(splitstring[2]) then
			self.buttons[1]:setEnable(false);
		else
			self.buttons[1]:setEnable(true);
		end
		
		self.CoxisShopList:clear();
		
		for perkString,value in pairs(self.items) do
			local perkName = nil;
			local perkType = nil;
			for k=0, PerkFactory.PerkList:size()-1, 1 do
				if tostring(PerkFactory.PerkList:get(k):getType()) == perkString then
					perkName = PerkFactory.PerkList:get(k):getName();
					perkType = PerkFactory.PerkList:get(k):getType();
				end
			end
			if perkName ~= nil and perkType ~= nil then
				local lvlacquire = self.char:getPerkLevel(Perks.FromString(perkString))+1;
				if lvlacquire <= 10 then
					self.CoxisShopList:addItem(perkName .. " - Lvl. " .. tostring(lvlacquire) .. " (" .. tostring(luautils.round(value*(lvlacquire/1.2),0)) .. ")", tostring(perkType) .. "|" .. tostring(luautils.round(value*(lvlacquire/1.2),0)));
				end
			end
		end
	else
		self.buttons[1]:setEnable(false);
	end
end

function ISCoxisShopPanelSkills:loadJoypadButtons()
	self:clearJoypadFocus()
	self.joypadButtonsY = {}
	self:insertNewLineOfButtons(self.buttons[1])
	self:insertNewLineOfButtons(self.buttons[2])
	self:insertNewLineOfButtons(self.buttons[3])
	self:insertNewLineOfButtons(self.buttons[4], self.buttons[5]);
	self:insertNewLineOfButtons(self.buttons[6], self.buttons[7]);
	self.joypadIndex = 1
	self.joypadIndexY = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
end

function ISCoxisShopPanelSkills:onJoypadDown(button, joypadData)
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

function ISCoxisShopPanelSkills:new(x, y, width, height, player, _items)
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
	o.items = _items;
	o.CoxisShopList = nil;
   return o;
end

-- **************************************************************************************
-- redefining the ISScrollingListBox:onBuyMouseDown to pass more variables
-- **************************************************************************************
function ISCoxisShopList:onMouseDown(x, y)
	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = #self.items;
	end
	if row < 1 then
		row = 1;
	end

	-- RJ: If you select the same item it unselect it
	--if self.selected == y then
	--if self.selected == y then
		--self.selected = -1;
		--return;
	--end

	self.selected = row;

	if self.onmousedown then
		self.onmousedown(self.target, self.items[self.selected].item, self);
	end
end

function ISCoxisShopList:new(x, y, width, height, player, playerId, parent)
	local o = {}
	--o.data = {}
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
	o:noBackground();
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9};
	o.altBgColor = {r=0.2, g=0.3, b=0.2, a=0.1}
	-- Since these were broken before, don't draw them by default
	o.altBgColor = nil
	o.drawBorder = false
	o.width = width;
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.font = UIFont.Large
	o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
	o.itemPadY = 7
	o.itemheight = o.fontHgt + o.itemPadY * 2;
	o.selected = 1;
    o.count = 0;
	o.itemheightoverride = {}
	o.items = {}
	o.char = player;
	o.playerId = playerId;
	o.parent = parent;
	return o
end
