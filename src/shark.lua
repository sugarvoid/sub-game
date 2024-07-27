--local flux = require("lib.flux")

require("src.shark_parts")

Shark = {}
Shark.__index = Shark

local _sfx_die = love.audio.newSource("asset/audio/shark_death.ogg", "stream")


local _player = nil

--TODO: Remove body, it is not needed. can use simple AABB
local spr_sheet = love.graphics.newImage("asset/image/shark.png")


function Shark:new(x, y, facing_dir)
    local _shark = setmetatable({}, Shark)
    
    local s_grid = anim8.newGrid(22, 16, spr_sheet:getWidth(), spr_sheet:getHeight())
    _shark.animations = {
        default = anim8.newAnimation(s_grid(('1-4'), 1), 0.2),
    }
    _shark.curr_animation = _shark.animations["default"]
    _shark.is_alive = true
    _shark.facing_dir = facing_dir
    _shark.x = x
    _shark.y = y
    _shark.move_speed = 0.4
    _shark.w, _shark.h = _shark.curr_animation:getDimensions()
    _shark.hitbox = { x = _shark.x, y = _shark.y, w = _shark.w-6, h = _shark.h -10}
    
    return _shark
end

function Shark:update(dt)
    --flux.update(dt)
    self.curr_animation:update(dt)
    self.x = self.x + self.move_speed * self.facing_dir
    self.hitbox.x = (self.x - self.w /2)+2
    self.hitbox.y = (self.y - self.h/2) +3
    --self.body:setPosition(self.hitbox.x,self.hitbox.y)
end

function Shark:die(pos)
    --FIXME: If two sharks die back to back, the second one doesn't play sound
    --_sfx_die:play()
    love.audio.play_sfx(_sfx_die)
    player:increase_score(20)
    spawn_shark_peices(self.x, self.y, self.facing_dir)
    table.remove_item(all_sharks, self)
end

function Shark:draw()
    self.curr_animation:draw(spr_sheet, self.x, self.y - 2, 0, self.facing_dir, 1, self.w / 2, self.h / 2)
    draw_hitbox(self.hitbox, "#f30909")
end


all_sharks = {}


function update_sharks(dt)
    for p in table.for_each(all_sharks) do
        if check_collision(p.hitbox, player.hitbox) then
            --remove_item(all_sharks, p)
            print("player die")
        end
        for _t in table.for_each(player_torpedos) do
            if check_collision(p.hitbox, _t.hitbox) then
                p:die()
                table.remove_item(player_torpedos, _t)
                print("SHARK KILLED")
            end
        end
        p:update(dt)
    end
end

function draw_sharks()
    for p in table.for_each(all_sharks) do
        p:draw()
    end
end