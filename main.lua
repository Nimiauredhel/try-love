require "gradient"

-- Constants --
Tau = 6.283185
Pi = 3.14159
HalfPi = Pi*0.5

-- Time --
Runtime = 0

-- Window --
WindowWidth, WindowHeight = 1920, 1080
HorizonY = WindowHeight * 0.4

-- Map --
MapWidth, MapHeight = 16, 16
MapCells = {}

TileWidth = WindowWidth / MapWidth
TileHeight = TileWidth

-- Player --
PlayerX, PlayerY = MapWidth/2, MapHeight/2
PlayerAngle = 0.0
PlayerBounds = 0.2
PlayerDirX = 1.0
PlayerDirY = 0.0
PlayerLatX = 1.0
PlayerLatY = 0.0

MoveSpeedMin = 1.0
MoveSpeedMax = 7.5
MoveSpeedCurrent = MoveSpeedMin
MoveDirection = 0

-- Entities --
EntityCount = 0
Entities = { }

-- Drawing --
FieldOfView = 40.0
Ratio = WindowWidth/WindowHeight
Cone = (FieldOfView / 360.0) * Tau * Ratio
PlaneX = PlayerLatX*Cone/2
PlaneY = PlayerDirX*Cone/2
DrawMode = 0

RayWallHits = { }
RayWallHitCount = 0
TopDist = 0
MaxStartY = HorizonY
MinEndY = HorizonY

-- Minimap --
MinimapScale = 0.25
MinimapOffsetX = WindowWidth * 0.025
MinimapOffsetY = WindowHeight * 0.025

-- Assets --
WallTextures = { }
WallQuads = { }

TileTextures = { }
TileQuads = { }

SpriteSheets = { }
SpriteQuads = { }

WallTextureWidth, WallTextureHeight = 64, 64
TileTextureWidth, TileTextureHeight = 64, 64
SpriteWidth, SpriteHeight = 64,64

ActorSides = 8
ActorFrames = 4
AnimSpeed = 3.0

local function get_vec2_dot(x1, y1, x2, y2)
	return (x1*x2)+(y1*y2)
end

local function get_vec2_mag(x, y)
	return math.sqrt(x*x+y*y)
end

local function get_vec2_angle(x1, y1, x2, y2)
	return (get_vec2_dot(x1, y1, x2, y2) / (get_vec2_mag(x1, y1)*get_vec2_mag(x2, y2)))
end

local function load_map()
	MapWidth, MapHeight = 16, 16
	MapCells = {
		4, 4, 4, 4, 4, 4, 7, 7, 4, 5, 8, 4, 4, 4, 4, 4,
		6, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 4, 0, 0, 0, 6,
		4, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 4, 0, 0, 0, 4,
		6, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 4, 0, 0, 0, 6,
		4, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
		6, 0, 0, 2, 5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 6,
		4, 0, 0, 1, 2, 3, 0, 0, 0, 0, 0, 0, 1, 1, 0, 4,
		4, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 4,
		4, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 4,
		4, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 4,
		8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 4,
		5, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 1, 1, 1, 0, 4,
		4, 6, 7, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 4,
		4, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
		4, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	}
end

local function update_scale(win_w, win_h)
	WindowWidth, WindowHeight = win_w, win_h
	HorizonY = WindowHeight * 0.4
	TileWidth = WindowWidth / MapWidth
	TileHeight = TileWidth
	WallRayCount = WindowWidth
	Ratio = WindowWidth/WindowHeight
	Cone = (FieldOfView / 360.0) * Tau * Ratio
end

function love.resize(w, h)
	update_scale(w, h)
end

