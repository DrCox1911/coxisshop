--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 		https://theindiestone.com/forums/index.php?/topic/20228-coxis-shop/											       										#
#########################################################################################################
--]]

require 'CoxisUtil'

CoxisShop = {};
CoxisShop.modData = {};
CoxisShop.boostGoldLvl = {};
CoxisShop.boostXPLvl = {};
CoxisShop.upgradeScreen = {};
CoxisShop.settings = {};
CoxisShop.gamemode = nil;
CoxisShop.luanet = nil;
CoxisShop.module = nil;
CoxisShop.network = false;
CoxisShop.zombieKills = 0;
CoxisShop.debug = true;

-- **************************************************************************************
-- loading up the saved player money from moddata
-- **************************************************************************************
CoxisShop.InitPlayer = function()
	--if isClient() then
		for i = 0,getNumActivePlayers() - 1 do
		local playerObj = getSpecificPlayer(i)
			if playerObj then
				CoxisShop.modData[i] = playerObj:getModData();
				CoxisShop.modData[i].playerMoney = CoxisShop.modData[i].playerMoney or 0;
				CoxisShop.modData[i].CoxisShopXp = CoxisShop.modData[i].CoxisShopX or 1;
				CoxisShop.modData[i].CoxisShopBoostGoldLevel = CoxisShop.modData[i].CoxisShopBoostGoldLevel or 1;
				CoxisShop.modData[i].CoxisShopBoostXpLevel = CoxisShop.modData[i].CoxisShopBoostXpLevel or 1;
				CoxisShop.modData[i].CoxisShopStartingGoldLevel = CoxisShop.modData[i].CoxisShopStartingGoldLevel or 1;
			end
		end
		CoxisShop.zombieKills = getPlayer():getZombieKills();
	--end
end


-- **************************************************************************************
-- showing the shop window (pretty much a copy from RJs code)
-- **************************************************************************************
local function showUpgradeScreen(_playerNum)
	if not CoxisShop.upgradeScreen[_playerNum] then
		local x = getPlayerScreenLeft(_playerNum)
		local y = getPlayerScreenTop(_playerNum)
		
		CoxisShop.upgradeScreen[_playerNum] = ISCoxisShop:new(x+70,y+50,420,408,_playerNum, CoxisShop.settings)
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


-- **************************************************************************************
-- asking the server to send the settings like amount of money, items in shop, ...
-- **************************************************************************************
CoxisShop.askSettings = function(_player)
	if CoxisShop.network then
		local player = _player;
		if not player then
			player = getPlayer();
		end
		CoxisShop.module.send("settings", player:getUsername());
	end
end


-- **************************************************************************************
-- handling key presses here
-- **************************************************************************************
CoxisShop.onKeyPressed = function(_key)
		if _key == getCore():getKey("OpenCoxisShop") then then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() then
				local next = next;
				if not (CoxisShop.settings["BASIC"] == nil) then
					showUpgradeScreen(0)
				else
					luautils.okModal(getText('UI_CoxisShop_NoSettings'), true, 100, 100, 0, 0)
					if CoxisShop.gamemode == "MP" then CoxisShop.askSettings(getPlayer()); end
					if CoxisShop.gamemode == "SP" then CoxisShop.LoadSettings(); end
				end
			end
		end
end


-- **************************************************************************************
-- giving the player the money
-- the info if zombie is dead is transmitted by the server (see ReceiveServerCommand)
-- **************************************************************************************
CoxisShop.AfterZombieDead = function(_player)
	local randi = ZombRand(100);
	for i = 0,getNumActivePlayers() - 1 do
		local playerObj = getSpecificPlayer(i);
		if CoxisShop.gamemode ~= "SP" then
			if (playerObj:getUsername() == _player:getUsername()) then
				if (randi >= tonumber(CoxisShop.settings["BASIC"]["random"])) then	-- if _settings["random"]=0 than the player will receive the money every kill, else it´s random, the lower the random-number the likelier
					CoxisShop.modData[i].playerMoney = math.floor(CoxisShop.modData[i].playerMoney + (tonumber(CoxisShop.settings["BASIC"]["amount"]) + (10 * (tonumber(playerObj:getModData()["CoxisShopBoostGoldLevel"]) / 100))));
				end
			end
		else
			if (randi >= tonumber(CoxisShop.settings["BASIC"]["random"])) then	-- if _settings["random"]=0 than the player will receive the money every kill, else it´s random, the lower the random-number the likelier
				CoxisShop.modData[i].playerMoney = math.floor(CoxisShop.modData[i].playerMoney + (tonumber(CoxisShop.settings["BASIC"]["amount"]) + (10 * (tonumber(playerObj:getModData()["CoxisShopBoostGoldLevel"]) / 100))));
			end
		end
	end
end

CoxisShop.hitZed = function(_player)
	if _player:getZombieKills() > CoxisShop.zombieKills then
		CoxisShop.module.sendPlayer(_player, "zeddead");
		CoxisShop.zombieKills =	_player:getZombieKills();
	end
end

-- **************************************************************************************
-- loading the settings if mode is SP, if MP than the settings are received from the server
-- **************************************************************************************
CoxisShop.LoadSettings = function()
	CoxisShop.settings = CoxisUtil.readINI("CoxisShop", "CoxisShopSettings.ini");
end

CoxisShop.receiveSettings = function(_player, _settings)
	print("...CoxisShop... receiving settings from server");
	if CoxisShop.network then
		CoxisShop.settings = _settings;
	end
end


CoxisShop.prepareReInit = function()
	Events.OnCreatePlayer.Add(CoxisShop.init);
end

-- **************************************************************************************
-- init the client, registering events and whatnot
-- **************************************************************************************
CoxisShop.init = function()
	if isClient() then
		print("...CoxisShop...INIT CLIENT")
		CoxisShop.luanet = LuaNet:getInstance();
		CoxisShop.module = CoxisShop.luanet.getModule("CoxisShop", CoxisShop.debug);
		CoxisShop.luanet.setDebug(CoxisShop.debug);
		CoxisShop.module.addCommandHandler("settings", CoxisShop.receiveSettings);
		CoxisShop.module.addCommandHandler("zeddead", CoxisShop.AfterZombieDead);
		
		CoxisShop.InitPlayer();
		CoxisShop.gamemode = "MP";
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnPlayerUpdate.Add(CoxisShop.hitZed);
		CoxisShop.network = true;
		print("...CoxisShop...INIT CLIENT DONE")
	end
	
	if (not(isClient()) and not(isServer())) then
		print("...CoxisShop...INIT SP")
		CoxisShop.InitPlayer();
		CoxisShop.LoadSettings();
		CoxisShop.gamemode = "SP";
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnZombieDead.Add(CoxisShop.AfterZombieDead);
		print("...CoxisShop...INIT SP DONE")
	end
end

CoxisShop.initMP = function()
	if isClient() then
		LuaNet:getInstance().onInitAdd(CoxisShop.init);
		LuaNet:getInstance().onInitAdd(CoxisShop.askSettings);
	end
	

end


CoxisShop.initSP = function()
	if (not(isClient()) and not(isServer())) then
		CoxisShop.init();
	end	
end
Events.OnConnected.Add(CoxisShop.initMP)
Events.OnGameStart.Add(CoxisShop.initSP)
Events.OnPlayerDeath.Add(CoxisShop.prepareReInit)
--Events.OnServerCommand.Add(CoxisShop.ReceiveServerCommand);