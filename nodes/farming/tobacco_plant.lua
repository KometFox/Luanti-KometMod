local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("komet_mod:tobacco_seeds", {
	description = S("Tobacco Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a tobacco plant"),
	groups = {craftitem = 1, compostability = 30},
	inventory_image = "mcl_farming_wheat_seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "komet_mod:tobacco_plant_1")
	end
})

for i=1,4 do
	local create, name, longdesc
	if i == 1 then
		create = true
		name = S("Premature Tobacco Plant")
		longdesc = S("Tobacco plants grow in 4 stages.") 
	else
		create = false
	end

	minetest.register_node("komet_mod:tobacco_plant_" .. i, {
		description = S("Premature Tobacco Plant (Stage @1)", i),
		_doc_items_create_entry = create,
		_doc_items_entry_name = name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 3,
		sunlight_propagates = true,
		walkable = false,
		drop = "komet_mod:tobacco_seeds",
        drawtype = "mesh",
        mesh = "tobacco_" .. (i) .. ".obj",
		tiles = {"tobacco_stage_" .. (i) .. ".png"},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1,
			dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1},
		--sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
	})
end

minetest.register_node("komet_mod:tobacco_plant", {
	description = S("Mature Tobacco Plant"),
	_doc_items_longdesc = S("Mature Tobacco plants can be harvested for tobacco leaves and seeds."),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "mesh",
    mesh = "tobacco_4.obj",
	tiles = {"tobacco_stage_4.png"},    
   	drop = {
		max_items = 5,
		items = {
			{ items = {"komet_mod:tobacco_seeds"}},
			{ items = {"komet_mod:tobacco_seeds"}, rarity = 3},
			{ items = {"komet_mod:tobacco_leaves"}},
			{ items = {"komet_mod:tobacco_leaves"}},
			{ items = {"komet_mod:tobacco_leaves"}},
		}
	},         
              
	groups = {dig_immediate=3, not_in_creative_inventory=0, plant=1, attached_node=1,
		dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

mcl_farming:add_plant("plant_tobacco", "komet_mod:tobacco_plant", {"komet_mod:tobacco_plant_1", "komet_mod:tobacco_plant_2", "komet_mod:tobacco_plant_3", "komet_mod:tobacco_plant_4"}, 25, 20)

minetest.register_craftitem("komet_mod:tobacco_leaves", {
	description = S("Tobacco Leaves"),
	_doc_items_longdesc = S("Tobacco leaves are used to make cigarette products."),
	inventory_image = "tobacco_leaves_icon.png",
	groups = {craftitem = 1, compostability = 65},
})


if minetest.get_modpath("doc") then
    for i = 2, 4 do
        doc.add_entry_alias("nodes", "komet_mod:wheat_1", "nodes", "komet_mod:tobacco_plant_"  .. i)
    end
end
