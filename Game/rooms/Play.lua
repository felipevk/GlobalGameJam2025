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

    self.canvasPos = {
        x = gw,
        y = 0
    }

    self.timer:tween(0.3, self.canvasPos, {x = 0, y = 0}, 'in-out-cubic')

    self.levels = {
        {spawns = chanceList({'normal', 8}, {'ice', 4}), time = 10, color = brown },
        {spawns = chanceList({'normal', 8}, {'ice', 4}, {'hot', 4}), time = 10, color = orange },
        {spawns = chanceList({'normal', 1}, {'ice', 30}, {'hot', 4}), time = 10, color = matcha },
        {spawns = chanceList({'normal', 10}, {'ice', 6}, {'hot', 6}, {'heal', 6}), time = 10, color = pink },
        {spawns = chanceList({'normal', 1}, {'ice', 30}, {'hot', 4}, {'break', 1}), time = 10, color = matcha },
        {spawns = chanceList({'normal', 10}, {'ice', 8}, {'hot', 6}, {'heal', 6}), time = 10, color = mango },
        {spawns = chanceList({'normal', 12}, {'ice', 15}, {'hot', 7}, {'heal', 4}, {'break', 1}), time = 10, color = cyan },
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
    self.isGameOver = false

    self.endAlpha = 0.5
    self.currentEndAlpha = 0

    self.levelStats = {
        current_time = 0,
        consumed = 0,
        goal = 0,
        isComplete = false,
    }

    self.area:addGameObject('Portrait', gw - 200 - 32, 32, {play = self})

    self.area:addGameObject('Progress', gw / 2 - sprites.progress:getWidth() / 2, gh - 36 - sprites.progress:getHeight(), {play = self})

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
        self.isGameOver = true
        self.timer:after(0.5, function()
            self.timer:tween(1, self, {currentEndAlpha = self.endAlpha}, 'linear', 
            function() 
                sounds.gameOver:play()
            end)
         end)
         self.timer:after(3, function()
            gotoRoom('Credits')
         end)
        return
    end

    self.current_level_index = self.current_level_index + 1
    self.current_level = self.levels[self.current_level_index]

    self.levelStats = {
        current_time = 0,
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
    if input:pressed('shortcut') then
        gotoRoom('Credits')
        return
    end
    if self.timer then self.timer:update(dt) end
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)

    if self.isGameOver then return end
    
    self.area:update(dt)

    if not self.levelStats.isComplete then
        if self.levelStats.consumed == self.levelStats.goal then
            sounds.complete:play()
            self.levelStats.isComplete = true
            self.area:addGameObject('RoundCompleteEffect', 0, 0)
            self.timer:after(1, function() self:startLevel() end)
        
        elseif self.hp <= 0 then
            self.levelStats.isComplete = true
            
            self.timer:after(0.5, function()
                self.isGameOver = true
                self.timer:tween(1, self, {currentEndAlpha = self.endAlpha}, 'linear', 
                function() 
                    sounds.loss:play()
                end)
             end)
             self.timer:after(3, function()
                gotoRoom('Start')
             end)
        end
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Play:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(self.canvasPos.x, self.canvasPos.y, gw, gh)
        love.graphics.draw(sprites.table, 0, gh - sprites.table:getHeight(), 0)
        love.graphics.draw(sprites.shadow, gw / 2 - sprites.shadow:getWidth() / 2, 900, 0, nil, nil, 0 ,sprites.shadow:getHeight() / 2)
        love.graphics.setColor(self.current_level.color)
        love.graphics.draw(sprites.liquid, gw / 2 - sprites.liquid:getWidth() / 2, 900, 0, nil, nil, 0 ,sprites.liquid:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        
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
        love.graphics.draw(sprites.instructions, 20, 50, 0, nil, nil, 0 )
        self.area:draw()

        if self.isGameOver then
            love.graphics.setColor(0, 0, 0, self.currentEndAlpha)
            love.graphics.rectangle("fill", 0, 0, gw, gh)

            local textA = self.currentEndAlpha < self.endAlpha and self.currentEndAlpha or 1
            
            if self.hp == 0 then
                love.graphics.setColor(1, 1, 1, textA)
                printInsideRect("You died while drinking bubble tea", fonts.qilka, "center")
            else
                love.graphics.setColor(0, 1, 0, textA)
                printInsideRect("You won free bubble tea for life!", fonts.qilka, "center")
            end

            love.graphics.setColor(1, 1, 1, 1)
        end
        
        --love.graphics.setFont(self.demoFont)
        --printInsideRect("Consumed: "..self.levelStats.consumed.." / "..self.levelStats.goal, self.demoFont, "bottomLeft")
        --printInsideRect("Hp: "..self.hp.." / "..self.maxHp, self.demoFont, "bottomRight")
        --printInsideRect("Progress: "..self.current_level_index.." / "..#self.levels, self.demoFont, "bottom")
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
        flash(4, {224/255, 120/255, 23/255, 0.3})
        camera:shake(6, 60, 0.4)
        self.area:addGameObject('DamageEffect', 0, 0)
    elseif type == 'heal' then
        self.hp = math.min(self.hp + 1, self.maxHp)
        flash(4, {123/255, 166/255, 70/255, 0.3})
        sounds.heal:play()
    elseif type == 'break' then
        camera:shake(10, 60, 1)
       local iceObjs = self.area:getGameObjects(
        function(obj)
            return obj.class == 'Ice'
        end)

        M.each(iceObjs, 
            function(o, _)
                o:die()
            end
        )
        sounds.iceBreak:play()
    end
end

function Play:destroy()
    self.area:destroy()
    self.area = nil
    self.straw = nil
end

return Play