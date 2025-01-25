local Straw = GameObject:extend()

function Straw:new(area, x, y, opts)
    Straw.super.new(self, area, x, y, opts)

    self.x, self.y = x - 25, y + 50
    self.w = 50
    self.h = 1000
    self.hOffset = 40

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
        local angleToPivot = angleBetweenPoints(mouseX, mouseY , self.pivotPoint.x , self.pivotPoint.y)
        local distanceToPivot = distanceBetweenPoints(mouseX, mouseY , self.pivotPoint.x , self.pivotPoint.y)
        local distancePivotToTop = self.h - distanceToPivot
        
        self.topStraw = movePointDistanceAngle(self.pivotPoint.x, self.pivotPoint.y, distancePivotToTop, angleToPivot)
        
        local top = movePointDistanceAngle(mouseX , mouseY, self.h / 2, angleToPivot)
        local topOff = movePointDistanceAngle(mouseX , mouseY, self.h / 2 + self.hOffset, angleToPivot)
        self.topLeftStraw = movePointDistanceAngle(topOff.x , topOff.y, self.w / 2, angleToPivot - math.pi / 2)
        self.topRightStraw = movePointDistanceAngle(top.x , top.y, self.w / 2, angleToPivot + math.pi / 2)
        
        self.left:setX(self.topLeftStraw.x)
        self.left:setY(self.topLeftStraw.y)
        self.left:setAngle(angleToPivot)

        self.right:setX(self.topRightStraw.x)
        self.right:setY(self.topRightStraw.y)
        self.right:setAngle(angleToPivot)

        if input:pressed('drink') then
            self.isDrinking = true
        end
    end
    
end 

function Straw:draw()
    love.graphics.setColor(0,0,1,1)
    love.graphics.circle('fill',self.topStraw.x,self.topStraw.y,5)
    love.graphics.circle('fill',self.topLeftStraw.x,self.topLeftStraw.y,5)
    love.graphics.circle('fill',self.topRightStraw.x,self.topRightStraw.y,5)
    love.graphics.setColor(0,1,0,1)
    love.graphics.circle('fill',self.pivotPoint.x,self.pivotPoint.y,5)
    love.graphics.setColor(1,1,1,1)
end

function Straw:destroy()
    Straw.super.destroy(self)
end

return Straw
