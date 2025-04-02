 local g3d = require "lib/g3d"
 
 love.graphics.setDefaultFilter("nearest", "nearest")

-- .obj model
 local ground = g3d.newModel("assets/cube.obj", "assets/desert.png", {10,5,-7}, {0,0,0}, {100,100,0.1})

-- json model ( minecraft block ) 
 local sayMyname = g3d.newModel("assets/sayMyname.json", "assets/tt.png", {5,5,-9}, {math.pi/2,0,0}, {2,2,2})

  -- Player position
  local x, y, z = 0, 0, 0
  -- Player model
  local PlayerModel = g3d.newModel("assets/sphere.obj", "assets/player.png", {0,0,0}, {0,0,0}, {7,7,7})
  

  -- Rotation and position 
  PlayerModel:setTranslation(x, y, z)  
  PlayerModel:setRotation(0, 0, 0)

-- Movment
  local moveSpeed = 1
  local cameraDistance = 30
  local cameraHeight = 0
  local cameraAngleX = 0 
  local cameraAngleY = 0
  
  -- Mouse Sensitivity
  local mouseSensitivity = 1/300

-- Key bindings
  w = {"w", 'up'}
  s = {"s", 'down'}
  d = {"d", 'right'}
  a = {"a", 'left'}

-- Mouse movment 
function love.mousemoved(x, y, dx, dy)
    -- Adjust camera rotation based on mouse movement
    cameraAngleX = cameraAngleX + dx * mouseSensitivity
    cameraAngleY = cameraAngleY + dy * mouseSensitivity
    
    -- Limit the vertical camera rotation to prevent flipping
    cameraAngleY = math.max(-math.pi/2 + 0.1, math.min(math.pi/2 - 0.1, cameraAngleY))
end

function love.load()
  -- lock the mouse 
  love.mouse.setRelativeMode(true)
  
  end

function love.update(dt)
  dt = math.min(dt, 1/60) -- Cap fps

  -- Movement input
  local moveX = 0
  local moveY = 0

  if love.keyboard.isDown(d) then moveY = moveY - 1 end
  if love.keyboard.isDown(a) then moveY = moveY + 1 end
  if love.keyboard.isDown(s) then moveX = moveX - 1 end
  if love.keyboard.isDown(w) then moveX = moveX + 1 end

  -- Normalize diagonal movement
    local length = math.sqrt(moveX * moveX + moveY * moveY)
    if length > 0 then
        moveX = moveX / length
        moveY = moveY / length
    end

    -- Calculate movement vectors based on camera orientation
    local moveForwardX = -math.sin(cameraAngleX)
    local moveForwardY = -math.cos(cameraAngleX)
    local moveRightX = math.cos(cameraAngleX)
    local moveRightY = -math.sin(cameraAngleX)
    
    -- Apply movement with delta time
    local frameSpeed = moveSpeed * dt * 60 
    x = x + (moveForwardX * moveX + moveRightX * moveY) * frameSpeed
    y = y + (moveForwardY * moveX + moveRightY * moveY) * frameSpeed
    
    -- Update player model
    PlayerModel:setTranslation(x, y, z)
    
    -- Calculate camera position (g3d doesn't use dt for camera)
    local camX = x + math.sin(cameraAngleX) * math.cos(cameraAngleY) * cameraDistance
    local camY = y + math.cos(cameraAngleX) * math.cos(cameraAngleY) * cameraDistance
    local camZ = z + math.sin(cameraAngleY) * cameraDistance + cameraHeight

   -- camera for the player 
    g3d.camera.lookAt(camX, camY, camZ, x, y, z + 5)
    
    -- Quit game
    if love.keyboard.isDown("escape") then love.event.quit() end
end

function love.draw()
 -- draw 3d models
  PlayerModel:draw() 
  sayMyname:draw()
  
  love.graphics.print("Pos: "..math.floor(x)..", "..math.floor(y), 10, 30)
  love.graphics.print(love.timer.getFPS(), 10, 10)
 end
