-- Constants --
Pi = 3.14159
Tau = 6.283185

-- Time --
Runtime = 0

-- Window --
WindowWidth, WindowHeight = 1920, 1080

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

MoveSpeedMin = 0.1
MoveSpeedMax = 0.75
MoveSpeedCurrent = MoveSpeedMin
MoveDirection = 0

-- Drawing --
FieldOfView = 55.0
RayCount = WindowWidth
ViewMode = 0
DrawMode = 0

-- Minimap --
MinimapScale = 0.25
MinimapOffsetX = WindowWidth * 0.025
MinimapOffsetY = WindowHeight * 0.025

-- Assets --
WallTextures = { }
WallQuads = { }

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

local function update_scale()
	WindowWidth, WindowHeight = love.graphics.getDimensions()
	TileWidth = WindowWidth / MapWidth
	TileHeight = TileWidth
    RayCount = WindowWidth
end

function love.load()
    Runtime = 0
	MoveSpeedMin = 0.1
	MoveSpeedMax = 0.75
	MoveSpeedCurrent = MoveSpeedMin
	load_map()
	update_scale()
	ViewMode = 0
	DrawMode = 0

	PlayerX, PlayerY = MapWidth/2, MapHeight/2
	MoveDirection = 0
	PlayerAngle = 0.0
	PlayerBounds = 0.2

	FieldOfView = 55.0

	MinimapScale = 0.25
	MinimapOffsetX = WindowWidth * 0.025
	MinimapOffsetY = WindowHeight * 0.025

	love.keyboard.setKeyRepeat(true)

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
	for i = 1, 64 do
		table.insert(WallQuads, love.graphics.newQuad(i, 0, 1, 64, 64, 64 ))
	end
end

local function map_to_window(in_x, in_y)
	local win_x = TileWidth * (in_x-1)
	local win_y = TileHeight * (in_y-1)
	return win_x, win_y
end

local function coord_to_cell(map_x, map_y)
	local fmap_x, fmap_y = math.floor(map_x), math.floor(map_y)
	local cell = ((fmap_y-1)*MapWidth)+fmap_x
	return cell
end

function love.update(dt)
	Runtime = Runtime + dt
	update_scale()
	PlayerDirX = math.cos(PlayerAngle)
	PlayerDirY = math.sin(PlayerAngle)
	MoveSpeedCurrent = MoveSpeedCurrent - MoveSpeedMin
	if (MoveSpeedCurrent < MoveSpeedMin) then MoveSpeedCurrent = MoveSpeedMin end
end

local function draw_map(ray_hits, hit_count)
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

	for i = 1, hit_count do
		win_x, win_y = map_to_window(ray_hits[i].rx, ray_hits[i].ry)
		win_x, win_y = win_x*MinimapScale + MinimapOffsetX, win_y*MinimapScale + MinimapOffsetY
		love.graphics.setColor(1.0, 0.0, 0.0)
		love.graphics.line(pwx, pwy, win_x, win_y)
		love.graphics.setColor(0.0, 1.0, 0.0)
		win_x, win_y = map_to_window(ray_hits[i].tx, ray_hits[i].ty)
		win_x, win_y = win_x*MinimapScale + MinimapOffsetX, win_y*MinimapScale + MinimapOffsetY
		love.graphics.rectangle("line", win_x, win_y, TileWidth*MinimapScale, TileHeight*MinimapScale)
	end
end

local function gather_raycast()
	local dof_max = 32
    local cone = (FieldOfView / 360.0) * Tau * (WindowWidth/WindowHeight)
	local ray_inc = cone / RayCount
	local ray_angle = PlayerAngle - cone/2

    local ray_count = RayCount

	if (DrawMode > 0) then
		ray_count = math.fmod(Runtime*DrawMode*(WindowWidth / 100), RayCount)
	end

	local hit_count = 0
	local ray_hits = { }

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
					side_px = 1+((dist-math.floor(dist))*64)

					if (dist < 0.001) then dist = 0.001 end

					local rx = PlayerX + xoff * dist
					local ry = PlayerY + yoff * dist

					if (side == 0) then
						wall_x = ry
					else
						wall_x = rx
					end
					wall_x = wall_x - math.floor(wall_x)
					side_px = 1+wall_x * 64

					local hit_data = { index = ray, type = hit, rx = rx, ry = ry, tx = tx, ty = ty, dist = dist, side_px = side_px }
					table.insert(ray_hits, hit_data)
					hit_count = hit_count + 1
				end
			end
		end
	ray_angle = ray_angle + ray_inc
	end
	return ray_hits, hit_count
end

local function draw_raycast(ray_hits, hit_count)
	local hor_h = WindowHeight * 0.4

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", 0, 0, WindowWidth, hor_h)
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.rectangle("fill", 0, hor_h, WindowWidth, WindowHeight)
    local s_w = WindowWidth/RayCount

	for i = 1, hit_count do
		local mod = 1.0 - (ray_hits[i].dist/10)

		if (mod < 0.0) then
			mod = 0.0
		end

		local r_mod = 0.4 * mod
		local g_mod = 0.3 * mod
		local b_mod = 0.1 * mod
		love.graphics.setColor(0.5 + r_mod, 0.6 + g_mod, 0.8 + b_mod)
		local s_h = (WindowHeight / ray_hits[i].dist)
		local start_x = s_w * (ray_hits[i].index-1)
		love.graphics.draw(WallTextures[ray_hits[i].type], WallQuads[math.floor(ray_hits[i].side_px)], start_x, hor_h-(s_h*0.5), 0, s_w, s_h/64, 0, 0, 0, 0 )
	end
end

function love.draw()
	local ray_hits, hit_count = gather_raycast()
	draw_raycast(ray_hits, hit_count)
	draw_map(ray_hits, hit_count)
end

local function move_player(dir)
	local move_x = PlayerDirX * MoveSpeedCurrent * dir
	local move_y = PlayerDirY * MoveSpeedCurrent * dir

	if (dir == MoveDirection) then
		MoveSpeedCurrent = MoveSpeedCurrent + MoveSpeedMin * 20
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

function love.keypressed(key, scancode, isrepeat)
	if (key == "up") then
		move_player(1)
	elseif (key == "down") then
		move_player(-1)
	else
		MoveSpeedCurrent = MoveSpeedMin
	end

	if (key == "left") then
		PlayerAngle = PlayerAngle - (Tau/100)
		if (PlayerAngle < 0.0) then PlayerAngle = Tau end
	elseif (key == "right") then
		PlayerAngle = PlayerAngle + (Tau/100)
		if (PlayerAngle > Tau) then PlayerAngle = 0.0 end
	elseif (key == "v") then
		ViewMode = ViewMode + 1
		if (ViewMode > 1) then ViewMode = 0 end
	elseif (key == "d") then
		DrawMode = DrawMode + 1
		if (DrawMode > 8) then DrawMode = 0 end
	elseif (key == "1") then
		FieldOfView = FieldOfView - 1
	elseif (key == "2") then
		FieldOfView = FieldOfView + 1
	end
end
