------------------------------------------------------------------------
--[[
Komet Mod's Basic Bench. Used for crafting various items which uses
a classic crafting system instead of minetest crafting grid system.

several code snippets are taken from Voxelibre implementation of 
mcl_stonecutter
--]]
------------------------------------------------------------------------
local base_bench = dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
local S = minetest.get_translator("stone_transformer")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:stone_transformer"
local SELECT = "komet_mod:stone_transformer_select"

kometmod_stone_transformer = {}
kometmod_stone_transformer_recipe = {}

function kometmod_stone_transformer.register_recipe(recipe)
	table.insert(kometmod_stone_transformer_recipe, recipe)
end


function kometmod_stone_transformer.show_stone_transformer_form(player)
	show_formspec(player:get_player_name(), formspec_name, base_bench.do_formspec(SELECT, kometmod_stone_transformer_recipe, player))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then 
		return 
	end

	base_bench.do_crafting(fields, SELECT, kometmod_stone_transformer_recipe, player, kometmod_stone_transformer.show_stone_transformer_form)

end)


minetest.register_node("komet_mod:stone_transformer_bench", {
	description = "Stone Transformer Bench",
	_tt_help = "Used to craft custom items",
	tiles = {"stone_transformer.png"},
	drawtype = "mesh",
	mesh = "stone_transformer.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 1 , axey = 1},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			kometmod_stone_transformer.show_stone_transformer_form(player)
		end
	end,
})

-------------------------------------------------------------------------
--Register Recipes here 
-------------------------------------------------------------------------


---Blocks---------------------------------------------------------------
local blocky = {}

table.insert(blocky, block_stone)
table.insert(blocky, block_stonebrick)
table.insert(blocky, block_granite)
table.insert(blocky, block_andesite)
table.insert(blocky, block_diorite)
table.insert(blocky, block_sandstone)
table.insert(blocky, block_redsandstone)
table.insert(blocky, item_clayball)
table.insert(blocky, block_ice)
table.insert(blocky, block_sand)
table.insert(blocky, block_gravel)

--Support for Marinara mod
if minetest.get_modpath("marinara") then
    table.insert(blocky, "marinara:coastbricks")
end

--Support for Natural Biomes mod
if minetest.get_modpath("naturalbiomes") then
    table.insert(blocky, "naturalbiomes:mediterran_rock")
    table.insert(blocky, "naturalbiomes:alpine_rock")
    table.insert(blocky, "naturalbiomes:palmbeach_sand")
    table.insert(blocky, "naturalbiomes:palmbeach_rock")
    table.insert(blocky, "naturalbiomes:beach_rock")
    table.insert(blocky, "naturalbiomes:bambooforest_rock")
    table.insert(blocky, "naturalbiomes:outback_rockformation1")
end

function kometmod_stone_transformer.add_stones(item_name)
    local recipe = {}
    
    recipe["recipe_name"] = item_name
    recipe["ingredient"] = {[block_cobblestone] = 10, ["komet_mod:stoneheart_crystal"] = 1}
    recipe["give_items"] = {[item_name] = 10}

    kometmod_stone_transformer.register_recipe(recipe)
end

function reverse_stone()
    local recipe = {}

    recipe["recipe_name"] = block_cobblestone
    recipe["ingredient"] = {["komet_mod:stoneheart_crystal"] = 1}
    recipe["give_items"] = {[block_cobblestone] = 10}

    kometmod_stone_transformer.register_recipe(recipe)
end

reverse_stone()

for _, v in pairs(blocky) do
    kometmod_stone_transformer.add_stones(v)
end
