-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- license: MIT License
-- version: 0.1

love = require("love")

require("lib.kgo.timer")
anim8 = require("lib.anim8")
require("src.diver")
require("src.player")
require("src.shark")
require("src.mini_sub")



add = table.insert

love.graphics.setDefaultFilter("nearest", "nearest")

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

local player = Player:new()



function love.load()
    --load_game()
    --title_music:play()
    --title_music:setVolume(0.3)
    --bg_music:setVolume(0.3)
    font = love.graphics.newFont("asset/font/c64esque.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)
    gamestate = gamestates.title

    diver_1 = Diver:new()
    table.insert(all_divers, diver_1)
    
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
    tick = tick + 1
    player:update(dt)
    update_divers(dt)
end

function update_gameover(dt)
    return
end


function love.draw()
    love.graphics.scale(4)

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
    love.graphics.push("all")
    love.graphics.pop()
    player:draw()
    draw_divers()
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

function all(_list)
    local i = 0
    return function()
        i = i + 1; return _list[i]
    end
end

function del(_table, _item)
    for i, v in ipairs(_table) do
        if v == _item then
            _table[i] = _table[#_table]
            _table[#_table] = nil
            return
        end
    end
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
