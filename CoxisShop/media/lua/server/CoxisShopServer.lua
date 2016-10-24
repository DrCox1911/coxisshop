--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 													       										#
#########################################################################################################
--]]

CoxisShopServer = {};

CoxisShopServer.AfterZombieDead = function()
	print("Here in onZombieDead")
	CoxisShopServer.SendToClient("afterZombieDead", {})
end

CoxisShopServer.SendToClient = function(_event, _data)
	print("...CoxisShop...SENDING DATA TO CLIENT")
	sendServerCommand('CoxisShop', _event, _data);
	print("...CoxisShop...SENDING DATA TO CLIENT DONE")
end


CoxisShopServer.InitServer = function()
	if (isServer()) then
		print("...CoxisShop...INIT SERVER")
		Events.OnZombieDead.Add(CoxisShopServer.AfterZombieDead);
		print("...CoxisShop...INIT SERVER DONE")
	end

end

Events.OnServerStarted.Add(CoxisShopServer.InitServer)
Events.OnGameStart.Add(CoxisShopServer.InitServer)
