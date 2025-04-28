local S = minetest.get_translator(minetest.get_current_modname())
local base_guns = dofile(minetest.get_modpath("komet_mod") .. "/library/base_guns.lua")

komet_mod_gun_bekas_12m = {}


local GRAVITY = 9.81
local BOW_DURABILITY = 800
--It is a shotgun so it spawns more projectiles
local GUN_DAMAGE = 2
local GUN_PROJ_SPEED = 480
local GUN_ACCURACY = 4.45
local FIRERATE = calc_rpm(1.85)
local GUN_PROJ_AMOUNT = 8

local fire_timer = 0

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

local my_gun = base_guns.get_pattern()

my_gun["_internal_name"] = "komet_mod:gun_bekas_12m"
my_gun["description"] = S("Bekas 12m") 
my_gun["inventory_image"] = "bekas_12m_icon.png"
my_gun["_tt_help"] = S("Fires 12-Gauge shells")
my_gun["mesh"] = "bekas_12m.obj"
my_gun["tiles"] = {"bekas_12m.png"}
my_gun["paramtype2"] = "facedir"
--my_gun["param2"] =


base_guns.register_node_gun(my_gun)

controls.register_on_release(function(player, key, time)
	if key~="LMB" and key~="zoom" then 
		return 
	end
	
	local wielditem = player:get_wielded_item()
	local name = player:get_player_name()
	
	if fire_timer > 0 then
		return	
	end
	
	if (wielditem:get_name()=="komet_mod:gun_bekas_12m") and base_guns.has_ammo(player, "komet_mod:12_gauge_shell") then 	
		player:set_wielded_item(wielditem)
		--~ reset_bow_state(player, true)
		fire_timer = FIRERATE
	
		local fire_prop = guns_fire_prop
		fire_prop.damage = GUN_DAMAGE
		fire_prop.proj_speed = GUN_PROJ_SPEED
		fire_prop.accuracy = GUN_ACCURACY
		fire_prop.amount = GUN_PROJ_AMOUNT
	
		base_guns.consume_ammo(player, "komet_mod:12_gauge_shell")
		minetest.sound_play("shotgun_fire", {pos=player:get_pos(), max_hear_distance=20}, true)
		base_guns.shoot_projectile(player, fire_prop)
		
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		
		fire_timer = fire_timer - 1
	end
	
	
end)

