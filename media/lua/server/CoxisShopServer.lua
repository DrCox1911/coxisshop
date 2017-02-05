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
CoxisShopServer.luanet = nil;
CoxisShopServer.module = nil;
CoxisShopServer.network = false;
self_net = nil;
-- **************************************************************************************
-- sending the info that zombie is dead to client
-- zombies are server-sided since a couple of builds, so the event isn´t fired on the client any longer
-- **************************************************************************************
CoxisShopServer.AfterZombieDead = function(_player)
	--CoxisShopServer.SendToClient("afterZombieDead", {_this})
end


CoxisShopServer.transmitSettings = function(_player, _username)
		if CoxisShopServer.network then
			local players 		= getOnlinePlayers();
			local array_size 	= players:size();	
			for i=0, array_size-1, 1 do
				local player = players:get(i);
				print(tostring(player:getUsername()));
				if _username == player:getUsername() then
					print(tostring(instanceof(player, "IsoPlayer" )));
					CoxisShopServer.module.sendPlayer(player, "settings", CoxisShopServer.settings);
				end
			end
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
CoxisShopServer.initServer = function()
	if (isServer()) then
		print("...CoxisShop...INIT SERVER")
		CoxisShopServer.LoadSettings();
		CoxisShopServer.network = true;
		CoxisShopServer.luanet = LuaNet:getInstance();
		CoxisShopServer.module = CoxisShopServer.luanet.getModule("CoxisShop", true);
		LuaNet:getInstance().setDebug( true );
	
		CoxisShopServer.module.addCommandHandler("settings", CoxisShopServer.transmitSettings);
		CoxisShopServer.module.addCommandHandler("zeddead", CoxisShopServer.AfterZombieDead);
		--Events.OnZombieDead.Add(CoxisShopServer.AfterZombieDead);
		
		CoxisShopServer.network = true;
		--Events.OnClientCommand.Add(CoxisShopServer.ReceiveFromClient);
		print("...CoxisShop...INIT SERVER DONE")
	end

end

CoxisShopServer.initMP = function()
	if isServer() then
		LuaNet:getInstance().onInitAdd(CoxisShopServer.initServer);
	end
end

Events.OnGameBoot.Add(CoxisShopServer.initMP)
