require 'OptionScreens/MainOptions'
require 'keyBinding'

-- Taken from the Spraypaint mod --
local function addBind(name, key)--{{{
	local bind = {}
	bind.value = name
	bind.key = key
	table.insert(keyBinding, bind) -- global key bindings in zomboid/media/lua/shared/keyBindings.lua
end

table.insert(keyBinding, {value="[CoxisShop]"}) -- adds a section header to keys.ini and the options screen
addBind("OpenCoxisShop", Keyboard.KEY_O);

