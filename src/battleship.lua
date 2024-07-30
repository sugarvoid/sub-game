
Battleship = {}
Battleship.__index = Battleship

function Battleship:new()
    local _battleship = setmetatable({}, Battleship)

    _battleship.sprite = love.graphics.newImage("asset/image/battleship.png")
    _battleship.warning_sfx = love.audio.newSource("asset/audio/battleship_warning.ogg", "stream")

    _battleship.tmr_delay = Timer:new(function() _battleship:go() end, false)

    _battleship.x = -50
	_battleship.y = 4
	_battleship.moving_dir = 1
	_battleship.move_speed = 2
	_battleship.time_on_screen = 0 --To know when to stop updating and drawing the ship
	_battleship.is_in_game = false
	_battleship.ox = _battleship.sprite:getWidth()/2
	_battleship.oy = _battleship.sprite:getHeight()/2

    return _battleship
end

function Battleship:update(dt)
    self.tmr_delay:update()
    if self.is_in_game then
    	self.time_on_screen = self.time_on_screen + 1
    	--flux.update(dt)
	    self.x = self.x + self.move_speed * self.moving_dir --* dt
	    if self.time_on_screen == 300 then
	    	self.is_in_game = false
	    	self.tmr_delay:stop()
	    end
    end
end

function Battleship:pass_by()
	love.audio.play_sfx(self.warning_sfx)
	self.x = -50
    self.tmr_delay:start(2*60)
end

function Battleship:go( ... )
	self.is_in_game = true
	--[[
	TODO: Figure out a way to
		make it look like mine are being dropped
		by the ship
	]]-- 
	spawn_mine(40)
	print("start moving")
end

function Battleship:Reset()
    
end

function Battleship:draw()
	if self.is_in_game then
		love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.ox, self.oy)
	end
end