function love.load()
    love.graphics.setDefaultFilter( "nearest", "nearest", 16 )
    Runtime = 0
	MoveSpeedMin = 5.0
	MoveSpeedMax = 15.0
	MoveSpeedCurrent = MoveSpeedMin
	load_map()
	update_scale(love.graphics.getDimensions())
	DrawMode = 0

	PlayerX, PlayerY = MapWidth/2, MapHeight/2
	MoveDirection = 0
	PlayerAngle = 0.0
	PlayerBounds = 0.2

	FieldOfView = 40.0

	MinimapScale = 0.25
	MinimapOffsetX = WindowWidth * 0.025
	MinimapOffsetY = WindowHeight * 0.025

    -- load tile textures
	table.insert(TileTextures, love.graphics.newImage("Brick01.png", nil))
	table.insert(TileTextures, love.graphics.newImage("Brick07.png", nil))

    -- load wall textures
	table.insert(WallTextures, love.graphics.newImage("Brick01.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick02.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick03.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick04.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick05.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick06.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick07.png", nil))
	table.insert(WallTextures, love.graphics.newImage("Brick08.png", nil))
	-- define wall vertical strips as list of quads
	for i = 0, WallTextureWidth-1 do
		table.insert(WallQuads, love.graphics.newQuad(i, 0, 1, WallTextureHeight, WallTextureWidth, WallTextureHeight ))
	end

	-- define tile pixels as list of quads
	for y = 0, TileTextureHeight-1 do
	for x = 0, TileTextureWidth-1 do
		table.insert(TileQuads, love.graphics.newQuad(x, y, 1, 1, TileTextureWidth, TileTextureHeight))
	end
	end

	-- load entity sprite sheets
	table.insert(SpriteSheets, love.graphics.newImage("stella_walk.png", nil))

	local sides_fix = { 4, 8, 3, 5, 1, 6, 2, 7 }

	-- define sprite vertical strips as list of quads
	for side = 0, ActorSides-1 do
        for frame = 0, ActorFrames-1 do
	for stripe = 0, SpriteWidth-1 do
		table.insert(SpriteQuads, love.graphics.newQuad(SpriteWidth*frame+stripe, SpriteHeight*(sides_fix[side+1]-1), 1, SpriteHeight, SpriteWidth*ActorFrames, SpriteHeight*ActorSides))
	end
        end
	end

	-- load entity list
	local entity_count = 6
	local entities_to_load = {
        { x = 8, y = 6.5, sheet = 1, x_scale = 0.75, y_scale = 0.75, y_offset = -0.25/2.0, heading = 0.0, speed = MoveSpeedMin },
        { x = 4.5, y = 8.5, sheet = 1, x_scale = 0.5, y_scale = 0.5, y_offset = -0.5/2.0, heading = 0.0, speed = MoveSpeedMin  },
        { x = 3.5, y = 12.5, sheet = 1, x_scale = 0.5, y_scale = 0.5, y_offset = -0.5/2.0, heading = 0.0, speed = MoveSpeedMin  },
        { x = 11.5, y = 8, sheet = 1, x_scale = 0.4, y_scale = 0.4, y_offset = -0.6/2.0, heading = 0.0, speed = MoveSpeedMin  },
        { x = 11.5, y = 9, sheet = 1, x_scale = 0.5, y_scale = 0.5, y_offset = -0.5/2.0, heading = Pi*0.5, speed = MoveSpeedMin  },
        { x = 11.5, y = 10, sheet = 1, x_scale = 0.25, y_scale = 0.25, y_offset = -0.75/2.0, heading = Pi, speed = MoveSpeedMin  },
	}
	for i = 1, entity_count do
		table.insert(Entities, entities_to_load[i])
		EntityCount = EntityCount + 1
	end
end

local function map_to_window(in_x, in_y)
	local win_x = TileWidth * (in_x-1)
	local win_y = TileHeight * (in_y-1)
	return win_x, win_y
end

local function coord_to_cell(map_x, map_y)
	local fmap_x, fmap_y = math.abs(math.floor(map_x)), math.abs(math.floor(map_y))
	local cell = ((fmap_y-1)*MapWidth)+fmap_x
	return cell
end

