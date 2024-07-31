
# Notes on how to handle world and body detection

`main.lua`
```lua

love = require("love")


world = love.physics.newWorld(0, 0, false)


player = Player:new()


function love.load()
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    surface_rect = {
        x = 0, y = 0, w = 240 * 4, h = 8 * 3
    }
    surface = {}
    surface.body = love.physics.newBody(world, 0, 0, "static")
    surface.shape = love.physics.newRectangleShape(surface_rect.w, surface_rect.h)
    surface.fixture = love.physics.newFixture(surface.body, surface.shape)
    surface.body:setAwake(true)
    surface.fixture:setUserData("Surface")
end



function love.update(dt)
    world:update(dt)
    player:update(dt)
    update_surfaces()
    update_divers(dt)
    update_sharks(dt)
    update_mines(dt)
    update_mini_subs(dt)
    update_bubbles(dt)
end



function love.draw()

end


function beginContact(a, b, coll)
    x, y = coll:getNormal()
    obj_a = a:getUserData()
    obj_b = b:getUserData()
    if obj_a["type"] == "P_Torpedo" and obj_b["type"] == "Shark" or
            obj_b["type"] == "P_Torpedo" and obj_a["type"] == "Shark" then
        player:play_sound(3)
        player.is_submerged =  not player.is_submerged
        obj_a:setAwake(false)
        obj_a["owner"]:die()
        table.remove_item(all_sharks, obj_b)
        end

    if obj_a == "Player" and obj_b["type"] == "Shark" then
    print("player made contact with shark")
    end
    if obj_a == "Player" and obj_b == "Surface" then
        --TODO: Make on_surface function in player
        player.can_move = false
        player:on_surfaced()
        player:play_sound(3)
        player.is_submerged = not player.is_submerged
        player:unload_divers()
    end
end

function endContact(a, b, coll)
    if obj_a == "Player" and obj_b == "Surface" then
        logger.debug("Player going back in water")
    end
end

function preSolve(a, b, coll)
    -- only say when they first start touching
    local text = text.."\n"..a:getUserData().." touching "..b:getUserData()
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    -- we won't do anything with this function
    print(a:getUserData() .. b:getUserData())
end

```

`player.lua`
```lua
Player = {}
Player.__index = Player

function Player:new()
    local _player = setmetatable({}, Player)
 
    _player.w, _player.h = _player.image:getDimensions()
    _player.hitbox = { x = _player.x, y = _player.y, w = _player.w -2, h = _player.h - 10 }
    _player.body = love.physics.newBody(world,_player.x,_player.y,"dynamic")
    _player.shape = love.physics.newRectangleShape(_player.hitbox.w, _player.hitbox.h)
    _player.fixture = love.physics.newFixture(_player.body, _player.shape)

    --This help with adding data to the class
    _player.fixture:setUserData({type="Player", owner=_player})
    

    return _player
end

function Player:update(dt)
    
    self.curr_animation:update(dt)

    self.hitbox.x = self.x - self.w / 2
    self.hitbox.y = (self.y - self.h / 2) + 6
    self.body:setPosition(self.hitbox.x, self.hitbox.y)
end

function Player:on_surfaced()
    level = level + 1
    logger.info("Entering level: " .. level)
    self:refill_o2()
end


function Player:move(dt)
    if self.is_alive then
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
end

```