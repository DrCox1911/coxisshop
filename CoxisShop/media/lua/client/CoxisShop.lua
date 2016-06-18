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

CoxisShop.Init = function()
	print("...CoxisShop...INIT")
	Events.OnZombieDead.Add(CoxisShop.onZombieDead);
	Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
	CoxisShop.InitPlayer();
	print("...CoxisShop...INIT")
end

CoxisShop.onZombieDead = function()
		-- every zombie killed, you gain 10 money
		for i = 0,getNumActivePlayers() - 1 do
			local playerObj = getSpecificPlayer(i)
			if playerObj then
	--~ 		getSpecificPlayer(i):getModData()["CoxisShopXp"] = getSpecificPlayer(i):getModData()["CoxisShopXp"] + 10;
				CoxisShop.modData[i].playerMoney = math.floor(CoxisShop.modData[i].playerMoney + (10 + (10 * (tonumber(playerObj:getModData()["CoxisShopBoostGoldLevel"]) / 100))));
				print(CoxisShop.modData[i].playerMoney)
			end
		end
end

local function showUpgradeScreen(playerNum)
	print("here in show screen")
	if not CoxisShop.upgradeScreen[playerNum] then
		local x = getPlayerScreenLeft(playerNum)
		local y = getPlayerScreenTop(playerNum)
		
		CoxisShop.upgradeScreen[playerNum] = ISCoxisShop:new(x+70,y+50,420,408,playerNum)
		--CoxisShop.upgradeScreen[playerNum] = ISCoxisShopUpgradeTab:new(x+70,y+50,320,608,playerNum)
		CoxisShop.upgradeScreen[playerNum]:initialise()
		CoxisShop.upgradeScreen[playerNum]:addToUIManager()
		CoxisShop.upgradeScreen[playerNum]:setVisible(false)
	end
	CoxisShop.upgradeScreen[playerNum]:reloadButtons()
	if CoxisShop.upgradeScreen[playerNum]:getIsVisible() then
		CoxisShop.upgradeScreen[playerNum]:setVisible(false)
	else
		CoxisShop.upgradeScreen[playerNum]:setVisible(true)
	end

	local joypadData = JoypadState.players[playerNum+1]
	if joypadData then
		if CoxisShop.upgradeScreen[playerNum]:getIsVisible() then
			joypadData.focus = CoxisShop.upgradeScreen[playerNum]
		else
			joypadData.focus = nil
		end
	end
end

CoxisShop.onKeyPressed = function(key)
--~ 		if key == getCore():getKey("Equip/Unequip Handweapon") then
--~ 			if CoxisShop.zombiesSpawned > 0 then
--~ 				CoxisShop.onZombieDead();
--~ 			end
--~ 		end

		if key == Keyboard.KEY_O then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() then
				showUpgradeScreen(0)
			end
		elseif key == Keyboard.KEY_L then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() and CoxisShop.debug then
				getSpecificPlayer(0):getModData().playerMoney = math.floor(getSpecificPlayer(0):getModData().playerMoney + 500);
			end
		end
end

Events.OnGameStart.Add(CoxisShop.Init)