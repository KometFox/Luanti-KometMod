local S = minetest.get_translator("kometmod_water_boiler")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:water_boiler"
local SELECT = "komet_mod:water_boiler_select"

kometmod_water_boiler = {}
kometmod_water_boiler_recipes = {}
         
local last_player 
local timer
local timer_start = 14 --in seconds

local function change_liquid_texture(texture) 
    

end


local function build_water_boiler_formspec(player)
    local F = minetest.formspec_escape


    local img_water = "mcl_colorblocks_concrete_blue.png"
	local img_bg = "mcl_inventory_background9.png"
	local img_pressed = "mcl_inventory_hotbar_selected.png"


	local formspec = table.concat({
		"formspec_version[7]",
		
		--Background
		"size[11.75,10.425]",

        --Input Slot
		"image[1.5,1.0;1.0,1.0;" ..  img_bg  ..";2]",
        "list[context;src;1.5, 1.0;1, 1;]",
        
        --Output Slot
		"image[1.5,2.25;1.0,1.0;" ..  img_bg  ..";2]",
        "list[context;dst;1.5, 2.25;1, 1;]",

        --Timer count
        --"label[3.0, 2.25;" .. tostring(timer:get_timeout()) .. "]",
        
        --Liquid slot
        "image[3.0, 1.0;1, 1;" .. img_water .. ";]",

		
	-- Player inventory
        "label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

        mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
        "list[current_player;main;0.375,5.1;9,3;9]",

        mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
        "list[current_player;main;0.375,9.05;9,1;]",
		
        "listring[context;dst]",
        "listring[current_player;main]",
        "listring[context;src]",
	})

	return formspec
end


function kometmod_water_boiler.show_basic_bench_form(player)
	show_formspec(player:get_player_name(), formspec_name, build_water_boiler_formspec(player))
end


function kometmod_water_boiler.start_timer(pos)
    timer = minetest.get_node_timer(pos)
    timer:start(timer_start)
end


function kometmod_water_boiler.process_item(pos)
    if pos == nil then
        print("kometmod_water_boiler.process_item has no pos value!")
        return
    end

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local input_item = inv:get_stack("src", 1)
    local output_item = inv:get_stack("dst", 1)

    local new_item = ItemStack("komet_mod:table_salt")
    new_item:set_count(5)

    if input_item:get_name() == "komet_mod:basic_filter" then
        inv:add_item("dst", new_item)
    end

end

function wbp_on_rightclick (pos, node, player, itemstack)
    if not player:get_player_control().sneak then
        last_player = player:get_player_name()
        kometmod_water_boiler.show_basic_bench_form(player)
    end
end
    
function wbp_on_construct (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    meta:set_string("formspec", formspec_name)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    
    kometmod_water_boiler.start_timer(pos)
end

function wbp_on_timer (pos, elapsed)
    if pos then
        kometmod_water_boiler.process_item(pos)
    end
    
    return true
end

local base_bench = dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
local wb_pattern = base_bench.get_furnace_pattern()

wb_pattern["_internal_name"] = "komet_mod:water_boiler"
wb_pattern["description"] = "Water Boiler"
wb_pattern["_tt_help"] = "Used to boil water"
wb_pattern["tiles"] = {"water_boiler.png"}
wb_pattern["mesh"] = "water_boiler.obj"
wb_pattern["groups"] = { cracky = 1, container = 2}
--wb_pattern["sounds"] = mcl_sounds.node_sound_stone_defaults()
wb_pattern["_mcl_blast_resistance"] = 3.5
wb_pattern["_mcl_hardness"] = 3.5
wb_pattern["on_rightclick"] = wbp_on_rightclick
wb_pattern["on_construct"] = wbp_on_construct
wb_pattern["on_timer"] = wbp_on_timer

base_bench.register_node(wb_pattern)