local function move_player(dir, lateral, dt)
	local dirx = PlayerDirX
	local diry = PlayerDirY

	if lateral then
		dirx = PlayerLatX
		diry = PlayerLatY
	end

	local move_x = dirx * MoveSpeedCurrent * dir * dt
	local move_y = diry * MoveSpeedCurrent * dir * dt

	if (dir == MoveDirection) then
		MoveSpeedCurrent = MoveSpeedCurrent + MoveSpeedMin
	else
		MoveSpeedCurrent = MoveSpeedMin
	end

	if (MoveSpeedCurrent > MoveSpeedMax) then
		MoveSpeedCurrent = MoveSpeedMax
	end

	PlayerX, PlayerY = PlayerX + move_x, PlayerY + move_y
	if (PlayerX > MapWidth) or (PlayerX < 0) or (PlayerY > MapHeight) or (PlayerY < 0)
		or MapCells[coord_to_cell(PlayerX+PlayerBounds, PlayerY+PlayerBounds)] > 0
		or MapCells[coord_to_cell(PlayerX-PlayerBounds, PlayerY+PlayerBounds)] > 0
		or MapCells[coord_to_cell(PlayerX+PlayerBounds, PlayerY-PlayerBounds)] > 0
		or MapCells[coord_to_cell(PlayerX-PlayerBounds, PlayerY-PlayerBounds)] > 0
		then
		PlayerX, PlayerY = PlayerX - move_x, PlayerY - move_y
		MoveSpeedCurrent = MoveSpeedMin
	end
end

local function move_actor(actor, dt)
	local dirx = math.cos(actor.heading)
	local diry = math.sin(actor.heading)

	local move_x = dirx * actor.speed * dt * actor.y_scale * 0.1
	local move_y = diry * actor.speed * dt * actor.y_scale * 0.1

	actor.x, actor.y = actor.x + move_x, actor.y + move_y
	if (actor.x > MapWidth) or (actor.x < 0) or (actor.y > MapHeight) or (actor.y < 0)
		or MapCells[coord_to_cell(actor.x+PlayerBounds, actor.y+PlayerBounds)] > 0
		or MapCells[coord_to_cell(actor.x-PlayerBounds, actor.y+PlayerBounds)] > 0
		or MapCells[coord_to_cell(actor.x+PlayerBounds, actor.y-PlayerBounds)] > 0
		or MapCells[coord_to_cell(actor.x-PlayerBounds, actor.y-PlayerBounds)] > 0
		then
		actor.x, actor.y = actor.x - move_x, actor.y - move_y
		actor.heading = actor.heading + (math.random()*Tau)
		actor.speed = MoveSpeedMin
		if (actor.heading > Tau) then actor.heading = actor.heading - Tau
		elseif (actor.heading < 0.0) then actor.heading = actor.heading + Tau end
	else
		actor.speed = actor.speed + MoveSpeedMin
		if (actor.speed > MoveSpeedMax) then actor.speed = MoveSpeedMax end
	end
end

local function gather_rays()
	local dof_max = 32
	local ray_inc = Cone / WallRayCount
	local ray_angle = PlayerAngle - Cone/2

	TopDist = 0
    MaxStartY = HorizonY
    MinEndY = HorizonY

	local ray_wall_hit_count = 0
	local ray_wall_hits = { }

	local ray_count = WallRayCount

	if (DrawMode > 0) then
		ray_count = math.fmod(Runtime*DrawMode*(WindowWidth / 100), WallRayCount)
	end

	-- cast walls
	for ray=1, ray_count do
		if (ray_angle < 0.0) then ray_angle = ray_angle + Tau
		elseif (ray_angle > Tau) then ray_angle = ray_angle - Tau end

		local dof = 0

		local xoff = math.cos(ray_angle)
		local yoff = math.sin(ray_angle)
		local x_delta, y_delta, x_side, y_side, x_step, y_step = 0.0, 0.0, 0.0, 0.0, 1, 1

		if (xoff == 0) then
			x_delta = 1e30
		else x_delta = math.abs(1.0/xoff) end

		if (yoff == 0) then
			y_delta = 1e30
		else y_delta = math.abs(1.0/yoff) end

		if (xoff < 0.0) then
			x_side = (PlayerX - math.floor(PlayerX)) * x_delta
			x_step = -1
		else x_side = (math.floor(PlayerX) + 1.0 - PlayerX) * x_delta end

		if (yoff < 0.0) then
			y_side = (PlayerY - math.floor(PlayerY)) * y_delta
			y_step = -1
		else y_side = (math.floor(PlayerY) + 1.0 - PlayerY) * y_delta end

		local tx, ty = math.floor(PlayerX), math.floor(PlayerY)
		local side = 0

		while (dof < dof_max) do
			dof = dof + 1
			if (x_side < y_side) then
				side = 0
				x_side = x_side + x_delta
				tx = tx + x_step
			else
				side = 1
				y_side = y_side + y_delta
				ty = ty + y_step
			end
			if (tx < MapWidth+1 and ty < MapHeight+1 and tx > -1 and ty > -1) then
				local hit = MapCells[coord_to_cell(tx, ty)]

				if (hit > 0) then
					dof = dof_max
					local dist = 0
					local wall_x = 0.0
					local side_px = 1

					if (side == 0) then
						dist = x_side - x_delta
					else
						dist = y_side - y_delta
					end
					side_px = 1+((dist-math.floor(dist))*WallTextureWidth)

					if (dist < 0.001) then dist = 0.001 end

					local rx = PlayerX + xoff * dist
					local ry = PlayerY + yoff * dist

					if (side == 0) then
						wall_x = ry
					else
						wall_x = rx
					end
					wall_x = wall_x - math.floor(wall_x)
					side_px = 1+wall_x * WallTextureWidth

					if dist > TopDist then TopDist = dist end

					local hit_data = { index = ray, type = hit, rx = rx, ry = ry, tx = tx, ty = ty, dist = dist, side_px = side_px, start_y = HorizonY, end_y = HorizonY }
					table.insert(ray_wall_hits, hit_data)
					ray_wall_hit_count = ray_wall_hit_count + 1
				end
			end
		end
	ray_angle = ray_angle + ray_inc
	end


	return ray_wall_hits, ray_wall_hit_count
