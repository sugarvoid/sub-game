--local flux = require("lib.flux")



Shark = {}
Shark.__index = Shark

local _sfx_die = love.audio.newSource("asset/audio/shark_death.ogg", "stream")


local _player = nil

function Shark:new(x, y, player)
    local _shark = setmetatable({}, Shark)
    _shark.spr_sheet = love.graphics.newImage("asset/image/shark.png")
    local s_grid = anim8.newGrid(22, 16, _shark.spr_sheet:getWidth(), _shark.spr_sheet:getHeight())
    _shark.animations = {
        default = anim8.newAnimation(s_grid(('1-4'), 1), 0.2),
    }
    _player = player
    _shark.curr_animation = _shark.animations["default"]
    _shark.is_alive = true
    _shark.facing_dir = 1
    _shark.x = x
    _shark.y = y
    _shark.move_spped = 0.4
    _shark.w, _shark.h = _shark.curr_animation:getDimensions()

    _shark.hitbox = { x = _shark.x, y = _shark.y, w = _shark.w-6, h = _shark.h -10}

    --TODO: Use hitbox for this and player
    _shark.body = love.physics.newBody(world, _shark.hitbox.x,_shark.hitbox.y, "dynamic")
    _shark.shape = love.physics.newRectangleShape(_shark.hitbox.w, _shark.hitbox.h)
    _shark.fixture = love.physics.newFixture(_shark.body, _shark.shape)
    _shark.fixture:setUserData({type="Shark", owner=_shark})


    
    return _shark
end

function Shark:update(dt)
    --flux.update(dt)
    self.curr_animation:update(dt)
    self.x = self.x + self.move_spped * self.facing_dir
    self.hitbox.x = (self.x - self.w /2)+2
    self.hitbox.y = (self.y - self.h/2) +3
    self.body:setPosition(self.hitbox.x,self.hitbox.y)
end

function Shark:die(pos)
    --print("im dead????")
    _sfx_die:play()
end

function Shark:draw()
    self.curr_animation:draw(self.spr_sheet, self.x, self.y - 2, 0, self.facing_dir, 1, self.w / 2, self.h / 2)
    draw_hitbox(self.hitbox, "#f30909")
end


all_sharks = {}


function update_sharks(dt)
    for p in table.for_each(all_sharks) do
        if check_collision(p.hitbox, _player.hitbox) then
            --remove_item(all_sharks, p)
        end
        p:update(dt)
    end
end

function draw_sharks()
    for p in table.for_each(all_sharks) do
        p:draw()
    end
end