--[[
License: Unknown

Base library for adding custom benches and furnaces 
--]]

local S = minetest.get_translator("stuff")
local C = minetest.colorize

local base_bench = {}


bb_furnace_pattern = {}
bb_bench_pattern = {}

MAX_INGREDIENT = 3

--
-- Node callback functions that are the same for active and inactive furnace
--

function base_bench.register_node(pattern)
    minetest.register_node(pattern["_internal_name"], pattern)
end

function base_bench.allow_metadata_inventory_put(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		-- Special case: empty bucket (not a fuel, but used for sponge drying)
		if stack:get_name() == "mcl_buckets:bucket_empty" then
			if inv:get_stack(listname, index):get_count() == 0 then
				return 1
			else
				return 0
			end
		end

		-- Test stack with size 1 because we burn one fuel at a time
		local teststack = ItemStack(stack)
		teststack:set_count(1)
		local output, decremented_input = minetest.get_craft_result({ method = "fuel", width = 1, items = { teststack } })
		if output.time ~= 0 then
			-- Only allow to place 1 item if fuel get replaced by recipe.
			-- This is the case for lava buckets.
			local replace_item = decremented_input.items[1]
			if replace_item:is_empty() then
				-- For most fuels, just allow to place everything
				return stack:get_count()
			else
				if inv:get_stack(listname, index):get_count() == 0 then
					return 1
				else
					return 0
				end
			end
		else
			return 0
		end
	elseif listname == "input" then
		return stack:get_count()
	elseif listname == "output" then
		return 0
	end
	
	local ret_val = 0
	
	if stack then
		ret_val = stack:get_count()
	else
		ret_val = 0
	end
	
	
	return ret_val
end

function base_bench.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)

	--~ print("POS: ", pos)
	--~ print("from_list: ", from_list)
	--~ print("from_index: ", from_index)
	--~ print("to_list: ", to_list)
	--~ print("to_index: ", to_index)
	--~ print("count: ", count)
	--~ print("player: ", player)

	
	return base_bench.allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

function base_bench.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end

function base_bench.on_metadata_inventory_take(pos, listname, index, stack, player)
end

function base_bench.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
end

function base_bench.reset_delta_time(pos)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get("time_speed") or 72)
	if (time_speed < 0.1) then
		return
	end
	local time_multiplier = 86400 / time_speed
	local current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)

	-- TODO: Change meta:get/set_string() to get/set_float() for "last_gametime".
	-- In Windows *_float() works OK but under Linux it returns rounded unusable values like 449540.000000000
	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 or math.abs(last_game_time - current_game_time) <= 1.5 then
		return
	end

	meta:set_string("last_gametime", tostring(current_game_time))
end

------------------------------------------------------------------------
--Common functions for benches 
------------------------------------------------------------------------

---@param itemname string
function base_bench.itemname_to_fieldname(itemname)
	return string.gsub(itemname, ":", "__")
end

---@param fieldname string
function base_bench.fieldname_to_itemname(fieldname)
	return string.gsub(fieldname, "__", ":")
end


--Very specific function to get list of items from the recipe
function base_bench.get_table_element(recipes)
    local ret_table = {}
    local count = 0
    
    for index, subtables in pairs(recipes) do
	

	for k, v in pairs(subtables) do
	    count = count + 1
	
	    if k == "recipe_name" then
		ret_table[count] = v
	    end

	end
    end

    return ret_table 
end

--function for getting specific part of a table
function base_bench.get_recipe_stuff(recipes, recipe_name, value_name)
    local name_catch = "" 
    local subtable_catch = {}
    local count = 0

	--[[
	if recipes ~= type("table") then
		print("recipe is not a table")
		return {} 
	end
	--]]

	--bleh
    for k, v in pairs(recipes) do
        --bleh
        for k2, v2 in pairs(v) do

            if v2 == recipe_name then
                name_catch = v2
                count = k
            end
        end
    end


    for k, v in pairs(recipes[count]) do
	  if k == value_name then
  
				for k2, v2 in pairs(v) do
				subtable_catch[k2] = v2
            end
        end
    end
    
    return subtable_catch
end

