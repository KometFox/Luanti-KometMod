minetest.register_node("komet_mod:copper_powerdrill", {
	description = "Copper PowerDrill",
    stack_max = 1,
    tiles = {"copper_powerdrill.png"},
    drawtype = "mesh",
    mesh="copper_powerdrill.obj",
	inventory_image = "copper_powerdrill_icon.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=5, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		damage_groups = {fleshy = 3},
		punch_attack_uses = 64,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_copper:copper_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 12, level = 4, uses = 300 }
	},
})



