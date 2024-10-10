-- Window settings
local windowWidth, windowHeight = 800, 600

-- Dart settings
local dart = {
    x = 100,       -- Dart start position
    y = windowHeight / 2,
    radius = 5,    -- Dart size
    speedX = 0,    -- Horizontal velocity (initially 0)
    speedY = 0,    -- Vertical velocity (initially 0)
    gravity = 500, -- Gravity affecting the dart
    isThrown = false, -- Dart is not thrown initially
    charge = 0,    -- Charge amount for shooting
    maxCharge = 1000 -- Maximum charge
}

-- Target settings
local target = {
    x = windowWidth - 200,
    y = windowHeight / 2,
    radius = 100 -- Size of the target
}

-- Game variables
local score = 0
local isLanded = false   -- Track if dart has landed
local landedTimer = 0    -- Timer for dart reset after landing
local landedDelay = 2    -- Delay in seconds before dart resets

-- Angle and charge control
local throwAngle = 45  -- Initial angle of throw
local isCharging = false  -- To track if player is charging the shot

-- Love2D load function to initialize game
function love.load()
    love.window.setTitle("Throwing Dart Game with Physics")
    love.window.setMode(windowWidth, windowHeight)
end

-- Function to reset the dart after it lands or hits the target
function resetDart()
    dart.x = 100
    dart.y = windowHeight / 2
    dart.speedX = 0
    dart.speedY = 0
    dart.isThrown = false
    dart.charge = 0
    isLanded = false  -- Dart is no longer landed
    landedTimer = 0   -- Reset the timer
end

-- Love2D update function to handle game logic
function love.update(dt)
    -- Charge the dart while holding the spacebar
    if isCharging and not dart.isThrown then
        dart.charge = math.min(dart.charge + 500 * dt, dart.maxCharge)
    end

    -- Update the dart movement if it's thrown and not yet landed
    if dart.isThrown and not isLanded then
        dart.x = dart.x + dart.speedX * dt
        dart.y = dart.y + dart.speedY * dt
        dart.speedY = dart.speedY + dart.gravity * dt  -- Gravity affects the dart

        -- Check if the dart hits the ground (or goes out of bounds)
        if dart.y > windowHeight or dart.x > windowWidth then
            isLanded = true  -- Dart has landed
            landedTimer = landedDelay  -- Start the landing delay timer
        end

        -- Check if the dart hits the target
        local distance = math.sqrt((dart.x - target.x)^2 + (dart.y - target.y)^2)
        if distance <= target.radius then
            -- Score based on hit location
            if distance <= target.radius * 0.25 then
                score = score + 100
            elseif distance <= target.radius * 0.5 then
                score = score + 50
            elseif distance <= target.radius * 0.75 then
                score = score + 20
            else
                score = score + 10
            end

            isLanded = true  -- Dart has landed
            landedTimer = landedDelay  -- Start the landing delay timer
        end
    end

    -- Handle resetting the dart after the delay when it has landed
    if isLanded then
        landedTimer = landedTimer - dt
        if landedTimer <= 0 then
            resetDart()  -- Reset dart after delay
        end
    end
end

-- Love2D function to handle player input
function love.keypressed(key)
    if key == "space" and not dart.isThrown then
        isCharging = true  -- Start charging the shot
    end
end

function love.keyreleased(key)
    if key == "space" and not dart.isThrown then
        isCharging = false  -- Stop charging the shot
        -- Calculate the dart's velocity based on charge and angle
        local radianAngle = math.rad(throwAngle)
        dart.speedX = dart.charge * math.cos(radianAngle)
        dart.speedY = -dart.charge * math.sin(radianAngle)  -- Negative for upward direction
        dart.isThrown = true
    end

    -- Arrow keys for adjusting throw angle
    if key == "up" then
        throwAngle = math.min(throwAngle + 5, 90)  -- Max angle 90 degrees
    elseif key == "down" then
        throwAngle = math.max(throwAngle - 5, 0)  -- Min angle 0 degrees
    end
end

-- Love2D draw function to render game objects
function love.draw()
    -- Draw the dart
    love.graphics.setColor(1, 0, 0)  -- Red color for dart
    love.graphics.circle("fill", dart.x, dart.y, dart.radius)

    -- Draw the target
    love.graphics.setColor(0, 1, 0)  -- Green color for target
    love.graphics.circle("line", target.x, target.y, target.radius)  -- Outer circle
    love.graphics.circle("line", target.x, target.y, target.radius * 0.75)
    love.graphics.circle("line", target.x, target.y, target.radius * 0.5)
    love.graphics.circle("line", target.x, target.y, target.radius * 0.25)

    -- Draw the score
    love.graphics.setColor(1, 1, 1)  -- White color for text
    love.graphics.print("Score: " .. score, 10, 10)

    -- Draw the charging bar
    love.graphics.print("Charge: " .. math.floor(dart.charge), 10, 30)
    love.graphics.rectangle("fill", 10, 50, dart.charge / 10, 20)

    -- Show throw angle
    love.graphics.print("Throw Angle: " .. throwAngle .. "°", 10, 80)

    -- Instructions
    love.graphics.print("Hold Space to Charge, Release to Throw", 10, 100)
    love.graphics.print("Use Arrow Keys to Adjust Angle", 10, 120)
end