end

local function update_player_orientation()
	PlayerDirX = math.cos(PlayerAngle)
	PlayerDirY = math.sin(PlayerAngle)
	PlayerLatX = math.cos(PlayerAngle+HalfPi)
	PlayerLatY = math.sin(PlayerAngle+HalfPi)
	PlaneX = PlayerLatX*Cone/2
	PlaneY = PlayerDirX*Cone/2
end

function love.update(dt)
	Runtime = Runtime + dt

	if (MoveSpeedCurrent < MoveSpeedMin) then MoveSpeedCurrent = MoveSpeedMin end

	local dir = 0.0
	local dir_lat = 0.0

	if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
        dir = 1.0
	elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
		dir = -1.0
	end

	if (love.keyboard.isDown("5")) then
		HorizonY = HorizonY - 1000.0 * dt
	elseif (love.keyboard.isDown("6")) then
		HorizonY = HorizonY + 1000.0 * dt
	end

	if (love.keyboard.isDown("d")) then
        dir_lat = 1.0
	elseif (love.keyboard.isDown("a")) then
		dir_lat = -1.0
	end

	if (love.keyboard.isDown("left")) then
		PlayerAngle = PlayerAngle - Tau*dt*0.25
		if (PlayerAngle < 0.0) then PlayerAngle = Tau end
	elseif (love.keyboard.isDown("right")) then
		PlayerAngle = PlayerAngle + Tau*dt*0.25
		if (PlayerAngle > Tau) then PlayerAngle = 0.0 end
	end

	if (dir ~= 0) then
		move_player(dir, false, dt)
	end

	if (dir_lat ~= 0) then
		move_player(dir_lat, true, dt)
	end

	if (dir+dir_lat == 0) then
		MoveSpeedCurrent = MoveSpeedCurrent - MoveSpeedMin*0.01
	end

	for entity = 1, EntityCount do
		move_actor(Entities[entity], dt)
	end

	update_player_orientation()

	RayWallHits, RayWallHitCount = gather_rays()
end

