# coxisshop
Item and skill shop system for the indie game Project Zomboid

Basic shop system which gives the player money upon killing a zombie.
The money can be used to buy various items/skills.

Advanced user can alter the following things by editing the "CoxisShopSettings.ini" shipped with the mod:
  - define the amount of money gained
  - define the randomness of money gain (not the amount is random, but you won´t get money after each zombie kill)
  - define the items available in the shop (with prize setting aswell)
  - new section "food/drink"
  
The sections of the "CoxisShopSettings.ini" are not be altered! You can only add keys, the "[BASIC]"-section doesn´t accept any new keys.
The "random"-key in "[BASIC]" is used as followed:

        randi = ZombRand(100);
				if (randi >= tonumber(CoxisShop.settings["BASIC"]["random"])) then
        
As the above formula describes: higher numbers make the earning of money less likely. If you set "random" to zero you will always earn money.

You can create shop zones to limit where people can shop. They can overlap. The first line covers probably most maps, enabling worldwide access.
####Always leave an empty line after your last line. Do not delete all lines.
GUIDE: 
- Bottom Left corner (x1, y1)
- Top Right corner (x2, y2)

        name=x1 x2 y1 x2

Default example:

        [ZONE]
        buyZone=-999999 999999 -999999 999999
        buyZone2=10885 10885 10145 10145


				