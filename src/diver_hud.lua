local icon_sheet = love.graphics.newImage("asset/image/ui_diver.png")
local DEBUG_IMAGE = love.graphics.newImage("asset/image/test_diver_ui_sheet.png")

--local diver_quad = love.graphics.newQuad(0, 0, 62, 15, DEBUG_IMAGE)
local draw_frame = nil



diver_HUD = {
    frame = 1, 
    frames = {
        love.graphics.newQuad(0, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(62, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(124, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(186, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(248, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(310, 0, 62, 15, DEBUG_IMAGE),
        love.graphics.newQuad(372, 0, 62, 15, DEBUG_IMAGE),
    },
    current_divers = 0,
    all_icons = {
        { frame = 0 },
        { frame = 0 },
        { frame = 0 },
        { frame = 0 },
        { frame = 0 },
        { frame = 0 }
    },
    update_display = function(self, new_amount)
       -- print(new_amount)
        self.frame = new_amount + 1
        --diver_quad = love.graphics.newQuad((63 * self.frame), 0, 62, 15, DEBUG_IMAGE)
    end,
    draw = function(self)
        love.graphics.draw(DEBUG_IMAGE, self.frames[self.frame], 120, 2, 0, 0.7, 0.7)
    end
}
