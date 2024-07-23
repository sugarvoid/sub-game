
OxygenBar = {}
OxygenBar.__index = OxygenBar

local _oxygen_bar = nil
local O2_BAR_BG = love.graphics.newImage("asset/image/o2_bar.png")
local MAX = 60
local POSITION = {20,5}
local bar_x = POSITION[1] + 3
local top={}
local middle=nil
local bottom=nil

function OxygenBar:new()
    local _oxygen_bar = setmetatable({}, OxygenBar)
    _oxygen_bar.value = 0
    --_oxygen_bar
    --_oxygen_bar
    --_oxygen_bar
    return _oxygen_bar
end

function OxygenBar:update()

end



function OxygenBar:draw()
     love.graphics.draw(O2_BAR_BG, POSITION[1], POSITION[2])
        love.graphics.push("all")
        change_draw_color("#ffffff")
        love.graphics.line( POSITION[1] + 3, POSITION[2]+2.5, POSITION[1] + 3 + self.value, POSITION[2]+2.5)
        change_draw_color("#0ce6f2")
        love.graphics.line( POSITION[1] + 3, POSITION[2]+3.5, POSITION[1] + 3 + self.value, POSITION[2]+3.5)
        change_draw_color("#0098db")
        love.graphics.line( POSITION[1] + 3, POSITION[2]+4.5, POSITION[1] + 3 + self.value, POSITION[2]+4.5)
        love.graphics.pop()
end
