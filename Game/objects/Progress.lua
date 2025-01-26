local Progress = GameObject:extend()

function Progress:new(area, x, y, opts)
    Progress.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.play = opts.play
    self.barSprite = sprites.progress
    self.indicatorSprite = sprites.progressIndicator
    self.indicatorR = 0
end

function Progress:update(dt)
    Progress.super.update(self, dt)
end 

function Progress:draw()
    local indicatorOffset = self.barSprite:getWidth() * ((self.play.current_level_index - 1) / (#self.play.levels - 1))  - self.indicatorSprite:getWidth() / 2
    love.graphics.draw(self.barSprite, self.x, self.y, 0, nil, nil)
    love.graphics.draw(self.indicatorSprite, 
    self.x + indicatorOffset, 
    self.y - self.indicatorSprite:getHeight()/2, self.indicatorR, nil, nil)
end

function Progress:destroy()
   Progress.super.destroy(self)
end

return Progress