local function draw_map(ray_wall_hits, ray_wall_hit_count)
	local x = MinimapOffsetX
	local y = MinimapOffsetY
	local scale = MinimapScale

	local pwx, pwy = map_to_window(PlayerX, PlayerY)
	pwx, pwy = pwx*scale+x, pwy*scale+y

	love.graphics.setColor(0.0, 0.0, 0.0)
	for map_x=1, MapWidth do
		for map_y=1, MapHeight do
			local cell = coord_to_cell(map_x, map_y)
			local win_x, win_y = map_to_window(map_x, map_y)
			if MapCells[cell] > 0 then
				love.graphics.rectangle("fill", win_x*scale+x, win_y*scale+y, TileWidth*scale, TileHeight*scale)
			end
		end
	end

	local win_x, win_y = map_to_window(PlayerX, PlayerY)
	love.graphics.setColor(1.0, 1.0, 1.0)
	love.graphics.line(win_x*scale+x, win_y*scale+y, win_x*scale+(PlayerDirX*2.0*TileWidth*scale)+x, win_y*scale+(PlayerDirY*2.0*TileHeight*scale)+y)
	win_x = win_x - TileWidth/2
	win_y = win_y - TileHeight/2
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.rectangle("fill", win_x*scale+x, win_y*scale+y, TileWidth*scale, TileHeight*scale)

	for i = 1, ray_wall_hit_count do
		win_x, win_y = map_to_window(ray_wall_hits[i].rx, ray_wall_hits[i].ry)
		win_x, win_y = win_x*MinimapScale + MinimapOffsetX, win_y*MinimapScale + MinimapOffsetY
		love.graphics.setColor(1.0, 0.0, 0.0)
		love.graphics.line(pwx, pwy, win_x, win_y)
		love.graphics.setColor(0.0, 1.0, 0.0)
		win_x, win_y = map_to_window(ray_wall_hits[i].tx, ray_wall_hits[i].ty)
		win_x, win_y = win_x*MinimapScale + MinimapOffsetX, win_y*MinimapScale + MinimapOffsetY
		love.graphics.rectangle("line", win_x, win_y, TileWidth*MinimapScale, TileHeight*MinimapScale)
	end
end

local function draw_constants()
	local ceil_color = { 0.45, 0.4, 0.4 }
	local floor_color = { 0.4, 0.45, 0.4 }
	local horizon_color = { 0.075, 0.1, 0.15 }
	local under_horizon = WindowHeight-HorizonY

	love.gradient.draw(
		function()
			love.graphics.rectangle("fill", 0, 0, WindowWidth, HorizonY)
		end, "vertical",
		WindowWidth/2,  HorizonY/2, WindowWidth/2, HorizonY/2, ceil_color, horizon_color)

	love.gradient.draw(
		function()
			love.graphics.rectangle("fill", 0, HorizonY, WindowWidth, under_horizon)
		end, "vertical",
		WindowWidth/2,  HorizonY+(under_horizon/2), WindowWidth/2, under_horizon/2, horizon_color, floor_color)

end

local function draw_tiles(ray_wall_hits, ray_wall_hit_count)
	local batch_size = 4
	local horizon_color = { r = 0.075, g = 0.1, b = 0.15 }
	local horizon_rem = { r = 1.0 - horizon_color.r, g = 1.0 - horizon_color.g, b = 1.0 - horizon_color.b }

	-- cast floors/ceilings
    local tile_ray_count = math.max(HorizonY, WindowHeight-HorizonY)
	local ray_count = tile_ray_count

	if (DrawMode > 0) then
		ray_count = math.fmod(Runtime*DrawMode*(tile_ray_count / 100), tile_ray_count)
	end

	local ray_dir_x0 = PlayerDirX-PlaneX
	local ray_dir_y0 = PlayerDirY-PlaneY
	local ray_dir_x1 = PlayerDirX+PlaneX
	local ray_dir_y1 = PlayerDirY+PlaneY

	local pos_z = WindowHeight/2

	local ray_dir_x_diff = (ray_dir_x1 - ray_dir_x0) / WindowWidth
    local ray_dir_y_diff = (ray_dir_y1 - ray_dir_y0) / WindowWidth

    local floor_row = HorizonY+1
    local ceiling_row = HorizonY-1

	for y = 1, ray_count, batch_size do
		local row_distance = pos_z / y
        floor_row = floor_row+batch_size
        ceiling_row = ceiling_row-batch_size

		local floor_step_x = row_distance * (ray_dir_x_diff)
		local floor_step_y = row_distance * (ray_dir_y_diff)

		local floor_x = PlayerX + row_distance * ray_dir_x0
		local floor_y = PlayerY + row_distance * ray_dir_y0

		local cell_x, cell_y, tex_x, tex_y, tex_q = 0, 0, 0, 0, 0

		for x = 1, ray_wall_hit_count, batch_size do
			cell_x, tex_x = math.modf(floor_x)
			cell_y, tex_y = math.modf(floor_y)
			tex_x = math.floor(tex_x * TileTextureWidth)
			tex_y = math.floor(tex_y * TileTextureHeight)
			tex_q = 1 + tex_x + (tex_y * TileTextureWidth)
			local quad = TileQuads[tex_q]

			if (quad ~= nil) then
				if (floor_row < WindowHeight and floor_row > ray_wall_hits[x].end_y) then
                    local mod = y/(WindowHeight-HorizonY)
                    love.graphics.setColor(horizon_color.r + mod * horizon_rem.r, horizon_color.g + mod * horizon_rem.r, horizon_color.g + mod * horizon_rem.b)
                    love.graphics.draw(TileTextures[2], quad, x, floor_row, 0, batch_size, batch_size, 0, 0, 0, 0 )
                end

                if (ceiling_row > 0 and ceiling_row < ray_wall_hits[x].start_y) then
                    local mod = 1.0-(ceiling_row/HorizonY)
                    love.graphics.setColor(horizon_color.r + mod * horizon_rem.r, horizon_color.g + mod * horizon_rem.r, horizon_color.g + mod * horizon_rem.b)
                    love.graphics.draw(TileTextures[1], quad, x, ceiling_row, 0, batch_size, batch_size, 0, 0, 0, 0 )
				end
			end
            floor_x = floor_x + floor_step_x*batch_size
            floor_y = floor_y + floor_step_y*batch_size
		end
	end
