local base_bench = dofile(minetest.get_modpath("komet_mod") .. "/library/base_bench.lua")
local S = minetest.get_translator("kometmod_ammo_bench")
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local formspec_name = "komet_mod:ammo_bench"
local SELECT = "komet_mod:ammo_bench_select"

kometmod_ammo_bench = {}
kometmod_ammo_bench_recipes = {}

function kometmod_ammo_bench.register_recipe(recipe)
	table.insert(kometmod_ammo_bench_recipes, recipe)
end


function kometmod_ammo_bench.show_ammo_bench_form(player)
	show_formspec(player:get_player_name(), formspec_name, base_bench.do_formspec(SELECT, kometmod_ammo_bench_recipes, player))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then 
		return 
	end

	base_bench.do_crafting(fields, SELECT, kometmod_ammo_bench_recipes, player, kometmod_ammo_bench.show_ammo_bench_form)

end)



minetest.register_node("komet_mod:ammo_bench", {
	description = S("Ammo Bench"),
	_tt_help = S("Used to craft ammunition"),
	tiles = {"mcl_core_planks_big_oak.png", "mcl_wool_lime.png", "mcl_blackstone_top.png", "mcl_colorblocks_concrete_silver.png", "mcl_core_apple_golden.png"},
	drawtype = "mesh",
	mesh = "ammo_bench.glb",
	paramtype = "light",
	paramtype2 = "facedir",
	visualscale = 10,
	groups = {cracky = 1, axey = 1},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			kometmod_ammo_bench.show_ammo_bench_form(player)
		end
	end,
})


local function add_recipe(items) 
	kometmod_ammo_bench.register_recipe(items)

end

add_recipe({
			recipe_name = item_gunpowder, 
			ingredient = {[block_cobblestone] = 2}, 
			give_items = {[item_gunpowder] = 1}})

add_recipe({
			recipe_name = "komet_mod:9x19mmCase", 
			ingredient = {[item_copper_ingot] = 2}, 
			give_items = {["komet_mod:9x19mmCase"] = 10}})

add_recipe({
			recipe_name = "komet_mod:12_gauge_case", 
			ingredient = {[item_copper_ingot] = 2}, 
			give_items = {["komet_mod:12_gauge_case"] = 5}})

add_recipe({
			recipe_name = "komet_mod:9x19mmBullet", 
			ingredient = {["komet_mod:9x19mmCase"] = 10, [item_gunpowder] = 3, [item_copper_ingot] = 2}, 
			give_items = {["komet_mod:9x19mmBullet"] = 10}})

add_recipe({
			recipe_name = "komet_mod:12_gauge_shell", 
			ingredient = {["komet_mod:12_gauge_case"] = 5, [item_gunpowder] = 4, [item_copper_ingot] = 2}, 
			give_items = {["komet_mod:12_gauge_shell"] = 5}})			