

local spr_surface_back = love.graphics.newImage("asset/image/surface_back.png")
local spr_surface_front = love.graphics.newImage("asset/image/surface_front.png")


SurfaceSection = {}
SurfaceSection.__index = SurfaceSection


local STARTING_Y = 10


function SurfaceSection:new(x)
	local _section = setmetatable({}, SurfaceSection)
	_section.x = x
	_section.y = STARTING_Y

	return _section
end

function SurfaceSection:update()
end

function SurfaceSection:draw_back()
	love.graphics.draw(spr_surface_back, self.x, self.y)
end

function SurfaceSection:draw_front()
	love.graphics.draw(spr_surface_front, self.x, self.y)
end

function SurfaceSection:move_up()
	flux.to(self, 5, {y = STARTING_Y - 3}):after(self, 5, {y = STARTING_Y}):oncomplete(function() self:move_down() end)
	--flux.to(self, 5, {y = 7}):oncomplete(self.move_down)
end

function SurfaceSection:move_down()
	flux.to(self, 5, {y = STARTING_Y + 3}):after(self, 5, {y = STARTING_Y}):oncomplete(function() self:move_up() end)
end


surface_sections={}



function set_up_surface()
	for i = 0, 14 do

		local _s_section = SurfaceSection:new(i*16)
		
		
		table.insert(surface_sections, _s_section)
	end	
	surface_sections[3]:move_up()
end
