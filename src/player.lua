--player.lua

Player = {}
Player.__index = Player


local flux = require("lib.flux")

local _sfx_diver_saved = love.audio.newSource("asset/audio/diver_saved.ogg", "static")
local _sfx_diver_killed = love.audio.newSource("asset/audio/diver_death.ogg", "static")
local _sfx_surface = love.audio.newSource("asset/audio/surface.wav", "stream")

local sounds = {
    _sfx_diver_saved,
    _sfx_diver_killed,
    _sfx_surface
}

local surface_rect = {
    x=0,y=0,w=240,h=16
}


function Player:new()
    local _player = setmetatable({}, Player)
    _player.score = 0
    
    _player.MAX_OXYGEN = 60
    _player.oxygen = _player.MAX_OXYGEN
    _player.image = love.graphics.newImage("asset/image/ship_player.png")
    _player.spr_sheet = love.graphics.newImage("asset/image/player/player.png")
    local s_grid = anim8.newGrid(19, 14, _player.spr_sheet:getWidth(), _player.spr_sheet:getHeight())

    _player.animations = {
        default = anim8.newAnimation(s_grid(('1-4'), 1), 0.1),
        death = anim8.newAnimation(s_grid(('1-4'), 1), 0.1),
    }
    _player.starting_pos = { x = 100, y = 100 }
    _player.curr_animation = _player.animations["default"]
    _player.rotation = 0
    _player.is_alive = true
    _player.facing_dir = 1
    _player.x = _player.starting_pos.x
    _player.y = _player.starting_pos.y
    _player.is_moving_left = false
    _player.is_moving_right = false
    _player.speed = 100
    _player.vel_y = 50
    _player.vel_x = 0
    _player.xvel = 0
    _player.yvel = 0
    _player.friction = 1.1
    _player.max_speed = 80
    _player.acceleration = 25
    _player.w, _player.h = _player.image:getDimensions()
    _player.hitbox = { x = _player.x, y = _player.y, w = _player.w, h = _player.h - 6 }
    
    _player.body = love.physics.newBody(world,_player.x,_player.y,"dynamic")
    _player.shape = love.physics.newRectangleShape(_player.hitbox.w, _player.hitbox.h)
    _player.fixture = love.physics.newFixture(_player.body, _player.shape)
    _player.fixture:setUserData("Player")




    return _player
end

function Player:update(dt)
    self:move(dt)
    self.oxygen = clamp(0, self.oxygen - 0.1, self.MAX_OXYGEN)
    print(self.oxygen)
    
    --print(self.body:isAwake())
    -- if love.keyboard.isDown('d') then
    --     self.facing_dir = 1
    --     self.x = self.x + 1
    --     --vel_x = clamp(self.max_speed, vel_x + self.acceleration, 0)

    -- elseif love.keyboard.isDown('a') then
    --     self.facing_dir = -1
    --     self.x = self.x - 1
    --     --vel_x = clamp(-self.max_speed, vel_x + -self.acceleration, 0)
    -- end

    -- if love.keyboard.isDown('s') then

    --     self.y = self.y + 1
    --     --vel_x = clamp(self.max_speed, vel_x + self.acceleration, 0)

    -- elseif love.keyboard.isDown('w') then

    --     self.y = self.y - 1
    --     --vel_x = clamp(-self.max_speed, vel_x + -self.acceleration, 0)
    -- end

    self.curr_animation:update(dt)

    if self.is_alive then
        flux.update(dt)
    end

    self.hitbox.x = self.x - self.w /2
    self.hitbox.y = (self.y - self.h/2) + 6
    self.body:setPosition(self.hitbox.x,self.hitbox.y)
end

-- function Player:move(dt)
--     if self.xvel < 0 then
--         self.facing_dir = -1
--     else
--         self.facing_dir = 1
--     end
--     if love.keyboard.isDown("d") and
--         self.xvel < self.speed then
--         self.xvel = self.xvel + self.speed * dt
--     end

--     if love.keyboard.isDown("a") and
--         self.xvel > -self.speed then
--         self.xvel = self.xvel - self.speed * dt
--     end

--     if love.keyboard.isDown("s") and
--         self.yvel < self.speed then
--         self.yvel = self.yvel + self.speed * dt
--     end

--     if love.keyboard.isDown("w") and
--         self.yvel > -self.speed then
--         self.yvel = self.yvel - self.speed * dt
--     end
-- end

function Player:move(dt)
    local speed = self.speed * dt
    
    if love.keyboard.isDown("d") then
        self.xvel = math.min(self.xvel + speed, self.speed)
        self.facing_dir = 1
    elseif love.keyboard.isDown("a") then
        self.xvel = math.max(self.xvel - speed, -self.speed)
        self.facing_dir = -1
    end

    if love.keyboard.isDown("s") then
        self.yvel = math.min(self.yvel + speed, self.speed)
    elseif love.keyboard.isDown("w") then
        self.yvel = math.max(self.yvel - speed, -self.speed)
    end

    self.xvel = clamp(-self.max_speed, (self.xvel * (1 - math.min(dt * self.friction, 1))), self.max_speed)
    self.yvel = self.yvel * (1 - math.min(dt * self.friction, 1))

    self.x = clamp(20, (self.x + self.xvel * dt), 220)
    self.y = clamp(14, (self.y + self.yvel * dt), 136)
    


end

function Player:die(pos, condition)
    self.rotation = 0
    self.is_alive = false
    self.curr_animation = self.animations["death"]
end

function Player:shoot(...)
    print("pew")
end

function Player:draw()
    --self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2, self.h / 2)
    love.graphics.draw(self.image, self.x, self.y, 0, self.facing_dir, 1, self.w/2, self.h/2)
    draw_hitbox(self.hitbox, "#D70040")
    draw_hitbox(surface_rect, "#feae34")
    
end

function Player:reset()
    self.animations["death"]:resume()
    self.animations["death"]:gotoFrame(1)
    self.is_alive = true
    self.curr_animation = self.animations["default"]
end

function Player:play_sound(num)
    sounds[num]:play()
end