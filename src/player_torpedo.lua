

local spr_torpedo = love.graphics.newImage("asset/image/player_torpedo.png")


Torpedo = {}
Torpedo.__index = Torpedo


--TODO: Remove body, it is not needed. can use simple AABB


local STARTING_Y = 10


function Torpedo:new(x, y, _parent)
	local _torpedo = setmetatable({}, Torpedo)
	_torpedo.parent = _parent
	_torpedo.x = x
	_torpedo.y = y
	_torpedo.xvel = 0
	_torpedo.move_speed = 3
	_torpedo.facing_dir = 1
	_torpedo.trusting = false
	_torpedo.bubbles={}
	

	_torpedo.w, _torpedo.h = spr_torpedo:getDimensions()

    _torpedo.hitbox = { 
    	x = _torpedo.x, 
    	y = _torpedo.y, 
    	w = _torpedo.w, 
    	h = _torpedo.h + 2
    }

   -- _torpedo.body = love.physics.newBody(world, _torpedo.hitbox.x,_torpedo.hitbox.y, "dynamic")
    --_torpedo.shape = love.physics.newRectangleShape(_torpedo.hitbox.w, _torpedo.hitbox.h)
   -- _torpedo.fixture = love.physics.newFixture(_torpedo.body, _torpedo.shape)
   -- _torpedo.fixture:setUserData({type="P_Torpedo", owner=_torpedo})



	return _torpedo
end

function Torpedo:update(dt)
	--TODO: Add bubble particles 
	if self.trusting then
		self.xvel = clamp(0, self.xvel + 0.05, 100)
		self.x = (self.x + (self.xvel * self.facing_dir))
		--self.x = self.x + self.move_speed * self.facing_dir
	end
	self.hitbox.x = (self.x - self.w /2)
    self.hitbox.y = (self.y - 1 )
   --self.body:setPosition(self.hitbox.x,self.hitbox.y)
end

function Torpedo:drop(starting_y)
	flux.to(self, 0.5, {y = starting_y + 4}):oncomplete(function() self.trusting = true self.parent.can_shoot = true end)
end

function Torpedo:draw()
	love.graphics.draw(spr_torpedo, self.x, self.y, 0, self.facing_dir, 1, 3, 1)
	
	draw_hitbox(self.hitbox, "#ff80a4")
end



player_torpedos={}


