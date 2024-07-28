-- --color.lua
-- -- From Lume (https://github.com/rxi/lume/)

-- function _color(str, mul)
--   mul = mul or 1
--   local r, g, b, a
--   r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
--   if r then
--     r = tonumber(r, 16) / 0xff
--     g = tonumber(g, 16) / 0xff
--     b = tonumber(b, 16) / 0xff
--     a = 1
--   elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
--     local f = str:gmatch("[%d.]+")
--     r = (f() or 0) / 0xff
--     g = (f() or 0) / 0xff
--     b = (f() or 0) / 0xff
--     a = f() or 1
--   else
--     error(("bad color string '%s'"):format(str))
--   end
--   return r * mul, g * mul, b * mul, a * mul
-- end

-- function change_draw_color(hex)
-- 	love.graphics.setColor(_color(hex))
-- end

-- function changeBgColor(hex)
-- 	love.graphics.setBackgroundColor(_color(hex))
-- end


function set_draw_color_from_hex(rgba)
    --  setColorHEX(rgba)
    --  where rgba is string as "#336699cc"
    local rb = tonumber(string.sub(rgba, 2, 3), 16)
    local gb = tonumber(string.sub(rgba, 4, 5), 16)
    local bb = tonumber(string.sub(rgba, 6, 7), 16)
    local ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    --  print (rb, gb, bb, ab) -- prints    51  102 153 204
    --  print (love.math.colorFromBytes( rb, gb, bb, ab )) -- prints    0.2 0.4 0.6 0.8
    love.graphics.setColor(love.math.colorFromBytes(rb, gb, bb, ab))
end
