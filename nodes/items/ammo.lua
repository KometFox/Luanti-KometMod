local function make_item_ammo(item_name, item_desc)
	minetest.register_node(item_name, {
		description = item_desc.description,
		range = 0,
		stack_max = item_desc.stack_max,
		tiles = {item_desc.tiles .. ".png"},
		drawtype="mesh",
		mesh=item_desc.mesh .. ".obj",
		on_use = function(itemstack, user, pointed_thing)
			return itemstack
		end,
		on_place = function(itemstack, user, pointed_thing)
			return itemstack
		end,
	})
end

make_item_ammo("komet_mod:9x19mmCase",
				{
					stack_max = 500,
					description = "9x19mm Case",
					tiles = "9x19mmCase",
					mesh = "9x19mmCase"})

make_item_ammo("komet_mod:9x19mmBullet",
				{
					stack_max = 200,
					description = "9x19mm Bullet",
					tiles = "ammo_9mm",
					mesh = "ammo_box"})

make_item_ammo("komet_mod:12_gauge_case",
				{
					stack_max = 200,
					description = "12 Gauge Case",
					tiles = "12_gauge_hull",
					mesh = "12_gauge"})

make_item_ammo("komet_mod:12_gauge_shell",
				{
					stack_max = 100,
					description = "12 Gauge Shell",
					tiles = "ammo_12g",
					mesh = "ammo_box"})
					
