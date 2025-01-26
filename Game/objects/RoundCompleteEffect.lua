local RoundCompleteEffect = GameObject:extend()

function RoundCompleteEffect:new(area, x, y, opts)
    RoundCompleteEffect.super.new(self, area, x, y, opts)

    self.x, self.y = gw /2 , gh / 2
    self.scale = 0.5
    self.a = 0
    self.timer = Timer()

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

function RoundCompleteEffect:update(dt)
    RoundCompleteEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function RoundCompleteEffect:draw()
    love.graphics.setColor(1,1,1,self.a)
    love.graphics.draw(sprites.yummy, self.x, self.y, 0, self.scale, self.scale, sprites.yummy:getWidth() / 2, sprites.yummy:getHeight() / 2)
    love.graphics.setColor(1,1,1, 1)
end

function RoundCompleteEffect:destroy()
   RoundCompleteEffect.super.destroy(self)
end

return RoundCompleteEffect
