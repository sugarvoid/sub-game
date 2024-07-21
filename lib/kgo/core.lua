--color.lua
-- From Lume (https://github.com/rxi/lume/)

function _color(str, mul)
    mul = mul or 1
    local r, g, b, a
    r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
    if r then
        r = tonumber(r, 16) / 0xff
        g = tonumber(g, 16) / 0xff
        b = tonumber(b, 16) / 0xff
        a = 1
    elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
        local f = str:gmatch("[%d.]+")
        r = (f() or 0) / 0xff
        g = (f() or 0) / 0xff
        b = (f() or 0) / 0xff
        a = f() or 1
    else
        error(("bad color string '%s'"):format(str))
    end
    return r * mul, g * mul, b * mul, a * mul
end

function changeFontColor(hex)
    love.graphics.setColor(_color(hex))
end

function changeBgColor(hex)
    love.graphics.setBackgroundColor(_color(hex))
end

function draw_hitbox(obj, color)
    love.graphics.push("all")
    changeFontColor(color)
    love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)
    love.graphics.pop()
end

function print_mouse_pos(x,y, scale) 
	local mx, my = love.mouse.getPosition() -- get the position of the mouse
	love.graphics.print("mPos: ("..mx/scale..","..my/scale..")",x,y,0,2,2)
end

-- TABLES
function all(_list)
    local i = 0
    return function()
        i = i + 1; return _list[i]
    end
end