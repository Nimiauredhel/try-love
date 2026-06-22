function load_map()
    dist_max = 32
	map_w, map_h = 16, 16
	map = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	}
end

function update_scale()
	win_w, win_h = love.graphics.getDimensions()
	tile_w = win_w / map_w
	tile_h = win_h / map_h
end

function love.load()
    runtime = 0
	pi = 3.14
	tau = 6.28
	love.keyboard.setKeyRepeat(true)
	move_speed_min = 0.25
	move_speed_max = 0.5
	move_speed = move_speed_min
	load_map()
	update_scale()
	view_mode = 0
	draw_mode = 0
	player_x, player_y = map_w/2, map_h/2
	player_dir = 0
	player_angle = 0.0
end

function map_to_window(map_x, map_y)
	win_x = tile_w * (map_x-1)
	win_y = tile_h * (map_y-1)
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
	for map_x=1, map_w do
		for map_y=1, map_h do
		cell = coord_to_cell(map_x, map_y)
		if map[cell] == 1 then
			love.graphics.setColor(0.7, 0.7, 0.7)
		else
			love.graphics.setColor(0.2, 0.2, 0.2)
		end
		win_x, win_y = map_to_window(map_x, map_y)
		love.graphics.rectangle("fill", win_x, win_y, tile_w, tile_h)
		end
	end

	win_x, win_y = map_to_window(player_x, player_y)
	love.graphics.setColor(0.2, 0.8, 0.2)
	love.graphics.line(win_x, win_y, win_x+(pdx*tile_w), win_y+(pdy*tile_h))
	win_x = win_x - tile_w/2
	win_y = win_y - tile_h/2
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.rectangle("fill", win_x, win_y, tile_w, tile_h)
end

function draw_raycast(top_down)
	hor_h = win_h * 0.5
	pwx, pwy = map_to_window(player_x, player_y)
	dof_max = 80
	ray_count = win_w
    fov = (60.0 / 360.0) * tau
	ray_inc = fov / ray_count
	local ray_angle = player_angle - fov/2

	if (top_down) then
	else
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.rectangle("fill", 0, 0, win_w, hor_h)
		love.graphics.setColor(0.25, 0.25, 0.25)
		love.graphics.rectangle("fill", 0, hor_h, win_w, win_h)
        s_w = win_w/ray_count
	end

    if (draw_mode > 0) then
        ray_count = math.fmod(runtime*draw_mode*(win_w / 100), ray_count)
    end

	for ray=1, ray_count do
		if (ray_angle < 0.0) then ray_angle = ray_angle + tau
		elseif (ray_angle > tau) then ray_angle = ray_angle - tau end

		dof = 0
		atan = -math.tan(ray_angle)
		pxi, pxf = math.modf(player_x)
		pyi, pyf = math.modf(player_y)
		yoff = math.sin(ray_angle)
		xoff = math.cos(ray_angle)
		ry = player_y
		rx = player_x

		while (dof < dof_max) do
			dof = dof + 1
			if (rx < map_w+1
			and ry < map_h+1
			and rx > -1 and ry > -1) then
				if (map[coord_to_cell(rx, ry)] == 1) then
                    dof = dof_max
					if (player_x > rx) then
						vrx = math.ceil(rx)
					else
						vrx = math.floor(rx)
					end
					if (player_y > ry) then
						hry = math.ceil(ry)
					else
						hry = math.floor(ry)
					end
                    dist_x = math.abs(player_x-rx)
                    dist_y = math.abs(player_y-ry)
                    if (dist_x < dist_y) then
                        frx, fry = vrx, ry
                    else
                        frx, fry = rx, hry
                    end
					if (top_down) then
                        wx, wy = map_to_window(frx, fry)
						love.graphics.setColor(1.0, 0.0, 0.0)
						love.graphics.line(pwx, pwy, wx, wy)
					else
						corr_angle = player_angle - ray_angle
						if (corr_angle < 0) then
							corr_angle = corr_angle + tau
						elseif (corr_angle > tau) then
							corr_angle = corr_angle - tau
						end
                        if (dist_x < dist_y) then
                            mod = 1.0 - (dist_x/dist_max)
                        else
                            mod = 1.0 - (dist_y/dist_max)
                        end
						mod = mod * math.cos(corr_angle)
						love.graphics.setColor(0.5 * mod, mod, 0.2 * mod)
						s_h = win_h * mod
						start_x = s_w * (ray-1)
						love.graphics.rectangle("fill", start_x, hor_h-(s_h*0.5), s_w, s_h)
					end
				end
            else
                if (top_down) then
                    if (dist_x < dist_y) then
                        wx, wy = map_to_window(rx, ry)
                    else
                        wx, wy = map_to_window(rx, ry)
                    end
                    love.graphics.setColor(0.2, 0.2, 1.0)
                    love.graphics.line(pwx, pwy, wx, wy)
                end
                dof = dof_max
			end
            rx = rx + xoff
            ry = ry + yoff
		end
	ray_angle = ray_angle + ray_inc
	end
end

function love.draw()
	if (view_mode == 0) then
		draw_map()
		draw_raycast(true)
	elseif (view_mode == 1) then
		draw_raycast(false)
	end
end

function move_player(dir)
	move_x = pdx * move_speed * dir
	move_y = pdy * move_speed * dir

	if (dir == player_dir) then
		move_speed = move_speed + move_speed_min * 10
	else
		move_speed = move_speed_min
	end

	if (move_speed > move_speed_max) then
		move_speed = move_speed_max
	end

	player_x, player_y = player_x + move_x, player_y + move_y
	if (player_x > map_w-1) or (player_x < 2) or (player_y > map_h-1) or (player_y < 2)
		or map[coord_to_cell(player_x, player_y)] == 1 then
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
		player_angle = player_angle - (tau/180)
		if (player_angle < 0.0) then player_angle = tau end
	elseif (key == "right") then
		player_angle = player_angle + (tau/180)
		if (player_angle > tau) then player_angle = 0.0 end
	elseif (key == "v") then
		view_mode = view_mode + 1
		if (view_mode > 1) then view_mode = 0 end
	elseif (key == "d") then
		draw_mode = draw_mode + 1
		if (draw_mode > 8) then draw_mode = 0 end
	end
end
