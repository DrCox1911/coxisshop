--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 													       										#
#########################################################################################################
--]]


CoxisShop = {};
CoxisShop.modData = {};
--CoxisShop.playersMoney = {};
CoxisShop.boostGoldLvl = {};
CoxisShop.boostXPLvl = {};
CoxisShop.upgradeScreen = {};
CoxisShop.debug = true;

CoxisShop.InitPlayer = function()
	--if isClient() then
		for i = 0,getNumActivePlayers() - 1 do
		local playerObj = getSpecificPlayer(i)
			if playerObj then
				CoxisShop.modData[i] = playerObj:getModData();
				CoxisShop.modData[i].playerMoney = CoxisShop.modData[i].playerMoney or 100;
				CoxisShop.modData[i].CoxisShopXp = CoxisShop.modData[i].CoxisShopX or 1;
				CoxisShop.modData[i].CoxisShopBoostGoldLevel = CoxisShop.modData[i].CoxisShopBoostGoldLevel or 1;
				CoxisShop.modData[i].CoxisShopBoostXpLevel = CoxisShop.modData[i].CoxisShopBoostXpLevel or 1;
				CoxisShop.modData[i].CoxisShopStartingGoldLevel = CoxisShop.modData[i].CoxisShopStartingGoldLevel or 1;
				print("...CoxisShop...")
				print(CoxisShop.modData[i].playerMoney);
				print("...CoxisShop...")
			end
		end
	--end
end

local function showUpgradeScreen(_playerNum)
	print("here in show screen")
	if not CoxisShop.upgradeScreen[_playerNum] then
		local x = getPlayerScreenLeft(_playerNum)
		local y = getPlayerScreenTop(_playerNum)
		
		CoxisShop.upgradeScreen[_playerNum] = ISCoxisShop:new(x+70,y+50,420,408,_playerNum)
		--CoxisShop.upgradeScreen[_playerNum] = ISCoxisShopUpgradeTab:new(x+70,y+50,320,608,_playerNum)
		CoxisShop.upgradeScreen[_playerNum]:initialise()
		CoxisShop.upgradeScreen[_playerNum]:addToUIManager()
		CoxisShop.upgradeScreen[_playerNum]:setVisible(false)
	end
	CoxisShop.upgradeScreen[_playerNum]:reloadButtons()
	if CoxisShop.upgradeScreen[_playerNum]:getIsVisible() then
		CoxisShop.upgradeScreen[_playerNum]:setVisible(false)
	else
		CoxisShop.upgradeScreen[_playerNum]:setVisible(true)
	end

	local joypadData = JoypadState.players[_playerNum+1]
	if joypadData then
		if CoxisShop.upgradeScreen[_playerNum]:getIsVisible() then
			joypadData.focus = CoxisShop.upgradeScreen[_playerNum]
		else
			joypadData.focus = nil
		end
	end
end

CoxisShop.onKeyPressed = function(_key)
--~ 		if key == getCore():getKey("Equip/Unequip Handweapon") then
--~ 			if CoxisShop.zombiesSpawned > 0 then
--~ 				CoxisShop.onZombieDead();
--~ 			end
--~ 		end

		if _key == Keyboard.KEY_O then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() then
				showUpgradeScreen(0)
			end
		elseif _key == Keyboard.KEY_L then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() and CoxisShop.debug then
				getSpecificPlayer(0):getModData().playerMoney = math.floor(getSpecificPlayer(0):getModData().playerMoney + 500);
			end
		end
end

CoxisShop.ReceiveServerCommand = function(_module, _command, _args)
	if _module ~= 'CoxisShop' then return end
	print("...CoxisShop...RECEIVED SERVER COMMAND");
	if _command == 'afterZombieDead' then
		CoxisShop.AfterZombieDead();
	end

end

CoxisShop.AfterZombieDead = function()
	print("...CoxisShop...ZOMBIE DIED")
		for i = 0,getNumActivePlayers() - 1 do
			local playerObj = getSpecificPlayer(i)
			if playerObj then
	--~ 		getSpecificPlayer(i):getModData()["CoxisShopXp"] = getSpecificPlayer(i):getModData()["CoxisShopXp"] + 10;
				CoxisShop.modData[i].playerMoney = math.floor(CoxisShop.modData[i].playerMoney + (10 + (10 * (tonumber(playerObj:getModData()["CoxisShopBoostGoldLevel"]) / 100))));
				print(CoxisShop.modData[i].playerMoney)
			end
		end

end

CoxisShop.Init = function()
	if isClient() then
		print("...CoxisShop...INIT CLIENT")
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnServerCommand.Add(CoxisShop.ReceiveServerCommand);
		CoxisShop.InitPlayer();
		print("...CoxisShop...INIT CLIENT DONE")
	end
	
	if (not(isClient()) and not(isServer())) then
		print("...CoxisShop...INIT SP")
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnZombieDead.Add(CoxisShop.AfterZombieDead);
		CoxisShop.InitPlayer();
		print("...CoxisShop...INIT SP DONE")
	end
end

Events.OnGameStart.Add(CoxisShop.Init)
--Events.OnServerStarted.Add(CoxisShop.InitServer)