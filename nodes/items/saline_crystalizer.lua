local S = minetest.get_translator("kometmod_saline_crystalizer")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:saline_crystalizer"
local SELECT = "komet_mod:saline_crystalizer"

kometmod_saline_crystalizer = {}
kometmod_saline_crystalizer_recipes = {}
         
local sc_timer
local sc_timer_start = 12 --in seconds
local last_pos = {x = 0, y = 0, z = 0}

local function change_liquid_texture(texture) 
    

end


local function build_saline_crystalizer_formspec(player)
    local F = minetest.formspec_escape

    local img_water = "mcl_colorblocks_concrete_blue.png"
	local img_bg = "mcl_inventory_background9.png"
	local img_pressed = "mcl_inventory_hotbar_selected.png"

	local formspec = table.concat({
		"formspec_version[7]",
		
		--Background
		"size[11.75,10.425]",

        --Input Slot
        --~ mcl_formspec.get_itemslot_bg_v4(1.5, 1, 1, 1),
		"image[1.5,1.0;1.0,1.0;" .. img_bg  .. ";2]",
        "list[context;src;1.5, 1.0;1, 1;]",
        
        --Output Slot
		"image[1.5,2.25;1.0,1.0;" .. img_bg  .. ";2]",
        --~ mcl_formspec.get_itemslot_bg_v4(1.5, 2.25, 1, 1),
        "list[context;dst;1.5, 2.25;1, 1;]",

        --Timer count
        --"label[3.0, 2.25;" .. tostring(sc_timer:get_timeout()) .. "]",
        
	---Button switcher 
	--Orethyst
	"image_button[4.0, 1.0; 1,1;orethyst.png;orethyst;Orethyst]",
	
	--Stoneheart Crystal
	"image_button[5.0, 1.0; 1,1;stoneheart_crystal.png;stoneheart;Stoneheart]",
	
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


function kometmod_saline_crystalizer.show_basic_bench_form(pos, player)
	last_pos = pos
	show_formspec(player:get_player_name(), formspec_name, build_saline_crystalizer_formspec(player))
end


function kometmod_saline_crystalizer.start_timer(pos)
    sc_timer = minetest.get_node_timer(pos)
    sc_timer:start(sc_timer_start)
end


function kometmod_saline_crystalizer.process_item(pos)
    if pos == nil then
        print("kometmod_saline_crystalizer.process_item has no pos value!")
        return
    end

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local input_item = inv:get_stack("src", 1)
    local output_item = inv:get_stack("dst", 1)
    local selected_item = meta:get_string("selected_item")

    local new_item = ItemStack(selected_item)
    new_item:set_count(2)

    if input_item:get_name() == "komet_mod:table_salt" and input_item:get_count() >= 8 then
        inv:add_item("dst", new_item)
 
	input_item:set_count(input_item:get_count() - 8) 
	inv:set_stack("src", 1, input_item)
    end

end

function wbp_on_rightclick(pos, node, player, itemstack)
    if not player:get_player_control().sneak then
        last_player = player:get_player_name()
        kometmod_saline_crystalizer.show_basic_bench_form(pos, player)
    end
end
    
function wbp_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    meta:set_string("formspec", formspec_name)
    meta:set_string("selected_item", "komet_mod:orethyst")
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    
    kometmod_saline_crystalizer.start_timer(pos)
end

function wbp_on_timer(pos, elapsed)
    if pos then
        kometmod_saline_crystalizer.process_item(pos)
    end
    
    return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then 
		return 
	end
	
	local meta = minetest.get_meta(last_pos)

	if fields.orethyst then
	    meta:set_string("selected_item", "komet_mod:orethyst")
	end
	
	if fields.stoneheart then
	    meta:set_string("selected_item", "komet_mod:stoneheart_crystal")
	end
	
	
end)




local base_bench = dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
local sc_pattern = base_bench.get_furnace_pattern()

sc_pattern["_internal_name"] = "komet_mod:saline_crystalizer"
sc_pattern["description"] = "Saline Crystalizer"
sc_pattern["_tt_help"] = "Used to crystalize water and salt together"
sc_pattern["tiles"] = {"saline_crystalizer.png"}
sc_pattern["mesh"] = "saline_crystalizer.obj"
sc_pattern["groups"] = { cracky = 1, container = 2}
--sc_pattern["sounds"] = mcl_sounds.node_sound_stone_defaults()
sc_pattern["_mcl_blast_resistance"] = 3.5
sc_pattern["_mcl_hardness"] = 3.5
sc_pattern["on_rightclick"] = wbp_on_rightclick
sc_pattern["on_construct"] = wbp_on_construct
sc_pattern["on_timer"] = wbp_on_timer

base_bench.register_node(sc_pattern)
