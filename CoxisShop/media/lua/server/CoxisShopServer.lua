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

CoxisShopServer = {};
CoxisShopServer.settings = {};

-- **************************************************************************************
-- sending the info that zombie is dead to client
-- zombies are server-sided since a couple of builds, so the event isn´t fired on the client any longer
-- **************************************************************************************
CoxisShopServer.AfterZombieDead = function()
	CoxisShopServer.SendToClient("afterZombieDead", {})
end


CoxisShopServer.SendSettings = function()
	CoxisShopServer.SendToClient("sendSettings", CoxisShopServer.settings)
end


-- **************************************************************************************
-- basic function to send something to the client
-- the _data has to be a table, _event a unique name that is also recognized by the client
-- **************************************************************************************
CoxisShopServer.SendToClient = function(_event, _data)
	print("...CoxisShop...SENDING DATA TO CLIENT")
	sendServerCommand('CoxisShop', _event, _data);
	print("...CoxisShop...SENDING DATA TO CLIENT DONE")
end


CoxisShopServer.ReceiveFromClient = function(_module, _command, _player, _args)
	if _module ~= 'CoxisShop' then return end
	print("...CoxisShop...received from client!")
	if _command == 'askSettings' then
		print("New Client knocked, sending the settings...");
		CoxisShopServer.SendSettings();
		print("Settings sended");
	end
end


-- **************************************************************************************
-- reading in ini-file
-- can be used to read any setting shipped with the mod
-- **************************************************************************************
CoxisShopServer.LoadSettings = function()
	CoxisShopServer.settings = CoxisUtil.readINI("CoxisShop", "CoxisShopSettings.ini");
end


-- **************************************************************************************
-- init the server, registering events and whatnot
-- **************************************************************************************
CoxisShopServer.InitServer = function()
	if (isServer()) then
		print("...CoxisShop...INIT SERVER")
		CoxisShopServer.LoadSettings();
		Events.OnZombieDead.Add(CoxisShopServer.AfterZombieDead);
		Events.OnClientCommand.Add(CoxisShopServer.ReceiveFromClient);
		print("...CoxisShop...INIT SERVER DONE")
	end

end

Events.OnServerStarted.Add(CoxisShopServer.InitServer)
--Events.OnGameStart.Add(CoxisShopServer.InitServer)
