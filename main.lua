-- title:       Sub Game
-- author:      sugarvoid
-- description: A clone of Seaquest for the Atari 2600
-- license:     MIT License
-- version:     0.1

DEBUG = false


love = require("love")


if DEBUG then
    love.profiler = require('lib.profile')
end

logger = require "lib.log"
anim8 = require("lib.anim8")
flux = require("lib.flux")
world = love.physics.newWorld(0, 0, false)
love.graphics.setDefaultFilter("nearest", "nearest")

local lume = require("lib.lume")

kb_manager = require("lib.kgo.keyboard_manager")

require("lib.color")
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
require("src.battleship")
require("src.sea_mine")
require("src.spawner")

local high_score = 0
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

local background = love.graphics.newImage("asset/image/background.png")
local sand = love.graphics.newImage("asset/image/sand_bottom.png")

local title_bg = love.graphics.newImage("asset/image/titlescreen.png")
local gameover_bg = love.graphics.newImage("asset/image/gameover.png")


local o2_bar = OxygenBar:new()
local spawner = Spawner:new()

player = Player:new()
battleship = Battleship:new()
level = 1

function love.load()
    if DEBUG then
        logger.level = logger.Level.DEBUG
        logger.debug("Entering debug mode")
        love.profiler.start()
    else
        logger.level = logger.Level.INFO
        logger.info("logger in INFO mode")
    end

    kb_manager:init()
    load_game()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.scale(4)
    font = love.graphics.newFont("asset/font/c64esque.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)
    gamestate = gamestates.title
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    --TODO: Move to separate file. The scale is messing with the hitbox
    surface_rect = {
        x = 0, y = 0, w = 240 * 4, h = 8 * 3
    }

    surface = {}
    surface.body = love.physics.newBody(world, 0, 0, "static")
    surface.shape = love.physics.newRectangleShape(surface_rect.w, surface_rect.h)
    surface.fixture = love.physics.newFixture(surface.body, surface.shape)
    surface.body:setAwake(true)
    surface.fixture:setUserData("Surface")
    set_up_surface()
end

function reset_game()
    spawner:reset()
    level = 1
    player:reset()
end

function start_game()
    reset_game()
    spawner:start()
end

function on_player_win()
    gamestate = gamestates.win
end

function love.update(dt)
    if kb_manager:just_pressed("escape") then
        if DEBUG then
            love.profiler.stop()
            print(love.profiler.report(30))
        end
        love.event.quit()
    end
    if gamestate == gamestates.title then
        update_title()
    elseif gamestate == gamestates.game then
        update_game(dt)
    else
        update_gameover(dt)
    end
    kb_manager:update(dt)
end

function update_title()
    if kb_manager:just_pressed("space") then
        gamestate = gamestates.game
        start_game()
    end
end

function update_game(dt)
    if kb_manager:just_pressed("space") then
        player:shoot()
    end
    flux.update(dt)
    spawner:update(dt)
    battleship:update(dt)
    o2_bar.value = player.oxygen
    o2_bar:update()
    world:update(dt)
    player:update(dt)
    update_surfaces()
    update_divers(dt)
    update_sharks(dt)
    update_mines(dt)
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
    for ssp in table.for_each(sub_parts) do
        ssp:update()
    end
end

function update_gameover(dt)
    if kb_manager:just_pressed("space") then
        gamestate = gamestates.title
    end
end

function love.draw()
    love.graphics.scale(4)

    if gamestate == gamestates.title then
        draw_title()
    elseif gamestate == gamestates.game then
        draw_game()
    elseif gamestate == gamestates.retry then
        draw_gameover()
    elseif gamestate == gamestates.win then
        draw_win()
    end
end

function draw_title()
    love.graphics.draw(title_bg, 0, 0)
    love.graphics.print("sub game", 80, 40, 0, 1, 1)
    love.graphics.print("[space] to play", 70, 80, 0, 1, 1)
    love.graphics.print("high score: " .. high_score, 70, 120, 0, 0.6, 0.6)
end

function draw_game()
    love.graphics.draw(background, 0, 0)
    draw_surface_back()
    draw_bubbles()
    battleship:draw()
    player:draw()
    draw_divers()
    draw_sharks()
    draw_mini_subs()
    draw_torpedos()
    draw_mines()
    for sp in table.for_each(shark_parts) do
        sp:draw()
    end
    for ssp in table.for_each(sub_parts) do
        ssp:draw()
    end
    draw_surface_front()
    love.graphics.draw(sand, 0, 136 - 31)
    change_draw_color("#000000")
    love.graphics.rectangle("fill", 0, 126, 250, 10)
    change_draw_color("#ffffff")
    diver_HUD:draw()
    o2_bar:draw()
    love.graphics.print(string.format("%05d", player.score), 200, 124)
end

function draw_gameover()
    love.graphics.draw(gameover_bg, 0, 0)
    if math.floor(love.timer.getTime()) % 2 == 0 then
        love.graphics.print("game over", 60, 50, 0, 1, 1)
    end
    love.graphics.print("[space] to try again", 65, 70, 0, 1, 1)
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
    save_game()
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
    if player.score > high_score then
        logger.debug("Players score was higher that current high score")
        data = {}
        data.high_score = player.score
        serialized = lume.serialize(data)
        love.filesystem.write("sub_game.sav", serialized)
    end
end

function load_game()
    if love.filesystem.getInfo("sub_game.sav") then
        file = love.filesystem.read("sub_game.sav")
        data = lume.deserialize(file)
        high_score = data.high_score or 0
    end
end


function beginContact(a, b, coll)
    x, y = coll:getNormal()
    obj_a = a:getUserData()
    obj_b = b:getUserData()
    if obj_a == "Player" and obj_b == "Surface" then
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
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function get_kill_value(e_type)
    if e_type == "shark" then
        return 20
    elseif e_type == "mini_sub" then
        return 20
    end
end