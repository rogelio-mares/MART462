-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------



-- Your code here
-- Initialize variables
local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {} -- this is an array
 
local ship
local gameLoopTimer
local livesText
local scoreText
local currentDelay = 500
local timeToChange = 5

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

---- audio ----
local musicTrack
musicTrack = audio.loadStream( "escape_looping.wav")
audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 } )
audio.play( musicTrack, { channel=1, loops=-1 } )

local explosionSound
local fireSound

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
        x = 0,
        y = 0,
        width = 102,
        height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}

local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

-- Load the background
local backGroup = display.newGroup()

local background = display.newImageRect("background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

backGroup:insert(background)

local mainGroup = display.newGroup()
ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 78 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"
mainGroup:insert(ship)

local uiGroup = display.newGroup()
livesText = display.newText( "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( "Score: " .. score, 400, 80, native.systemFont, 36 )
uiGroup:insert(livesText)
uiGroup:insert(scoreText)

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- this function updates the stats of the game
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- this function creates variety of asteroids and adds them to the table
local function createAsteroid()
    local mainGroup = display.newGroup()
    local newAsteroid = display.newImageRect( objectSheet, 1, 102, 85 )
    
    -- add the asteroid to the table
    table.insert( asteroidsTable, newAsteroid )
    physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
    newAsteroid.myName = "asteroid" -- this is a tag name so we can use this in collision
    local whereFrom = math.random(1, 3 ) -- how do we know what the range is?
   -- whereFrom = 1
    if ( whereFrom == 1 ) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
    newAsteroid:applyTorque( math.random( -6,6 ) )
    mainGroup:insert(newAsteroid)
 
end

-- this function fires the laser after creating it
-- it uses the transition.to to move the laser up to a new location over time
local function fireLaser()
    audio.play( fireSound )

    local mainGroup = display.newGroup()
    local newLaser = display.newImageRect(objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "laser"
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()
    transition.to( newLaser, { y=-40, time=500,
        onComplete = function() display.remove( newLaser ) end
    } )
    mainGroup:insert(newLaser)
end

ship:addEventListener( "tap", fireLaser )

-- this function moves the ship by figuring out the offset of the mouse x,y from the ship x and y
-- this determines the new location of the mouse and adjusts the ship taking into account the
-- the offset
local function dragShip( event )
 
    local ship = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
        ship.touchOffsetY = event.y - ship.y

    elseif ( "moved" == phase ) then
        
        

        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
        ship.y = event.y - ship.touchOffsetY
        
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
        ship.touchOffsetY = event.y - ship.y
    
        --ship.x = event.x - ship.touchOffsetX
        --ship.y = event.y - ship.touchOffsetY
        

    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects


end

ship:addEventListener( "touch", dragShip )

explosionSound = audio.loadSound( "audio/explosion.wav" )
    fireSound = audio.loadSound( "audio/fire.wav" )

-- this is the loop that creates new asteroids over and over
local function gameLoop()

    -- this section is where we can increase the speed of the asteroid creation
    if(timeToChange >= 5) then
        currentDelay = currentDelay - 10
       -- maybe it was just that we needed to cancel and restart
       -- in a new location
        timer.cancel(gameLoopTimer); -- stop the timer here
        -- restart the timer with the new value here
        gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0)
        timeToChange = 0
       
    end

 -- Create new asteroid
 createAsteroid()

 -- Remove asteroids which have drifted off screen
 -- for(var i = 0; i < 5; i++)
 -- for(var i = asteroidsTable.length; i > 0; i--)
 for i = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]
 
    if ( thisAsteroid.x < -100 or
         thisAsteroid.x > display.contentWidth + 100 or
         thisAsteroid.y < -100 or
         thisAsteroid.y > display.contentHeight + 100 )
    then
        display.remove( thisAsteroid )
        table.remove( asteroidsTable, i )
    end
 end
 timeToChange = timeToChange + 1
 

end

--local function startGameLoop()

    --gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0 )

--end

--print(currentDelay)
gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0)

--otherTimer = timer.performWithDelay( 1000, startGameLoop, 0 )

-- this function brings the ship back using the transition.to and alpha value
local function restoreShip()
 
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end

-- this is the collision function that checks collision based on their names
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2
        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            -- Play explosion sound!
            audio.play( explosionSound )

            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end
             -- Increase score
             score = score + 100
             scoreText.text = "Score: " .. score
            elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
            then
                if ( died == false ) then
                    died = true
                        -- Update lives
                    lives = lives - 1
                    livesText.text = "Lives: " .. lives

                    if ( lives == 0 ) then
                        display.remove( ship )
                    else
                        ship.alpha = 0
                        timer.performWithDelay( 1000, restoreShip )
                    end
                end
        end
    end
end
Runtime:addEventListener( "collision", onCollision )
