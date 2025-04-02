-- written by SnakeLab for g3dPlus
-- MIT license

local json = require("lib/json")
local vectors = require(g3d.path .. ".vectors")
local vectorRotate = vectors.rotate

-- Helper function to apply rotation to a point
local function rotatePoint(x, y, z, angle, axis, origin)
    if angle == 0 then return x, y, z end
    
    -- Translate to origin
    x = x - origin[1]
    y = y - origin[2]
    z = z - origin[3]
    
    -- Rotate
    if axis == "x" then
        y, z = vectorRotate(y, z, angle)
    elseif axis == "y" then
        x, z = vectorRotate(x, z, angle)
    elseif axis == "z" then
        x, y = vectorRotate(x, y, angle)
    end
    
    -- Translate back
    return x + origin[1], y + origin[2], z + origin[3]
end

-- Calculate UV coordinates based on face direction and UV data
local function calculateUVs(faceData, faceDir, textureWidth, textureHeight)
    -- Blockbench UV format: [u1, v1, u2, v2] in texture pixels
    local u1, v1, u2, v2 = faceData.uv[1], faceData.uv[2], faceData.uv[3], faceData.uv[4]
    
    -- Convert to normalized coordinates (0-1)
    u1, u2 = u1/textureWidth, u2/textureWidth
    v1, v2 = v1/textureHeight, v2/textureHeight
    
    -- Determine UV mapping based on face direction
    local uvs = {}
    if faceDir == "north" or faceDir == "up" then
        uvs = {
            {u1, v2},  -- bottom-left
            {u2, v2},  -- bottom-right
            {u2, v1},  -- top-right
            {u1, v1}   -- top-left
        }
    elseif faceDir == "south" or faceDir == "down" then
        uvs = {
            {u2, v2},  -- bottom-right
            {u2, v1},  -- top-right
            {u1, v1},  -- top-left
            {u1, v2}   -- bottom-left
        }
    elseif faceDir == "east" then
        uvs = {
            {u1, v2},  -- bottom-left
            {u2, v2},  -- bottom-right
            {u2, v1},  -- top-right
            {u1, v1}   -- top-left
        }
    elseif faceDir == "west" then
        uvs = {
            {u2, v2},  -- bottom-right
            {u2, v1},  -- top-right
            {u1, v1},  -- top-left
            {u1, v2}   -- bottom-left
        }
    end
    
    -- Apply UV rotation if specified
    if faceData.rotation then
        local rotation = faceData.rotation
        if rotation == 90 then
            for _, uv in ipairs(uvs) do
                uv[1], uv[2] = 1 - uv[2], uv[1]
            end
        elseif rotation == 180 then
            for _, uv in ipairs(uvs) do
                uv[1], uv[2] = 1 - uv[1], 1 - uv[2]
            end
        elseif rotation == 270 then
            for _, uv in ipairs(uvs) do
                uv[1], uv[2] = uv[2], 1 - uv[1]
            end
        end
    end
    
    return uvs
end