--[[
Function to check for if there is enough items that the player has
in his inventory
--]]
function base_bench.is_enough_items(recipes, item_string, player, mult)
    local inv = player:get_inventory()
    local ingredients = base_bench.get_recipe_stuff(recipes, item_string, "ingredient")
    
    local total_item_amount = {}
    local ing_count = 0
    local check_count = 0
    
    --pre-processing
    for ing_items, ing_amount in pairs(ingredients) do
	ing_count = ing_count + 1
	ingredients[ing_items] = ingredients[ing_items] * mult
    end
    
    --Loop through the player's inventory 
    for i = 1, inv:get_size("main") do
	local item = inv:get_stack("main", i)
	   
	   
	for ing_items, ing_amount in pairs(ingredients) do
	    
	    if ing_items == item:get_name() then
		total_item_amount[ing_items] = item:get_count()
	    end
	    
	end

    end

    --Now check for total amount
    for player_item, player_count in pairs(total_item_amount) do
	for item_name, amount_need in pairs(ingredients) do 
	    
	    if player_item == item_name and player_count >= amount_need then
		check_count = check_count + 1
	    end
		
	    --Final result
	    if check_count >= ing_count then
		return true
	    end
	
	end
    end
    
     return false
end


--[[
Function to take items of whatever recipe the player is using to craft
new items with
--]]
function base_bench.take_player_item(recipes, item_string, player, mult)
    local inv = player:get_inventory()
    local ingredients = base_bench.get_recipe_stuff(recipes, item_string, "ingredient")
    
    for name, count in pairs(ingredients) do
	ingredients[name] = ingredients[name] * mult
    end


    function take_items() 
	local item_modified = {}

	for i = 1, inv:get_size("main") do
	    local item = inv:get_stack("main", i)
	    
	    if item_modified[item:get_name()] == nil then
		item_modified[item:get_name()] = 0
	    end

	    for name, amount in pairs(ingredients) do

		if name == item:get_name() and item:get_count() > 0 then

		    while item_modified[name] < amount do
			item:set_count(item:get_count() - 1)
			inv:set_stack("main", i, item)
			item_modified[name] = item_modified[name] + 1
		    end
		    
		end
	    end
	
	end
	   
    end
    
    return take_items()

end

--Function for getting the item name 
function base_bench.set_selected_item(player, _string, item_name)
	player:get_meta():set_string(_string, item_name and item_name or "item:none")
end



--[[
Function to add items to the player and calling other functions for
that.  
--]]
function base_bench.craft_items(player, item_string, recipes, amount) 
    local meta = player:get_meta()
    local inv = player:get_inventory()
    
    --failsafe against empty value
    if item_string == nil or item_string == "" then
	return
    end
   
   
    local item_bag = base_bench.get_recipe_stuff(recipes, item_string, "give_items")
    
    for bag_name, bag_count in pairs(item_bag) do
	if base_bench.is_enough_items(recipes, item_string, player, amount) == true then
	    base_bench.take_player_item(recipes, item_string, player, amount)
	    local sitem = ItemStack(bag_name)
	    sitem:set_count(bag_count * amount)
	
	    inv:add_item("main", sitem)
	end
    end
    
    
end



