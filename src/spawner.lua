LANES = {
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110
}

SIDES = {
    { x = -15, f_dir = 1 },
    { x = 250, f_dir = -1 }
}

print(SIDES[1])

SPAWN_TYPES = {
    0,
    1,
    2
}


spawner = {
    spawn_actor = function(type, side, lane)
        if type == 0 then
            --spawn diver
            _diver = Diver:new(SIDES[side]["x"], LANES[lane], SIDES[side]["f_dir"])
            print(LANES[lane])
            table.insert(all_divers, _diver)
        elseif type == 1 then
            _shark = Shark:new(SIDES[side]["x"], LANES[lane], SIDES[side]["f_dir"])
            print(LANES[lane])
            table.insert(all_sharks, _shark)
        elseif type == 2 then
            --spawn mini sub
        end
    end,
}
