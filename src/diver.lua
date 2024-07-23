
Diver = {}
Diver.__index = Diver

local _player = nil

function Diver:new(x, y, player)
    local _diver = setmetatable({}, Diver)
    _diver.spr_sheet = love.graphics.newImage("asset/image/diver.png")
    local s_grid = anim8.newGrid(17, 16, _diver.spr_sheet:getWidth(), _diver.spr_sheet:getHeight())
    _diver.animations = {
        default = anim8.newAnimation(s_grid(('1-2'), 1), 0.3),
    }
    _player = player
    _diver.curr_animation = _diver.animations["default"]
    _diver.is_alive = true
    _diver.facing_dir = 1
    _diver.x = x
    _diver.y = y
    _diver.move_speed = 0.4
    _diver.w, _diver.h = _diver.curr_animation:getDimensions()
    _diver.hitbox = { x = _diver.x, y = _diver.y, w = _diver.w-6, h = _diver.h -10}
    return _diver
end

function Diver:update(dt)
    --flux.update(dt)
    self.curr_animation:update(dt)
    self.x = self.x + self.move_speed * self.facing_dir
    self.hitbox.x = (self.x - self.w /2)+2
    self.hitbox.y = (self.y - self.h/2) +3
end

function Diver:die(pos)

end

function Diver:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, 0, self.facing_dir-0.3, 0.7, self.w / 2, self.h / 2)
    draw_hitbox(self.hitbox, "#3e8948")
end


all_divers = {}


function update_divers(dt)
    for p in table.for_each(all_divers) do
        if check_collision(p.hitbox, _player.hitbox) then
            player.diver_on_board = player.diver_on_board + 1
            diver_HUD:update_display(player.diver_on_board)
            table.remove_item(all_divers, p)
            _player:play_sound(1)

        end
        p:update(dt)
    end
end

function draw_divers()
    for p in table.for_each(all_divers) do
        p:draw()
    end
end