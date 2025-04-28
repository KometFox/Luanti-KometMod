------------------------------------------------------------------------
--New Basic Bench code v2.0, code heavily modified from mcl_stonecutter 
--TODO: Refactor code some more
------------------------------------------------------------------------
local S = minetest.get_translator("komet_mod_basic_bench")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:basic_bench"

komet_mod_basic_bench = {}

komet_mod_basic_bench.bb_recipes = {}

---@param itemname string
local function itenname_to_fieldname(itemname)
	return string.gsub(itemname, ":", "__")
end

---@param fieldname string
local function fieldname_to_itemname(fieldname)
	return string.gsub(fieldname, "__", ":")
end

-- Get the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@return integer
local function get_stack_size(player)
	return player:get_meta():get_int("komet_mod:switch_stack")
end

-- Set the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@param n integer
local function set_stack_size(player, n)
	player:get_meta():set_int("komet_mod:switch_stack", n)
end

---Change the selected output item.
---@param player mt.PlayerObjectRef
---@param item_name? string The item name of the output
function set_selected_item(player, item_name)
	player:get_meta():set_string("komet_mod:basic_bench_selected", item_name and item_name or "")
end


function iterate_subtable(subtable)
-- if e is a table, we should iterate over its elements
    for k,v in pairs(subtable) do -- for every element in the table
        if type(v) == "table" then
          --~ print(k)
          iterate_subtable(v)       -- recursively repeat the same procedure
        else -- if not, we can just print it
          --~ print(k .. v)
          return k, v          
        end
    end
end

local function get_recipe_name(name)
    local returnval = {}
    
    for k, v in pairs(komet_mod_basic_bench.bb_recipes) do
        for k2, v2 in pairs(k) do
          
            for k3, v3 in pairs(v) do

                if name == k2 then
                    returnval[k2] = k3
                end
            
            end
        end
    end
    
    return returnval
end

local function get_list_of_recipes(recipe)
    local subtables = komet_mod_basic_bench.bb_recipes or {}
    local return_value = {}
    
    --~ if not subtables then
        --~ return error("Invalid Table")
    --~ end
    

    --iterate through the first sub tables
    for k, v in pairs(subtables) do
        --then the sub tables
        for k2, v2 in pairs(v) do 
            --get the pre result
            for k3, v3 in pairs(k2) do


                --now the final result
                if recipe == k3 then
                    --~ print("TRUE:", recipe)
                    
                    for k4, v4 in pairs(v2) do
                        --~ print("JUNK: ", k4, v4)
                        table.insert(return_value, k4)
                    end
                    
                end
                
            end
        end        
    end    
    
    return return_value

end


local function get_ingredient_table(ing)
    local recipes = komet_mod_basic_bench.bb_recipes or {}
    local return_value = {}
    
    for k, v in pairs(recipes) do
        for k2, v2 in pairs(v) do
            for k3, v3 in pairs(k2) do
            
                return_value[k3] = v3
            end
        end
    end
    
    return return_value
    
end
    





