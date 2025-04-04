local Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

function Area:update(dt)
    if self.world then self.world:update(dt) end

    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then 
            game_object:destroy()
            table.remove(self.game_objects, i)
        end
    end
end

function Area:draw()
    if self.world and drawCol then self.world:draw() end

    table.sort(self.game_objects, function(a, b) 
        return a.depth < b.depth
    end)
    
    for _, game_object in ipairs(self.game_objects) do game_object:draw() end
end

function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    game_object.class = game_object_type
    table.insert(self.game_objects, game_object)
    return game_object
end

function Area:getGameObjects(f)
    return M.select(self.game_objects, f)
end

function Area:queryCircleArea(x, y, radius, targets)
    return M.select(self.game_objects, 
        function(obj)
            return M.any(targets, obj.class) and isInsideCircle(obj.x, obj.y, x, y, radius)
        end)
end

function Area:getClosestObject(x, y, radius, targets)
    return M.sort(self:queryCircleArea(x, y, radius, targets), 
    function(a, b)
        return distanceBetweenPoints(x,y, a.x, a.y) < distanceBetweenPoints(x,y, b.x, b.y)
    end)[1]
end

function Area:addPhysicsWorld()
    self.world = Physics.newWorld(0, 30, true)
    self.world:setQueryDebugDrawing(drawCol)
end

function Area:destroy()
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:destroy()
        table.remove(self.game_objects, i)
    end
    self.game_objects = {}

    if self.world then
        self.world:destroy()
        self.world = nil
    end
end

return Area