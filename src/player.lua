--player.lua

Player = {}
Player.__index = Player


local flux = require("lib.flux")




function Player:new()
    local _player = setmetatable({}, Player)
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
    _player.friction = 1
    _player.max_speed = 80
    _player.acceleration = 25
    _player.w, _player.h = _player.curr_animation:getDimensions()
    _player.hitbox = { x = _player.x, y = _player.y, w = _player.w, h = _player.h-3 }
    return _player
end

function Player:update(dt)
    self:move(dt)
    self.x = self.x + self.xvel * dt
    self.y = self.y + self.yvel * dt
    self.xvel = clamp(-self.max_speed, (self.xvel * (1 - math.min(dt * self.friction, 1))), self.max_speed)
    self.yvel = self.yvel * (1 - math.min(dt * self.friction, 1))

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
    self.hitbox.y = self.y - self.h/2
end

function Player:move(dt)
    if self.xvel < 0 then
        self.facing_dir = -1
    else
        self.facing_dir = 1
    end
    if love.keyboard.isDown("d") and
        self.xvel < self.speed then
        self.xvel = self.xvel + self.speed * dt
    end

    if love.keyboard.isDown("a") and
        self.xvel > -self.speed then
        self.xvel = self.xvel - self.speed * dt
    end

    if love.keyboard.isDown("s") and
        self.yvel < self.speed then
        self.yvel = self.yvel + self.speed * dt
    end

    if love.keyboard.isDown("w") and
        self.yvel > -self.speed then
        self.yvel = self.yvel - self.speed * dt
    end
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
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2,
        self.h / 2)
    draw_hitbox(self, "#D70040")
end

function Player:reset()
    self.animations["death"]:resume()
    self.animations["death"]:gotoFrame(1)
    self.is_alive = true
    self.curr_animation = self.animations["default"]
end