local function build_basic_bench_formspec(player)
	local meta = player:get_meta()
    local inv = player:get_inventory()
	local selected = meta:get_string("komet_mod:basic_bench_selected")
    local input_slots = {}
    
    local input = {}
    local recipes = {}
    local items = {}
    local item_dict = {}
    
    for i = 1, 3 do
        input[i] = inv:get_stack("basic_bench_input" .. tostring(i), 1)
        
        if input[i] then
            recipes = get_list_of_recipes(input[i]:get_name())
        end
    end

    item_dict = recipes
    
    if item_dict == table then
        for k, v in pairs(item_dict) do
            items = v            
        end
    end
    
	-- Buttons are 3.5 / 4 = 0.875 wide
    
	local c = 0
	local items_content = "style_type[item_image_button;noclip=false;content_offset=0]" ..
		(selected ~= "" and "style[" .. itenname_to_fieldname(selected) .. ";border=false;bgimg=mcl_inventory_button9_pressed.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]" or "")

    --~ items_content = items_content ..
        --~ string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", ((1 - 1) % 4) * 0.875, (math.floor((1 - 1) / 4)) * 0.875,
            --~ "mcl_farm:Wheat", "mcl_farm:Wheat", tostring(1))

    for count, name in table.pairs_by_keys(item_dict) do
        --~ print("Item Grids: ", count, name)
    
        c = c + 1
        local x = ((c - 1) % 4) * 0.875
        local y = (math.floor((c - 1) / 4)) * 0.875

        items_content = items_content ..
            string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", x, y,
                name, itenname_to_fieldname(name), tostring(count))
    end
    
    
    
	local formspec = table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. C(mcl_formspec.label_color, S("Basic Bench")) .. "]",

        --
        --Input
        --
        mcl_formspec.get_itemslot_bg_v4(0.1, 1, 1, 1),
        "list[current_player;basic_bench_input1;0.1, 1;1 ,1;]",
        mcl_formspec.get_itemslot_bg_v4(1.3, 1, 1, 1),
        "list[current_player;basic_bench_input2;1.3, 1;1 ,1;]",
        mcl_formspec.get_itemslot_bg_v4(2.5, 1, 1, 1),
        "list[current_player;basic_bench_input3;2.5, 1;1 ,1;]",

		-- Container background
		"image[4.075,0.7;3.6,3.6;mcl_inventory_background9.png;2]",

		-- Style for item image buttons
		"style_type[item_image_button;noclip=false;content_offset=0]",

		-- Scroll Container with buttons if needed
		"scroll_container[4.125,0.75;3.5,3.5;scroll;vertical;0.875]",
		items_content,
		"scroll_container_end[]",

		-- Scrollbar
		-- TODO: style the scrollbar correctly when possible
		"scrollbaroptions[min=0;max=" ..
		math.max(math.floor(#items / 4) + 1 - 4, 0) .. ";smallstep=1;largesteps=1]",
		"scrollbar[7.625,0.7;0.75,3.6;vertical;scroll;0]",

		-- Switch stack size button
		--"image_button[9.75,0.75;1,1;mcl_stonecutter_saw.png^[verticalframe:3:1;__switch_stack;]",
		--"label[10.25,1.5;" .. C("#FFFFFF", tostring(get_stack_size(player))) .. "]",
		--"tooltip[__switch_stack;" .. S("Switch stack size") .. "]",

        --
        --Output 
        --
        mcl_formspec.get_itemslot_bg_v4(8.7, 1, 1, 1, 0.1),
        "list[current_player;basic_bench_output1;8.7,1;1,1;]",
        mcl_formspec.get_itemslot_bg_v4(10.1, 1, 1, 1, 0.1),
        "list[current_player;basic_bench_output2;10.1,1;1,1;]",
        mcl_formspec.get_itemslot_bg_v4(8.7, 2.3, 1, 1, 0.1),
        "list[current_player;basic_bench_output3;8.7,2.3;1,1;]",   

		-- Player inventory
		"label[0.375,4.7;" .. C(mcl_formspec.label_color, S("Inventory")) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[current_player;basic_bench_output1]",
        "listring[current_player;basic_bench_output2]",
        "listring[current_player;basic_bench_output3]",
		"listring[current_player;main]",
		"listring[current_player;basic_bench_input1]",
        "listring[current_player;basic_bench_input2]",
        "listring[current_player;basic_bench_input3]",
		"listring[current_player;main]",
	})      

    return formspec
end


function komet_mod_basic_bench.show_basic_bench_form(player)
	show_formspec(player:get_player_name(), formspec_name,
		build_basic_bench_formspec(player, komet_mod_basic_bench.bb_recipes[player:get_inventory():get_stack("basic_bench_input1", 1):get_name()]))
end

function komet_mod_basic_bench.register_recipe(name, input, output)
    local new_dict = {}
    new_dict[input] = output

    komet_mod_basic_bench.bb_recipes[name] = new_dict
end


function set_selected_item(player, item_name)
	player:get_meta():set_string("komet_mod:basic_bench_selected", item_name and item_name or "")
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

    for i = 1, 3 do
        inv:set_size("basic_bench_input" .. tostring(i), 1)
        inv:set_size("basic_bench_output" .. tostring(i), 1)
    end

	set_selected_item(player, nil)

	--The player might have items remaining in the slots from the previous join; this is likely
	--when the server has been shutdown and the server didn't clean up the player inventories.
	for i = 1, 3 do
        mcl_util.move_player_list(player, "basic_bench_input" .. tostring(i))
        player:get_inventory():set_list("basic_bench_output" .. tostring(i), {})
    end

