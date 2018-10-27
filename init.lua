pointlib = {}
pointlib.huds = {}
local show_image = true

--Check pointlib Visibility
local function pointlib_visible(node, player)
	--To prevent a crash from unknown nodes
	local def = minetest.registered_items[node]
	if def == nil then return false end

	--Don't show air!
	if def.name == "air" then return false end

	--Check if the Player is holding down the sneak key, if they are then show all nodes
	if not player:get_player_control().sneak then
		if def.drawtype == "liquid" or def.drawtype == "flowingliquid" or def.drawtype == "airlike" then return false end
	end

	--Make sure the node hasn't requested to be hidden
	if def.groups.not_pointlib_visible and def.groups.not_pointlib_visible ~= 0 then return false end
	return true
end

--Create pointlib Hud
local function create_pointlib_hud(player)
	local elems = {}
	elems.bg = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 0, y = 0},
		name = "pointlib Background",
		text = "pointlib_bg.png",
		alignment = 0,
		offset = {x = 0, y = 40},
		direction = 0
	})
	elems.tooltip = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFFFFF,
		alignment = 0,
		offset = {x = 0, y = 26},
		direction = 0,
		name = "pointlib Display Name",
		text = "",
	})
	elems.technical = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 100, y = 100},
		number = 0xCCCCCC,
		alignment = 0,
		offset = {x = 0, y = 46},
		direction = 0,
		name = "pointlib Technical Name",
		text = "",
	})

	pointlib.huds[player:get_player_name()] = elems
end

--Detect and show block
function pointlib.update(player)
	local name
	local dir = player:get_look_dir()
	local pos = vector.add(player:getpos(),{x=0,y=1.625,z=0})

	--TODO Go back to old method, it gives more flexibility
	-- local has_sight, node_pos = minetest.line_of_sight(pos, vector.add(pos,vector.multiply(dir,40)),0.3)

	local ray = minetest.raycast(pos, vector.add(pos,vector.multiply(dir,4)), false, true)
	local name = ""
	for pointed_thing in ray do
		local cname = minetest.get_node(pointed_thing.under).name
		if pointlib_visible(cname, player) then name = cname break end
	end

	local display_name = ""
	if name ~= "" and minetest.registered_items[name].description ~= "" then display_name = minetest.registered_items[name].description end
	local s = 0
	--local techoff = 48
	if name ~= "" then s = 1 end
	--if display_name == "" then techoff = 38 end

	if not pointlib.huds[player:get_player_name()] then
		create_pointlib_hud(player)
	else
		local elems = pointlib.huds[player:get_player_name()]
		player:hud_change(elems.bg, "scale", {x = s * 3, y = s * 3})
		player:hud_change(elems.tooltip, "text", display_name)
		player:hud_change(elems.technical, "text", name)
		return name
	end
end

-- Register Update
local time = 0
local incr = 0.1
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time > incr then
		time = time - incr
		for _,player in ipairs(minetest.get_connected_players()) do
			if player and player:is_player() then
				pointlib.update(player)
			end
		end
	end
end)

--Register Leave Clearing
minetest.register_on_leaveplayer(function (player)
	pointlib.huds[player:get_player_name()] = nil
end)
