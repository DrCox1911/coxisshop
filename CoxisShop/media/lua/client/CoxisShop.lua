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
--CoxisShop.playersMoney = {};
CoxisShop.boostGoldLvl = {};
CoxisShop.boostXPLvl = {};
CoxisShop.upgradeScreen = {};
CoxisShop.settings = {};
CoxisShop.gamemode = nil;
CoxisShop.debug = false;


-- **************************************************************************************
-- loading up the saved player money from moddata
-- **************************************************************************************
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
			end
		end
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
CoxisShop.AskSettings = function(_ticks)
	if _ticks > 200 then
		print("now asking for settings");
		Events.OnTick.Remove(CoxisShop.AskSettings);
		CoxisShop.SendToServer("askSettings", CoxisShop.settings);
	end
end


-- **************************************************************************************
-- handling key presses here
-- **************************************************************************************
CoxisShop.onKeyPressed = function(_key)
		if _key == getCore():getKey("OpenCoxisShop") then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() then
				showUpgradeScreen(0)
			end
		elseif _key == Keyboard.KEY_L then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() and CoxisShop.debug then
				-- CoxisShop.AskSettings();
				getSpecificPlayer(0):getModData().playerMoney = math.floor(getSpecificPlayer(0):getModData().playerMoney + 500);
			end
		end
end


-- **************************************************************************************
-- basic function to send something to the server
-- the _data has to be a table, _event a unique name that is also recognized by the server
-- **************************************************************************************
CoxisShop.SendToServer = function(_event, _data)
	print("...CoxisShop...SENDING DATA TO SERVER")
	sendClientCommand('CoxisShop', _event, _data);
	print("...CoxisShop...SENDING DATA TO SERVER DONE")
end


-- **************************************************************************************
-- basic function to receive something from the server
-- all the _command from the server have to be known here
-- **************************************************************************************
CoxisShop.ReceiveServerCommand = function(_module, _command, _args)
	if _module ~= 'CoxisShop' then return end
	print("...CoxisShop...RECEIVED SERVER COMMAND");
	if _command == 'afterZombieDead' then
		CoxisShop.AfterZombieDead();
	end
	if _command == "sendSettings" then
		CoxisShop.settings = _args;
		print(CoxisShop.settings["WEAPONS"]["Base.Axe"]);
	end
	CoxisShop.conn = true;
end


-- **************************************************************************************
-- giving the player the money
-- the info if zombie is dead is transmitted by the server (see ReceiveServerCommand)
-- **************************************************************************************
CoxisShop.AfterZombieDead = function()
	print("...CoxisShop...ZOMBIE DIED")
		for i = 0,getNumActivePlayers() - 1 do
			local playerObj = getSpecificPlayer(i)
			if playerObj then
	--~ 		getSpecificPlayer(i):getModData()["CoxisShopXp"] = getSpecificPlayer(i):getModData()["CoxisShopXp"] + 10;
				randi = ZombRand(100);
				if (randi >= tonumber(CoxisShop.settings["BASIC"]["random"])) then	-- if _settings["random"]=0 than the player will receive the money every kill, else it´s random, the lower the random-number the likelier
					CoxisShop.modData[i].playerMoney = math.floor(CoxisShop.modData[i].playerMoney + (tonumber(CoxisShop.settings["BASIC"]["amount"]) + (10 * (tonumber(playerObj:getModData()["CoxisShopBoostGoldLevel"]) / 100))));
				end
			end
		end
end

-- **************************************************************************************
-- loading the settings if mode is SP, if MP than the settings are received from the server
-- **************************************************************************************
CoxisShop.LoadSettings = function()
	CoxisShop.settings = CoxisUtil.readINI("CoxisShop", "CoxisShopSettings.ini");
end

-- **************************************************************************************
-- init the client, registering events and whatnot
-- **************************************************************************************
CoxisShop.Init = function()
	if isClient() then
		print("...CoxisShop...INIT CLIENT")
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnTick.Add(CoxisShop.AskSettings);
		CoxisShop.InitPlayer();
		CoxisShop.gamemode = "MP";
		print("...CoxisShop...INIT CLIENT DONE")
	end
	
	if (not(isClient()) and not(isServer())) then
		print("...CoxisShop...INIT SP")
		Events.OnKeyPressed.Add(CoxisShop.onKeyPressed);
		Events.OnZombieDead.Add(CoxisShop.AfterZombieDead);
		CoxisShop.InitPlayer();
		CoxisShop.LoadSettings();
		CoxisShop.gamemode = "SP";
		print("...CoxisShop...INIT SP DONE")
	end
end

Events.OnGameStart.Add(CoxisShop.Init)
Events.OnServerCommand.Add(CoxisShop.ReceiveServerCommand);
