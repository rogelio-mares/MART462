-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local tapCount = 0

local background = display.newImageRect( "background.png", 1125, 2436 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local musicTrack
musicTrack = audio.loadStream( "lofi.wav")
audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 } )
audio.play( musicTrack, { channel=1, loops=-1 } )

local tapText = display.newText( tapCount, display.contentCenterX, 450, native.systemFont, 300 )
tapText:setFillColor( 1, 1, 1 )

local platform = display.newImageRect( "platform.png", 1125, 400 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-50


local balloon = display.newImageRect( "balloon.png", 223, 487 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.9

local physics = require( "physics" )
physics.start()
math.randomseed(os.time())
local grav = 0.5 math.random();

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } )

local function pushBalloon()
	balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
	tapCount = tapCount + 1
	tapText.text = tapCount
end

balloon:addEventListener( "tap", pushBalloon )

