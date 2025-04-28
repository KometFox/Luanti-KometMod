minetest.register_node("komet_mod:test_block", {
	description = "Test Block",
	tiles = {
		"node_test_cube.png",
	},
	is_ground_content = true,
	groups = {oddly_breakable_by_hand = 5},
	drop = "mcl_core:coal"
})

minetest.register_node("komet_mod:free_recipe", {
	description = "Free Recipe",
	range = 0,
	stack_max = 0,
	tiles = {"tnt1a0.png"},
})

