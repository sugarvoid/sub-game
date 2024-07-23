-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- license: MIT License
-- version: 0.1

love = require("love")
world = love.physics.newWorld(0,0,false)
love.graphics.setDefaultFilter("nearest", "nearest")

require("lib.kgo.core")

require("lib.kgo.timer")
anim8 = require("lib.anim8")
require("src.diver")
require("src.player")
require("src.shark")
require("src.mini_sub")
require("src.diver_hud")



add = table.insert



local font = nil
local gamestates = {
    title = 0,
    credit = 0.1,
    info = 0.2,
    game = 1,
    retry = 1.1,
    win = 2
}

local gamestate = nil
local level = 1
local tick = 0

local background = love.graphics.newImage("asset/image/background.png")
local sand = love.graphics.newImage("asset/image/sand_bottom.png")
--local o2_bar = love.graphics.newImage("asset/image/o2_bar.png")
local player = Player:new()



local o2_bar = {
    image = love.graphics.newImage("asset/image/o2_bar.png"),
    max = 60,
    value = 30,
    position = {20, 5},
    draw=function(self)
        --TODO: Figure out the lines are not lining up with sprite
        love.graphics.draw(self.image, self.position[1], self.position[2])
        love.graphics.push("all")
        change_draw_color("#ffffff")
        love.graphics.line( self.position[1] + 3, self.position[2]+2.5, self.position[1] + 3 + self.value, self.position[2]+2.5)
        change_draw_color("#0ce6f2")
        love.graphics.line( self.position[1] + 3, self.position[2]+3.5, self.position[1] + 3 + self.value, self.position[2]+3.5)
        change_draw_color("#0098db")
        love.graphics.line( self.position[1] + 3, self.position[2]+4.5, self.position[1] + 3 + self.value, self.position[2]+4.5)
        love.graphics.pop()
    end,
    update=function(self)
        
    end,
}


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    --load_game()
    --title_music:play()
    --title_music:setVolume(0.3)
    --bg_music:setVolume(0.3)
    font = love.graphics.newFont("asset/font/c64esque.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)


    

    gamestate = gamestates.title

    diver_1 = Diver:new(100, 40, player)
    table.insert(all_divers, diver_1)

    diver_3 = Diver:new(50, 100, player)
    table.insert(all_divers, diver_3)

    diver_2 = Diver:new(10, 67, player)
    table.insert(all_divers, diver_2)


    shark_1 = Shark:new(10, 90, player)
    table.insert(all_sharks, shark_1)


    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    text       = "" -- we'll use this to put info text on the screen later
    persisting = 0  -- we'll use this to store the state of repeated callback calls

    surface_rect = {
    x=0,y=0,w=240,h=16
    }

    surface = {}
    surface.body = love.physics.newBody(world, 0,0, "static") -- "static" makes it not move
    surface.shape = love.physics.newRectangleShape((240*4),16)      -- set size to 200,50 (x,y)
    surface.fixture = love.physics.newFixture(surface.body, surface.shape)
    surface.body:setAwake(true)
    surface.fixture:setUserData("Surface")


    
end

function reset_game()
    player:reset()
end

function start_game()
    reset_game()
end

function on_player_win()
    gamestate = gamestates.win
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if gamestate == gamestates.game then
        if key == "space" then
            player:shoot()
        end
    end

    if gamestate == gamestates.retry then
        if key == "space" then
            reset_game()
            gamestate = gamestates.game
        end
    end

    if gamestate == gamestates.title then
        if key == "space" then
            gamestate = gamestates.game
            start_game()
        end
    end

    
end

function love.update(dt)

    if gamestate == gamestates.title then
        update_title()
    elseif gamestate == gamestates.game then
        update_game(dt)
    else
        update_gameover(dt)
    end
end

function update_title()
    return
end

function update_game(dt)
    o2_bar.value = player.oxygen
    o2_bar:update()
    if string.len(text) > 768 then    -- cleanup when 'text' gets too long
        text = "" 
    end
    world:update(dt)
    tick = tick + 1
    player:update(dt)
    update_divers(dt)
    update_sharks(dt)
end

function update_gameover(dt)
    return
end


function love.draw()
    love.graphics.scale(4)
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(sand, 0, 136 - 29)
    
    love.graphics.print(string.format("%05d", player.score), 200, 0)
    --print_mouse_pos(0,0,4)
    if gamestate == gamestates.title then
        draw_title()
    end
    if gamestate == gamestates.game then
        draw_game()
        
    end
    if gamestate == gamestates.retry then
        draw_gameover()
    end
    if gamestate == gamestates.win then
        draw_win()
    end
end

function draw_title()
    love.graphics.print("[space] to play", 70, 80, 0, 1, 1)
end

function draw_game()
    --love.graphics.push("all")
    --love.graphics.pop()
    player:draw()
    draw_divers()
    draw_sharks()
    diver_HUD:draw()
    love.graphics.push("all")
    love.graphics.scale(0.5)
    love.graphics.print(text, 10, 40)
    love.graphics.pop()
    o2_bar:draw()
end


function draw_gameover()

    love.graphics.print("jump to try again", 65, 70, 0, 1, 1)
end

function draw_win()
    if math.floor(love.timer.getTime()) % 2 == 0 then
        love.graphics.print("you win", 60, 70, 0, 1, 1)
        love.graphics.print("thnaks for playing", 60, 80, 0, 1, 1)
    end
end

function playSound(_sound)
    love.audio.stop(_sound)
    love.audio.play(_sound)
end

function go_to_gameover()
    gamestate = gamestates.retry
end

function clamp(_min, _val, _max)
    return math.max(_min, math.min(_val, _max));
end





function check_collision(a, b)
    return a.x < b.x + b.w and
        b.x < a.x + a.w and
        a.y < b.y + b.h and
        b.y < a.y + a.h
end

function do_tables_match(_table_1, _table_2)
    return table.concat(_table_1) == table.concat(_table_2)
end

function save_game()
    data = {}
    data.has_won = true
    serialized = lume.serialize(data)
    love.filesystem.write("sickle.sav", serialized)
end

function load_game()
    if love.filesystem.getInfo("sickle.sav") then
        file = love.filesystem.read("sickle.sav")
        data = lume.deserialize(file)
        player.has_won = data.has_won or false
    end
end



--TODO: Move to sperate physics file

function beginContact(a, b, coll)
    
    x,y = coll:getNormal()
    obj_a = a:getUserData()
    obj_b = b:getUserData()
    if obj_a == "Player" and obj_b == "Shark" then
        print("player made contact with shark")
    elseif obj_a == "Player" and obj_b == "Surface" then
        player:play_sound(3)
    end
    -- text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
    -- print(text)
end


function endContact(a, b, coll)
    print("uncolliding")
    persisting = 0    -- reset since they're no longer touching
    text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
    collectgarbage()
end

function preSolve(a, b, coll)
    if persisting == 0 then    -- only say when they first start touching
        text = text.."\n"..a:getUserData().." touching "..b:getUserData()
    elseif persisting < 20 then    -- then just start counting
        text = text
    end
    persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    -- we won't do anything with this function
    --print(a:getUserData() .. b:getUserData())
end