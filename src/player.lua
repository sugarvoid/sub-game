--player.lua

Player = {}
Player.__index = Player


local flux = require("lib.flux")
local player_mass = 0.22



function Player:new()
    local _player = setmetatable({}, Player)
    _player.spr_sheet = love.graphics.newImage("asset/image/player_sheet.png")
    _player.image = love.graphics.newImage("asset/image/player.png")
    _player.crown = love.graphics.newImage("asset/image/crown.png")
    local s_grid = anim8.newGrid(16, 16, _player.spr_sheet:getWidth(), _player.spr_sheet:getHeight())
    
    _player.animations = {
        idle = anim8.newAnimation(s_grid(('1-6'), 1), 0.1),
        death = anim8.newAnimation(s_grid(('7-14'), 1), 0.1, 'pauseAtEnd')
    }
    _player.starting_pos = { x = 60, y = 111 }
    _player.curr_animation = _player.animations["idle"]
    _player.alpha = 255
    _player.rotation = 0
    _player.is_alive = true
    _player.is_ghost = false
    _player.facing_dir = 1
    _player.x = _player.starting_pos.x
    _player.y = _player.starting_pos.y
    _player.has_won = false
    _player.is_moving_left = false
    _player.is_moving_right = false
    _player.tmr_standing_still = Timer:new(60 * 3, function() _player:inactive_die() end, true)
    _player.tmr_standing_still:start()
    _player.tmr_ghost_mode = Timer:new(15, function() _player:exit_ghost_mode() end, false)
    _player.tmr_wait_for_animation = Timer:new(60 * 0.9, function() go_to_gameover() end, false)
    _player.jumps_left = 2
    _player.jump_effect = JumpSfx:new()
    _player.speed = 100
    _player.vel_y = 50
    _player.vel_x = 0
    _player.max_speed = 100
    _player.acceleration = 20
    _player.friction = 3500
    _player.is_moving = false
    _player.w, _player.h = _player.curr_animation:getDimensions()
    _player.hitbox = { x = _player.x, y = _player.y, w = _player.w - 10, h = _player.h - 4 }
    _player.body = world:newRectangleCollider(_player.x, _player.y - 2, _player.hitbox.w, _player.hitbox.h - 2)
    _player.body:setType("dynamic")
    _player.body:setCollisionClass("Player")
    _player.body:setObject(_player)
    _player.body:setFixedRotation(true)
    _player.body:setMass(player_mass)
    return _player
end

function Player:update(dt)
    local vel_x, vel_y = self.body:getLinearVelocity()

    if love.keyboard.isDown('d') then
        self.facing_dir = 1
        vel_x = clamp(self.max_speed, vel_x + self.acceleration, 0)
    end
    if love.keyboard.isDown('a') then
        self.facing_dir = -1
        vel_x = clamp(-self.max_speed, vel_x + -self.acceleration, 0)
    end

    self.body:setLinearVelocity(vel_x, vel_y)
    self.curr_animation:update(dt)
    self.jump_effect:update(dt)
    self.tmr_wait_for_animation:update()

    if self.is_alive then
        if self.body:enter("Sickle") then
            if self.is_ghost then
                print("player phased through sickle")
                return
            else
                local collision_data = self.body:getEnterCollisionData("Sickle")
                local sickle = collision_data.collider:getObject()
                sickle:shatter()
                local death_x, death_y = self.body:getPosition()
                self:die({ death_x, death_y })
            end
        end
        flux.update(dt)
        self.tmr_ghost_mode:update()
        if vel_x == 0 then
            self.tmr_standing_still:update()
        else
            self.tmr_standing_still:start()
        end
        if self.body:enter("Ground") then
            self.rotation = 0
            self.jumps_left = 2
        end

        self.x = self.body:getX()
        self.y = self.body:getY()

        if self.body:getY() >= 132 or self.body:getX() <= 2 or self.body:getX() >= 239 then
            local death_x, death_y = self.body:getPosition()
            self:die({ death_x, death_y })
        end
    end
end

function Player:jump()
    if self.is_alive then
        local vel_x, vel_y = self.body:getLinearVelocity()
        if self.jumps_left == 2 then -- First jump
            jump_sfx:play()
            self.body:applyLinearImpulse(0, -55, self.body:getX(), self.body:getY() + (self.h / 2))
            self.jumps_left = self.jumps_left - 1
        elseif self.jumps_left == 1 then -- Double jump
            jump_sfx2:play()
            self.jump_effect:do_animation(self.x, self.y)
            self:enter_ghost_mode()
            self:flip()
            self.body:setLinearVelocity(vel_x, 0)
            self.body:applyLinearImpulse(0, (-55 * 0.8))
            self.jumps_left = self.jumps_left - 1
        end
    end
end

function Player:inactive_die()
    local death_x, death_y = self.body:getPosition()
    self:die({ death_x, death_y })
end

function Player:die(pos, condition)
    self.rotation = 0
    self.body:setType("static")
    self.is_alive = false
    self.curr_animation = self.animations["death"]
    self.tmr_wait_for_animation:start()
    death_sfx:play()
    spawn_death_marker(pos[1], pos[2])
end

function Player:draw()
    self.jump_effect:draw()
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, self.alpha))
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2,
        self.h / 2)
    if self.is_alive and self.has_won then
        love.graphics.draw(self.crown, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2,
            self.h /
            2)
    end
    love.graphics.setColor(255, 255, 255)
end

function Player:flip()
    flux.to(self, 0.3, { rotation = -360 })
end

function Player:enter_ghost_mode()
    self.is_ghost = true
    self.tmr_ghost_mode:start()
    self.alpha = 150
end

function Player:exit_ghost_mode()
    self.is_ghost = false
    self.alpha = 255
end

function Player:reset()
    self.body:setType("dynamic")
    self.is_ghost = false
    self.body:setAwake(true)
    self.body:setMass(player_mass)
    self.body:setPosition(self.starting_pos.x, self.starting_pos.y)
    self.animations["death"]:resume()
    self.animations["death"]:gotoFrame(1)
    self.tmr_wait_for_animation:stop()
    self.is_alive = true
    self.curr_animation = self.animations["idle"]
end