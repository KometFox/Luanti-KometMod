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

make_item_3d("komet_mod:table_salt",
				{
					stack_max = 100,
					icon = "salt_bag_icon.png",
					description = "Table Salt",
					tiles = {"salt_bag.png"},
					mesh = "salt_bag.glb"})

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

make_item_3d("komet_mod:basic_filter",
				{
					stack_max = 50,
					icon = "basic_filter.png",
					description = "Basic Filter",
					tiles = {"mcl_polished_deepslate.png", "mcl_bamboo_bamboo_bottom_stripped.png"},
					mesh = "filter.glb"})
