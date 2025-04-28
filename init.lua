function calc_rpm(firerate)
    local rpm1 = firerate / 60
    local rpm2 = 1.0 / rpm1
    
    return rpm2
end

function calc_timer_rate(amount)
    local rate1 = amount / 60
    
    return rate1
end


function get_tool_dig_speed(tool, node)
    local tool_group = {} 
    local node_group = {}
    
end

function km_dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


minetest.register_on_joinplayer(function(player)
	player:hud_set_flags({
		minimap = true,
		minimap_radar =  true
	})
end)


------------------------------------------------------------------------
--Global item name
------------------------------------------------------------------------
item_iron_ore = "mcl_raw_ores:raw_iron"
item_gold_ore = "mcl_raw_ores:raw_gold"
item_copper_ore = "mcl_copper:raw_copper"
item_diamond_ore = "mcl_core:diamond"
item_coal_ore = "mcl_core:coal_lump"

item_clay = "mcl_core:clay_lump"

item_iron_ingot = "mcl_core:iron_ingot" 
item_copper_ingot = "mcl_copper:copper_ingot" 
item_gold_ingot = "mcl_core:gold_ingot"

item_gunpowder = "mcl_mobitems:gunpowder"

item_clayball = "mcl_core:clay_lump"

block_cobblestone = "mcl_core:cobble"
block_stone = "mcl_core:stone"
block_stonebrick = "mcl_core:stonebrick"
block_granite = "mcl_core:granite"
block_andesite = "mcl_core:andesite"
block_diorite = "mcl_core:diorite"
block_sandstone = "mcl_core:sandstone"
block_redsandstone = "mcl_core:redsandstone"
block_clay = "mcl_core:clay"
block_ice = "mcl_core:ice"
block_sand = "mcl_core:sand"
block_gravel = "mcl_core:gravel"

------------------------------------------------------------------------
--Load assets here
------------------------------------------------------------------------
--Stuff from mineclone, remove it later.
dofile(minetest.get_modpath("komet_mod") .. "/library/mcl_controls.lua")


--Library 
dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
dofile(minetest.get_modpath("komet_mod") .. "/library/base_guns.lua")
dofile(minetest.get_modpath("komet_mod") .. "/library/base_tools.lua")

--Others
dofile(minetest.get_modpath("komet_mod") .. "/nodes/test_block.lua")
--dofile(minetest.get_modpath("komet_mod") .. "/nodes/farming/tobacco_plant.lua")

--Items
dofile(minetest.get_modpath("komet_mod") .. "/nodes/items.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/items/ammo.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/items/other.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/items/water_boiler.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/items/saline_crystalizer.lua")

--Weapons
dofile(minetest.get_modpath("komet_mod") .. "/nodes/weapons/musket_bullet.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/weapons/enforcer.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/weapons/bekas_12m.lua")

dofile(minetest.get_modpath("komet_mod") .. "/nodes/basic_bench.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/ammo_bench.lua")
dofile(minetest.get_modpath("komet_mod") .. "/nodes/stone_transformer.lua")




