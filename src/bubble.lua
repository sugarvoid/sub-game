Bubble = {}
Bubble.__index = Bubble


function Bubble:new(x, y)
    local _bubble = setmetatable({}, Bubble)
    _bubble.x = x 
    _bubble.starting_y = y
    _bubble.y = y 
    _bubble.r = 0.1
    _bubble.dir = {0,-10}
    return _bubble
end

function Bubble:update(dt)
    --flux.update(dt)
    --self.y = self.y + self.dir[2] * dt
    self.r = self.r + 0.02
end

function Bubble:die(pos)

end

function Bubble:draw()
    love.graphics.push("all")
    love.graphics.scale(0.5)
    love.graphics.circle("line", self.x*2, self.y*2, self.r)
    love.graphics.pop()
end



