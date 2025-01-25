local Pearl = GameObject:extend()

function Pearl:new(area, x, y, opts)
    Pearl.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.r = opts.r
    self.type = opts.type
    self.play = opts.play

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

end

function Pearl:die()
    self.dead = true
    self.play:consumePearl(self.type)
 end

function Pearl:destroy()
   Pearl.super.destroy(self)
end

return Pearl
