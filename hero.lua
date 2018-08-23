
hero = {}
hero.x=0
hero.y=0
hero.vx=0
hero.vy=0
hero.speed =6
hero.sprite = {}
hero.atlas = love.graphics.newImage('assets/img/hero.png')
hero.frame = 0
hero.direction = 'walkUp'
hero.fps = 1/5
hero.animTimer = 1/5
hero.debug = false

hero.sprite.walkUp = {}
hero.sprite.walkUp[0] = love.graphics.newQuad(0*16, 0*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.walkUp[1] = love.graphics.newQuad(1*16, 0*16, 16, 16, hero.atlas:getDimensions())

hero.sprite.walkRight = {}
hero.sprite.walkRight[0] = love.graphics.newQuad(0*16, 1*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.walkRight[1] = love.graphics.newQuad(1*16, 1*16, 16, 16, hero.atlas:getDimensions())

hero.sprite.walkDown = {}
hero.sprite.walkDown[0] = love.graphics.newQuad(0*16, 2*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.walkDown[1] = love.graphics.newQuad(1*16, 2*16, 16, 16, hero.atlas:getDimensions())

hero.sprite.walkLeft = {}
hero.sprite.walkLeft[0] = love.graphics.newQuad(0*16, 3*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.walkLeft[1] = love.graphics.newQuad(1*16, 3*16, 16, 16, hero.atlas:getDimensions())

hero.sprite.atkUp = {}
hero.sprite.atkUp[0] = love.graphics.newQuad(0*16, 4*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.atkUp[1] = love.graphics.newQuad(1*16, 4*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.atkUp[2] = love.graphics.newQuad(2*16, 4*16, 16, 16, hero.atlas:getDimensions())
hero.sprite.atkUp[3] = love.graphics.newQuad(3*16, 4*16, 16, 16, hero.atlas:getDimensions())

hero.getBootomColl = function (this)
  return this.x*BLOCKSIZE*PPM +0.3 * PPM *BLOCKSIZE,
  this.y*BLOCKSIZE*PPM + 1*PPM*BLOCKSIZE ,
  0.4*BLOCKSIZE*PPM,
  0.05*BLOCKSIZE*PPM
end

hero.getUpColl = function (this)
  return this.x*BLOCKSIZE*PPM +0.3 * PPM *BLOCKSIZE,
  this.y*BLOCKSIZE*PPM + 0.5*PPM*BLOCKSIZE,
  0.4*BLOCKSIZE*PPM,
  0.05*BLOCKSIZE*PPM
end

hero.getLeftColl = function (this)
  return this.x*BLOCKSIZE*PPM +0.2 * PPM *BLOCKSIZE,
  this.y*BLOCKSIZE*PPM + 0.7*PPM*BLOCKSIZE,
  0.1*BLOCKSIZE*PPM,
  0.2*BLOCKSIZE*PPM
end

hero.getRightColl = function (this)
  return this.x*BLOCKSIZE*PPM +0.7 * PPM *BLOCKSIZE,
  this.y*BLOCKSIZE*PPM + 0.7*PPM*BLOCKSIZE,
  0.1*BLOCKSIZE*PPM,
  0.2*BLOCKSIZE*PPM
end

hero.update = function(this,dt)
  local sp = this.speed
  this.lastVx = this.vx
  this.lastVy = this.vy
  hero.vx,hero.vy = 0,0
  this.idle = false

  if love.keyboard.isDown('up') then
    this.direction = 'walkUp'
    this.vy =  -1
  end
  if love.keyboard.isDown('down') then
    this.direction = 'walkDown'
    this.vy = 1
  end
  if love.keyboard.isDown('left') then
    this.direction = 'walkLeft'
    this.vx =  -1
  end
  if love.keyboard.isDown('right') then
    this.direction = 'walkRight'
    this.vx =  1
  end

  if this.lastVx ~= this.vx or this.lastVy ~= this.vy then
    this.frame = 0
    this.fps = 1/5
  end

  if this.vx==0 and this.vy ==0 then
    this.idle = true
    this.frame = 0 
  elseif this.vx ~=0 and this.vy ~=0 then
    sp = sp* 0.7
  end


  
  if  this.idle == false then 
    this.animTimer = this.animTimer - dt
    if this.animTimer <= 0 then
      this.frame = (this.frame+1)%(#this.sprite[this.direction]+1)
      this.animTimer = this.fps
    end
  end

--[[   if terrain[rafUtils.clamp(rafUtils.round(this.y + this.vy * sp * dt),0,#terrain[0])][ rafUtils.clamp(rafUtils.round( this.x + this.vx * sp * dt ),0,#terrain)] > 0
  then
    return
  end ]]
  local dist = 1
  local startX = rafUtils.round(this.x - dist)
  local endX = rafUtils.round(this.x + dist)
  local startY = rafUtils.round(this.y - dist)
  local endY = rafUtils.round(this.y + dist)

  startY = rafUtils.clamp(startY,0,#terrain)
  startX = rafUtils.clamp(startX,0,#terrain[startY])
  endY = rafUtils.clamp(endY,0,#terrain)
  endX = rafUtils.clamp(endX,0,#terrain)

  for yy = startY,endY do
    for xx = startX,endX do
      if terrain[yy][xx] == 1 
      or terrain[yy][xx] == 257
      or terrain[yy][xx] == 256
      or terrain[yy][xx] == 28
      or terrain[yy][xx] == 199
      or terrain[yy][xx] == 255
      or terrain[yy][xx] == 135
      or terrain[yy][xx] == 143
      or terrain[yy][xx] == 207
      or terrain[yy][xx] == 31
      or terrain[yy][xx] == 30
      or terrain[yy][xx] == 15 --
      or terrain[yy][xx] == 47 --
      or terrain[yy][xx] == 39 --
      or terrain[yy][xx] == 175 --
      or terrain[yy][xx] == 158
      or terrain[yy][xx] == 62
      or terrain[yy][xx] == 231
      or terrain[yy][xx] == 124
      or terrain[yy][xx] == 7
      or terrain[yy][xx] == 60
      or terrain[yy][xx] == 252
      or terrain[yy][xx] == 253
      or terrain[yy][xx] == 247
      or terrain[yy][xx] == 167--
      or terrain[yy][xx] == 156--
      or terrain[yy][xx] == 183--
      or terrain[yy][xx] == 156  then 
        local cx,cy,cwidth,cheight = this:getLeftColl()
        if rafUtils.isCollideRec(cx,cy,cwidth,cheight,xx*BLOCKSIZE*PPM, yy*BLOCKSIZE*PPM, BLOCKSIZE*PPM, BLOCKSIZE*PPM) then
          this.vx = 0
          this.x = xx + 0.825 
          return
        end
        cx,cy,cwidth,cheight = this:getRightColl()
        if rafUtils.isCollideRec(cx,cy,cwidth,cheight,xx*BLOCKSIZE*PPM, yy*BLOCKSIZE*PPM, BLOCKSIZE*PPM, BLOCKSIZE*PPM) then
          this.vx = 0
          this.x = xx - 0.805 
          return
        end
        cx,cy,cwidth,cheight = this:getBootomColl()
        if rafUtils.isCollideRec(cx,cy,cwidth,cheight,xx*BLOCKSIZE*PPM, yy*BLOCKSIZE*PPM, BLOCKSIZE*PPM, BLOCKSIZE*PPM) then
          this.vy = 0
          this.y = yy -1.05 
          return
        end
        cx,cy,cwidth,cheight = this:getUpColl()
        if rafUtils.isCollideRec(cx,cy,cwidth,cheight,xx*BLOCKSIZE*PPM, yy*BLOCKSIZE*PPM, BLOCKSIZE*PPM, BLOCKSIZE*PPM) then
          this.vy = 0
          this.y = yy + 0.6 
          return
        end
      end
    end
  end
  
  this.x = this.x + (this.vx * sp * dt)
  this.y = this.y +( this.vy * sp * dt)

  this.x = this.x%WORLDWIDTH
  this.y = this.y%WORLDHEIGHT
end

hero.draw = function(this)
  love.graphics.draw(this.atlas, this.sprite[this.direction][this.frame],
  hero.x*BLOCKSIZE*PPM - rafUtils.camera.x,
  hero.y*BLOCKSIZE*PPM - rafUtils.camera.y,
  0,PPM*0.5,PPM*0.5)

  --bottom
  if hero.debug then
    love.graphics.setColor(1,0,1,1)
    local x,y,w,h = hero:getBootomColl()
    love.graphics.rectangle('line',x-rafUtils.camera.x,y-rafUtils.camera.y,w,h)
    --up
    
    x,y,w,h = hero:getUpColl()
    love.graphics.rectangle('line',x-rafUtils.camera.x,y-rafUtils.camera.y,w,h)
    
    x,y,w,h = hero:getLeftColl()
    love.graphics.rectangle('line',x-rafUtils.camera.x,y-rafUtils.camera.y,w,h)
    
    x,y,w,h = hero:getRightColl()
    love.graphics.rectangle('line',x-rafUtils.camera.x,y-rafUtils.camera.y,w,h)
    
    love.graphics.setColor(1,1,1,1)
  end
end