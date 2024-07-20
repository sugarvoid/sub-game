

function draw_hitbox(obj, color)
    love.graphics.push("all")
    changeFontColor(color)
    love.graphics.rectangle("line", obj.hitbox.x, obj.hitbox.y, obj.hitbox.w, obj.hitbox.h)
    love.graphics.pop()
end