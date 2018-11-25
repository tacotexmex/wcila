-- Create public mod table
pointlib = {
	hud = {}
}

-- Check for custom hand range
local range = minetest.registered_items[""].range or 4

-- Check pointlib Visibility
local function visible(node, player)
	--To prevent a crash from unknown nodes
	local def = minetest.registered_items[node]
	if def == nil then return false end
	-- Don't show air!
	if def.name == "air" then return false end
	-- Check if the Player is holding down the sneak key, if they are then show all nodes
	if not player:get_player_control().sneak then
		if def.drawtype == "liquid"
		or def.drawtype == "flowingliquid"
		or def.drawtype == "airlike" then
			return false
		end
	end
	-- Make sure the node hasn't requested to be hidden
	if def.groups.not_pointlib_visible
	and def.groups.not_pointlib_visible ~= 0 then
		return false
	end
	-- If def passes these checks then node is visible
	return true
end

-- Check for closest visible node in ray and update HUD accordingly
function pointlib.update(player)
	-- Get player position
	local pos = vector.add(player:getpos(),{x=0,y=1.625,z=0})
	-- Get player view direction
	local dir = player:get_look_dir()
	-- Cast a ray in this direction
	local ray = minetest.raycast(pos, vector.add(pos,vector.multiply(dir,range)), false, true)
	-- Create variable of node name of possible outcome
	local name = ""
	-- Create variable of node description of possible outcome
	local description = ""
	-- Step through ray
	for pointed_thing in ray do
		-- Create variable for nodes found in ray
		local name_in_ray = minetest.get_node(pointed_thing.under).name
		-- Check if node should be ignored or not
		if visible(name_in_ray, player) then
			-- If so, put it in node name outcome variable
			name = name_in_ray
			-- No need to step further in ray
			break
		end
	end
	-- If both name and description, update HUD
	if name ~= ""	and minetest.registered_items[name].description ~= "" then
		-- Get node description
		description = minetest.registered_items[name].description
	end
	-- Update name HUD
	player:hud_change(pointlib.hud.name, "text", name)
	-- Update description HUD
	player:hud_change(pointlib.hud.description, "text", description)
	-- Return pointed node to external API function
	return name
end

-- Create HUD for new players
minetest.register_on_joinplayer(function (player)
	-- Create HUD element for node description
	pointlib.hud.description = player:hud_add({
		name = "pointlib:description",
		position = {x=0.5,y=0},
		hud_elem_type = "text",
		number = 0xFFFFFF,
		alignment = 0,
		offset = { x = 0, y = 20},
		text = ""
	})
	-- Create HUD element for node name
	pointlib.hud.name = player:hud_add({
		name = "pointlib:name",
		position = {x=0.5,y=0},
		hud_elem_type = "text",
		number = 0xE5E5E5,
		alignment = 0,
		offset = { x = 0, y = 40},
		text = ""
	})
end)

-- Create timer variable
local timer = 0
-- Create loop for updating frequency
minetest.register_globalstep(function (dtime)
	-- Iterate on timer with past time
	timer = timer + dtime
	-- Do things when 200 milliseconds have passed
	if timer > 0.2 then
		-- Check for all online players
		for _,player in pairs(minetest:get_connected_players()) do
			-- Update all player's HUDs
			pointlib.update(player)
		end
		-- Reset timer
		timer = 0
	end
end)
