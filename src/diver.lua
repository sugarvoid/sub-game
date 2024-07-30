
Diver = {}
Diver.__index = Diver

local _player = nil

function Diver:new(x, y, facing_dir)
    local _diver = setmetatable({}, Diver)
    _diver.spr_sheet = love.graphics.newImage("asset/image/diver.png")
    local s_grid = anim8.newGrid(17, 16, _diver.spr_sheet:getWidth(), _diver.spr_sheet:getHeight())
    _diver.animations = {
        default = anim8.newAnimation(s_grid(('1-2'), 1), 0.3),
    }
    _diver.curr_animation = _diver.animations["default"]
    _diver.is_alive = true
    _diver.facing_dir = facing_dir
    _diver.sx = 0.6 * facing_dir
    _diver.sy = 0.6
    _diver.x = x
    _diver.y = y
    _diver.move_speed = 30
    _diver.w, _diver.h = _diver.curr_animation:getDimensions()
    _diver.hitbox = { x = _diver.x, y = _diver.y, w = _diver.w-6, h = _diver.h -10}
    return _diver
end

function Diver:update(dt)
    --flux.update(dt)
    self.curr_animation:update(dt)
    self.x = self.x + self.move_speed * self.facing_dir * dt
    self.hitbox.x = (self.x - self.w /2)+2
    self.hitbox.y = (self.y - self.h/2) +3
end

function Diver:die(pos)

end

function Diver:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, 0, self.sx, self.sy, self.w / 2, self.h / 2)
    --draw_hitbox(self.hitbox, "#3e8948")
end


all_divers = {}


function update_divers(dt)
    for _, d in ipairs(all_divers) do
        d:update(dt)
        if check_collision(d.hitbox, player.hitbox) then
            if player.diver_on_board > 6 then
                player.diver_on_board = player.diver_on_board + 1
                diver_HUD:update_display(player.diver_on_board)
                table.remove_item(all_divers, d)
                player:play_sound(1)
                love.audio.play_sfx(_sfx_diver_saved)
            end
        end
    end
end

function draw_divers()
    for p in table.for_each(all_divers) do
        p:draw()
    end
end