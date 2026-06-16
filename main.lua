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
	win_w, win_h = love.graphics.getDimensions()
	w, h = 40, 40
	x = love.math.random(win_w * 0.25, win_w * 0.75)
	y = love.math.random(win_h * 0.25, win_h * 0.75)
	dir_x, dir_y = 8, 8
	if (love.math.random(0, 1) == 1) then dir_x = dir_x * -1 end
	if (love.math.random(0, 1) == 1) then dir_y = dir_y * -1 end
	rectcol_r, rectcol_g, rectcol_b = 0, 0.4, 0.4
	hit_x, hit_y = 0, 0
end

function love.update()
	win_w, win_h = love.graphics.getDimensions()
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

function love.draw()
	love.graphics.setColor(rectcol_r, rectcol_g, rectcol_b)
	love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.line(x, y, hit_x, hit_y)
end
