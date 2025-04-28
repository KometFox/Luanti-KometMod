------------------------------------------------------------------------
--[[
This script is used as a base method for defining weapons and handling
weapons.


License: MIT
--]]
------------------------------------------------------------------------
--The module of this script
local base_guns = {}

bows = {
	registered_arrows = {},
	registered_bows = {}
}

--Used for registering new node guns, based upon minetest.register_items() function 
node_guns = {}

guns_fire_prop = {}

guns_fire_prop["amount"] = 1
guns_fire_prop["accuracy"] = 100
guns_fire_prop["damage"] = 5 
guns_fire_prop["proj_speed"] = 50

local function do_nothing()
    return 
end

local function _on_place(itemstack, player, pointed_thing)
    if pointed_thing and pointed_thing.type == "node" then
	-- Call on_rightclick if the pointed node defines it
        local node = minetest.get_node(pointed_thing.under)
		
        if player and not player:get_player_control().sneak then
            if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
				end
			end
		end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end
    
local function _on_secondary_use(itemstack)
    itemstack:get_meta():set_string("active", "true")

	


    return itemstack
end

--you can change these 
node_guns["_internal_name"] = "komet_mod:gun_none"
node_guns["description"] = "km_empty_gun" -- name of the gun
node_guns["_tt_help"] = "Unknown gun" -- gun tool tip description
node_guns["mesh"] = "box.obj"
node_guns["tiles"] = "cube.png"
node_guns["inventory_image"] = "tnt1a0.png" -- fancy image
node_guns["groups"] = {weapon = 1} -- the group it belongs to
node_guns["_mcl_uses"] = 100 -- weapon durability

--default variables, don't change these.
node_guns["type"] = "node"
node_guns["drawtype"] = "mesh"
node_guns["stack_max"] = 1
node_guns["range"] = 0
node_guns["on_use"] = do_nothing() 
node_guns["on_place"] = do_nothing()
node_guns["on_secondary_use"] =  do_nothing()
node_guns["paramtype"] = "light"
node_guns["paramtype2"] = "facedir"
node_guns["param2"] = {x = 0.5, y = 0, z = 0.5}
node_guns["sunlight_propagates"] = true



function base_guns.register_node_gun(gun_pattern)
    minetest.register_item(gun_pattern["_internal_name"], gun_pattern)
end

function base_guns.get_pattern()
    return node_guns
end

function base_guns.get_firing_properties()
    return guns_fire_prop
end

function base_guns.consume_ammo(player, ammo_stack)
    ammo_stack = ItemStack(ammo_stack)
    local inv = player:get_inventory()

    for i = 1, inv:get_size("main") do
	local it = inv:get_stack("main", i)
	
	if not it:is_empty() and it:get_name() == ammo_stack:get_name() then
	     ammo_stack:set_count(it:get_count() -1) 
	     inv:set_stack("main", i, ammo_stack)
	    break
	end
    end
end

function base_guns.has_ammo(player, ammo_stack)
    ammo_stack = ItemStack(ammo_stack)
    local inv = player:get_inventory()

    for i = 1, inv:get_size("main") do
	local it = inv:get_stack("main", i)
	
	if not it:is_empty() and it:get_name() == ammo_stack:get_name() then

	    return true
	end
    end

    return false

end

function base_guns.shoot_projectile(player, gun)
    for i = 1, gun.amount, 1 do
	bows.tmp = {}
	bows.tmp.user = player
	bows.tmp.name = "projectile"
	bows.tmp.dmg = gun.damage
	
	local prop = player:get_properties()
	local pos = player:get_pos() ; pos.y = pos.y + (prop.eye_height - 0.15)
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()
	local pitch = player:get_look_vertical()

	local bdir
	local d = gun.accuracy / 50

	bdir = vector.offset(dir, (math.random()*d)-(d/2), (math.random()*d)-(d/2), (math.random()*d)-(d/2))
	

	local proj = minetest.add_entity({
		x = pos.x,
		y = pos.y,
		z = pos.z,
	}, "komet_mod:musket_shot_entity"):get_luaentity()
	
	local acc = math.random(-gun.accuracy, gun.accuracy)
	    
	proj._dir = bdir
	proj._shooter = player
	proj._speed = gun.proj_speed
	proj._damage = gun.damage
	proj._lifetime = 0.5
	proj._bullet_drop = -5

	
    end
end


function base_guns.bg_fire_gun(player, key, time)
	
end

------------------------------------------------------------------------
--End of module
------------------------------------------------------------------------
return base_guns
