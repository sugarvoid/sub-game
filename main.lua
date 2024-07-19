-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- license: MIT License
-- version: 0.1


require("diver")
require("player")


local game_bg = love.graphics


local t = 0
local x = 96
local y = 24

local obj = {
    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(
            tbl, {
                __index = self
            })
        return tbl
    end
}

player = {}

-- DIVER --
all_divers = {}
diver = obj:new({
    x,
    y = 50,
    color = nil,
    timer = 0,
    update = function(self)
        self.x = self.x + 1
    end,
    draw = function(self)
        spr(288, self.x, self.y)
    end
})

function spawn_diver(pos)
    n_diver = diver:new()
    n_diver.x = pos[1]
    n_diver.y = pos[2]
    add(all_divers, n_diver)
end

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

-- DIVER END --


function _DRAW()
    cls(13)
    rect(0, 20, 300, 200, 8)
    rect(0, 110, 300, 50, 3)
    rect(0, 120, 300, 50, 15)
    spr(256, x, y, 0, 1, 0, 0, 3, 2)
    draw_divers()
    print(t)
end

-- EXTRA STUFF --

add = table.insert


--! main.lua

love = require("love")


love.graphics.setDefaultFilter("nearest", "nearest")

require("lib.color")
require("src.player")
require("src.platform")
require("src.sickle_manager")
require("src.sickle")
require("lib.kgo.debug")
require("lib.kgo.timer")


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
    font = love.graphics.newFont("asset/font/cozette_vector.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)
    gamestate = gamestates.title
    
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

    if key == "m" then
        if bg_music:isPlaying() then
            bg_music:pause()
        else
            bg_music:play()
        end
    end

    if gamestate == gamestates.game then
        if key == "space" or key == "w" then
            player:jump()
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
            title_music:stop()
            bg_music:stop()
            bg_music:play()
            start_game()
        end
    end

    for i = 1, 9 do
        if key == (tostring(i)) then
            sickle_manager.debug_key_functions[key]()
        end
    end
end

function love.update(dt)
    snow_system:update(dt)

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
    if seconds_left >= 1 then
        if tick == 60 then
            seconds_left = seconds_left - 1
            tick = 0
            sickle_manager:on_every_second(seconds_left)
        end
    end
    if seconds_left == 0 then
        save_game()
        gamestate = gamestates.win
    end
    world:update(dt)
    sickle_manager:update(dt)
    player:update(dt)
end

function update_gameover(dt)
    return
end

function spawn_death_marker(_x, _y)
    table.insert(death_markers, { _x, _y })
end

function love.draw()
    love.graphics.scale(4)
    love.graphics.draw(background, 0, 0)

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
    love.graphics.draw(title_img, 50, 45, 0, 0.19, 0.19)
end

function draw_game()
    love.graphics.push("all")
    draw_hud()
    love.graphics.pop()
    draw_snow()
    player:draw()
    platfrom:draw()
    --world:draw()
    sickle_manager:draw()
    draw_death_markers()
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 100))
    love.graphics.print(seconds_left, 110, 15, 0, 3, 3)
    love.graphics.setColor(255, 255, 255)
end

function draw_death_markers()
    for dm in all(death_markers) do
        love.graphics.draw(death_marker, dm[1], dm[2], 0, 0.2, 0.2, death_marker:getWidth() / 2,
            death_marker:getHeight() / 2)
    end
end

function draw_snow()
    love.graphics.draw(snow_system, 0, -6)
end

function draw_hud()
    love.graphics.print("Attempt: " .. tostring(player_attempt), 180, 0, 0, 1, 1)
end

function draw_gameover()
    draw_snow()
    draw_death_markers()
    platfrom:draw()
    draw_hud()
    love.graphics.print(seconds_left, 110, 15, 0, 3, 3)
    if math.floor(love.timer.getTime()) % 2 == 0 then
        love.graphics.print("jump to try again", 65, 70, 0, 1, 1)
    end
end

function draw_win()
    draw_snow()
    draw_death_markers()
    platfrom:draw()
    draw_hud()
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
