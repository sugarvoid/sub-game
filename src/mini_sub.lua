--local flux = require("lib.flux")



MiniSub = {}
MiniSub.__index = MiniSub

local _sfx_die = love.audio.newSource("asset/audio/bad_ship_die.wav", "stream")
local spr_sheet = love.graphics.newImage("asset/image/mini_submarine/mini_sub.png")

function MiniSub:new(x, y, facing_dir, speed_multiplier)
    local _mini_sub = setmetatable({}, MiniSub)
    local s_grid = anim8.newGrid(20, 12, spr_sheet:getWidth(), spr_sheet:getHeight())
    _mini_sub.animations = {
        default = anim8.newAnimation(s_grid(('1-4'), 1), 0.2),
    }
    _mini_sub.curr_animation = _mini_sub.animations["default"]
    _mini_sub.is_alive = true
    _mini_sub.facing_dir = facing_dir
    _mini_sub.x = x
    _mini_sub.y = y
    _mini_sub.BASE_SPEED = 20
    _mini_sub.move_speed = _mini_sub.BASE_SPEED + (10 * speed_multiplier)
    _mini_sub.w, _mini_sub.h = _mini_sub.curr_animation:getDimensions()
    _mini_sub.hitbox = { x = _mini_sub.x, y = _mini_sub.y, w = _mini_sub.w-6, h = _mini_sub.h -5}
    return _mini_sub
end

function MiniSub:update(dt)
    --flux.update(dt)
    self.curr_animation:update(dt)
    self.x = self.x + self.move_speed * self.facing_dir * dt
    self.hitbox.x = (self.x - self.w /2)+2
    self.hitbox.y = (self.y - self.h/2) + 2
    
end

function MiniSub:die(pos)
    love.audio.play_sfx(_sfx_die)
    player:increase_score(get_kill_value("mini_sub"))
    --spawn_mini_sub_peices(self.x, self.y, self.facing_dir)
    table.remove_item(all_mini_subs, self)
end

function MiniSub:draw()
    self.curr_animation:draw(spr_sheet, self.x, self.y - 2, 0, self.facing_dir, 1, self.w / 2, self.h / 2)
    draw_hitbox(self.hitbox, "#f30909")
end


all_mini_subs = {}


function update_mini_subs(dt)
    for p in table.for_each(all_mini_subs) do
        if check_collision(p.hitbox, player.hitbox) then
            --remove_item(all_mini_subs, p)
            print("player die")
        end
        for _t in table.for_each(player_torpedos) do
            if check_collision(p.hitbox, _t.hitbox) then
                p:die()
                table.remove_item(player_torpedos, _t)
            end
        end
        p:update(dt)
    end
end

function draw_mini_subs()
    for p in table.for_each(all_mini_subs) do
        p:draw()
    end
end