--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 													       										#
#########################################################################################################
--]]

require "ISUI/ISCollapsableWindow"

ISCoxisShop = ISCollapsableWindow:derive("ISCoxisShop");
ISCoxisShop.instance = {}

function ISCoxisShop:initialise()
	ISCollapsableWindow.initialise(self);
end

function ISCoxisShop:createChildren()
	ISCollapsableWindow.createChildren(self);
	local th = self:titleBarHeight()
	local rh = self:resizeWidgetHeight()
	self.panel = ISTabPanel:new(0, th, self.width, self.height-th-rh);
	self.panel:initialise();
	self:addChild(self.panel);
	
	-- Tab with weapon stuff
	self.weaponScreen = ISCoxisShopWeaponUpWindow:new(0, 8, 400, 400, self.playerId);
	self.weaponScreen:initialise();
	self.panel:addView(getText('UI_CoxisShop_Weapons'), self.weaponScreen);
	-------------------------
	
	-- Tab with repair stuff
	self.repairScreen = ISCoxisShopWeaponRepairWindow:new(0, 8, 400, 400, self.playerId);
	self.repairScreen:initialise();
	self.panel:addView(getText('UI_CoxisShop_RepairWeapon'), self.repairScreen);
	-------------------------
	
	-- Tab with various stuff
	self.itemScreen = ISCoxisShopVariousItemWindow:new(0, 8, 400, 400, self.playerId);
	self.itemScreen:initialise();
	self.panel:addView(getText('UI_CoxisShop_Various'), self.itemScreen);
	-------------------------
	
	-- Tab with skills
	self.playerScreen = ISCoxisShopPlayerUpWindow:new(0, 8, 400, 400, self.playerId);
	self.playerScreen:initialise();
	self.panel:addView(getText('UI_CoxisShop_Player'), self.playerScreen);
	-------------------------
end

function ISCoxisShop:render()
	ISCollapsableWindow.render(self)

	if JoypadState.players[self.playerId+1] then
		self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
		self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
	end
end

function ISCoxisShop:reloadButtons()
	self.playerScreen:reloadButtons();
	self.weaponScreen:reloadButtons();
	self.itemScreen:reloadButtons();
	self.repairScreen:reloadButtons();
end

function ISCoxisShop:onGainJoypadFocus(joypadData)
	ISCollapsableWindow.onGainJoypadFocus(self, joypadData)
	joypadData.focus = self.panel:getActiveView()
end

function ISCoxisShop:onJoypadDown(button, joypadData)
	if button == Joypad.LBumper or button == Joypad.RBumper then
		if #self.panel.viewList < 2 then return end
		local viewIndex
		for i,v in ipairs(self.panel.viewList) do
			if v.view == self.panel:getActiveView() then
				viewIndex = i
				break
			end
		end
		if button == Joypad.LBumper then
			if viewIndex == 1 then
				viewIndex = #self.panel.viewList
			else
				viewIndex = viewIndex - 1
			end
		end
		if button == Joypad.RBumper then
			if viewIndex == #self.panel.viewList then
				viewIndex = 1
			else
				viewIndex = viewIndex + 1
			end
		end
		self.panel:activateView(self.panel.viewList[viewIndex].name)
--		setJoypadFocus(self.playerId, self.panel:getActiveView())
		joypadData.focus = self.panel:getActiveView()
	end
end

function ISCoxisShop:new (x, y, width, height, player)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
--	o:noBackground();
	o:setTitle(getText("UI_ISCoxisShop_WindowTitle"))
	o.playerId = player;
	ISCoxisShop.instance[player] = o;
	return o;
end