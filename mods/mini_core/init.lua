mini_core = {}

--Helper function for shorter file loading
function mini_core.load_file(file)
	dofile(core.get_modpath(core.get_current_modname()).."/"..file..".lua")
end

--Load .lua files
mini_core.load_file("func")
mini_core.load_file("inventory")
mini_core.load_file("creative_inv")
mini_core.load_file("hand")
mini_core.load_file("sounds")
mini_core.load_file("basic_flat_mapgen")
mini_core.load_file("compat")

--Set up player related stuff and sky
core.register_on_joinplayer(function(player)
	player:set_properties({
		visual = "upright_sprite",
		textures = {"mini_player.png", "mini_player_back.png" },
		visual_size = { x = 0.875, y = 1.875 },
		collisionbox = { -0.4375, 0, -0.4375, 0.4375, 1.875, 0.4375 },
		eye_height = 1.75,
	})
	player:set_fov(65, false)
	player:hud_set_hotbar_image("mini_hotbar.png")
	player:hud_set_hotbar_selected_image("mini_hotbar_selected.png")
	player:set_minimap_modes({
	{
		type = "off",
		label = "Map disabled"
	},
	{
		type = "surface",
		label = "Map enabled",
		size = 75
	},
	{
		type = "radar",
		label = "Cave map  enabled",
		size = 50
	},
	}, 0)
	player:set_formspec_prepend(mini_core.formspec_wrapper([[
		background9[0,0;0,0;${bg};true;8]
		listcolors[#787878ff;#505050ff;#787878ff;#7869c4ff;#ffffffff]
		style_type[button:default;border=false;bgimg=${bg};bgimg_middle=8,8]
		style_type[button:pressed;border=false;bgimg=${btn_active};bgimg_middle=8,8]
	]],
	{
		bg = mini_core.sheet("ui",0,0,6,1).."^[resize:24x24",
		btn_active = mini_core.sheet("ui",1,0,6,1).."^[resize:24x24"
	}))
	--physics
	player:set_physics_override({
		sneak_glitch = true
	})

	--visual
	player:set_sky({
		type = "regular",
		body_orbit_tilt = 20,
		sky_color = {
			day_sky = "#67b6bd",
			day_horizon = "#67b6bd",
			
			dawn_sky = "#7869c4",
			dawn_horizon = "#7869c4",
			
			night_sky = "#40318d",
			night_horizon = "#40318d",
			
			indoors = "#787878",
		},
		fog = {
			fog_start = 0.2
		}
	})
	player:set_sun({
		texture = "mini_sun.png",
		sunrise_visible = false,
	})
	player:set_moon({
		texture = "mini_moon.png",
	})
	player:set_stars({
		count = "5000",
		star_color = "#67b6bd",
		scale = "0.1",
	})
	player:set_clouds({
		density = 0.3,
		color = "#ffffffff",
		shadow = "#9f9f9f",
		height = 250,
		thickness = 48,
		speed = {x=5,z=3},
		density = 0.5
	})
	player:set_lighting({
		saturation = 1,
		shadows = {
			intensity = 1,
			tint = "#787878"
		},
		exposure = {
			luminance_min = -4,
			luminance_max = -2,
			exposure_correlation = 0,
			speed_dark_bright = 200,
			speed_bright_dark = 100,
			center_weight_power = 3
		},
		bloom = {
			intensity = 0.05,
			strength_factor = 2,
			radius = 1
		},
		volumetric_light = {
			strength = 0.25
		}
	})
end)

--move around the hud a bit
local huds = {
	health = {
		type = "statbar",
		position = {x = 0.5, y = 1},
		text = mini_core.sheet('bars',0,0,8,1),
		text2 = mini_core.sheet('bars',7,0,8,1),
		number = 62,
		item = 62,
		size = {x = 11, y = 11},
		offset = {x = (-11*62)/4, y = -11-(74)},
	},
	breath = {
		type = "statbar",
		position = {x = 0.5, y = 1},
		text = mini_core.sheet('bars',1,0,8,1),
		text2 = mini_core.sheet('bars',7,0,8,1),
		number = 62,
		item = 62,
		size = {x = 11, y = 11},
		offset = {x = (-11*62)/4, y = -(11*2)-(74)},
	},
	hotbar = {
		type = "hotbar",
		position = {x = 0.5, y = 1},
		direction = 0,
		alignment = {x = 0, y = -1},
		offset = {x = 0, y = -16},
	},
	minimap = {
		type = "minimap",
		position = {x = 0, y = 1},
		alignment = {x = 1, y = -1},
		offset = {x = 16, y = -16},
		size = {x = 0, y = 0},
	},
}

if core.settings:get_bool("mini_change_hud", true) then
	for k,v in pairs(huds) do
		core.hud_replace_builtin(k,v)
	end
end

--Infinite materials in creative
core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if placer and placer:is_player() then
		return core.is_creative_enabled(placer:get_player_name())
	end
end
)

local starter_items = {
	"mini_items:stone_axe_wood_stick",
	"mini_items:recipe_book"
}

core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	for i,v in pairs(starter_items) do
		if not inv:contains_item("main", v) then
			inv:add_item("main", v)
		end
	end
end)

--Drop items on death
core.register_on_dieplayer(function(entity, reason)
	if entity:is_player() then
		local inv = entity:get_inventory()
		local player_name = entity:get_player_name()
		for _, list_name in ipairs(inv:get_list("main")) do
			local pos = entity:get_pos()
			pos.x = pos.x + math.random(-2,2)
			pos.z = pos.z + math.random(-2,2)
			pos.y = pos.y + math.random(0,2)
			core.item_drop(list_name, entity, pos)
		end
		inv:set_list("main", {})
		core.chat_send_player(player_name, "You died.")
	end
end)
