function load_map()
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

function on_edge(is_x)
	hit_x = x
	hit_y = y
	temp_r = rectcol_r
	temp_g = rectcol_g
	temp_b = rectcol_b
	rectcol_r = temp_b
	rectcol_g = temp_r
	rectcol_b = temp_g

end

function love.load()
	load_map()
	update_scale()
	view_mode = 0
	player_x, player_y = map_w/2, map_h/2
	w, h = 40, 40
	x = love.math.random(win_w * 0.25, win_w * 0.75)
	y = love.math.random(win_h * 0.25, win_h * 0.75)
	dir_x, dir_y = 8, 8
	if (love.math.random(0, 1) == 1) then dir_x = dir_x * -1 end
	if (love.math.random(0, 1) == 1) then dir_y = dir_y * -1 end
	rectcol_r, rectcol_g, rectcol_b = 0, 0.4, 0.4
	hit_x, hit_y = 0, 0
end

function map_to_window(map_x, map_y)
	win_x = tile_w * (map_x-1)
	win_y = tile_h * (map_y-1)
	return win_x, win_y
end

function coord_to_cell(map_x, map_y)
	cell = ((map_y-1)*map_w)+map_x
	return cell
end

function love.update()
	update_scale()
	x = x + dir_x
	y = y + dir_y
	if (x > (win_w - w) or x < 0) then
		on_edge()
		dir_x = dir_x * -1
	end
	if (y > (win_h - h) or y < 0) then
		on_edge()
		dir_y = dir_y * -1
	end
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

	love.graphics.setColor(0.8, 0.2, 0.2)
	win_x, win_y = map_to_window(player_x, player_y)
	love.graphics.rectangle("fill", win_x, win_y, tile_w, tile_h)
end

function draw_pov()
	hor_h = win_h * 0.5
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", 0, 0, win_w, hor_h)
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.rectangle("fill", 0, hor_h, win_w, win_h)

	dist = { 0, 0, 0, 0, 0 }
	seg_start_x = { 0.0, 0.1, 0.35, 0.65, 0.9 }
	seg_w = { 0.1, 0.25, 0.3, 0.25, 0.1 }
	seg_corr = { 0.2, 0.2, 0.2, 0.2, 0.2 }
	test_x_init = { -1, -1, 0, 1, 1 }
	test_y_init = { 0, -1, -1, -1, 0 }
	test_x_dir = { 0, 0, 0, 0, 0 }
	test_y_dir = { -1, -1, -1, -1, -1 }

	mid = 3
	mult = 100

	for i = 1, 5 do
		test_x, test_y = player_x + test_x_init[i], player_y + test_y_init[i]
		repeat
			dist[i] = dist[i] + 1
			test_x, test_y = test_x + test_x_dir[i], test_y + test_y_dir[i]
		until (dist[i] > 200 or test_y < 1 or map[coord_to_cell(test_x, test_y)] == 1)
		for s = 1, mult do
			mod = s/mult
			if i == mid then mod = 1.0
			elseif (i > mid) then mod = 1.0 - mod end
			mod = mod * (seg_corr[i] / dist[i])
			love.graphics.setColor(0.25+(i*0.1)-((player_x%3)*0.005), 0.25+((player_x%4)*0.01), 1.0 / (1.0 + (dist[i])))
			s_w = (win_w*seg_w[i])/mult
			start_x = (win_w*seg_start_x[i])+(s_w*(s-1))
			s_h = (win_h/dist[i]) + (mod*(hor_h/dist[i]))
			love.graphics.rectangle("fill", start_x, hor_h-(s_h*0.5), s_w, s_h)
		end
	end
end

function love.draw()
	if (view_mode == 0) then
		draw_map()
	else
		draw_pov()
	end
	love.graphics.setColor(rectcol_r, rectcol_g, rectcol_b)
	love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.line(x, y, hit_x, hit_y)
end

function love.keypressed(key, scancode, isrepeat)
	move_x, move_y = 0, 0
	if (key == "left") then
		move_x, move_y = -1, 0
	elseif (key == "up") then
		move_x, move_y = 0, -1
	elseif (key == "right") then
		move_x, move_y = 1, 0
	elseif (key == "down") then
		move_x, move_y = 0, 1
	else
		if (key == "v") then
			view_mode = view_mode + 1
			if (view_mode > 1) then view_mode = 0 end
		end
		return
	end
	
	player_x, player_y = player_x + move_x, player_y + move_y
	if (player_x > map_w-1) or (player_x < 2) or (player_y > map_h-1) or (player_y < 2)
		or map[coord_to_cell(player_x, player_y)] == 1 then
		player_x, player_y = player_x - move_x, player_y - move_y
	end

end
