local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    --self.area.world:addCollisionClass('Straw')
    self.area.world:addCollisionClass('Pearl')
    --self.area.world:addCollisionClass('Background')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.cupW = 600
    self.cupH = 700
    self.cupX = gw / 2 - self.cupW / 2
    self.cupY = 200

    self.levels = {
        {spawns = chanceList({'normal', 8}, {'ice', 4}), time = 10, color = {241/255, 103/255, 69/255} }
    }

    self.straw = self.area:addGameObject('Straw', gw / 2, 10, 
    {cupX = self.cupX, cupY = self.cupY, cupW = self.cupW, cupH = self.cupH})

    self.demoFont = love.graphics.newFont(40)
    
    self.cup = {
        self.area.world:newLineCollider(self.cupX, self.cupY, self.cupX, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX + self.cupW, self.cupY, self.cupX + self.cupW, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX, self.cupY + self.cupH, self.cupX + self.cupW, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX, self.cupY, self.cupX + self.cupW / 2 - 30, self.cupY),
        self.area.world:newLineCollider(self.cupX + self.cupW / 2 + 30, self.cupY, self.cupX + self.cupW, self.cupY),
    }

    for col = 1, 5 do
        self.cup[col]:setType('static')
    end

    for i = 1, 40 do
        self.area:addGameObject('Pearl', self.cupX + i * 10 , gh /2, 
        {r = 25, type = 'normal', play = self})
    end


    self.level = 1
    self.consumed = 0

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
        printInsideRect("Consumed: "..self.consumed, self.demoFont, "bottomLeft")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Play:consumePearl(type)
    self.consumed = self.consumed + 1
    print(self.consumed)
end

function Play:destroy()
    self.area:destroy()
    self.area = nil
    self.straw = nil
end

return Play