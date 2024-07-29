
SeaMine = {}
SeaMine.__index = SeaMine

all_mines = {}

function SeaMine:new(_x)
    local _sea_mine = setmetatable({}, SeaMine)

    _sea_mine.sprite = love.graphics.newImage("asset/image/sea_mine.png")
    _sea_mine.warning_sfx = love.audio.newSource("asset/audio/battleship_warning.ogg", "stream")
    _sea_mine.x = _x
	_sea_mine.y = 25
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
	love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.ox, self.oy)
	draw_hitbox(self.hitbox, "#3e8948")
end


function update_mines(dt)
	for m in table.for_each(all_mines) do 
		if check_collision(m.hitbox, player.hitbox) then
            --remove_item(all_sharks, p)
            print("player hit mine")
        end
		m:update(dt)
	end
end

function draw_mines()
	for _, m in ipairs(all_mines) do
		m:draw()
	 end
end