end

local function draw_raycast(ray_wall_hits, ray_wall_hit_count)
	local s_w = WindowWidth/WallRayCount

	for i = 1, ray_wall_hit_count do
		local base_dist = ray_wall_hits[i].dist
		local mod = 1.0 - (((math.floor(base_dist*4)+0.5)/4)/8)

		if (mod < 0.0) then
			mod = 0.0
		end

		local r_mod = 0.6 * mod
		local g_mod = 0.6 * mod
		local b_mod = 0.1 * mod
		love.graphics.setColor(0.4 + r_mod, 0.4 + g_mod, 0.9 + b_mod)
		local s_h = (WindowHeight / ray_wall_hits[i].dist)
		local start_x = s_w * (ray_wall_hits[i].index-1)
		local start_y = HorizonY-(s_h*0.5)
		local end_y = start_y+s_h

        if (start_y > MaxStartY) then MaxStartY = start_y end
        if (end_y < MinEndY) then MinEndY = end_y end

		ray_wall_hits[i].start_y = start_y
		ray_wall_hits[i].end_y = end_y
		love.graphics.draw(WallTextures[ray_wall_hits[i].type], WallQuads[math.floor(ray_wall_hits[i].side_px)], start_x, start_y, 0, s_w, s_h/WallTextureHeight, 0, 0, 0, 0 )
	end
end

local function compareDistDescending(a, b)
	return a.dist > b.dist
end

