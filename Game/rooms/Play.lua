local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.timer = Timer()
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
        {spawns = chanceList({'normal', 8}, {'ice', 4}), time = 10, color = {241/255, 103/255, 69/255} },
        {spawns = chanceList({'normal', 8}, {'ice', 4}, {'hot', 4}), time = 10, color = {241/255, 103/255, 69/255} },
        {spawns = chanceList({'normal', 10}, {'ice', 4}, {'hot', 6}), time = 10, color = {241/255, 103/255, 69/255} },
        {spawns = chanceList({'normal', 10}, {'ice', 4}, {'hot', 6}, {'heal', 6}), time = 10, color = {241/255, 103/255, 69/255} },
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

    self.current_level = 0
    self.current_level_index = 0
    self.consumed = 0
    self.goal = 0
    self.isLevelComplete = false
    self.maxHp = 5
    self.hp = self.maxHp

    self:startLevel()
end

function Play:startLevel()

    local previousObjects = self.area:getGameObjects(
        function(obj)
            return obj.class == 'Pearl' or obj.class == 'Ice'
        end
    )

    M.each(previousObjects, 
        function(o, _)
            o:die()
        end
    )

    self.current_level_index = self.current_level_index + 1
    self.current_level = self.levels[self.current_level_index]

    self.goal = 0
    self.consumed = 0
    self.isLevelComplete = false

    for i = 1, self.current_level.spawns:size() do
        local toSpawn = self.current_level.spawns:next()
        print(toSpawn)
        if toSpawn == 'ice' then
            self.area:addGameObject('Ice', self.cupX + i * 10 , gh /2 - 40, {w = 80, h = 80})
        else
            self.area:addGameObject('Pearl', self.cupX + i * 10 , gh /2, 
            {r = 25, type = toSpawn, play = self})
            if toSpawn == 'normal' then
                self.goal = self.goal + 1
            end
        end
    end

end

function Play:update(dt)
    if self.timer then self.timer:update(dt) end
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if not self.isLevelComplete then
        if self.consumed == self.goal then
            self.isLevelComplete = true
            self.timer:after(2, function() self:startLevel() end)
        end
    end
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
        printInsideRect("Consumed: "..self.consumed.." / "..self.goal, self.demoFont, "bottomLeft")
        printInsideRect("Hp: "..self.hp.." / "..self.maxHp, self.demoFont, "bottomRight")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Play:consumePearl(type)
    if type == 'normal' then
        self.consumed = self.consumed + 1
    elseif type == 'hot' then
        self.hp = math.max(self.hp - 1, 0)
    elseif type == 'heal' then
        self.hp = math.min(self.hp + 1, self.maxHp)
    end
end

function Play:destroy()
    self.area:destroy()
    self.area = nil
    self.straw = nil
end

return Play