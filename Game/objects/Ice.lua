local Ice = GameObject:extend()

function Ice:new(area, x, y, opts)
    Ice.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = opts.w, opts.h

    self.collider = self.area.world:newRectangleCollider(self.x , self.y, self.w, self.h)
    self.collider:setCollisionClass('Pearl')
    --self.collider:setObject(self)
    self.collider:setFixedRotation(false)
end

function Ice:update(dt)
    Ice.super.update(self, dt)
end 

function Ice:draw()
    love.graphics.draw(sprites.ice, self.collider:getX(), self.collider:getY(), self.collider:getAngle(), nil, nil, sprites.ice:getWidth() / 2, sprites.ice:getWidth() / 2)
end

function Ice:destroy()
   Ice.super.destroy(self)
end

return Ice