function base_bench.do_formspec(sel, recipe_array, player)
	local meta = player:get_meta()
	local selected = meta:get_string(sel)

	local F = minetest.formspec_escape

	local items =  base_bench.get_table_element(recipe_array)

	local sel_item
	local item_bag = {}
	local ingredients = {"", "", ""}
	local ing_amount = {0, 0, 0}

	if selected ~= "" then
	    sel_item = player:get_meta():get_string(sel)
	    item_bag = base_bench.get_recipe_stuff(recipe_array, sel_item, "ingredient")
	end

	if item_bag == nil then
		print("item_bag is nil")
		return ""
	end

	local numba = 1
	for name, count in pairs(item_bag) do
		ingredients[numba] = name
		ing_amount[numba] = count
		numba = numba + 1
	end

	local bg_image = "mcl_inventory_background9.png"
	local image_pressed = "mcl_inventory_hotbar_selected.png"


	--~ -- Buttons are 3.5 / 4 = 0.875 wide
	local c = 0
	local items_content = "style_type[item_image_button;noclip=false;content_offset=0]" ..
		(selected ~= "" and "style[" .. base_bench.itemname_to_fieldname(selected) .. ";border=false;bgimg=" .. bg_image  .. ";bgimg_pressed=" .. image_pressed .. ";bgimg_middle=2,2]") 

	for count, name in pairs(items) do
		c = c + 1
		local x = ((c - 1) % 4) * 0.875
		local y = (math.floor((c - 1) / 4)) * 0.875

		items_content = items_content ..
			string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", x, y,
				name, base_bench.itemname_to_fieldname(name), tostring(count))
	end	

	local formspec = table.concat({
		"formspec_version[7]",
		
		
		--Background
		"size[11.75,10.425]",
		
		--Crafting Categories

		-- Container background
		"image[4.25, 0.75;3.6,3.6;mcl_inventory_background9.png;2]",		

		-- ingredients background
		"image[0.65, 0.5;3.0, 1.2;mcl_inventory_background9.png;2]",		
				
		
		--ingredients needed
		"item_image[1.025, 0.5; 1,1;" ..
		 ingredients[1] .. "]",
		 "label[1.025, 1.9;" .. ing_amount[1] .. "]",
		 		
		"item_image[1.9, 0.5; 1,1;" ..
		 ingredients[2] .. "]",
		 "label[1.9, 1.9;" .. ing_amount[2] .. "]",		
		
		"item_image[2.775, 0.5; 1,1;" ..
		 ingredients[3] .. "]",		
		"label[2.775, 1.9;" .. ing_amount[3] .. "]",
		
		-- Scroll Container with buttons if needed
		"scroll_container[4.3,0.85;3.5,3.5;scroll;vertical;3.5]",
		items_content,
		"scroll_container_end[]",
		
		--Available crafting items
		"scrollbaroptions[min=0;max=" .. 10 .. ";smallstep=1;largesteps=5]",
		"scrollbar[7.7,0.75;0.75,3.5;vertical;scroll;0]",
		
		"button[9.5, 1; 1.2, 1;craft1;Craft 1]",
		
		"button[9.5, 1.8; 1.2, 1;craft5;Craft 5]",
		
	
		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",
	
		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",
	})

	return formspec
end

function base_bench.do_crafting(fields, select, recipes, player, show_formspec)
	for field_name, value in pairs(fields) do
	    --Set the selected items when the player presses a item
	    if string.match(field_name, ".*__.*") then
		    local itemname = base_bench.fieldname_to_itemname(field_name)
		    base_bench.set_selected_item(player, select, itemname)
		    
		    show_formspec(player)
	    end
	end
		
	local item_name = player:get_meta():get_string(select)
	
	if fields.craft1 then
	    base_bench.craft_items(player, item_name, recipes, 1)
	end
	
	if fields.craft5 then
	    base_bench.craft_items(player, item_name, recipes, 5)
	end
end



------------------------------------------------------------------------
--Base pattern goes here 
------------------------------------------------------------------------
function metadata_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
	base_bench.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
end

function metadata_inv_take(pos, listname, index, stack, player)
	base_bench.on_metadata_inventory_take(pos, listname, index, stack, player)
end   

--Public
bb_furnace_pattern["_internal_name"] = "komet_mod:unknown_node"
bb_furnace_pattern["description"] = S("unknown node")
bb_furnace_pattern["_tt_help"] = S("None")
bb_furnace_pattern["tiles"] = {"tnt1a0.png"}
bb_furnace_pattern["drawtype"] = "mesh"
bb_furnace_pattern["mesh"] = "box.obj"
bb_furnace_pattern["groups"] = { pickaxey = 1, material_stone = 1, container = 2}
--bb_furnace_pattern["sounds"] = mcl_sounds.node_sound_stone_defaults()
bb_furnace_pattern["_mcl_blast_resistance"] = 3.5
bb_furnace_pattern["_mcl_hardness"] = 3.5

--Private
bb_furnace_pattern["paramtype"] = "light"
bb_furnace_pattern["paramtype2"] = "facedir"
bb_furnace_pattern["is_ground_content"] = false
bb_furnace_pattern["allow_metadata_inventory_put"] = base_bench.allow_metadata_inventory_put
bb_furnace_pattern["allow_metadata_inventory_move"] = base_bench.allow_metadata_inventory_move
bb_furnace_pattern["allow_metadata_inventory_take"] = base_bench.allow_metadata_inventory_take
bb_furnace_pattern["on_metadata_inventory_move"] = metadata_inv_move
bb_furnace_pattern["on_metadata_inventory_take"] = metadata_inv_take
bb_furnace_pattern["on_receive_fields"] = base_bench.receive_fields


function base_bench.get_furnace_pattern()
    return bb_furnace_pattern
end

function base_bench.get_bench_pattern()
    return bb_bench_pattern
end

return base_bench
