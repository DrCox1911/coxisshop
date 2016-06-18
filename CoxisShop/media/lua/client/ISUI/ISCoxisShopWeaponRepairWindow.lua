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

ISCoxisShopWeaponRepairWindow = ISPanelJoypad:derive("ISCoxisShopWeaponRepairWindow");


--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISCoxisShopWeaponRepairWindow:initialise()
	ISPanelJoypad.initialise(self);
	self:create();
end

function ISCoxisShopWeaponRepairWindow:render()
	local y = 42;

	self:drawText(self.char:getDescriptor():getForename().." "..self.char:getDescriptor():getSurname(), 20, y, 1,1,1,1, UIFont.Medium);
	y = y + 25;
	self:drawText(getText("UI_CoxisShop_Px_Money", self.playerId, self.char:getModData().playerMoney), 20, y, 1,1,1,1, UIFont.Small);
end

function ISCoxisShopWeaponRepairWindow:create()
	local y = 90;

	local label = ISLabel:new(16, y, 20, getText("UI_CoxisShop_RepairWeapon"), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 390, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);
end

function ISCoxisShopWeaponRepairWindow:onOptionMouseDown(button, x, y)
	-- manage the item
	if button.internal == "repair" then
		button.item:setCondition(button.item:getConditionMax());
		self.char:getModData().playerMoney = self.char:getModData().playerMoney - button.cost;
	end
	ISCoxisShop.instance[self.playerId]:reloadButtons();
end

function ISCoxisShopWeaponRepairWindow:reloadButtons()
	-- first we remove every buttons
	for i,v in ipairs(self.buttons) do
		self:removeChild(v);
		v:removeFromUIManager();
	end
	self.buttons = {};
	-- fetch all the item in the player inventory to find weapon with a condition under 1
	for i=0, self.char:getInventory():getItems():size() - 1 do
		local item = self.char:getInventory():getItems():get(i);
		if instanceof(item, "HandWeapon") then -- found a weapon slightly damaged
			-- calcul the money needed to repair it
			local cost = math.ceil((100 - item:getCurrentCondition()) * 2);
			-- add a new button
			local button = ISButton:new(16, 90 + ((#self.buttons + 1) * 30), 100, 25, getText("UI_CoxisShop_ItemButton", item:getName(), cost), self, ISCoxisShopWeaponRepairWindow.onOptionMouseDown);
			button.internal = "repair";
			button.item = item;
			button.cost = cost;
			button:initialise();
			button:instantiate();
			button.borderColor = {r=1, g=1, b=1, a=0.1};

			button:setFont(UIFont.Small);
			button:ignoreWidthChange();
			button:ignoreHeightChange();
			self:addChild(button);
			table.insert(self.buttons, button);

			-- disable this button if the condition is ok or if you don't have enough money
			if item:getCurrentCondition() == 100 or (self.char:getModData().playerMoney < button.cost) then
				button:setEnable(false);
			end
		end
	end

	self:loadJoypadButtons()
end

function ISCoxisShopWeaponRepairWindow:loadJoypadButtons()
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

function ISCoxisShopWeaponRepairWindow:onJoypadDown(button, joypadData)
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

function ISCoxisShopWeaponRepairWindow:new(x, y, width, height, player)
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
