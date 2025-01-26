local Portrait = GameObject:extend()

function Portrait:new(area, x, y, opts)
    Portrait.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.play = opts.play
    self.sprite = nil
end

function Portrait:update(dt)
    print('updated portrait')
    Portrait.super.update(self, dt)
    if self.play.hp == 4 then
        self.sprite = sprites.h4
    elseif self.play.hp == 3 then
        self.sprite = sprites.h3
    elseif self.play.hp == 2 then
        self.sprite = sprites.h2
    elseif self.play.hp == 1 then
        self.sprite = sprites.h1
    elseif self.play.hp == 0 then
        self.sprite = sprites.h0
    end
end 

function Portrait:draw()
    if self.sprite then
        love.graphics.draw(self.sprite, self.x, self.y, 0, nil, nil)
    end
end

function Portrait:destroy()
   Portrait.super.destroy(self)
end

return Portrait
