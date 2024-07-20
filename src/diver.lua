
local flux = require("lib.flux")


Diver = {}
Diver.__index = Diver



function Diver:new()
    local _diver = setmetatable({}, Diver)
    _diver.spr_sheet = love.graphics.newImage("asset/image/diver/diver.png")
    local s_grid = anim8.newGrid(20, 20, _diver.spr_sheet:getWidth(), _diver.spr_sheet:getHeight())
    
    _diver.animations = {
        default = anim8.newAnimation(s_grid(('1-2'), 1), 0.5),
    }
    _diver.curr_animation = _diver.animations["default"]
    _diver.rotation = 0
    _diver.is_alive = true
    _diver.facing_dir = 1
    _diver.x = 60
    _diver.y = 11
    _diver.tmr_ghost_mode = Timer:new(15, function() _diver:exit_ghost_mode() end, false)
    _diver.tmr_wait_for_animation = Timer:new(60 * 0.9, function() go_to_gameover() end, false)
    _diver.speed = 100
    _diver.max_speed = 100
    _diver.is_moving = false
    _diver.w, _diver.h = _diver.curr_animation:getDimensions()
    _diver.hitbox = { x = _diver.x, y = _diver.y, w = _diver.w - 10, h = _diver.h - 4 }
    return _diver
end

function Diver:update(dt)
    flux.update(dt)
end

function Diver:die(pos)

end

function Diver:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, math.rad(self.rotation), self.facing_dir, 1, self.w / 2,
        self.h / 2)
end


all_divers = {}


function update_divers()
    for p in all(all_divers) do
        p:update()
    end
end

function draw_divers()
    for p in all(all_divers) do
        p:draw()
    end
end