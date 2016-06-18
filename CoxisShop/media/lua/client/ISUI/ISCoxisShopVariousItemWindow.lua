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

ISCoxisShopVariousItemWindow = ISPanelJoypad:derive("ISCoxisShopVariousItemWindow");


--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISCoxisShopVariousItemWindow:initialise()
	ISPanelJoypad.initialise(self);
	self:create();
end

function ISCoxisShopVariousItemWindow:render()
	local y = 42;

	self:drawText(self.char:getDescriptor():getForename().." "..self.char:getDescriptor():getSurname(), 20, y, 1,1,1,1, UIFont.Medium);
	y = y + 25;
	self:drawText(getText("UI_CoxisShop_Px_Money", self.playerId, self.char:getModData().playerMoney), 20, y, 1,1,1,1, UIFont.Small);
end

function ISCoxisShopVariousItemWindow:create()
	local y = 90;

	local label = ISLabel:new(16, y, 20, getText("UI_CoxisShop_Carpentry"), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);

	y = y + 25;
	self:createItemButton(y, "Base.Hammer", 70)

	y = y + 30;
	self:createItemButton(y, "Base.Plank", 30)

	y = y + 30;
	self:createItemButton(y, "Base.Nails", 10)

	y = y + 30;
	self:createItemButton(y, "Base.Saw", 40)

	y = y + 30;

	local label = ISLabel:new(16, y, 20, getText("UI_CoxisShop_Health"), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);

	y = y + 25;
	self:createItemButton(y, "Base.RippedSheets", 20)

	y = y + 30;
	self:createItemButton(y, "Base.Pills", 20)

	y = y + 30;
	self:createItemButton(y, "Base.PillsBeta", 20)

	self:loadJoypadButtons()
end

function ISCoxisShopVariousItemWindow:createItemButton(y, itemType, cost)
	local item = ScriptManager.instance:getItem(itemType)
	local label = nil
	if item:getCount() > 1 then
		label = getText("UI_CoxisShop_ItemButton2", item:getDisplayName(), item:getCount(), cost)
	else
		label = getText("UI_CoxisShop_ItemButton", item:getDisplayName(), cost)
	end
	local button = ISButton:new(16, y, 100, 25, label, self, ISCoxisShopVariousItemWindow.onOptionMouseDown);
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

function ISCoxisShopVariousItemWindow:onOptionMouseDown(button, x, y)
	-- manage the item
	if button.internal == "item" then
		 self.char:getModData().playerMoney =  self.char:getModData().playerMoney - button.cost;
		self.char:getInventory():AddItem(button.item);
	end
	ISCoxisShop.instance[self.playerId]:reloadButtons();
end

function ISCoxisShopVariousItemWindow:reloadButtons()
	for i,v in ipairs(self.buttons) do
		if  self.char:getModData().playerMoney < v.cost then
			v:setEnable(false);
		else
			v:setEnable(true);
		end
	end
end

function ISCoxisShopVariousItemWindow:loadJoypadButtons()
	self:clearJoypadFocus()
	self.joypadButtonsY = {}
	for n = 1,#self.buttons do
		self:insertNewLineOfButtons(self.buttons[n])
	end
	self.joypadIndex = 1
	self.joypadIndexY = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
end

function ISCoxisShopVariousItemWindow:onJoypadDown(button, joypadData)
	if button == Joypad.AButton then
		ISPanelJoypad.onJoypadDown(self, button, joypadData)
	end
	if button == Joypad.BButton then
		ISCoxisShop.instance[self.playerId]:setVisible(false)
		joypadData.focus = nil
	end
	if button == Joypad.LBumper then
		ISCoxisShop.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
	if button == Joypad.RBumper then
		ISCoxisShop.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
end

function ISCoxisShopVariousItemWindow:new(x, y, width, height, player)
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
