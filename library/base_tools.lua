--[[
License: Unknown




--]]
-- Localize some functions for faster access
local vector = vector
local math = math
local string = string

local raycast = minetest.raycast
local get_node = minetest.get_node
local set_node = minetest.set_node
local add_node = minetest.add_node
local add_item = minetest.add_item

local registered_nodes = minetest.registered_nodes
local get_item_group = minetest.get_item_group
local is_creative_enabled = minetest.is_creative_enabled
local is_protected = minetest.is_protected
local record_protection_violation = minetest.record_protection_violation


local base_tools = {}
local player_digged = {player = "", pos = {}}


function k_dump(o)
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

local function km_get_pointed_node(user)
	local start = user:get_pos()
	start.y = start.y + user:get_properties().eye_height
	local look_dir = user:get_look_dir()
	local _end = vector.add(start, vector.multiply(look_dir, 5))

	local ray = raycast(start, _end, false, false)
	for pointed_thing in ray do
        return pointed_thing        
    end
        
    return nil

end

function base_tools.spawn_drop(player, node_name)

        for k, v in pairs(minetest.registered_nodes) do
            
            if k == node_name then
                drops = v.drop
            end
        end
        
        if drops == nil then
            return
        end
        
        local neo_pos = player:get_pos()
        neo_pos.x = neo_pos.x + math.random(-0.5, 0.5)
        neo_pos.y = neo_pos.y + math.random(-0.5, 0.5)
        
        if type(drops) == "string" then
            --~ minetest.add_item(neo_pos, drops)
            
            local inv = player:get_inventory()
            local Itemy = ItemStack(drops)
            local Itemy_Count = Itemy:get_count()
            
            Itemy:set_count(Itemy_Count)
            
            inv:add_item("main", Itemy)
            
            return
            
        elseif type(drops) == "table" then
            for name, count in pairs(drops) do
                --~ minetest.add_item(neo_pos, name)
                
                local inv = player:get_inventory()
                local Itemy = ItemStack(drops)
                local Itemy_Count = Itemy:get_count() + count
            
                Itemy:set_count(Itemy_Count)
            
                inv:add_item("main", Itemy)
                
            end
                
            return
        end
end


local dig_timer = 0
local dig_timer_max = 0.5

controls.register_on_hold(function(player, key, time)
	if key~="LMB" and key~="zoom" then 
		return 
	end
	
	local wielditem = player:get_wielded_item()
	local name = player:get_player_name()
   
	if (wielditem:get_name()== "komet_mod:copper_powerdrill" ) then 	

        local pointy_node = km_get_pointed_node(player)
        local object
                
        if pointy_node == nil then
            return        
        end
        
        dig_timer = dig_timer + calc_timer_rate(2.5)

        if dig_timer >= dig_timer_max then
            base_tools.spawn_drop(player, get_node(pointy_node.under).name)
            
            dig_timer = 0
        end

	end
	
end)