-- Create vertices for a face with proper UV mapping
local function createFaceVertices(from, to, faceData, faceDir, element, textureWidth, textureHeight)
    local x1, y1, z1 = from[1], from[2], from[3]
    local x2, y2, z2 = to[1], to[2], to[3]
    
    -- Apply element rotation if it exists
    if element.rotation then
        x1, y1, z1 = rotatePoint(x1, y1, z1, element.rotation.angle, element.rotation.axis, element.rotation.origin)
        x2, y2, z2 = rotatePoint(x2, y2, z2, element.rotation.angle, element.rotation.axis, element.rotation.origin)
    end
    
    -- Calculate normal vector
    local nx, ny, nz = 0, 0, 0
    if faceDir == "north" then nx, ny, nz = 0, 0, 1
    elseif faceDir == "south" then nx, ny, nz = 0, 0, -1
    elseif faceDir == "east" then nx, ny, nz = 1, 0, 0
    elseif faceDir == "west" then nx, ny, nz = -1, 0, 0
    elseif faceDir == "up" then nx, ny, nz = 0, 1, 0
    elseif faceDir == "down" then nx, ny, nz = 0, -1, 0
    end
    
    -- Get pre-calculated UVs
    local uvs = calculateUVs(faceData, faceDir, textureWidth, textureHeight)
    
    -- Create vertices based on face direction
    local vertices = {}
    if faceDir == "north" then
        vertices = {
            {x1, y1, z2, uvs[1][1], uvs[1][2], nx, ny, nz}, -- bottom-left
            {x2, y1, z2, uvs[2][1], uvs[2][2], nx, ny, nz}, -- bottom-right
            {x2, y2, z2, uvs[3][1], uvs[3][2], nx, ny, nz}, -- top-right
            {x1, y2, z2, uvs[4][1], uvs[4][2], nx, ny, nz}  -- top-left
        }
    elseif faceDir == "south" then
        vertices = {
            {x1, y1, z1, uvs[1][1], uvs[1][2], nx, ny, nz}, -- bottom-right
            {x1, y2, z1, uvs[2][1], uvs[2][2], nx, ny, nz}, -- top-right
            {x2, y2, z1, uvs[3][1], uvs[3][2], nx, ny, nz}, -- top-left
            {x2, y1, z1, uvs[4][1], uvs[4][2], nx, ny, nz}  -- bottom-left
        }
    elseif faceDir == "east" then
        vertices = {
            {x2, y1, z1, uvs[1][1], uvs[1][2], nx, ny, nz}, -- bottom-left
            {x2, y1, z2, uvs[2][1], uvs[2][2], nx, ny, nz}, -- bottom-right
            {x2, y2, z2, uvs[3][1], uvs[3][2], nx, ny, nz}, -- top-right
            {x2, y2, z1, uvs[4][1], uvs[4][2], nx, ny, nz}  -- top-left
        }
    elseif faceDir == "west" then
        vertices = {
            {x1, y1, z1, uvs[1][1], uvs[1][2], nx, ny, nz}, -- bottom-right
            {x1, y2, z1, uvs[2][1], uvs[2][2], nx, ny, nz}, -- top-right
            {x1, y2, z2, uvs[3][1], uvs[3][2], nx, ny, nz}, -- top-left
            {x1, y1, z2, uvs[4][1], uvs[4][2], nx, ny, nz}  -- bottom-left
        }
    elseif faceDir == "up" then
        vertices = {
            {x1, y2, z1, uvs[1][1], uvs[1][2], nx, ny, nz}, -- bottom-left
            {x2, y2, z1, uvs[2][1], uvs[2][2], nx, ny, nz}, -- bottom-right
            {x2, y2, z2, uvs[3][1], uvs[3][2], nx, ny, nz}, -- top-right
            {x1, y2, z2, uvs[4][1], uvs[4][2], nx, ny, nz}  -- top-left
        }
    elseif faceDir == "down" then
        vertices = {
            {x1, y1, z1, uvs[1][1], uvs[1][2], nx, ny, nz}, -- top-left
            {x1, y1, z2, uvs[2][1], uvs[2][2], nx, ny, nz}, -- top-right
            {x2, y1, z2, uvs[3][1], uvs[3][2], nx, ny, nz}, -- bottom-right
            {x2, y1, z1, uvs[4][1], uvs[4][2], nx, ny, nz}  -- bottom-left
        }
    end
    
    return vertices
end

-- Main loader function
return function (path, texturePath)
    local data = love.filesystem.read(path)
    local modelData = json.decode(data)
    local result = {}
    
    -- Get texture dimensions for proper UV mapping
    local textureWidth, textureHeight = 16, 16 -- Default texture size
    if texturePath then
        local success, texture = pcall(love.graphics.newImage, texturePath)
        if success then
            textureWidth, textureHeight = texture:getDimensions()
        end
    end

    -- Process each element in the model
    for _, element in ipairs(modelData.elements) do
        local from = element.from
        local to = element.to
        
        -- Process each face
        for faceName, faceData in pairs(element.faces) do
            if type(faceData) == "table" and faceData.uv then
                local faceVerts = createFaceVertices(from, to, faceData, faceName, element, textureWidth, textureHeight)
                
                -- Triangulate the quad (split into two triangles)
                if #faceVerts >= 4 then
                    -- First triangle
                    table.insert(result, faceVerts[1])
                    table.insert(result, faceVerts[2])
                    table.insert(result, faceVerts[3])
                    
                    -- Second triangle
                    table.insert(result, faceVerts[1])
                    table.insert(result, faceVerts[3])
                    table.insert(result, faceVerts[4])
                end
            end
        end
    end

    return result
end