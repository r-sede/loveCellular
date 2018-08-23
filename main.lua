PPM = 4 -- scale
BLOCKSIZE = 8
local SWIDTH = 1024--640--*2 -- screen width in pixels
local SHEIGHT = 768--576--*2 -- screen height in pixels
WTWIDTH = SWIDTH/(BLOCKSIZE*PPM) -- number of blocks on screen along x
WTHEIGHT = SHEIGHT/(BLOCKSIZE*PPM) -- number of blocks on screen along y
WORLDWIDTH = 256*2 -- width of world in block
WORLDHEIGHT = 256*2 -- height of world in block
local TILES = {}
local ATLAS = nil
local SEED = nil

rafUtils = require"rafUtils"
local rRockCells = 0.48
local nIter =11
local startIter = 11
local neighBorHoodThres = 5
 terrain = nil
local fog = nil
local debug = true
local playerX,playerY = nil,nil

local torchTimer = 1/4
local torchFps = 1/4
local torchFrame = 0
local densTorch = 28
local torchs = nil

local chests = nil
local densChest = 4

local OBJTILES = {}


function love.load(arg)
  love.graphics.setDefaultFilter('nearest')
  love.keyboard.setKeyRepeat(true)
  love.window.setMode(SWIDTH, SHEIGHT)
  love.window.setTitle('loveCellular')
  love.graphics.setBackgroundColor(32/255,70/255,50/255,1)
  
  SEED = love.timer.getTime()
  love.math.setRandomSeed(SEED)
  require'hero'
  resetMap()

  ATLAS = love.graphics.newImage('assets/img/CB-All_Temple.png')
  TILES[0] = love.graphics.newQuad(2*8, 3*8, 8, 8, ATLAS:getDimensions())
  TILES[-1] = love.graphics.newQuad(3*8, 3*8, 8, 8, ATLAS:getDimensions())
  TILES[-2] = love.graphics.newQuad(2*8, 2*8, 8, 8, ATLAS:getDimensions())
  
  ----------------------------------------------
  TILES[31] = love.graphics.newQuad(13*8, 6*8, 8, 8, ATLAS:getDimensions())
  TILES[191] = TILES[31]
  TILES[63] = TILES[31]
  TILES[159] = TILES[31]
  
  TILES[28] = love.graphics.newQuad(16*8, 8*8, 8, 8, ATLAS:getDimensions())
  TILES[60] = TILES[28]
  TILES[30] = TILES[28]
  TILES[62] = TILES[28]
  TILES[188] = TILES[28]
  TILES[156] = TILES[28]
  
  TILES[15] = love.graphics.newQuad(12*8, 8*8, 8, 8, ATLAS:getDimensions())
  TILES[135] = TILES[15]
  TILES[7] = TILES[15]
  TILES[183] = TILES[15]
  TILES[143] = TILES[15]
  TILES[167] = TILES[15]

  TILES[127] = love.graphics.newQuad(16*8, 6*8, 8, 8, ATLAS:getDimensions())

  TILES[223] = love.graphics.newQuad(12*8, 6*8, 8, 8, ATLAS:getDimensions())

  TILES[199] = love.graphics.newQuad(12*8, 7*8, 8, 8, ATLAS:getDimensions())
  TILES[207] = TILES[199]
  TILES[239] = TILES[199]
  TILES[231] = TILES[199]
  
  TILES[193] = love.graphics.newQuad(13*8, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[225] = TILES[193]
  TILES[227] = TILES[193]
  TILES[195] = TILES[193]
  TILES[203] = TILES[193]
  TILES[201] = TILES[193]
  TILES[217] = TILES[193]
  TILES[233] = TILES[193]

  TILES[247] = love.graphics.newQuad(11*8, 10*8, 8, 8, ATLAS:getDimensions())
  --------------------------------------------------
  
  TILES[241] = love.graphics.newQuad(16*8, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[249] = TILES[241]
  TILES[251] = TILES[241]
  TILES[243] = TILES[241]
  TILES[251] = TILES[241]

  TILES[253] = love.graphics.newQuad(17*8, 10*8, 8, 8, ATLAS:getDimensions())
  
  TILES[248] = love.graphics.newQuad(15*8, 10*8, 8, 8, ATLAS:getDimensions())
  TILES[240] = TILES[248]
  TILES[120] = TILES[248]
  TILES[112] = TILES[248]
  TILES[122] = TILES[248]
  
  TILES[124] = love.graphics.newQuad(16*8, 7*8, 8, 8, ATLAS:getDimensions())
  TILES[126] = TILES[124]
  TILES[252] = TILES[124]
  TILES[254] = TILES[124]

  -----------------------------------
  TILES[256] = love.graphics.newQuad(14*8,7*8,8,8,ATLAS:getDimensions())
  TILES[257] = love.graphics.newQuad(14*8,8*8,8,8,ATLAS:getDimensions())

  ---------------OBJECT------------
  OBJTILES['torch'] = {}
  OBJTILES['torch'][0] = love.graphics.newQuad(18*8,14*8,16,24,ATLAS:getDimensions())
  OBJTILES['torch'][1] = love.graphics.newQuad(20*8,14*8,16,24,ATLAS:getDimensions())

  OBJTILES['chest'] = {}
  OBJTILES['chest'][0] = love.graphics.newQuad(6*8, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][1] = love.graphics.newQuad(7*8, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][2] = love.graphics.newQuad(8*8, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][3] = love.graphics.newQuad(9*8, 17*8,8,8,ATLAS:getDimensions())
  OBJTILES['chest'][4] = love.graphics.newQuad(10*8, 17*8,8,8,ATLAS:getDimensions())
end

function love.update(dt)
  hero:update(dt)
  rafUtils.camera.lookAt(hero.x,hero.y)
  updateFog(9)
  updateTorch(dt)
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
          and terrain[yy][xx] ~= 251
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
          or terrain[yy][xx] == 227 then
            love.graphics.draw(ATLAS,TILES[terrain[yy][xx]],xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,0,PPM,PPM)
            --love.graphics.rectangle('line',xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,PPM*BLOCKSIZE,PPM*BLOCKSIZE)
          end
        end
      end
      if debug then 
        love.graphics.setColor(1,0,1,1)
        
        love.graphics.print(terrain[yy][xx],xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y)
        if yy == playerY and xx == playerX then
          love.graphics.rectangle('fill',
          xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,
          BLOCKSIZE*PPM, BLOCKSIZE*PPM)
        end
        love.graphics.setColor(1,1,1,1)
      end
    end
  end
  if true then
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
  if key == 'return' then
    -- print(SEED)
    resetMap()
  end
  if key == "s" then 
    SEED = love.timer.getTime()
  end
end

function love.wheelmoved(a,dir)
  if love.keyboard.isDown('lshift') then
    PPM = PPM + dir*0.1
    if PPM < 0.1 then PPM = 0.1 end
    WTWIDTH = SWIDTH/(BLOCKSIZE*PPM) -- number of blocks on screen along x
    WTHEIGHT = SHEIGHT/(BLOCKSIZE*PPM) -- number of blocks on screen along y
  else
    startIter = startIter + dir
    if startIter < 1 then startIter = 1 end
  end
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
  fog = createFog(WORLDWIDTH,WORLDHEIGHT)
end

function createTorchs(terrain, dens)
  local freezeCount = 0
  local res = {}
   local it = WORLDWIDTH / 128
   for yyy = 0,it-1 do
    for xxx=0,it-1 do
      local d = dens
      local torchPlacedX = {}
      while d > 0 do
        freezeCount = freezeCount + 1
        if freezeCount >= 900000 then
          print('yes')
          SEED = love.timer.getTime()
          --torchs = {}
          nIter=startIter
          love.math.setRandomSeed(SEED)
          terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
          terrain = iterCellular(terrain)
          terrain = createWall(terrain)
          terrain = createWall2(terrain)
          createWall3(terrain)
          varyFloor(terrain)
          d= 0
          return createTorchs(terrain,dens)
        end
        local xtent = love.math.random(xxx*128,(xxx+1)*128)
        local ytent = love.math.random(yyy*128,(yyy+1)*128)
        ytent = rafUtils.clamp(ytent, 0,#terrain-2)
        xtent = rafUtils.clamp(xtent, 0,#terrain[ytent]-4)
        if terrain[ytent][xtent] == 31 and terrain[ytent][xtent+1] == 31 then
          local notFound = true
          for i=1,#torchPlacedX do
            if  rafUtils.distance(xtent,ytent,torchPlacedX[i].x,torchPlacedX[i].y) < 3 then
              notFound = false
            end
          end
      --[[print()
          print(xtent)
          print(ytent)
          print() ]]
          if notFound then
            table.insert( res, {x=xtent,y=ytent} )
            --print(xtent)
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
        --love.graphics.rectangle('line',torchs[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,torchs[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM *2,BLOCKSIZE*PPM*3)
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
          --torchs = {}
          nIter=startIter
          love.math.setRandomSeed(SEED)
          terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
          terrain = iterCellular(terrain)
          terrain = createWall(terrain)
          terrain = createWall2(terrain)
          createWall3(terrain)
          varyFloor(terrain)
          torchs = createTorchs(terrain,densTorch)
          d=0
          return createChest(terrain,dens)
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
      --[[print()
          print(xtent)
          print(ytent)
          print() ]]
          if notFound then
            table.insert( res, {x=xtent,y=ytent,open=false,inside={'lol'},frame=4} )
            --print(xtent)
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
    if chests[i].x >= startX and chests[i].x < endX and chests[i].y > startY-3 and chests[i].y < endY then
      if fog[chests[i].y][chests[i].x] == 0 then
        love.graphics.draw(ATLAS,OBJTILES['chest'][chests[i].frame],chests[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,chests[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,0,PPM,PPM)
        --love.graphics.rectangle('line',torchs[i].x * PPM * BLOCKSIZE - rafUtils.camera.x,torchs[i].y * PPM * BLOCKSIZE - rafUtils.camera.y,BLOCKSIZE* PPM *2,BLOCKSIZE*PPM*3)
      end
    end 
  end
end

function createFog (width,height)
  local fog = {}

  for yy=0,height-1 do
    fog[yy] = {}
    for xx=0,width-1 do
    fog[yy][xx] = 1
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
          terrain[yy+1][xx] = 256
          terrain[yy+2][xx] = 257
        elseif yy <= #terrain -1 then 
          terrain[yy+1][xx] = 256
        end
      else
      end
    end
  end
  return terrain
end