end)


minetest.register_on_leaveplayer(function(player)
	set_selected_item(player, nil)

    for i = 1, 3 do
        mcl_util.move_player_list(player, "basic_bench_input" .. tostring(i))
        player:get_inventory():set_list("basic_bench_output" .. tostring(i), {})
    end
    
end)


function update_basic_bench_slots(player)
	local meta = player:get_meta()
	local inv = player:get_inventory()

	local input = inv:get_stack("basic_bench_input1", 1)
	local recipes = get_list_of_recipes(input:get_name())
    local output_item = meta:get_string("komet_mod:basic_bench_selected")
	local stack_size = meta:get_int("komet_mod:switch_stack")
 
    for i = 1, 3 do
    
        if recipes then
            if output_item then
                
                local recipe = {}
                
                for k, v in pairs(recipes) do
                    recipe[v] = k
                end
                
                local cut_item = {}
                cut_item[i] = ItemStack(output_item)
                local count = math.min(math.floor(stack_size), cut_item[i]:get_count())
                cut_item[i]:set_count(count)

                print("==================")
                print(cut_item[i])
                print(count)

                if cut_item[i] then
                    inv:set_stack("basic_bench_output" .. tostring(i), 1, cut_item[i])
                else
                    inv:set_stack("basic_bench_output" .. tostring(i), 1, nil)
                end
                
                
            end
        end
    end

	komet_mod_basic_bench.show_basic_bench_form(player)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then return end

	if fields.quit then
        for i = 1, 3 do
            mcl_util.move_player_list(player, "basic_bench_input" .. tostring(i))
            player:get_inventory():set_list("basic_bench_output" .. tostring(i), {})
        end
		return
	end

	if fields.__switch_stack then
		local switch = 1
		if get_stack_size(player) == 1 then
			switch = 5
		end
		set_stack_size(player, switch)
		update_basic_bench_slots(player)
		komet_mod_basic_bench.show_basic_bench_form(player)
		return
	end

	for field_name, value in pairs(fields) do
		if field_name ~= "scroll" then
			local itemname = fieldname_to_itemname(field_name)
			player:get_meta():set_string("komet_mod:basic_bench_selected", itemname)
			set_selected_item(player, itemname)
			update_basic_bench_slots(player)
			komet_mod_basic_bench.show_basic_bench_form(player)
			break
		end
	end
end)


minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    for i = 1, 3 do
        if action == "move" then
            if inventory_info.to_list == "basic_bench_output" .. tostring(i) then
                return 0
            end
    
            if inventory_info.from_list == "basic_bench_output" .. tostring(i) and inventory_info.to_list == "basic_bench_input" .. tostring(i) then
                if inventory:get_stack(inventory_info.to_list, inventory_info.to_index):is_empty() then
                    return inventory_info.count
                else
                    return 0
                end
            end
    
            if inventory_info.from_list == "basic_bench_output" .. tostring(i) then
                local selected = player:get_meta():get_string("komet_mod:basic_bench_selected")
                
                local istack = {}
                istack[i] = inventory:get_stack("basic_bench_input" .. tostring(i), 1)
                local recipes = {}
                
                if recipes then
                
                    recipes[i] = get_list_of_recipes(istack[i]:get_name())
                        
                    if recipes[i] == nil then
                        recipes[i] = 0
                    end
                
                    if not selected or not recipes then 
                        return 0 
                    end
                    
                    local recipe = recipes
                    local remainder = inventory_info.count % 1
                    
                    if remainder ~= 0 then
                
                        return 0
                    end
                    
                end
            end
        elseif action == "put" then
            if inventory_info.to_list == "basic_bench_output" .. tostring(i) then
                return 0
            end
            if inventory_info.from_list == "basic_bench_output" .. tostring(i) then
                local selected = player:get_meta():get_string("komet_mod:basic_bench_selected")
                local istack = {}
                istack[i] = inventory:get_stack("basic_bench_input" .. tostring(i), 1)
                local recipes = {}
                
                recipes = get_list_of_recipes(istack:get_name())
                if not selected or not recipes then return 0 end
                local recipe = recipes[selected]
                local remainder = inventory_info.stack:get_count() % recipe
                if remainder ~= 0 then
                    return 0
                end
            end
        end
    end
