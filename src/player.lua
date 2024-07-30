
Player = {}
Player.__index = Player

_sfx_diver_saved = love.audio.newSource("asset/audio/diver_saved.ogg", "static")
local _sfx_diver_killed = love.audio.newSource("asset/audio/diver_death.ogg", "static")
local _sfx_surface = love.audio.newSource("asset/audio/surface.wav", "stream")

local sounds = {
    _sfx_diver_saved,
    _sfx_diver_killed,
    _sfx_surface
}

function Player:new()
    local _player = setmetatable({}, Player)
    _player.score = 0
    _player.high_score = 0 --TODO: Add to game object, not player??
    
    _player.MAX_OXYGEN = 60
    _player.oxygen = _player.MAX_OXYGEN
    _player.image = love.graphics.newImage("asset/image/ship_player.png")
    _player.spr_sheet = love.graphics.newImage("asset/image/player_sheet.png")
    local s_grid = anim8.newGrid(24, 16, _player.spr_sheet:getWidth(), _player.spr_sheet:getHeight())

    _player.animations = {
        default = anim8.newAnimation(s_grid(('1-5'), 1), 0.1),
        death = anim8.newAnimation(s_grid(('1-4'), 1), 0.1),
    }
    _player.is_submerged = true
    _player.diver_on_board = 0
    _player.starting_pos = { x = 100, y = 100 }
    _player.curr_animation = _player.animations["default"]
    _player.rotation = 0
    _player.is_alive = true
    _player.facing_dir = 1
    _player.x = _player.starting_pos.x
    _player.y = _player.starting_pos.y
    _player.is_moving_left = false
    _player.is_moving_right = false
    _player.can_shoot = true
    _player.can_move = true
    _player.speed = 100
    _player.vel_y = 50
    _player.vel_x = 0
    _player.xvel = 0
    _player.yvel = 0
    _player.friction = 1.1
    _player.max_speed = 80
    _player.acceleration = 25
    _player.w, _player.h = _player.image:getDimensions()
    _player.hitbox = { x = _player.x, y = _player.y, w = _player.w -2, h = _player.h - 10 }
    
    _player.body = love.physics.newBody(world,_player.x,_player.y,"dynamic")
    _player.shape = love.physics.newRectangleShape(_player.hitbox.w, _player.hitbox.h)
    _player.fixture = love.physics.newFixture(_player.body, _player.shape)
    _player.fixture:setUserData("Player")

    return _player
end

function Player:update(dt)
    if self.can_move then

        self:move(dt)
    end
    if self.is_submerged then
        self.oxygen = clamp(0, self.oxygen - 0.05, self.MAX_OXYGEN)
    end

    self.curr_animation:update(dt)

    if self.is_alive then
        flux.update(dt)
    end

    self.hitbox.x = self.x - self.w /2
    self.hitbox.y = (self.y - self.h/2) + 6
    self.body:setPosition(self.hitbox.x,self.hitbox.y)
end

function Player:on_surfaced()
    self:refill_o2()
end

function Player:refill_o2()
    flux.to(self, 3, { oxygen = 60 }):oncomplete(
        function()
            self.xvel = 0
            self.yvel = 0
            flux.to(self, 1,{y = 30}):oncomplete(
                function()
                    self.can_move = true
                    self.is_submerged =  not self.is_submerged
                end
                )
            print("done refilling. Send back down.")
        end
    )
end

function Player:increase_score(amount)
    self.score = self.score + amount
end

function Player:unload_divers()
    --TODO: Make a general update_diver(value) function in player
    if player.diver_on_board > 0 then
        player.diver_on_board = clamp(0, player.diver_on_board - 1, 6)
        diver_HUD:update_display(player.diver_on_board)
    else
        print("Kill player...")
    end
    
end

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
    self.y = clamp(16, (self.y + self.yvel * dt), 108)
end

function Player:die(pos, condition)
    self.rotation = 0
    self.is_alive = false
    self.curr_animation = self.animations["death"]
end

function Player:shoot(...)
    if self.can_shoot and self.can_move then
        self.can_shoot = false
        local _x = self.x --+ self.w / 2
        local _y = self.y + 4 --+ self.h / 2
        local new_torpedo = Torpedo:new(_x, _y, self)
        new_torpedo.facing_dir = self.facing_dir
        table.insert(player_torpedos, new_torpedo)
        new_torpedo:drop(_y)
    end
end

function Player:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2, self.h / 2)
    draw_hitbox(self.hitbox, "#D70040")
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