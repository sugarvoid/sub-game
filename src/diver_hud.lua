local icon_sheet = love.graphics.newImage("asset/image/ui_diver.png")
local DEBUG_IMAGE = love.graphics.newImage("asset/image/test_diver_ui.png")

diver_HUD = {

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
    end,
    draw = function(self)
        love.graphics.draw(DEBUG_IMAGE, 120,2,0,0.7,0.7)
        for i in table.for_each(self.all_icons) do
            
        end
    end
}