end)



function remove_from_input(player, inventory, crafted_count)
	local meta = player:get_meta()
	local selected = meta:get_string("komet_mod:basic_bench_selected")
	local istack = {}
    local recipes = {}
    local stack_size = {}
    
    for i = 1, 3 do
    
        istack[i] = inventory:get_stack("basic_bench_input" .. tostring(i), 1)
        recipes[i] = get_list_of_recipes(istack[i]:get_name())
        stack_size[i] = meta:get_int("komet_mod:switch_stack")
    
        -- selected should normally never be nil, but just in case
        if selected and recipes[i] then
            local recipe = {}
            recipe[i] = recipes[selected]
            
            if recipe[i] then
                local count = crafted_count/recipe[i]
                if count < 1 then count = 1 end
                istack[i]:set_count(math.max(0, istack[i]:get_count() - count))
                inventory:set_stack("basic_bench_input" .. tostring(i), 1, istack[i])
            end
            
        end
    end
end


minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    for i = 1, 3 do
        if action == "move" then
            if inventory_info.to_list == "basic_bench_input" .. tostring(i) or inventory_info.from_list == "basic_bench_input" .. tostring(i) then
                update_basic_bench_slots(player)
                return
            elseif inventory_info.from_list == "basic_bench_output" .. tostring(i) then
                remove_from_input(player, inventory, inventory_info.count)
                update_basic_bench_slots(player)
            end
        elseif action == "put" then
            if inventory_info.listname == "basic_bench_input" .. tostring(i) or inventory_info.listname == "basic_bench_input" .. tostring(i) then
                update_basic_bench_slots(player)
            end
        elseif action == "take" then
            if inventory_info.listname == "basic_bench_output" .. tostring(i) then
                remove_from_input(player, inventory, inventory_info.stack:get_count())
                update_basic_bench_slots(player)

            end
        end
    end    

end)

minetest.register_node("komet_mod:basic_bench", {
	description = "Basic Bench",
	_tt_help = "Used to craft custom items",
	tiles = {"basic_bench.png"},
	drawtype = "mesh",
	mesh = "basic_bench.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey = 1, material_wood = 1 },
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			komet_mod_basic_bench.show_basic_bench_form(player)
		end
	end,
})

local add_ingredient = {}
local add_recipe = {}

------------------------------------------------------------------------
--Cases
------------------------------------------------------------------------
add_ingredient = {["mcl_copper:copper_ingot"] = 1}
add_recipe = {["komet_mod:9x19mmCase"] = 10}
komet_mod_basic_bench.register_recipe("9x19mmCase", add_ingredient, add_recipe)
------------------------------------------------------------------------
--Ammo
------------------------------------------------------------------------
add_ingredient = {["mcl_copper:copper_ingot"] = 2, ["mcl_mobitems:gunpowder"] = 2, ["komet_mod:9x19mmCase"] = 10}
add_recipe = {["komet_mod:9x19mmBullet"] = 10}
komet_mod_basic_bench.register_recipe("9x19mmBullet", add_ingredient, add_recipe)

------------------------------------------------------------------------
--Guns
------------------------------------------------------------------------
add_ingredient = {["mcl_copper:copper_ingot"] = 2, ["mcl_copper:iron_ingot"] = 3}
add_recipe = {["komet_mod:gun_enforcer"] = 1}
komet_mod_basic_bench.register_recipe("Enforcer", add_ingredient, add_recipe)

add_ingredient = {["mcl_copper:copper_ingot"] = 4, ["mcl_copper:iron_ingot"] = 10}
add_recipe = {["komet_mod:gun_bekas_12m"] = 1}
komet_mod_basic_bench.register_recipe("Bekas 12m", add_ingredient, add_recipe)
