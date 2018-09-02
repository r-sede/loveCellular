local debug = false
local showTile = false
local showFog = true
local mute = true

PPM = 4 -- scale
BLOCKSIZE = 8
local SWIDTH = 1024--640--*2 -- screen width in pixels
local SHEIGHT = 768--576--*2 -- screen height in pixels
WTWIDTH = SWIDTH/(BLOCKSIZE*PPM) -- number of blocks on screen along x
WTHEIGHT = SHEIGHT/(BLOCKSIZE*PPM) -- number of blocks on screen along y
WORLDWIDTH = 128*4--*8 -- width of world in block
WORLDHEIGHT = 128*4--*8 -- height of world in block
local TILES = {}
local ATLAS = nil
local SEED = nil

local backMusic = nil
rafUtils = require"rafUtils"

local rRockCells = 0.48
local nIter =11
local startIter = 11
local neighBorHoodThres = 5
terrain = nil
local fog = nil
local playerX,playerY = nil,nil
local clickX,clickY = 0,0

local OBJTILES = {}

local torchTimer = 1/4
local torchFps = 1/4
local torchFrame = 0
local densTorch = 28
local torchs = nil

local chests = nil
local densChest = 1
local colorGB = 4

local bombAtlas = nil
local bombTiles = {}
local bombTimer = 1/3
local bombFps = 1/3
local bombFrame = 0
local bombs = {}

local decos = nil
local densDeco = 1

local tp = false

