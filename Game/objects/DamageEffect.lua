local DamageEffect = GameObject:extend()

function DamageEffect:new(area, x, y, opts)
    DamageEffect.super.new(self, area, x, y, opts)

    self.x, self.y = 1600 + random(-40, 40) , 260 + random(-40, 40)
    self.scale = 0.5
    self.a = 0
    self.timer = Timer()
    self.depth = 100

   self.timer:tween(0.5, self, {a = 1, scale = 1}, 'in-out-cubic',
    function()
        self.timer:after(1.5, function()
            self.timer:tween(0.25, self, {a = 0}, 'in-out-cubic',
            function()
                self.dead = true
            end)
        end)
    end)
end

function DamageEffect:update(dt)
    DamageEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function DamageEffect:draw()
    love.graphics.setColor(1,1,1,self.a)
    love.graphics.draw(sprites.yuck, self.x, self.y, 0, self.scale, self.scale, sprites.yuck:getWidth() / 2, sprites.yuck:getHeight() / 2)
    love.graphics.setColor(1,1,1, 1)
end

function DamageEffect:destroy()
   DamageEffect.super.destroy(self)
end

return DamageEffect
