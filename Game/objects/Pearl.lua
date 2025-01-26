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

    if not self.play.levelStats.isComplete and (self.y < -10 or self.x < 0 or self.x > gw) then
        self.play:consumePearl(self.type)
        self:die()
    end
end 

function Pearl:draw()
    local sprite = sprites.normalPearl
    if self.type == 'normal' then
        sprite = sprites.normalPearl
    elseif self.type == 'hot' then
        sprite = sprites.hotPearl
    elseif self.type == 'heal' then
        sprite = sprites.healPearl
    elseif self.type == 'break' then
        sprite = sprites.breakPearl
    end
    love.graphics.draw(sprite, self.collider:getX(), self.collider:getY(), 0, nil, nil, sprite:getWidth() / 2, sprite:getWidth() / 2)
end

function Pearl:die()
    self.dead = true
 end

function Pearl:destroy()
   Pearl.super.destroy(self)
end

return Pearl
