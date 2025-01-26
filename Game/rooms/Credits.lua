local Credits = Object:extend()

function Credits:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.name = 'credits'

    self.titleScale = 0.4
    self.ggjScale = 0.75

    self.text =
    {
        "Pedro Kauati - Programmer",
        "An Tran - 2D Artist",
        "Nicholas Marriott - Music and Sound Design",
        "Game Font: Qilka by Rahagita Studio",
    }

end

function Credits:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if input:pressed('drink') then
        gotoRoom('Start')
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Credits:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setFont(fonts.qilka)
        love.graphics.draw(sprites.title, gw / 2 - (sprites.title:getWidth() * self.titleScale) - 20, 100, 0,  self.titleScale, self.titleScale)
        love.graphics.draw(sprites.ggj, gw / 2 + 20, 30, 0,  self.ggjScale, self.ggjScale)

        love.graphics.print(self.text[1], gw / 2 - (fonts.qilka:getWidth(self.text[1]) / 2), 512 + (fonts.qilka:getHeight() * 0))
        love.graphics.print(self.text[2], gw / 2 - (fonts.qilka:getWidth(self.text[2]) / 2), 512 + (fonts.qilka:getHeight() * 1))
        love.graphics.print(self.text[3], gw / 2 - (fonts.qilka:getWidth(self.text[3]) / 2), 512 + (fonts.qilka:getHeight() * 2))
        
        love.graphics.print(self.text[4], gw / 2 - (fonts.qilka:getWidth(self.text[4]) / 2), 592 + (fonts.qilka:getHeight() * 3))
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Credits