------------------------------------------------------------------------
--[[
Komet Mod's Basic Bench. Used for crafting various items which uses
a classic crafting system instead of minetest crafting grid system.

several code snippets are taken from Voxelibre implementation of 
mcl_stonecutter
--]]
------------------------------------------------------------------------
local base_bench = dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
local S = minetest.get_translator("kometmod_basic_bench")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:basic_bench"
local SELECT = "komet_mod:basic_bench_select2"

kometmod_basic_bench = {}
kometmod_basic_bench_recipes = {}

function kometmod_basic_bench.register_recipe(recipe)
	table.insert(kometmod_basic_bench_recipes, recipe)
end


function kometmod_basic_bench.show_basic_bench_form(player)
	show_formspec(player:get_player_name(), formspec_name, base_bench.do_formspec(SELECT, kometmod_basic_bench_recipes, player))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then 
		return 
	end

	base_bench.do_crafting(fields, SELECT, kometmod_basic_bench_recipes, player, kometmod_basic_bench.show_basic_bench_form)

end)



minetest.register_node("komet_mod:basic_bench", {
	description = S("Basic Bench"),
	_tt_help = S("Used to craft custom items"),
	tiles = {"CraftingBench.png"},
	drawtype = "mesh",
	mesh = "crafting_bench.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 1, axey = 1},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	--sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			kometmod_basic_bench.show_basic_bench_form(player)
		end
	end,
})

-------------------------------------------------------------------------
--Register Recipes here 
-------------------------------------------------------------------------
minetest.register_craft({
  output = "komet_mod:basic_bench",
  recipe = {
    {"","group:wood", ""},
    {"group:wood","group:wood", ""},
    {"", "", ""},
  },
})



local function add_recipe(items) 
	kometmod_basic_bench.register_recipe(items)

end

add_recipe({
			recipe_name = "komet_mod:stone_transformer_bench", 
			ingredient = {["komet_mod:item_material"] = 5}, 
			give_items = {["komet_mod:stone_transformer_bench"] = 1}})

add_recipe({
			recipe_name = "komet_mod:ammo_bench", 
			ingredient = {["komet_mod:item_material"] = 2}, 
			give_items = {["komet_mod:ammo_bench"] = 1}})

add_recipe({
			recipe_name = "komet_mod:water_boiler", 
			ingredient = {["komet_mod:item_material"] = 3}, 
			give_items = {["komet_mod:water_boiler"] = 1}})

add_recipe({
			recipe_name = "komet_mod:saline_crystalizer", 
			ingredient = {["komet_mod:item_material"] = 10}, 
			give_items = {["komet_mod:saline_crystalizer"] = 1}})

add_recipe({
			recipe_name = "komet_mod:item_material",
			ingredient = {[block_cobblestone] = 5}, 
			give_items = {["komet_mod:item_material"] = 2}})
			
add_recipe({
			recipe_name = "komet_mod:basic_filter",
			ingredient = {[item_coal_ore] = 2}, 
			give_items = {["komet_mod:basic_filter"] = 1}})			

add_recipe({
			recipe_name = item_coal_ore, 
			ingredient = {["komet_mod:orethyst"] = 1}, 
			give_items = {[item_coal_ore] = 2}})

add_recipe({
			recipe_name = item_copper_ore, 
			ingredient = {["komet_mod:orethyst"] = 1}, 
			give_items = {[item_copper_ore] = 2}})

add_recipe({
			recipe_name = item_iron_ore, 
			ingredient = {["komet_mod:orethyst"] = 1}, 
			give_items = {[item_iron_ore] = 1}})

add_recipe({
			recipe_name = item_gold_ore, 
			ingredient = {["komet_mod:orethyst"] = 2}, 
			give_items = {[item_gold_ore] = 1}})

add_recipe({
			recipe_name = item_diamond_ore, 
			ingredient = {["komet_mod:orethyst"] = 8}, 
			give_items = {[item_diamond_ore] = 1}})


if minetest.get_modpath("moreores") then
    kometmod_basic_bench.register_recipe({recipe_name = "moreores:tin_lump", ingredient = {["komet_mod:orethyst"] = 1}, give_items = {["moreores:tin_lump"] = 2}})
    kometmod_basic_bench.register_recipe({recipe_name = "moreores:silver_lump", ingredient = {["komet_mod:orethyst"] = 1}, give_items = {["moreores:silver_lump"] = 1}})
    kometmod_basic_bench.register_recipe({recipe_name = "moreores:mithril_lump", ingredient = {["komet_mod:orethyst"] = 3}, give_items = {["moreores:mithril_lump"] = 1}})
end

if minetest.get_modpath("technic") then
    kometmod_basic_bench.register_recipe({recipe_name = "technic:zinc_lump", ingredient = {["komet_mod:orethyst"] = 1}, give_items = {["technic:zinc_lump"] = 2}})
    kometmod_basic_bench.register_recipe({recipe_name = "technic:lead_lump", ingredient = {["komet_mod:orethyst"] = 1}, give_items = {["technic:lead_lump"] = 2}})
    kometmod_basic_bench.register_recipe({recipe_name = "technic:chromium_lump", ingredient = {["komet_mod:orethyst"] = 2}, give_items = {["technic:chromium_lump"] = 1}})
    kometmod_basic_bench.register_recipe({recipe_name = "technic:uranium_lump", ingredient = {["komet_mod:orethyst"] = 3}, give_items = {["technic:uranium_lump"] = 1}})
    kometmod_basic_bench.register_recipe({recipe_name = "technic:sulfur_lump", ingredient = {["komet_mod:orethyst"] = 1}, give_items = {["technic:sulfur_lump"] = 2}})

end