local function draw_sprites(ray_wall_hits, ray_wall_hit_count)
	local invDet = 1.0 / (PlaneX*PlayerDirY-PlayerDirX*PlaneY)
	local sprites = {}

	curr_frame = math.floor((Runtime * AnimSpeed) % ActorFrames)

	bob_dir = ((Runtime * AnimSpeed) % 2)-1
	HorizonY = HorizonY + bob_dir * 0.2

	for i = 1, EntityCount do
		local sprite_x = Entities[i].x-PlayerX
		local sprite_y = Entities[i].y-PlayerY
		local sprite_dist = math.abs(sprite_x)+math.abs(sprite_y)

		local sprite_angle = get_vec2_angle(Entities[i].x, Entities[i].y, PlayerX, PlayerY)
		sprite_angle = math.abs((((sprite_angle+1.0)/2.0)*Tau)-PlayerAngle)
		sprite_angle = sprite_angle+Entities[i].heading
		sprite_angle = sprite_angle+(Pi/4)
		if (sprite_angle > Tau) then sprite_angle = sprite_angle - Tau end

		table.insert(sprites, { sprite_x = sprite_x, sprite_y = sprite_y, dist = sprite_dist, index = i, angle = sprite_angle })
	end

    table.sort(sprites, compareDistDescending)

	for sprite = 1, EntityCount do
		entity = sprites[sprite].index
		local sprite_x = sprites[sprite].sprite_x
		local sprite_y = sprites[sprite].sprite_y
		local sprite_dist = sprites[sprite].dist
		if (sprite_dist > TopDist*2) then goto continue end

		local transform_x = invDet * (PlayerDirY*sprite_x-PlayerDirX*sprite_y)
		local transform_y = invDet * (-PlaneY*sprite_x+PlaneX*sprite_y)
		local sprite_screen_x = math.ceil((WindowWidth/2.0)*(1.0+transform_x/transform_y))

		local sprite_height = math.ceil(math.abs(math.floor(WindowHeight/transform_y)))
		local y_offset = math.ceil(Entities[entity].y_offset * sprite_height)
		sprite_height = sprite_height * Entities[entity].y_scale
		local start_y = -sprite_height / 2 + HorizonY - y_offset
		--if (start_y < 0) then start_y = 0 end
		local end_y = sprite_height / 2 + HorizonY - y_offset
		--if (end_y > WindowHeight) then end_y = WindowHeight end

		local sprite_width = math.ceil(math.abs(math.floor(WindowWidth/transform_y)) * Entities[entity].x_scale / Ratio)
		if (sprite_width % 2 > 0) then sprite_width = sprite_width - 1 end
		local start_x = -sprite_width / 2 + sprite_screen_x
		if (start_x < 0) then start_x = 0 end
		local end_x = sprite_width / 2 + sprite_screen_x
		if (end_x > WindowWidth) then end_x = WindowWidth end

		local base_dist = sprite_dist;
		local mod = 1.0 - (((math.floor(base_dist*4)+0.5)/4)/8)

		if (mod < 0.0) then
			mod = 0.0
		end

		local r_mod = 0.6 * mod
		local g_mod = 0.6 * mod
		local b_mod = 0.1 * mod
		love.graphics.setColor(0.4 + r_mod, 0.4 + g_mod, 0.9 + b_mod)

		local px_width = SpriteWidth
		local px_height = SpriteHeight
		local px_width_pow = px_width*px_width
		local final_width, final_height = sprite_width/px_width_pow, sprite_height/px_height
		if (final_width < 1.0) then final_width = 1.0 end
		--if (final_height < 1.0) then final_height = 1.0 end

		local sprite_side = math.floor((sprites[sprite].angle/Tau)*(ActorSides)) % ActorSides

		for stripe = start_x, end_x-1 do
			local tex_x = math.floor((stripe -(-sprite_width/2+sprite_screen_x)) * px_width / sprite_width)
			if (stripe < WindowWidth-1 and tex_x < px_width and stripe < ray_wall_hit_count and stripe > 0 and transform_y > 0 and ray_wall_hits[stripe] ~= nil and ray_wall_hits[stripe].dist > transform_y) then
				love.graphics.draw(SpriteSheets[Entities[entity].sheet], SpriteQuads[tex_x+1+(SpriteWidth*curr_frame)+(SpriteWidth*ActorFrames*sprite_side)], stripe, start_y, 0, final_width, final_height, 0, 0, 0, 0 )
			end
		end
		::continue::
	end
end

function love.draw()
	--draw_constants()
	draw_raycast(RayWallHits, RayWallHitCount)
	draw_tiles(RayWallHits, RayWallHitCount)
	draw_sprites(RayWallHits, RayWallHitCount)
	draw_map(RayWallHits, RayWallHitCount)
end

function love.keypressed(key, scancode, isrepeat)
	if (key == "1") then
		FieldOfView = FieldOfView - 1
	elseif (key == "2") then
		FieldOfView = FieldOfView + 1
	elseif (key == "3") then
		DrawMode = DrawMode - 1
		if (DrawMode < 0) then DrawMode = 8 end
	elseif (key == "4") then
		DrawMode = DrawMode + 1
		if (DrawMode > 8) then DrawMode = 0 end
	end
end
