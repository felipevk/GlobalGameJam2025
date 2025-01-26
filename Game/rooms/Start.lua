local Start = Object:extend()

function Start:new()
    self.area = Area(self)
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.name = 'start'
end

function Start:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if input:pressed('drink') then
        gotoRoom('Play')
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Start:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setFont(fonts.qilka)
        printInsideRect("Click to start!", fonts.qilka, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Start