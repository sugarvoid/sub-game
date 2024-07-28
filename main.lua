-- title:       Sub Game
-- author:      sugarvoid
-- description: A clone of Seaquest for the Atari 2600
-- license:     MIT License
-- version:     0.1

love = require("love")
anim8 = require("lib.anim8")
flux = require("lib.flux")
world = love.physics.newWorld(0, 0, false)
love.graphics.setDefaultFilter("nearest", "nearest")

require("lib.kgo.core")
require("lib.kgo.sound_manager")
require("lib.kgo.timer")

require("src.diver")
require("src.player")
require("src.shark")
require("src.spawner")
require("src.surface")
require("src.mini_sub")
require("src.o2_bar")
require("src.diver_hud")
require("src.player_torpedo")


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
local spawn_interval = 3*60
local trm_spawn_wave = Timer:new(function() spawner:spawn_something() end, true)

local background = love.graphics.newImage("asset/image/background.png")
local sand = love.graphics.newImage("asset/image/sand_bottom.png")
local o2_bar = OxygenBar:new()

local battleship = love.graphics.newImage("asset/image/battleship.png")

player = Player:new()



function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    --load_game()
    --title_music:play()
    --title_music:setVolume(0.3)
    --bg_music:setVolume(0.3)
    love.graphics.scale(4)
    font = love.graphics.newFont("asset/font/c64esque.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)
    gamestate = gamestates.title

    -- diver_1 = Diver:new(100, 40, 1)
    -- table.insert(all_divers, diver_1)

    -- diver_3 = Diver:new(50, 100, 1)
    -- table.insert(all_divers, diver_3)

    -- diver_2 = Diver:new(10, 67, 1)
    -- table.insert(all_divers, diver_2)

    -- spawner.spawn_actor(0, 1, 2)
    -- spawner.spawn_actor(0, 1, 3)
    -- spawner.spawn_actor(1, 2, 2)


    -- shark_1 = Shark:new(-15, 40, 1)
    -- table.insert(all_sharks, shark_1)
    -- shark_11 = Shark:new(250, 50, -1)
    -- table.insert(all_sharks, shark_11)
    -- shark_12 = Shark:new(-15, 60, 1)
    -- table.insert(all_sharks, shark_12)
    -- shark_2 = Shark:new(-15, 70, 1)
    -- table.insert(all_sharks, shark_2)
    -- shark_3 = Shark:new(-15, 80, 1)
    -- table.insert(all_sharks, shark_3)
    -- shark_4 = Shark:new(-15, 90, 1)
    -- table.insert(all_sharks, shark_4)
    -- shark_5 = Shark:new(-15, 100, 1)
    -- table.insert(all_sharks, shark_5)
    -- shark_6 = Shark:new(-15, 110, 1)
    -- table.insert(all_sharks, shark_6)


    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    text       = "" -- we'll use this to put info text on the screen later
    persisting = 0  -- we'll use this to store the state of repeated callback calls


    --TODO: Move to separate file. The scale is messing with the hitbox
    surface_rect = {
        x = 0, y = 0, w = 240 * 4, h = 8 * 3
    }

    surface = {}
    surface.body = love.physics.newBody(world, 0, 0, "static")                    -- "static" makes it not move
    surface.shape = love.physics.newRectangleShape(surface_rect.w, surface_rect.h) -- set size to 200,50 (x,y)
    surface.fixture = love.physics.newFixture(surface.body, surface.shape)
    surface.body:setAwake(true)
    surface.fixture:setUserData("Surface")

    set_up_surface()
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
           -- for n in pairs(_G) do print(n) end
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
            trm_spawn_wave:start(spawn_interval)
            start_game()
        end
    end
end

function love.update(dt)
    --love.audio.update()

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
    flux.update(dt)
    trm_spawn_wave:update()
    o2_bar.value = player.oxygen
    o2_bar:update()
    if string.len(text) > 768 then -- cleanup when 'text' gets too long
        text = ""
    end
    world:update(dt)
    tick = tick + 1
    player:update(dt)
    update_divers(dt)
    update_sharks(dt)
    update_mini_subs(dt)
    update_bubbles(dt)
    for t in table.for_each(player_torpedos) do
        t:update(dt)
        if t.x < -20 or t.x > 250 then
            table.remove_item(player_torpedos, t)
        end
    end
    for sp in table.for_each(shark_parts) do
        sp:update()
    end

    love.window.setTitle("Sub Game - fps: " .. tostring(love.timer.getFPS()))
end

function update_gameover(dt)
    return
end

function love.draw()
    love.graphics.scale(4)
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(sand, 0, 136 - 31)
    change_draw_color("#000000")
    love.graphics.rectangle("fill", 0, 126, 250, 10)
    change_draw_color("#ffffff")

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

    --draw_hitbox(surface_rect, "#feae34")
end

function draw_title()
    love.graphics.print("[space] to play", 70, 80, 0, 1, 1)
end

function draw_game()
    --love.graphics.push("all")
    --love.graphics.pop()
    draw_surface_back()
    draw_bubbles()
   
    love.graphics.draw(battleship, 80, 4, 0, 1, 1, battleship:getWidth()/2, battleship:getHeight()/2)
     player:draw()
    draw_divers()
    draw_sharks()
    draw_mini_subs()
    draw_torpedos()
    

    for sp in table.for_each(shark_parts) do
        sp:draw()
    end
    draw_surface_front()
    



    diver_HUD:draw()
    love.graphics.push("all")
    love.graphics.scale(0.5)
    love.graphics.print(text, 10, 40)
    love.graphics.pop()
    o2_bar:draw()
    love.graphics.print(string.format("%05d", player.score), 200, 124)
end

function draw_gameover()
    love.graphics.print("jump to try again", 65, 70, 0, 1, 1)
end

function draw_win()
    if math.floor(love.timer.getTime()) % 2 == 0 then
        love.graphics.print("game over", 60, 70, 0, 1, 1)
        love.graphics.print("thanks for playing", 60, 80, 0, 1, 1)
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
    data.high_score = player.high_score
    serialized = lume.serialize(data)
    love.filesystem.write("sub_game.sav", serialized)
end

function load_game()
    if love.filesystem.getInfo("sub_game.sav") then
        file = love.filesystem.read("sub_game.sav")
        data = lume.deserialize(file)
        player.high_score = data.high_score or 0
    end
end

--TODO: Move to separate physics file

function beginContact(a, b, coll)
    x, y = coll:getNormal()
    obj_a = a:getUserData()
    obj_b = b:getUserData()



    --if obj_a["type"] == "P_Torpedo" and obj_b["type"] == "Shark" or
    -- obj_b["type"] == "P_Torpedo" and obj_a["type"] == "Shark" then
    --player:play_sound(3)
    --player.is_submerged =  not player.is_submerged
    --obj_a:setAwake(false)
    --obj_a["owner"]:die()
    --table.remove_item(all_sharks, obj_b)
    --end
    --if obj_a == "Player" and obj_b["type"] == "Shark" then
    --print("player made contact with shark")
    --end
    if obj_a == "Player" and obj_b == "Surface" then
        --TODO: Make on_surface function in player
        --TODO: Prevent player moving until o2 is full
        player.can_move = false
        player:on_surfaced()
        player:play_sound(3)
        player.is_submerged = not player.is_submerged
        player:unload_divers()
        --player:refill_o2()
    end
    --print(obj_a)
end

function endContact(a, b, coll)
    persisting = 0 -- reset since they're no longer touching
    --text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()

    if obj_a == "Player" and obj_b == "Surface" then
        print("Player going back in water")
    end

    collectgarbage()
end

function preSolve(a, b, coll)
    -- if persisting == 0 then    -- only say when they first start touching
    --     --text = text.."\n"..a:getUserData().." touching "..b:getUserData()
    -- elseif persisting < 20 then    -- then just start counting
    --     text = text
    -- end
    --persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    -- we won't do anything with this function
    --print(a:getUserData() .. b:getUserData())
end


function get_kill_value(e_type)
    if e_type == "shark" then
        return 20
    elseif e_type == "mini_sub" then
        return 20
    end
end