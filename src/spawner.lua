local LANES = {
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110
}

local SIDES = {
    { x = -15, f_dir = 1 },
    { x = 250, f_dir = -1 }
}

local SPAWN_TYPES = {
    0, --Diver
    1, --Shark
    2  --MiniSub
}


local SPAWN_DIVER = 0
local SPAWN_SHARK = 1
local SPAWN_SUB = 2

local SPAWN_LEFT_X = -15
local SPAWN_RIGHT_X = 250

local FACE_LEFT = -1
local FACR_RIGHT = 1


local WAVES = {
    {
        {SPAWN_SUB, SPAWN_RIGHT_X, 2},
        {SPAWN_SHARK, SPAWN_RIGHT_X, 3},
        {SPAWN_DIVER, SPAWN_RIGHT_X, 4},
    },
    {
        {1, 2, 2},
        {SPAWN_DIVER, SPAWN_RIGHT_X, 5},
        {SPAWN_DIVER, SPAWN_LEFT_X, 4},
        {1, 2, 6},
    },
}


spawner = {
    spawn_actor = function(type, side, lane)
        local _facing_dir
        if side == SPAWN_RIGHT_X then
            _facing_dir = -1
        else
            _facing_dir = 1
        end

        if type == 0 then
            --spawn diver
            _diver = Diver:new(side, LANES[lane], _facing_dir)
            table.insert(all_divers, _diver)
        elseif type == 1 then
            _shark = Shark:new(side, LANES[lane], _facing_dir)
            table.insert(all_sharks, _shark)
        elseif type == 2 then
            _mini_sub = MiniSub:new(side, LANES[lane], _facing_dir)
            table.insert(all_mini_subs, _mini_sub)
        end
    end,
    spawn_something=function()
        for w in table.for_each(WAVES[2]) do
            spawner.spawn_actor(w[1], w[2], w[3])
        end
    end,
}
