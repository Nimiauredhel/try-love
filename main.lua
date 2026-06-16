function load_map()
	map_w, map_h = 8, 8
	map = {
		1, 1, 1, 1, 1, 1, 1, 1,
		1, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 1, 1, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 1,
		1, 0, 0, 0, 0, 0, 0, 1,
		1, 1, 1, 1, 1, 1, 1, 1,
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
		cell = ((map_y-1)*map_w)+map_x
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

function love.draw()
	draw_map()
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
	else return end
	
	player_x, player_y = player_x + move_x, player_y + move_y
	if (player_x > map_w) or (player_x < 1) or (player_y > map_h) or (player_y < 1) then
		player_x, player_y = player_x - move_x, player_y - move_y
	end

end
