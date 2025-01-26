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
    self.cupW2 = 415
    self.cupH = 700
    self.cupX = gw / 2 - self.cupW / 2
    self.cupY = 200
    self.name = 'play'

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
        self.area.world:newLineCollider(self.cupX, self.cupY, 748, self.cupY + self.cupH),
        self.area.world:newLineCollider(self.cupX + self.cupW, self.cupY, 1160, self.cupY + self.cupH),
        
        self.area.world:newLineCollider(self.cupX, self.cupY + self.cupH, self.cupX + self.cupW, self.cupY + self.cupH),
        
        self.area.world:newLineCollider(self.cupX, self.cupY, self.cupX + self.cupW / 2 - 30, self.cupY),
        self.area.world:newLineCollider(self.cupX + self.cupW / 2 + 30, self.cupY, self.cupX + self.cupW, self.cupY),
    }

    for col = 1, #self.cup do
        self.cup[col]:setType('static')
    end

    self.current_level = {}
    self.current_level_index = 0
    self.maxHp = 4
    self.hp = self.maxHp

    self.levelStats = {
        consumed = 0,
        goal = 0,
        isComplete = false,
    }

    self.area:addGameObject('Portrait', gw - 200 - 32, 32, {play = self})

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
    if self.current_level_index == #self.levels then
        self.timer:after(2, function()
            -- show celebration and go to credits
         end)
         self.timer:after(3, function()
            gotoRoom('Credits')
         end)
        return
    end

    self.current_level_index = self.current_level_index + 1
    self.current_level = self.levels[self.current_level_index]

    self.levelStats = {
        consumed = 0,
        goal = 0,
        isComplete = false,
    }

    for i = 1, self.current_level.spawns:size() do
        local toSpawn = self.current_level.spawns:next()
        if toSpawn == 'ice' then
            self.area:addGameObject('Ice', self.cupX + 40 + i * 10 , gh /2 - 40, {w = 80, h = 80})
        else
            self.area:addGameObject('Pearl', self.cupX + 40 + i * 10 , gh /2, 
            {r = 25, type = toSpawn, play = self})
            if toSpawn == 'normal' then
                self.levelStats.goal = self.levelStats.goal + 1
            end
        end
    end

end

function Play:update(dt)
    --[[if input:pressed('shortcut') then
        gotoRoom('Start')
    end]]
    if self.timer then self.timer:update(dt) end
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if not self.levelStats.isComplete then
        if self.levelStats.consumed == self.levelStats.goal then
            self.levelStats.isComplete = true
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
        love.graphics.draw(sprites.table, 0, gh - sprites.table:getHeight(), 0)
        love.graphics.draw(sprites.shadow, gw / 2 - sprites.shadow:getWidth() / 2, 900, 0, nil, nil, 0 ,sprites.shadow:getHeight() / 2)
        love.graphics.draw(sprites.cup, gw / 2 - sprites.cup:getWidth() / 2, 900, 0, nil, nil, 0 ,sprites.cup:getHeight())
        
        local cupXOffset = 800
        if self.current_level_index > 1 then
            love.graphics.draw(sprites.shadow, gw / 2 - sprites.shadow:getWidth() / 2 - cupXOffset, 900, 0, 0.6, 0.6, 0 ,sprites.shadow:getHeight() / 2)
            love.graphics.draw(sprites.cup, gw / 2 - sprites.cup:getWidth() / 2 - cupXOffset, 900, 0, 0.6, 0.6, 0 ,sprites.cup:getHeight())
        end
        if self.current_level_index < #self.levels then
            love.graphics.draw(sprites.shadow, gw / 2 + cupXOffset, 900, 0, 0.6, 0.6, 0 ,sprites.shadow:getHeight() / 2)
            love.graphics.draw(sprites.cup, gw / 2 + cupXOffset, 900, 0, 0.6, 0.6, 0 ,sprites.cup:getHeight())
        end
        self.area:draw()
        
        love.graphics.setFont(self.demoFont)
        printInsideRect("Consumed: "..self.levelStats.consumed.." / "..self.levelStats.goal, self.demoFont, "bottomLeft")
        --printInsideRect("Hp: "..self.hp.." / "..self.maxHp, self.demoFont, "bottomRight")
        printInsideRect("Progress: "..self.current_level_index.." / "..#self.levels, self.demoFont, "bottom")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Play:consumePearl(type)
    if type == 'normal' then
        self.levelStats.consumed = self.levelStats.consumed + 1
        sounds.normal:play()
    elseif type == 'hot' then
        self.hp = math.max(self.hp - 1, 0)
        sounds.hot:play()
    elseif type == 'heal' then
        self.hp = math.min(self.hp + 1, self.maxHp)
        sounds.heal:play()
    end
end

function Play:destroy()
    self.area:destroy()
    self.area = nil
    self.straw = nil
end

return Play