--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 		https://theindiestone.com/forums/index.php?/topic/20228-coxis-shop/											       										#
#########################################################################################################
--]]

# Changelog

### Version 1.3.0
	- bugfix: integrated LuaNet to get rid of the "all players earn money in MP"-bug
	- dialog informing the player that the settings aren´t loaded yet
	- bugfix: new character after player died in MP is fixed now (proper reinit)
	- definable shop key in the game options (thanks to blindcoder)
	- player starts now with 0 money instead of 100

### Version 1.2.0
	- definable settings within the "CoxisShopSettings.ini"
		- define the amount of money gained
		- define the randomness of money gain (not the amount is random, but you won´t get money after each zombie kill)
		- define the items available in the shop (with prize setting aswell)
	- now need the mod "CoxisUtils" to work ("CoxisUtils" reads the ini-file)
	- new section "food/drink"
	

### Version 1.1.0
	- support for dedicated server MP (Coop not working)

### Version 1.0.0
	- basic functionalitiy like the shop from challenge had
	- only SP
