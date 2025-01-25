local Pearl = GameObject:extend()

function Pearl:new(area, x, y, opts)
    Pearl.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.r = opts.r
    self.type = opts.type
    self.play = opts.play
    self.depth = 40

    self.collider = self.area.world:newCircleCollider(self.x , self.y, self.r)
    self.collider:setCollisionClass('Pearl')
    self.collider:setObject(self)
    self.collider:setFixedRotation(true)
end

function Pearl:update(dt)
    Pearl.super.update(self, dt)

    if self.y < -10 then
        self:die()
    end
end 

function Pearl:draw()
    local sprite = sprites.normalPearl
    if self.type == 'normal' then
        sprite = sprites.normalPearl
    end
    love.graphics.draw(sprite, self.collider:getX(), self.collider:getY(), 0, nil, nil, sprite:getWidth() / 2, sprite:getWidth() / 2)
end

function Pearl:die()
    self.dead = true
    self.play:consumePearl(self.type)
 end

function Pearl:destroy()
   Pearl.super.destroy(self)
end

return Pearl
