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

MoveSpeedMin = 0.1
MoveSpeedMax = 0.75
MoveSpeedCurrent = MoveSpeedMin
MoveDirection = 0

-- Entities --
EntityCount = 0
Entities = { }

-- Drawing --
FieldOfView = 55.0
Ratio = WindowWidth/WindowHeight
Cone = (FieldOfView / 360.0) * Tau * Ratio
DrawMode = 0

RayHits = { }
HitCount = 0
TopDist = 0

-- Minimap --
MinimapScale = 0.25
MinimapOffsetX = WindowWidth * 0.025
MinimapOffsetY = WindowHeight * 0.025

-- Assets --
WallTextures = { }
WallQuads = { }
CharSheets = { }
CharQuads = { }

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
    HorizonY = WindowHeight * 0.4
	TileWidth = WindowWidth / MapWidth
	TileHeight = TileWidth
    RayCount = WindowWidth
    Ratio = WindowWidth/WindowHeight
    Cone = (FieldOfView / 360.0) * Tau * Ratio
end

function love.load()
    love.graphics.setDefaultFilter( "nearest", "nearest", 16 )
    Runtime = 0
	MoveSpeedMin = 0.1
	MoveSpeedMax = 0.75
	MoveSpeedCurrent = MoveSpeedMin
	load_map()
	update_scale()
	DrawMode = 0

	PlayerX, PlayerY = MapWidth/2, MapHeight/2
	MoveDirection = 0
	PlayerAngle = 0.0
	PlayerBounds = 0.2

	FieldOfView = 55.0

	MinimapScale = 0.25
	MinimapOffsetX = WindowWidth * 0.025
	MinimapOffsetY = WindowHeight * 0.025

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

    -- load entity sprite sheets
	table.insert(CharSheets, love.graphics.newImage("gorksprite.png", nil))

    -- define sprite vertical strips as list of quads
	for i = 0, 3 do
        for j = 0, 3 do
	for stripe = 0, 15 do
            table.insert(CharQuads, love.graphics.newQuad(16*i+stripe, 16*j, 1, 16, 64, 64 ))
	end
        end
	end

    -- load entity list
    local entity_count = 4
    local entities_to_load = {
        { x = 8, y = 6.5, sheet = 1, x_scale = 1.0, y_scale = 1.0, y_offset = 0.0 },
        { x = 4.5, y = 8.5, sheet = 1, x_scale = 0.5, y_scale = 0.5, y_offset = 0.5 },
        { x = 3.5, y = 12.5, sheet = 1, x_scale = 0.5, y_scale = 0.5, y_offset = 0.5 },
        { x = 11.5, y = 10, sheet = 1, x_scale = 1.0, y_scale = 1.0, y_offset = 0.0 },
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
	local fmap_x, fmap_y = math.floor(map_x), math.floor(map_y)
	local cell = ((fmap_y-1)*MapWidth)+fmap_x
	return cell
end

local function move_player(dir, lateral)
    local dirx = PlayerDirX
    local diry = PlayerDirY

    if lateral then
        dirx = PlayerLatX
        diry = PlayerLatY
    end

	local move_x = dirx * MoveSpeedCurrent * dir
	local move_y = diry * MoveSpeedCurrent * dir

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

local function gather_raycast()
	local dof_max = 32
	local ray_inc = Cone / RayCount
	local ray_angle = PlayerAngle - Cone/2

    local ray_count = RayCount

	if (DrawMode > 0) then
		ray_count = math.fmod(Runtime*DrawMode*(WindowWidth / 100), RayCount)
	end

	TopDist = 0
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

					if dist > TopDist then TopDist = dist end
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

function love.update(dt)
	Runtime = Runtime + dt
	update_scale()
	PlayerDirX = math.cos(PlayerAngle)
	PlayerDirY = math.sin(PlayerAngle)
    PlayerLatX = math.cos(PlayerAngle+HalfPi)
    PlayerLatY = math.sin(PlayerAngle+HalfPi)
	MoveSpeedCurrent = MoveSpeedCurrent - MoveSpeedMin*0.01
	if (MoveSpeedCurrent < MoveSpeedMin) then MoveSpeedCurrent = MoveSpeedMin end

    local dir = 0.0
    local dir_lat = 0.0

	if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
        dir = 1.0
    elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
		dir = -1.0
    end

	if (love.keyboard.isDown("d")) then
        dir_lat = 1.0
    elseif (love.keyboard.isDown("a")) then
		dir_lat = -1.0
    end

    if (love.keyboard.isDown("left")) then
		PlayerAngle = PlayerAngle - (Tau/100)
		if (PlayerAngle < 0.0) then PlayerAngle = Tau end
    elseif (love.keyboard.isDown("right")) then
		PlayerAngle = PlayerAngle + (Tau/100)
		if (PlayerAngle > Tau) then PlayerAngle = 0.0 end
    end

    if (dir ~= 0) then
        move_player(dir, false)
    end

    if (dir_lat ~= 0) then
        move_player(dir_lat, true)
    end

	RayHits, HitCount = gather_raycast()
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

local function draw_constants()
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", 0, 0, WindowWidth, HorizonY)
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.rectangle("fill", 0, HorizonY, WindowWidth, WindowHeight)
end

local function draw_raycast(ray_hits, hit_count)
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
		love.graphics.draw(WallTextures[ray_hits[i].type], WallQuads[math.floor(ray_hits[i].side_px)], start_x, HorizonY-(s_h*0.5), 0, s_w, s_h/64, 0, 0, 0, 0 )
	end
end

local function compareDistDescending(a, b)
    return a.dist > b.dist
end

local function draw_sprites(ray_hits, hit_count)
	local plane_x = PlayerLatX*Cone/2
	local plane_y = PlayerDirX*Cone/2
	local invDet = 1.0 / (plane_x*PlayerDirY-PlayerDirX*plane_y)
    local sprites = {}

    for i = 1, EntityCount do
        local sprite_x = Entities[i].x-PlayerX
        local sprite_y = Entities[i].y-PlayerY
	local sprite_dist = math.abs(sprite_x+sprite_y)
	table.insert(sprites, { sprite_x = sprite_x, sprite_y = sprite_y, dist = sprite_dist, index = i })
    end

    table.sort(sprites, compareDistDescending)

    for sprite = 1, EntityCount do
	entity = sprites[sprite].index
        local sprite_x = sprites[sprite].sprite_x
        local sprite_y = sprites[sprite].sprite_y
	local sprite_dist = sprites[sprite].dist
	if (sprite_dist > TopDist) then goto continue end

        local transform_x = invDet * (PlayerDirY*sprite_x-PlayerDirX*sprite_y)
        local transform_y = invDet * (-plane_y*sprite_x+plane_x*sprite_y)
        local sprite_screen_x = math.ceil((WindowWidth/2.0)*(1.0+transform_x/transform_y))

        local sprite_height = math.ceil(math.abs(math.floor(WindowHeight/transform_y)) * Entities[entity].y_scale)

        local y_offset = math.ceil(Entities[entity].y_offset * sprite_height)

        local start_y = -sprite_height / 2 + HorizonY - y_offset
        if (start_y < 0) then start_y = 0 end
        local end_y = sprite_height / 2 + HorizonY - y_offset
        if (end_y > WindowHeight) then end_y = WindowHeight end

        local sprite_width = math.ceil(math.abs(math.floor(WindowWidth/transform_y)) * Entities[entity].x_scale / Ratio)
        if (sprite_width % 2 > 0) then sprite_width = sprite_width - 1 end
        local start_x = -sprite_width / 2 + sprite_screen_x
        if (start_x < 0) then start_x = 0 end
        local end_x = sprite_width / 2 + sprite_screen_x
        if (end_x > WindowWidth) then end_x = WindowWidth end

        love.graphics.setColor(1, 1, 1)
        local attempt_count = 0
        local stripe_count = 0

        local px_width = 16
        local px_height = 16
        local scaled_width = px_width * Entities[entity].x_scale
        local scaled_width_pow = scaled_width*scaled_width
        local scaled_height = px_height * Entities[entity].y_scale
        local final_width, final_height = sprite_width/scaled_width_pow, sprite_height/scaled_height
        if (final_width < 1.0) then final_width = 1.0 end
        if (final_height < 1.0) then final_height = 1.0 end

        for stripe = start_x, end_x-1 do
            local tex_x = math.floor((stripe -(-sprite_width/2+sprite_screen_x)) * px_width / sprite_width)
            attempt_count = attempt_count + 1
            if (stripe < WindowWidth-1 and tex_x < px_width and stripe < hit_count and stripe > 0 and transform_y > 0 and ray_hits[stripe] ~= nil and ray_hits[stripe].dist > transform_y) then
                stripe_count = stripe_count + 1
                love.graphics.draw(CharSheets[Entities[entity].sheet], CharQuads[tex_x+1], stripe, start_y, 0, final_width, final_height, 0, 0, 0, 0 )
            end
        end
	::continue::
    end
end

function love.draw()
    draw_constants()
	draw_raycast(RayHits, HitCount)
	draw_sprites(RayHits, HitCount)
	draw_map(RayHits, HitCount)
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