function love.load(arg)
  love.graphics.setDefaultFilter('nearest')
  love.keyboard.setKeyRepeat(true)
  love.audio.setVolume(0)
  love.window.setMode(SWIDTH, SHEIGHT)
  love.window.setTitle('loveCellular')
  --green
  --love.graphics.setBackgroundColor(32/255,70/255,50/255,1)
  -- gray
  love.graphics.setBackgroundColor(61/255,61/255,61/255,1)
  
  SEED = love.timer.getTime()
  love.math.setRandomSeed(SEED)
  require'hero'
  resetMap()
  
  bombAtlas = love.graphics.newImage('assets/img/bomb.png')
  bombTiles[0]=love.graphics.newQuad(0*16 , 0*16, 16, 16, bombAtlas:getDimensions())
  bombTiles[1]=love.graphics.newQuad(1*16 , 0*16, 16, 16, bombAtlas:getDimensions())
  bombTiles[2]=love.graphics.newQuad(2*16 , 0*16, 16, 16, bombAtlas:getDimensions())

  ATLAS = love.graphics.newImage('assets/img/CB-All_Temple.png')
  TILES[0] = love.graphics.newQuad(2*8 +colorGB*256, 3*8, 8, 8, ATLAS:getDimensions())
  TILES[-1] = love.graphics.newQuad(3*8+colorGB*256, 3*8, 8, 8, ATLAS:getDimensions())
  TILES[-2] = love.graphics.newQuad(2*8+colorGB*256, 2*8, 8, 8, ATLAS:getDimensions())
  
  ----------------------------------------------
  TILES[31] = love.graphics.newQuad(13*8+colorGB*256, 6*8, 8, 8, ATLAS:getDimensions())
  TILES[191] = TILES[31]
  TILES[63] = TILES[31]
  TILES[159] = TILES[31]
  
  TILES[28] = love.graphics.newQuad(16*8+colorGB*256, 8*8, 8, 8, ATLAS:getDimensions())
  TILES[60] = TILES[28]
  TILES[30] = TILES[28]
  TILES[158] = TILES[28]--
  TILES[62] = TILES[28]
  TILES[188] = TILES[28]--
  TILES[156] = TILES[28]--
  TILES[190] = TILES[28]--
  
  TILES[15] = love.graphics.newQuad(12*8+colorGB*256, 8*8, 8, 8, ATLAS:getDimensions())
  TILES[135] = TILES[15]
  TILES[7] = TILES[15]
  TILES[183] = TILES[15]--
  TILES[143] = TILES[15]
  TILES[167] = TILES[15]--
  TILES[47] = TILES[15]--
  TILES[39] = TILES[15]--
  TILES[175] = TILES[15]--

  TILES[127] = love.graphics.newQuad(16*8+colorGB*256, 6*8, 8, 8, ATLAS:getDimensions())

  TILES[223] = love.graphics.newQuad(12*8+colorGB*256, 6*8, 8, 8, ATLAS:getDimensions())

  TILES[199] = love.graphics.newQuad(12*8+colorGB*256, 7*8, 8, 8, ATLAS:getDimensions())
  TILES[207] = TILES[199]
  TILES[239] = TILES[199]
  TILES[231] = TILES[199]
  
  TILES[193] = love.graphics.newQuad(13*8+colorGB*256, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[225] = TILES[193]
  TILES[227] = TILES[193]
  TILES[195] = TILES[193]
  TILES[203] = TILES[193]--
  TILES[201] = TILES[193]--
  TILES[217] = TILES[193]--
  TILES[233] = TILES[193]--

  TILES[247] = love.graphics.newQuad(11*8+colorGB*256, 10*8, 8, 8, ATLAS:getDimensions())
  --------------------------------------------------
  
  TILES[241] = love.graphics.newQuad(16*8+colorGB*256, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[249] = TILES[241]
  TILES[251] = TILES[241]
  TILES[243] = TILES[241]
  TILES[251] = TILES[241]

  TILES[253] = love.graphics.newQuad(17*8+colorGB*256, 10*8, 8, 8, ATLAS:getDimensions())
  
  TILES[248] = love.graphics.newQuad(15*8+colorGB*256, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[240] = TILES[248]
  TILES[120] = TILES[248]
  TILES[112] = TILES[248]
  TILES[122] = TILES[248]--
  TILES[242] = TILES[248]--
  
  TILES[124] = love.graphics.newQuad(16*8+colorGB*256, 7*8, 8, 8, ATLAS:getDimensions())
  TILES[126] = TILES[124]
  TILES[252] = TILES[124]
  TILES[254] = TILES[124]

  -----------------------------------
  TILES[256] = love.graphics.newQuad(14*8+colorGB*256,7*8,8,8,ATLAS:getDimensions())
  TILES[257] = love.graphics.newQuad(14*8+colorGB*256,8*8,8,8,ATLAS:getDimensions())

  ---------------OBJECT------------
  OBJTILES['torch'] = {}
  OBJTILES['torch'][0] = love.graphics.newQuad(18*8+colorGB*256,14*8,16,24,ATLAS:getDimensions())
  OBJTILES['torch'][1] = love.graphics.newQuad(20*8+colorGB*256,14*8,16,24,ATLAS:getDimensions())

  OBJTILES['chest'] = {}
  OBJTILES['chest'][0] = love.graphics.newQuad(6*8+colorGB*256, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][1] = love.graphics.newQuad(7*8+colorGB*256, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][2] = love.graphics.newQuad(8*8+colorGB*256, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][3] = love.graphics.newQuad(9*8+colorGB*256, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][4] = love.graphics.newQuad(10*8+colorGB*256, 17*8,8,8,ATLAS:getDimensions())
  
  OBJTILES['deco'] = {}
  OBJTILES['deco'][0] = love.graphics.newQuad(7*8+colorGB*256, 13*8,8,8*3,ATLAS:getDimensions())
  OBJTILES['deco'][1] = love.graphics.newQuad(8*8+colorGB*256, 13*8,8,8*3,ATLAS:getDimensions())
  OBJTILES['deco'][2] = love.graphics.newQuad(9*8+colorGB*256, 13*8,8,8*3,ATLAS:getDimensions())
  OBJTILES['deco'][3] = love.graphics.newQuad(10*8+colorGB*256, 13*8,8,8*3,ATLAS:getDimensions())


  backMusic = love.audio.newSource('assets/music/cloudMoonLoop2.wav', 'stream')
  footSound = love.audio.newSource('assets/sfx/sfx_movement_footsteps1b.wav', 'static')
  footSound:setVolume(0.5)
  backMusic:setLooping(true)
  backMusic:setVolume(0.7)
  backMusic:play()
end

function love.update(dt)
  hero:update(dt)

  if rafUtils.camera.shake then
    rafUtils.camera.time = rafUtils.camera.time + dt
    rafUtils.camera.x = rafUtils.camera.x + (rafUtils.camera.mag * math.sin(rafUtils.camera.time * 20 * 2))
    rafUtils.camera.y =  rafUtils.camera.y + (rafUtils.camera.mag * math.sin(rafUtils.camera.time * 20))
    if rafUtils.camera.time >= rafUtils.camera.shakeTime then
      rafUtils.camera.time = 0
      rafUtils.camera.shake = false
    end
  else
    rafUtils.camera.lookAt(hero.x,hero.y)
  end
  updateFog(8)
  updateTorch(dt)
  updateBomb(dt)
end

function love.draw()
  local startX = math.floor(rafUtils.camera.x / (BLOCKSIZE * PPM))
  local endX = startX + WTWIDTH
  local startY = math.floor(rafUtils.camera.y / (BLOCKSIZE * PPM))
  local endY = startY + WTHEIGHT
  startX = math.max(0,startX-1)
  endX = math.min(#terrain[0],endX+1)
  startY = math.max(0,startY-1)
  endY = math.min(#terrain,endY+1)
 --1 layer
  for yy=startY,endY do
    for xx=startX,endX do
      if fog[yy][xx] == 0 then
      --if true then
        if  TILES[terrain[yy][xx]] ~= nil then
          if terrain[yy][xx] ~= 225
          and terrain[yy][xx] ~= 241
          and terrain[yy][xx] ~= 112
          and terrain[yy][xx] ~= 242
          and terrain[yy][xx] ~= 122
          and terrain[yy][xx] ~= 203
          and terrain[yy][xx] ~= 201
          and terrain[yy][xx] ~= 233
          and terrain[yy][xx] ~= 240
          and terrain[yy][xx] ~= 217
          and terrain[yy][xx] ~= 120
          and terrain[yy][xx] ~= 195
          and terrain[yy][xx] ~= 193
          and terrain[yy][xx] ~= 249
          and terrain[yy][xx] ~= 243
          and terrain[yy][xx] ~= 253
          and terrain[yy][xx] ~= 251
          and terrain[yy][xx] ~= 247--
          and terrain[yy][xx] ~= 248
          and terrain[yy][xx] ~= 227 then
            love.graphics.draw(ATLAS,TILES[terrain[yy][xx]],xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,0,PPM,PPM)
          end
        end
      end
    end
  end
  
  drawTorch (startX, endX, startY, endY)
  drawChest (startX, endX, startY, endY)
  drawDeco (startX, endX, startY, endY)
  --testBomb
  drawBomb(startX, endX, startY, endY)
  --love.graphics.draw(bombAtlas,bombTiles[bombFrame],bomb.x*BLOCKSIZE*PPM - rafUtils.camera.x, bomb.y*BLOCKSIZE*PPM - rafUtils.camera.y,PPM*0.5,PPM*0.5)
  --hero
  hero:draw()
 
  --2layer + debug
  for yy=startY,endY do
    for xx=startX,endX do
      if fog[yy][xx] == 0 then
      --if true then
        if  TILES[terrain[yy][xx]] ~= nil then
          if terrain[yy][xx] == 225
          or terrain[yy][xx] == 241
          or terrain[yy][xx] == 242
          or terrain[yy][xx] == 112
          or terrain[yy][xx] == 122
          or terrain[yy][xx] == 203
          or terrain[yy][xx] == 201
          or terrain[yy][xx] == 233
          or terrain[yy][xx] == 240
          or terrain[yy][xx] == 217
          or terrain[yy][xx] == 120
          or terrain[yy][xx] == 248
          or terrain[yy][xx] == 195
          or terrain[yy][xx] == 193
          or terrain[yy][xx] == 249
          or terrain[yy][xx] == 243
          or terrain[yy][xx] == 251
          or terrain[yy][xx] == 247
          or terrain[yy][xx] == 253
          or terrain[yy][xx] == 227 then
            love.graphics.draw(ATLAS,TILES[terrain[yy][xx]],xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,0,PPM,PPM)
            --love.graphics.rectangle('line',xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,PPM*BLOCKSIZE,PPM*BLOCKSIZE)
          end
        end
      end
      if showTile then 
        love.graphics.setColor(1,0,1,1)
        
        love.graphics.print(terrain[yy][xx],xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y)
        if yy == playerY and xx == playerX then
          love.graphics.rectangle('fill',
          xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,
          BLOCKSIZE*PPM, BLOCKSIZE*PPM)
        end
        if yy == clickY and xx == clickX then
          love.graphics.setColor(0,1,0,1)
          love.graphics.rectangle('fill',
          xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,
          BLOCKSIZE*PPM, BLOCKSIZE*PPM)
          love.graphics.setColor(1,1,1,1)
        end
        love.graphics.setColor(1,1,1,1)
      end
    end
  end
  if debug then
    love.graphics.setColor(1,0,1,1)
    love.graphics.print(startIter,0,0)
    love.graphics.print(rafUtils.camera.x..' ; '..rafUtils.camera.y,0,15)
    love.graphics.print('startX: '..startX..' ;endX: '..endX,0,30)
    love.graphics.print('startY: '..startY..' ;endY; '..endY,0,45)
    love.graphics.print(love.timer.getFPS() ..'fps',0,60)
    love.graphics.print('scale: '..PPM,0,75)
    love.graphics.print('---------',0,90)
    love.graphics.print('hero.x: '..hero.x,0,105)
    love.graphics.print('hero.y: '..hero.y,0,120)
    love.graphics.setColor(1,1,1,1)
  end
  
end

function love.keypressed (key)
  if key == 'escape' then love.event.quit() end
  if key == 'd' then
    if debug then debug = false else debug = true end
  end
  if key == 'f' then
    if showFog then showFog = false else showFog = true end
  end
  if key == 't' then
    if showTile then showTile = false else showTile = true end
  end
  if key == 'return' then
    -- print(SEED)
    resetMap()
  end
  if key == 'b' then
    -- print(SEED)
    if hero.inventory.bombs < 1 then return end
    table.insert(bombs, {x=rafUtils.round(hero.x),y=rafUtils.round(hero.y), coolD=3,active = true})
    hero.inventory.bombs = hero.inventory.bombs - 1

  -- rien ne vas plus
--[[     for yy=0,#terrain do
      for xx=0,#terrain[yy] do
        if terrain[yy][xx] == 0 then
          table.insert(bombs, {x=xx,y=yy, coolD=3,active = true})
        end
      end
    end ]]
  end
  if key == "s" then 
    SEED = love.timer.getTime()
  end
  if key == "p" then 
    if tp == false then
      tp = true
    else
      tp = false
    end
  end
  if key == "m" then
    if mute then
      love.audio.setVolume(1)
      mute = false
    else
      love.audio.setVolume(0)
      mute = true
    end
  end
end

function love.wheelmoved(a,dir)
  if love.keyboard.isDown('lshift') then
    PPM = PPM + dir*0.1
    if PPM < 0.1 then PPM = 0.1 end
    WTWIDTH = SWIDTH/(BLOCKSIZE*PPM) -- number of blocks on screen along x
    WTHEIGHT = SHEIGHT/(BLOCKSIZE*PPM) -- number of blocks on screen along y
    rafUtils.camera.x = hero.x * PPM * BLOCKSIZE - WTWIDTH * 0.5 * PPM * BLOCKSIZE
    rafUtils.camera.y = hero.y * PPM * BLOCKSIZE - WTHEIGHT * 0.5 * PPM * BLOCKSIZE
  else
    startIter = startIter + dir
    if startIter < 1 then startIter = 1 end
  end
end

function love.mousepressed(x,y,btn)
  if tp then
    clickX = (x + rafUtils.camera.x) / BLOCKSIZE / PPM
    clickY = (y + rafUtils.camera.y) / BLOCKSIZE / PPM
    clickX = math.floor(clickX)
    clickY = math.floor(clickY)
  
    if fog[clickY][clickX] == 0 and terrain[clickY][clickX] == 0 then
      if tp then
        hero.x = clickX
        hero.y = clickY
        tp = false
      end
    end
  end
  -- print(clickX,clickY)
  -- print(playerX,playerY)
end

---------------------------------
function resetMap()
  nIter=startIter
  love.math.setRandomSeed(SEED)
  terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
  terrain = iterCellular(terrain)
  terrain = createWall(terrain)
  terrain = createWall2(terrain)
  createWall3(terrain)
  varyFloor(terrain)

  torchs = createTorchs(terrain,densTorch)
  decos = createDecos(terrain,densDeco)
  while torchs == false  or decos == false  do
    densTorch = densTorch - 1
    densDeco = densDeco - 1
    SEED = love.timer.getTime()    
    nIter=startIter
    love.math.setRandomSeed(SEED)
    terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
    terrain = iterCellular(terrain)
    terrain = createWall(terrain)
    terrain = createWall2(terrain)
    createWall3(terrain)
    varyFloor(terrain)
    torchs = createTorchs(terrain,densTorch)
    decos = createDecos(terrain,densDeco)
  end
  

  chests = createChest(terrain,densChest)

  local xx,yy=0,0
  local startFound = false
  while not startFound do
    yy = love.math.random(0,#terrain)
    xx = love.math.random(0,#terrain[yy])
    if terrain[yy][xx] <= 0 then
      playerX = xx
      playerY = yy
      startFound = true
    end
  end
  hero.x,hero.y = playerX,playerY
  hero.inventory = {bombs=99}
  rafUtils.camera.x = playerX*BLOCKSIZE*PPM
  rafUtils.camera.y = playerY*BLOCKSIZE*PPM
  fog = createFog(WORLDWIDTH,WORLDHEIGHT)
end

function createTorchs(terrain, dens)
  local freezeCount = 0
  local res = {}
   local it = WORLDWIDTH / 128
   for yyy = 0,it-1 do
    for xxx=0,it-1 do
      --print('it: '..(yyy*128)..' : '..(yyy+1)*128)
      local d = dens
      local torchPlacedX = {}
      while d > 0 do
        freezeCount = freezeCount + 1
        if freezeCount >= 900000 then
          print('yes')
          return false
        end
        local xtent = love.math.random(xxx*128,(xxx+1)*128)
        local ytent = love.math.random(yyy*128,(yyy+1)*128)
        ytent = rafUtils.clamp(ytent, 0,#terrain-2)
        xtent = rafUtils.clamp(xtent, 0,#terrain[ytent]-4)
        if terrain[ytent][xtent] == 31 and terrain[ytent][xtent+1] == 31 then
          local notFound = true
          for i=1,#torchPlacedX do
            if  rafUtils.distance(xtent,ytent,torchPlacedX[i].x,torchPlacedX[i].y) < 4 then
              notFound = false
            end
          end

          if notFound then
            table.insert( res, {x=xtent,y=ytent} )
            table.insert(torchPlacedX,{x=xtent,y=ytent})
            d = d -1
          end
        end
      end
    end
  end
  return res
end

function updateTorch(dt)
  torchTimer = torchTimer - dt
  if torchTimer <= 0 then
    torchFrame = (torchFrame + 1)%(#OBJTILES['torch']+1)
    torchTimer = torchFps
  end
end

function drawTorch (startX, endX, startY, endY)
  for i=1,#torchs do
    if torchs[i].x >= startX and torchs[i].x < endX and torchs[i].y > startY-3 and torchs[i].y < endY then
      if fog[torchs[i].y][torchs[i].x] == 0 and
      fog[torchs[i].y][torchs[i].x+1] == 0 and
      fog[torchs[i].y+1][torchs[i].x] == 0 and
      fog[torchs[i].y+1][torchs[i].x+1] == 0 and
      fog[torchs[i].y+2][torchs[i].x] == 0 and
      fog[torchs[i].y+2][torchs[i].x+1] == 0 then
        love.graphics.draw(ATLAS,OBJTILES['torch'][torchFrame],torchs[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,torchs[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,0,PPM,PPM)
        if debug then 
          love.graphics.setColor(1,0,1,1)
          love.graphics.rectangle('line',torchs[i].x * PPM * BLOCKSIZE - rafUtils.camera.x, torchs[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM *2,BLOCKSIZE*PPM*3)
          love.graphics.setColor(1,1,1,1)
        end
      end
    end 
  end
end

function createChest(terrain,dens)
  local freezeCount = 0
  local res = {}
   local it = WORLDWIDTH / 128
   for yyy = 0,it-1 do
    for xxx=0,it-1 do
      local d = dens
      local chestPlacedX = {}
      while d > 0 do
        freezeCount = freezeCount + 1
        if freezeCount >= 900000 then
          print('yesChest')
          SEED = love.timer.getTime()
          nIter=startIter
          love.math.setRandomSeed(SEED)
          terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
          terrain = iterCellular(terrain)
          terrain = createWall(terrain)
          terrain = createWall2(terrain)
          createWall3(terrain)
          varyFloor(terrain)
          torchs = createTorchs(terrain,densTorch)
          createChest(terrain,dens)
          return
        end
        local xtent = love.math.random(xxx*128,(xxx+1)*128)
        local ytent = love.math.random(yyy*128,(yyy+1)*128)
        ytent = rafUtils.clamp(ytent, 0,#terrain-1)
        xtent = rafUtils.clamp(xtent, 0,#terrain[ytent]-1)
        if terrain[ytent][xtent] == 0  then
          local notFound = true
          for i=1,#chestPlacedX do
            if  rafUtils.distance(xtent,ytent,chestPlacedX[i].x,chestPlacedX[i].y ) <= 10 then
              notFound = false
            end
          end
          if notFound then
            table.insert( res, {x=xtent,y=ytent, open=false,inside={'lol'},frame=0} )
            table.insert(chestPlacedX,{x=xtent,y=ytent})
            terrain[ytent][xtent] = 1
            d = d -1
          end
        end
      end
    end
  end
  return res
end

function drawChest (startX, endX, startY, endY)
  for i=1,#chests do
    if chests[i].x >= startX and chests[i].x < endX and chests[i].y > startY-1 and chests[i].y < endY then
      if fog[chests[i].y][chests[i].x] == 0 then
        love.graphics.draw(ATLAS,OBJTILES['chest'][chests[i].frame], chests[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,chests[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,0,PPM,PPM)
        if debug then
          love.graphics.setColor(1,0,1,1)
          love.graphics.rectangle('line',chests[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,chests[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM,BLOCKSIZE*PPM)
          love.graphics.setColor(1,1,1,1)
        end
      end
    end 
  end
end

function updateBomb(dt)
  bombTimer = bombTimer - dt
  if bombTimer <= 0 then
    bombFrame = (bombFrame + 1)%(#bombTiles+1)
    bombTimer = bombFps
  end
  for i=1,#bombs do
    bombs[i].coolD = bombs[i].coolD - dt
    if bombs[i].coolD <= 0 then
      dropBomb(bombs[i].x, bombs[i].y)
      --add particle, sound, shake
      bombs[i].active = false
    end
  end
  --clean
  for i=#bombs,1,-1 do
    if bombs[i].active == false then
      table.remove( bombs, i )
    end
  end
end

function drawBomb(startX, endX, startY, endY)
  for i=1,#bombs do
    if bombs[i].x >= startX and bombs[i].x < endX and bombs[i].y > startY-1 and bombs[i].y < endY then
      if fog[bombs[i].y][bombs[i].x] == 0 then
        love.graphics.draw(bombAtlas,bombTiles[bombFrame],bombs[i].x*BLOCKSIZE*PPM - rafUtils.camera.x, bombs[i].y*BLOCKSIZE*PPM - rafUtils.camera.y,0,PPM*0.5,PPM*0.5)
        if debug then
          love.graphics.setColor(1,0,1,1)
          love.graphics.rectangle('line',bombs[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,bombs[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM,BLOCKSIZE*PPM)
          love.graphics.setColor(1,1,1,1)
        end
      end
    end 
  end
end

function createDecos (terrain,dens)
  local freezeCount = 0
  local res = {}
   local it = WORLDWIDTH / 128
   for yyy = 0,it-1 do
    for xxx=0,it-1 do
      local d = dens
      local decoPlacedX = {}
      while d > 0 do
        freezeCount = freezeCount + 1
        if freezeCount >= 900000 then
          print('yesDecos')
          return false
        end
        local xtent = love.math.random(xxx*128,(xxx+1)*128)
        local ytent = love.math.random(yyy*128,(yyy+1)*128)
        ytent = rafUtils.clamp(ytent, 0,#terrain-1)
        xtent = rafUtils.clamp(xtent, 0,#terrain[ytent]-4)
        if terrain[ytent][xtent] == 31  then
          local notFound = true
          for i=1,#decoPlacedX do
            if  rafUtils.distance(xtent,ytent,decoPlacedX[i].x,decoPlacedX[i].y) < 1 then
              notFound = false
            end
          end
          if torchs ~= false then
            for i=1,#torchs do
              if  rafUtils.distance(xtent,ytent,torchs[i].x,torchs[i].y) < 3 then
                notFound = false
              end
            end
          end
          if notFound then
            table.insert( res, {x=xtent,y=ytent,type=love.math.random(0,3)} )
            table.insert(decoPlacedX,{x=xtent,y=ytent})
            d = d -1
          end
        end
      end
    end
  end
  return res
end

function drawDeco(startX, endX, startY, endY)
  if #decos<=0 then return end
  for i=1,#decos do
    if decos[i].x >= startX and decos[i].x < endX and decos[i].y > startY-1 and decos[i].y < endY then
      if fog[decos[i].y][decos[i].x] == 0 then
        love.graphics.draw(ATLAS,OBJTILES.deco[decos[i].type],decos[i].x*BLOCKSIZE*PPM - rafUtils.camera.x, decos[i].y*BLOCKSIZE*PPM - rafUtils.camera.y,0,PPM,PPM)
        if debug then
          love.graphics.setColor(1,0,1,1)
          love.graphics.rectangle('line',decos[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,decos[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM,BLOCKSIZE*PPM*3)
          love.graphics.setColor(1,1,1,1)
        end
      end
    end 
  end
end

function createFog (width,height)
  local fog = {}

  for yy=0,height-1 do
    fog[yy] = {}
    for xx=0,width-1 do

    fog[yy][xx] = showFog and 1 or 0
    end
  end
  return fog
end

function updateFog(dist)
  local startX = rafUtils.round(hero.x - dist)
  local endX = rafUtils.round(hero.x + dist)
  local startY = rafUtils.round(hero.y - dist)
  local endY = rafUtils.round(hero.y + dist)

  startY = rafUtils.clamp(startY,0,#fog)
  startX = rafUtils.clamp(startX,0,#fog[startY])
  endY = rafUtils.clamp(endY,0,#fog)
  endX = rafUtils.clamp(endX,0,#fog)

  for yy = startY,endY do
    for xx = startX,endX do
      fog[yy][xx] = 0
    end
  end
end

function createRandTerrain (width, height)
  local terrain,xx,yy = {},0,0
  for yy=0,height-1 do
    terrain[yy] = {}
    for xx=0,width-1 do
      terrain[yy][xx] = love.math.random() < rRockCells and 1 or 0
    end
  end
  return terrain
end

function iterCellular(terrain)
  local tmp = {}

  for yy=0,#terrain do
    tmp[yy] = {}
    for xx=0,#terrain[yy] do
      local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
      local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
      local u = terrain[(yy-1)%(#terrain+1)]  [xx]
      local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
      local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
      local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
      local d = terrain[(yy+1)%(#terrain+1)]  [xx]
      local ld = terrain[(yy+1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
      -- local neighBorSum = l+lu+u+ru+r+rd+d
      local neighBorSum = 0
      if l <= 0 then neighBorSum = neighBorSum + 1 end
      if lu <= 0 then neighBorSum = neighBorSum + 1 end
      if u <= 0 then neighBorSum = neighBorSum + 1 end
      if ru <= 0 then neighBorSum = neighBorSum + 1 end
      if r <= 0 then neighBorSum = neighBorSum + 1 end
      if rd <= 0 then neighBorSum = neighBorSum + 1 end
      if d <= 0 then neighBorSum = neighBorSum + 1 end
      if ld <= 0 then neighBorSum = neighBorSum + 1 end
      -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
      if neighBorSum >= neighBorHoodThres then tmp[yy][xx]=1 else tmp[yy][xx]=0 end
    end
  end

  nIter = nIter - 1

  if nIter == 0 then return tmp else return iterCellular(tmp) end
end
function createWall(terrain)
  local tmp = {}
  for yy=0,#terrain do
    tmp[yy] = {}
    for xx=0,#terrain[yy] do
      if terrain[yy][xx] == 0 then
        local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
        local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        local u = terrain[(yy-1)%(#terrain+1)]  [xx]
        local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
        local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local d = terrain[(yy+1)%(#terrain+1)]  [xx]
        local ld = terrain[(yy+1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        -- local neighBorSum = l+lu+u+ru+r+rd+d
        local neighBorSum = 0
        if l == 1 then neighBorSum = neighBorSum + 1 end
        if lu == 1 then neighBorSum = neighBorSum + 1 end
        if u == 1 then neighBorSum = neighBorSum + 1 end
        if ru == 1 then neighBorSum = neighBorSum + 1 end
        if r == 1 then neighBorSum = neighBorSum + 1 end
        if rd == 1 then neighBorSum = neighBorSum + 1 end
        if d == 1 then neighBorSum = neighBorSum + 1 end
        if ld == 1 then neighBorSum = neighBorSum + 1 end
        -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
        if neighBorSum >= 1 then tmp[yy][xx]=2 else tmp[yy][xx] = terrain[yy][xx] end
      else tmp[yy][xx] = terrain[yy][xx]
      end
    end
  end
  return tmp
end
function createWall2(terrain)
  local tmp = {}
  for yy=0,#terrain do
    tmp[yy] = {}
    for xx=0,#terrain[yy] do
      if terrain[yy][xx] == 2 then
        local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
        local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        local u = terrain[(yy-1)%(#terrain+1)]  [xx]
        local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
        local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local d = terrain[(yy+1)%(#terrain+1)]  [xx]
        local ld = terrain[(yy+1)%(#terrain+1)]  [(xx-1)%(#terrain[yy]+1)]
        -- local neighBorSum = l+lu+u+ru+r+rd+d
        local neighBorSum = 0
        if l == 1 or l == 2 then neighBorSum = neighBorSum + 1 end
        if lu == 1 or lu == 2 then neighBorSum = neighBorSum + 2 end
        if u == 1 or u == 2 then neighBorSum = neighBorSum + 4 end
        if ru == 1 or ru == 2 then neighBorSum = neighBorSum + 8 end
        if r == 1 or r == 2 then neighBorSum = neighBorSum + 16 end
        if rd == 1 or rd == 2 then neighBorSum = neighBorSum + 32 end
        if d == 1 or d == 2 then neighBorSum = neighBorSum + 64 end
        if ld == 1 or ld == 2 then neighBorSum = neighBorSum + 128 end

        --print(neighBorSum)
        -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
        if neighBorSum >= 1 then tmp[yy][xx]=neighBorSum else tmp[yy][xx] = terrain[yy][xx] end
      else tmp[yy][xx] = terrain[yy][xx]
      end
    end
  end
  return tmp
end
function varyFloor(terrain)
  for yy=0,#terrain do
    for xx=0,#terrain[yy] do
      if terrain[yy][xx] == 0 then
        local rand = love.math.random()
        if rand < 0.005 then  
          terrain[yy][xx]=-1
        elseif rand < 0.01 then
          terrain[yy][xx]=-2
        else
          terrain[yy][xx]=0
        end
      end
    end
  end
  return terrain
end
function createWall3(terrain)
  for yy=0,#terrain do
    for xx=0,#terrain[yy] do
      if  terrain[yy][xx] == 31 or
          terrain[yy][xx] == 191 or
          terrain[yy][xx] == 39 or--
          terrain[yy][xx] == 175 or--
          terrain[yy][xx] == 167 or--
          terrain[yy][xx] == 158 or--
          terrain[yy][xx] == 156 or--
          terrain[yy][xx] == 188 or--
          terrain[yy][xx] == 63 or
          terrain[yy][xx] == 159 or
          terrain[yy][xx] == 135 or
          terrain[yy][xx] == 15 or
          terrain[yy][xx] == 7 or
          terrain[yy][xx] == 143 or
          terrain[yy][xx] == 28 or
          terrain[yy][xx] == 60 or
          terrain[yy][xx] == 30 or
          terrain[yy][xx] == 62 then
          if yy <= #terrain -2 then
            if terrain [yy+1][xx] <= 0 then
              terrain[yy+1][xx] = 256
            end
            if terrain [yy+2][xx] <= 0 then
              terrain[yy+2][xx] = 257
            end
          elseif yy <= #terrain -1 then 
            if terrain [yy+1][xx] <= 0 then
              terrain[yy+1][xx] = 256
            end
          end
      end
    end
  end
  return terrain
end
function dropBomb(x,y)
  local dist = 2
  local startX = (x - dist-2)
  local endX = (x + dist+1)
  local startY = (y - dist-2)
  local endY = (y + dist+1)
  local destChest = {}
  
  startY = rafUtils.clamp(startY,0,#terrain)
  startX = rafUtils.clamp(startX,0,#terrain[startY])
  endY = rafUtils.clamp(endY,0,#terrain)
  endX = rafUtils.clamp(endX,0,#terrain[endY])
  
  for yy = startY,endY do
    for xx = startX,endX do

      if terrain[yy][xx] > 0 then
        terrain [yy][xx] = 0
      end

      for i=#torchs,1,-1 do
         if rafUtils.isCollideRec(xx,yy,1,1,torchs[i].x,torchs[i].y,2,0.2) then
          -- if terrain[torchs[i].y][torchs[i].x] ~= 31 or
          -- terrain[torchs[i].y][torchs[i].x+1] ~= 31 or
          -- terrain[torchs[i].y+1][torchs[i].x] ~= 256 or
          -- terrain[torchs[i].y+1][torchs[i].x+1] ~= 256 or
          -- terrain[torchs[i].y+2][torchs[i].x] ~= 257 or
          -- terrain[torchs[i].y+2][torchs[i].x+1] ~= 257 then
          table.remove(torchs, i)
        end
      end
      for i=#decos,1,-1 do
         if rafUtils.isCollideRec(xx,yy,1,1,decos[i].x,decos[i].y,1,0.2) then
          -- if terrain[decos[i].y][decos[i].x] ~= 31 or
          -- terrain[decos[i].y+1][decos[i].x] ~= 256 or
          -- terrain[decos[i].y+2][decos[i].x] ~= 257 then
          table.remove(decos, i)
        end
      end
    end
  end

  
  -- for yy=rafUtils.clamp(startY-2,0,#terrain),rafUtils.clamp(endY+2,0,#terrain) do
  --   for xx=rafUtils.clamp(startX-2,0,#terrain[startY]),rafUtils.clamp(endX+2,0,#terrain[endY]) do
  --     if terrain[yy][xx] == 256 or terrain[yy][xx] == 257 then
  --       --print('walll')
  --       terrain[yy][xx] = 0
  --     end
  --   end
  -- end

  
  
  startY = rafUtils.clamp(startY-3,0,#terrain)
  startX = rafUtils.clamp(startX-3,0,#terrain[startY])
  endY = rafUtils.clamp(endY+3,0,#terrain)
  endX = rafUtils.clamp(endX+3,0,#terrain[endY])

  local tmp = {}
  for yy=startY,endY do
    tmp[yy] = {}
    for xx=startX,endX do
      for i=1,#chests do
        if chests[i].x == xx and chests[i].y == yy then
          terrain[yy][xx] = 0
          table.insert(destChest,{x=xx;y=yy})
        end
      end
      if terrain[yy][xx] == 0 then
        local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
        local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        local u = terrain[(yy-1)%(#terrain+1)]  [xx]
        local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
        local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local d = terrain[(yy+1)%(#terrain+1)]  [xx]
        local ld = terrain[(yy+1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        -- local neighBorSum = l+lu+u+ru+r+rd+d
        local neighBorSum = 0
        if l == 1 then neighBorSum = neighBorSum + 1 end
        if lu == 1 then neighBorSum = neighBorSum + 1 end
        if u == 1 then neighBorSum = neighBorSum + 1 end
        if ru == 1 then neighBorSum = neighBorSum + 1 end
        if r == 1 then neighBorSum = neighBorSum + 1 end
        if rd == 1 then neighBorSum = neighBorSum + 1 end
        if d == 1 then neighBorSum = neighBorSum + 1 end
        if ld == 1 then neighBorSum = neighBorSum + 1 end
        -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
        if neighBorSum >= 1 then tmp[yy][xx]=2 else tmp[yy][xx] = terrain[yy][xx] end
      else tmp[yy][xx] = terrain[yy][xx]
      end
    end
  end
  
  for yy=startY,endY do
    for xx=startX,endX do
      terrain[yy][xx]=tmp[yy][xx]
    end
  end
  
  tmp = {}
  for yy=startY,endY do
    tmp[yy] = {}
    for xx=startX,endX do
      if terrain[yy][xx] == 2 then
        local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
        local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        local u = terrain[(yy-1)%(#terrain+1)]  [xx]
        local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
        local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local d = terrain[(yy+1)%(#terrain+1)]  [xx]
        local ld = terrain[(yy+1)%(#terrain+1)]  [(xx-1)%(#terrain[yy]+1)]
        -- local neighBorSum = l+lu+u+ru+r+rd+d
        local neighBorSum = 0
        if l >= 1 or l == 2 then neighBorSum = neighBorSum + 1 end
        if lu >= 1 or lu == 2 then neighBorSum = neighBorSum + 2 end
        if u >= 1 or u == 2 then neighBorSum = neighBorSum + 4 end
        if ru >= 1 or ru == 2 then neighBorSum = neighBorSum + 8 end
        if r >= 1 or r == 2 then neighBorSum = neighBorSum + 16 end
        if rd >= 1 or rd == 2 then neighBorSum = neighBorSum + 32 end
        if d >= 1 or d == 2 then neighBorSum = neighBorSum + 64 end
        if ld >= 1 or ld == 2 then neighBorSum = neighBorSum + 128 end

        --print(neighBorSum)
        -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
        if neighBorSum >= 1 then tmp[yy][xx]=neighBorSum else tmp[yy][xx] = terrain[yy][xx] end
      else tmp[yy][xx] = terrain[yy][xx]
      end
    end
  end

  for yy=startY,endY do
    for xx=startX,endX do
      terrain[yy][xx]=tmp[yy][xx]
    end
  end


  for yy=startY,endY do
    for xx=startX,endX do
      if  terrain[yy][xx] == 31 or
          terrain[yy][xx] == 191 or
          terrain[yy][xx] == 39 or--
          terrain[yy][xx] == 175 or--
          terrain[yy][xx] == 167 or--
          terrain[yy][xx] == 158 or--
          terrain[yy][xx] == 156 or--
          terrain[yy][xx] == 188 or--
          terrain[yy][xx] == 63 or
          terrain[yy][xx] == 159 or
          terrain[yy][xx] == 135 or
          terrain[yy][xx] == 15 or
          terrain[yy][xx] == 7 or
          terrain[yy][xx] == 143 or
          terrain[yy][xx] == 28 or
          terrain[yy][xx] == 60 or
          terrain[yy][xx] == 30 or
          terrain[yy][xx] == 62 then
        if yy <= #terrain -2 then
          if terrain [yy+1][xx] <= 0 then
            terrain[yy+1][xx] = 256
          end
          if terrain [yy+2][xx] <= 0 then
            terrain[yy+2][xx] = 257
          end
        elseif yy <= #terrain -1 then 
          if terrain [yy+1][xx] <= 0 then
            terrain[yy+1][xx] = 256
          end
        end
      end
    end
  end

  for i=#torchs,1,-1 do
    if terrain[torchs[i].y][torchs[i].x] ~= 31 or
    terrain[torchs[i].y][torchs[i].x+1] ~= 31 or
    terrain[torchs[i].y+1][torchs[i].x] ~= 256 or
    terrain[torchs[i].y+1][torchs[i].x+1] ~= 256 or
    terrain[torchs[i].y+2][torchs[i].x] ~= 257 or
    terrain[torchs[i].y+2][torchs[i].x+1] ~= 257 then
      table.remove(torchs, i)
    end
  end
  for i=#decos,1,-1 do
    if terrain[decos[i].y][decos[i].x] ~= 31 or
    terrain[decos[i].y+1][decos[i].x] ~= 256 or 
    terrain[decos[i].y+2][decos[i].x] ~= 256 then
      table.remove(decos, i)
    end
  end

  for i=1,#destChest do
    terrain[destChest[i].y][destChest[i].x] = 1
  end

  rafUtils.camera.shake = true
  

end