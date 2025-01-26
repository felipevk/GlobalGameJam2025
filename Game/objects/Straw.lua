local Straw = GameObject:extend()

function Straw:new(area, x, y, opts)
    Straw.super.new(self, area, x, y, opts)

    self.x, self.y = x - 30, y + 30
    self.w = 60
    self.h = 1000
    self.hOffset = 40
    self.depth = 50

    self.cupX, self.cupY = opts.cupX, opts.cupY
    self.cupW, self.cupH = opts.cupW, opts.cupH

    self.pivotPoint = {
        x = gw / 2,
        y = 190
    }

    self.left = self.area.world:newRectangleCollider(self.x, 0, self.h, 1)
    self.right = self.area.world:newRectangleCollider(self.x, 0 - self.w, self.h + self.hOffset, 1)

    self.left:setType('static')
    self.right:setType('static')

    self.topStraw = {
        x = 0,
        y = 0
    }
    self.topLeftStraw = {
        x = 0,
        y = 0
    }
    self.topRightStraw = {
        x = 0,
        y = 0
    }
    self.left:setAngle(math.pi / 2)
    self.right:setAngle(math.pi / 2)

    self.isDrinking = false
    self.angleToPivot = 0

    self.strawSpritePos = {
        x = 0,
        y = 0
    }
end

function Straw:update(dt)
    Straw.super.update(self, dt)

    self.isDrinking = false

    local mouseX = love.mouse.getX() / sx
    local mouseY = love.mouse.getY() / sy

    if isInsideRect(mouseX, mouseY, self.cupX, self.cupY, self.cupW, self.cupH) then
        --find angle and distance between mouse and pivot
        --get remainig distance and find top of straw
        --angle between top of straw and mouse
        self.strawSpritePos.x, self.strawSpritePos.y = mouseX, mouseY
        self.angleToPivot = angleBetweenPoints(mouseX, mouseY , self.pivotPoint.x , self.pivotPoint.y)
        local distanceToPivot = distanceBetweenPoints(mouseX, mouseY , self.pivotPoint.x , self.pivotPoint.y)
        local distancePivotToTop = self.h - distanceToPivot
        
        self.topStraw = movePointDistanceAngle(self.pivotPoint.x, self.pivotPoint.y, distancePivotToTop, self.angleToPivot)
        
        local top = movePointDistanceAngle(mouseX , mouseY, self.h / 2, self.angleToPivot)
        local topOff = movePointDistanceAngle(mouseX , mouseY, self.h / 2 + self.hOffset, self.angleToPivot)
        self.topLeftStraw = movePointDistanceAngle(topOff.x , topOff.y, self.w / 2, self.angleToPivot - math.pi / 2)
        self.topRightStraw = movePointDistanceAngle(top.x , top.y, self.w / 2, self.angleToPivot + math.pi / 2)
        
        self.left:setX(self.topLeftStraw.x)
        self.left:setY(self.topLeftStraw.y)
        self.left:setAngle(self.angleToPivot)

        self.right:setX(self.topRightStraw.x)
        self.right:setY(self.topRightStraw.y)
        self.right:setAngle(self.angleToPivot)

        if input:down('drink') then
            self.isDrinking = true

            local queryPoint = movePointDistanceAngle(mouseX, mouseY, 20, self.angleToPivot - math.pi / 2)

            
            local colliders = self.area.world:queryCircleArea(queryPoint.x, queryPoint.y, 60, {'Pearl'})
            for i = 1, #colliders do
                local forceIntensity = 30000
                local forceDir = Vector(mouseX - colliders[i]:getX(), mouseY - colliders[i]:getY()):normalized()
                colliders[i]:applyForce( forceDir.x * forceIntensity,  forceDir.y * forceIntensity)
            end

            local topLeftExtended = movePointDistanceAngle(self.topLeftStraw.x, self.topLeftStraw.y, self.h, self.angleToPivot)
            local topRightExtended = movePointDistanceAngle(self.topRightStraw.x, self.topRightStraw.y, self.h, self.angleToPivot)
            local bottomLeftStraw = movePointDistanceAngle(self.topLeftStraw.x, self.topLeftStraw.y, self.h * 0.8, self.angleToPivot + math.pi)
            local bottomRightStraw = movePointDistanceAngle(self.topRightStraw.x, self.topRightStraw.y, self.h *0.8, self.angleToPivot + math.pi)
            local verts = {
                topLeftExtended.x, topLeftExtended.y,
                topRightExtended.x, topRightExtended.y,
                bottomRightStraw.x, bottomRightStraw.y,
                bottomLeftStraw.x, bottomLeftStraw.y,
            }
            local colliders = self.area.world:queryPolygonArea(verts, {'Pearl'})
            for i = 1, #colliders do
                local distanceToTop = distanceBetweenPoints(colliders[i]:getX(), colliders[i]:getY(), topLeftExtended.x, topLeftExtended.y)
                if distanceToTop > 0 then
                    
                    local forceIntensity = 80000 / (distanceToTop / 1000)
                    local forceDir = Vector(math.cos(self.angleToPivot), math.sin(self.angleToPivot))
                    colliders[i]:applyForce( forceDir.x * forceIntensity,  forceDir.y * forceIntensity)
                end
            end
        end
    end
    
end 

function Straw:draw()
    love.graphics.setColor(0,0,1,1)
    --love.graphics.circle('fill',self.topStraw.x,self.topStraw.y,5)
    --love.graphics.circle('fill',self.topLeftStraw.x,self.topLeftStraw.y,5)
    --love.graphics.circle('fill',self.topRightStraw.x,self.topRightStraw.y,5)
    love.graphics.setColor(0,1,0,1)
    --love.graphics.circle('fill',self.pivotPoint.x,self.pivotPoint.y,5)
    love.graphics.setColor(1,1,1,0.6)

    love.graphics.draw(sprites.straw, self.strawSpritePos.x, self.strawSpritePos.y, self.angleToPivot - math.pi, nil, nil, sprites.straw:getWidth(), sprites.straw:getHeight() / 2)
    love.graphics.setColor(1,1,1,1)
end

function Straw:destroy()
    Straw.super.destroy(self)
end

return Straw
