local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    --self.area.world:addCollisionClass('Straw')
    --self.area.world:addCollisionClass('Pearls')
    --self.area.world:addCollisionClass('Background')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.cupW = 600
    self.cupH = 700
    self.cupX = gw / 2 - self.cupW / 2
    self.cupY = 200

    self.straw = self.area:addGameObject('Straw', gw / 2, 10, 
    {cupX = self.cupX, cupY = self.cupY, cupW = self.cupW, cupH = self.cupH})

    self.demoFont = love.graphics.newFont(40)
    
    self.cup = {
        self.area.world:newLineCollider(self.cupX, self.cupY, self.cupX, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX + self.cupW, self.cupY, self.cupX + self.cupW, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX, self.cupY + self.cupH, self.cupX + self.cupW, self.cupY + self.cupH),
    }

    for col = 1, 3 do
        self.cup[col]:setType('static')
    end

    for i = 1, 40 do
        self.area.world:newCircleCollider(self.cupX + i * 10 , gh /2 , 20)
    end


    self.level = 1

    self:startLevel()
end

function Play:startLevel()

end

function Play:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Play:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setFont(self.demoFont)
        printInsideRect("Play", self.demoFont, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Play