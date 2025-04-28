local S = minetest.get_translator(minetest.get_current_modname())
local base_guns = dofile(minetest.get_modpath("komet_mod") .. "/library/base_guns.lua")

komet_mod_gun_enforcer = {}

-- local arrows = {
-- 	["komet_mod:arrow"] = "komet_mod:arrow_entity",
-- }

local GRAVITY = 9.81
local BOW_DURABILITY = 800
local GUN_DAMAGE = 5
local GUN_PROJ_SPEED = 350
local GUN_ACCURACY = 0.5
local FIRERATE = calc_rpm(6)

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_BOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

-- TODO: Use Minecraft speed (ca. 53 m/s)
-- Currently nerfed because at full speed the arrow would easily get out of the range of the loaded map.
local BOW_MAX_SPEED = 200

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}
local fire_timer = 0

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}


local my_gun = base_guns.get_pattern()

my_gun["_internal_name"] = "komet_mod:gun_enforcer"
my_gun["description"] = S("Enforcer") 
my_gun["inventory_image"] = "enforcer_icon.png"
my_gun["_tt_help"] = S("Fires 9x19mm Rounds")
my_gun["mesh"] = "enforcer.obj"
my_gun["tiles"] = {"enforcer.png"}

base_guns.register_node_gun(my_gun)

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local function reset_bows(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == "komet_mod:gun_enforcer" or stack:get_name() == "komet_mod:gun_enforcer_enchanted" then
			stack:get_meta():set_string("active", "")
		elseif stack:get_name()=="komet_mod:gun_enforcer_0" or stack:get_name()=="komet_mod:gun_enforcer_1" or stack:get_name()=="komet_mod:gun_enforcer_2" then
			stack:set_name("komet_mod:gun_enforcer")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		elseif stack:get_name()=="komet_mod:gun_enforcer_0_enchanted" or stack:get_name()=="komet_mod:gun_enforcer_1_enchanted" or stack:get_name()=="komet_mod:gun_enforcer_2_enchanted" then
			stack:set_name("komet_mod:gun_enforcer_enchanted")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local function reset_bow_state(player, also_reset_bows)
	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil
	if minetest.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "komet_mod:use_gun_enforcer")
	end
	if also_reset_bows then
		reset_bows(player)
	end
end

controls.register_on_press(function(player, key, time)
	if key~="LMB" and key~="zoom" then 
		return 
	end
	
	local wielditem = player:get_wielded_item()
	local name = player:get_player_name()
	
	
	if fire_timer > 0 then
		return	
	end
	
	if (wielditem:get_name() == "komet_mod:gun_enforcer") and base_guns.has_ammo(player, "komet_mod:9x19mmBullet") then 	
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
		fire_timer = FIRERATE
	
		local fire_prop = base_guns.get_firing_properties()
		fire_prop.damage = GUN_DAMAGE
		fire_prop.proj_speed = GUN_PROJ_SPEED
		fire_prop.accuracy = GUN_ACCURACY
	
		base_guns.consume_ammo(player, "komet_mod:9x19mmBullet")
		base_guns.shoot_projectile(player, fire_prop)
		minetest.sound_play("pistol_fire", {pos=pos, max_hear_distance=20}, true)

	end
	
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		
		fire_timer = fire_timer - 1
	
		--local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~="komet_mod:gun_enforcer_0" and wielditem:get_name()~="komet_mod:gun_enforcer_1" and wielditem:get_name()~="komet_mod:gun_enforcer_2" and wielditem:get_name()~="komet_mod:gun_enforcer_0_enchanted" and wielditem:get_name()~="komet_mod:gun_enforcer_1_enchanted" and wielditem:get_name()~="komet_mod:gun_enforcer_2_enchanted") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)

