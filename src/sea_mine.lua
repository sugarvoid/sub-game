
SeaMine = {}
SeaMine.__index = SeaMine

all_mines = {}

function SeaMine:new(_x, _y)
	print(_y)
    local _sea_mine = setmetatable({}, SeaMine)

    _sea_mine.sprite = love.graphics.newImage("asset/image/sea_mine.png")
    _sea_mine.warning_sfx = love.audio.newSource("asset/audio/battleship_warning.ogg", "stream")
    _sea_mine.x = _x
	_sea_mine.y = _y --or 25
	_sea_mine.ox = _sea_mine.sprite:getWidth()/2
	_sea_mine.oy = _sea_mine.sprite:getHeight()/2

	_sea_mine.w, _sea_mine.h = _sea_mine.sprite:getDimensions()
    _sea_mine.hitbox = { x = _sea_mine.x, y = _sea_mine.y, w = _sea_mine.w, h = _sea_mine.h}

    return _sea_mine
end

function SeaMine:update(dt)
	self.y = self.y + 20 * dt
	self.hitbox.x = (self.x - self.w/2)
    self.hitbox.y = (self.y - self.h/2)
end


function SeaMine:draw()
	if self.y >= 25 and self.y <= 136 then
		love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.ox, self.oy)
		--draw_hitbox(self.hitbox, "#3e8948")
	end
end

function spawn_mine(x, y)
	_sm = SeaMine:new(x,y)
	table.insert(all_mines, _sm)
end

function update_mines(dt)
	for _, m in ipairs(all_mines) do 
		if check_collision(m.hitbox, player.hitbox) then
			table.remove(all_mines, _)
			player:die()
        end
		m:update(dt)
	end
end

function draw_mines()
	for _, m in ipairs(all_mines) do
		m:draw()
	end
end


