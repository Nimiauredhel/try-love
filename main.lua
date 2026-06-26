function load_map()
	map_w, map_h = 16, 16
	map = {
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

function update_scale()
	win_w, win_h = love.graphics.getDimensions()
	tile_w = win_w / map_w
	tile_h = tile_w
end

function love.load()
	wall01 = love.graphics.newImage("Brick01.png", nil)
	wall02 = love.graphics.newImage("Brick02.png", nil)
	wall03 = love.graphics.newImage("Brick03.png", nil)
	wall04 = love.graphics.newImage("Brick04.png", nil)
	wall05 = love.graphics.newImage("Brick05.png", nil)
	wall06 = love.graphics.newImage("Brick06.png", nil)
	wall07 = love.graphics.newImage("Brick07.png", nil)
	wall08 = love.graphics.newImage("Brick08.png", nil)
	walltextures = { wall01, wall02, wall03, wall04, wall05, wall06, wall07, wall08 }
	wallquads = { }
	for i = 1, 64 do
		quad = love.graphics.newQuad(i, 0, 1, 64, 64, 64 )
		table.insert(wallquads, quad)
	end
    runtime = 0
	pi = 3.14159
	tau = 6.283185
	love.keyboard.setKeyRepeat(true)
	move_speed_min = 0.1
	move_speed_max = 0.75
	move_speed = move_speed_min
	load_map()
	update_scale()
	view_mode = 0
	draw_mode = 0

	player_x, player_y = map_w/2, map_h/2
	player_dir = 0
	player_angle = 0.0
	player_bounds = 0.2

	fov = 55.0

	minimap_scale = 0.25
	minimap_x = win_w * 0.025
	minimap_y = win_h * 0.025
end

function map_to_window(in_x, in_y)
	win_x = tile_w * (in_x-1)
	win_y = tile_h * (in_y-1)
	return win_x, win_y
end

function coord_to_cell(map_x, map_y)
	fmap_x, fmap_y = math.floor(map_x), math.floor(map_y)
	cell = ((fmap_y-1)*map_w)+fmap_x
	return cell
end

function love.update(dt)
	runtime = runtime + dt
	update_scale()
	pdx = math.cos(player_angle)
	pdy = math.sin(player_angle)
	move_speed = move_speed - move_speed_min
	if (move_speed < move_speed_min) then move_speed = move_speed_min end
end

function draw_map()
	x = minimap_x
	y = minimap_y
	scale = minimap_scale
	for map_x=1, map_w do
		for map_y=1, map_h do
			cell = coord_to_cell(map_x, map_y)
			win_x, win_y = map_to_window(map_x, map_y)
			love.graphics.setColor(0.2, 0.2, 0.2)
			if map[cell] > 0 then
				love.graphics.rectangle("fill", win_x*scale+x, win_y*scale+y, tile_w*scale, tile_h*scale)
			else
				love.graphics.rectangle("line", win_x*scale+x, win_y*scale+y, tile_w*scale, tile_h*scale)
			end
		end
	end

	win_x, win_y = map_to_window(player_x, player_y)
	love.graphics.setColor(1.0, 1.0, 1.0)
	love.graphics.line(win_x*scale+x, win_y*scale+y, win_x*scale+(pdx*2.0*tile_w*scale)+x, win_y*scale+(pdy*2.0*tile_h*scale)+y)
	win_x = win_x - tile_w/2
	win_y = win_y - tile_h/2
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.rectangle("fill", win_x*scale+x, win_y*scale+y, tile_w*scale, tile_h*scale)
end

function gather_raycast()
	dof_max = 32
	ray_count = win_w
        cone = (fov / 360.0) * tau * (win_w/win_h)
	local ray_inc = cone / ray_count
	local ray_angle = player_angle - cone/2

	if (draw_mode > 0) then
		ray_count = math.fmod(runtime*draw_mode*(win_w / 100), ray_count)
	end

	local hit_count = 0
	local ray_hits = { }

	for ray=1, ray_count do
		if (ray_angle < 0.0) then ray_angle = ray_angle + tau
		elseif (ray_angle > tau) then ray_angle = ray_angle - tau end

		dof = 0
		atan = -math.tan(ray_angle)
		pxi, pxf = math.modf(player_x)
		pyi, pyf = math.modf(player_y)

		xoff = math.cos(ray_angle)
		yoff = math.sin(ray_angle)
		x_delta, y_delta, x_side, y_side, x_step, y_step = 0.0, 0.0, 0.0, 0.0, 1, 1

		if (xoff == 0) then
			x_delta = 1e30
		else x_delta = math.abs(1.0/xoff) end

		if (yoff == 0) then
			y_delta = 1e30
		else y_delta = math.abs(1.0/yoff) end

		if (xoff < 0.0) then
			x_side = (player_x - math.floor(player_x)) * x_delta
			x_step = -1
		else x_side = (math.floor(player_x) + 1.0 - player_x) * x_delta end

		if (yoff < 0.0) then
			y_side = (player_y - math.floor(player_y)) * y_delta
			y_step = -1
		else y_side = (math.floor(player_y) + 1.0 - player_y) * y_delta end

		tx, ty = math.floor(player_x), math.floor(player_y)
		side = 0

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
			in_bounds = (tx < map_w+1 and ty < map_h+1 and tx > -1 and ty > -1)
			if (in_bounds) then
				local hit = map[coord_to_cell(tx, ty)]

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

					rx = player_x + xoff * dist
					ry = player_y + yoff * dist

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

function draw_raycast(ray_hits, hit_count)
	hor_h = win_h * 0.4
	pwx, pwy = map_to_window(player_x, player_y)
	pwx, pwy = pwx*minimap_scale + minimap_x, pwy*minimap_scale+minimap_y

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", 0, 0, win_w, hor_h)
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.rectangle("fill", 0, hor_h, win_w, win_h)
        s_w = win_w/ray_count

	for i = 1, hit_count do
		mod = 1.0 - (ray_hits[i].dist/10)

		if (mod < 0.0) then
			mod = 0.0
		end

		r_mod = 0.4 * mod
		g_mod = 0.3 * mod
		b_mod = 0.1 * mod
		love.graphics.setColor(0.5 + r_mod, 0.6 + g_mod, 0.8 + b_mod)
		s_h = (win_h / ray_hits[i].dist)
		start_x = s_w * (ray_hits[i].index-1)
		--love.graphics.rectangle("fill", start_x, hor_h-(s_h*0.5), s_w, s_h)
		love.graphics.draw(walltextures[ray_hits[i].type], wallquads[math.floor(ray_hits[i].side_px)], start_x, hor_h-(s_h*0.5), 0, s_w, s_h/64, 0, 0, 0, 0 )

-- minimap rays
		wx, wy = map_to_window(ray_hits[i].rx, ray_hits[i].ry)
		wx, wy = wx*minimap_scale + minimap_x, wy*minimap_scale + minimap_y
		love.graphics.setColor(1.0, 0.0, 0.0)
		love.graphics.line(pwx, pwy, wx, wy)
		love.graphics.setColor(0.0, 1.0, 0.0)
		wx, wy = map_to_window(ray_hits[i].tx, ray_hits[i].ty)
		wx, wy = wx*minimap_scale + minimap_x, wy*minimap_scale + minimap_y
		love.graphics.rectangle("line", wx, wy, tile_w*minimap_scale, tile_h*minimap_scale)
	end

end

function love.draw()
	ray_hits, hit_count = gather_raycast()
	draw_raycast(ray_hits, hit_count)
	draw_map()
end

function move_player(dir)
	move_x = pdx * move_speed * dir
	move_y = pdy * move_speed * dir

	if (dir == player_dir) then
		move_speed = move_speed + move_speed_min * 20
	else
		move_speed = move_speed_min
	end

	if (move_speed > move_speed_max) then
		move_speed = move_speed_max
	end

	player_x, player_y = player_x + move_x, player_y + move_y
	if (player_x > map_w) or (player_x < 0) or (player_y > map_h) or (player_y < 0)
		or map[coord_to_cell(player_x+player_bounds, player_y+player_bounds)] > 0
		or map[coord_to_cell(player_x-player_bounds, player_y+player_bounds)] > 0
		or map[coord_to_cell(player_x+player_bounds, player_y-player_bounds)] > 0
		or map[coord_to_cell(player_x-player_bounds, player_y-player_bounds)] > 0
		then
		player_x, player_y = player_x - move_x, player_y - move_y
		move_speed = move_speed_min
	end
end

function love.keypressed(key, scancode, isrepeat)
	if (key == "up") then
		move_player(1)
	elseif (key == "down") then
		move_player(-1)
	else
		move_speed = move_speed_min
	end

	if (key == "left") then
		player_angle = player_angle - (tau/100)
		if (player_angle < 0.0) then player_angle = tau end
	elseif (key == "right") then
		player_angle = player_angle + (tau/100)
		if (player_angle > tau) then player_angle = 0.0 end
	elseif (key == "v") then
		view_mode = view_mode + 1
		if (view_mode > 1) then view_mode = 0 end
	elseif (key == "d") then
		draw_mode = draw_mode + 1
		if (draw_mode > 8) then draw_mode = 0 end
	elseif (key == "1") then
		fov = fov - 1
	elseif (key == "2") then
		fov = fov + 1
	end
end
