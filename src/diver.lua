
local flux = require("lib.flux")



Diver = {}
Diver.__index = Diver



function Diver:new()
    local _diver = setmetatable({}, Diver)
    _diver.spr_sheet = love.graphics.newImage("asset/image/diver/diver.png")
    local s_grid = anim8.newGrid(20, 20, _diver.spr_sheet:getWidth(), _diver.spr_sheet:getHeight())
    _diver.animations = {
        default = anim8.newAnimation(s_grid(('1-2'), 1), 0.3),
    }
    _diver.curr_animation = _diver.animations["default"]
    _diver.is_alive = true
    _diver.facing_dir = 1
    _diver.x = 60
    _diver.y = 11
    _diver.move_spped = 100
    _diver.w, _diver.h = _diver.curr_animation:getDimensions()
    _diver.hitbox = { x = _diver.x, y = _diver.y, w = _diver.w, h = _diver.h }
    return _diver
end

function Diver:update(dt)
    flux.update(dt)
    self.curr_animation:update(dt)
end

function Diver:die(pos)

end

function Diver:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, 0, self.facing_dir-0.3, 0.7, self.w / 2, self.h / 2)
    draw_hitbox(self, "#ffffff")
end


all_divers = {}


function update_divers(dt)
    for p in all(all_divers) do
        p:update(dt)
    end
end

function draw_divers()
    for p in all(all_divers) do
        p:draw()
    end
end