minetest.register_craftitem("komet_mod:table_salt", {
	description = "Table Salt",
	inventory_image = "table_salt_icon.png",
	stack_max = 100,
	groups = { craftitem = 1 },
	_mcl_toollike_wield = true,
})

local function make_item_3d(item_name, item_desc)
	minetest.register_node(item_name, {
		description = item_desc.description,
		range = 0,
		stack_max = item_desc.stack_max,
		tiles = item_desc.tiles,
		inventory_image = item_desc.icon, 
		drawtype="mesh",
		mesh=item_desc.mesh,
		groups={cracky=2},
	})
end

make_item_3d("komet_mod:item_material",
				{
					stack_max = 100,
					icon = "build_material_icon.png",
					description = "Building Material",
					tiles = {"default_brick.png", "default_wood.png"},
					mesh = "build_material.glb"})


make_item_3d("komet_mod:orethyst",
				{
					stack_max = 50,
					icon = "ore_crystal.png",
					description = "Ore Crystal",
					tiles = {"wool_magenta.png", "mcl_stairs_stone_slab_top.png"},
					mesh = "neo_crystal.glb"})

make_item_3d("komet_mod:stoneheart_crystal",
				{
					stack_max = 50,
					icon = "stone_crystal.png",
					description = "Stone Crystal",
					tiles = {"wool_yellow.png", "mcl_stairs_stone_slab_top.png"},
					mesh = "neo_crystal.glb"})


