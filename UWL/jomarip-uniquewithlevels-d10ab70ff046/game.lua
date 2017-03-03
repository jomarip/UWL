	
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function goEndRound()
    composer.gotoScene( "menu", {effect="slideDown", time=100} )
	
end

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Configure image sheet


-- Initialize variables
local letter = "A"
local score = 0
local died = false

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVXYZ"
local answerField = {}
local indicatorLocationS
local correct 
local noRecord

--local categories = {"Breakfast Foods","Body Parts","Tools","City","Plays","Animal","Target Products"}


-- Display groups for sourting and layering our game objects
local backGroup -- Display group for the background image
local mainGroup    -- Display group for the ship, asteroids, lasers, etc.
local uiGroup       -- Display group for UI objects like the score


local function stringGen()
	local character = math.random(0,27)
	local letterpick = character
	local gameletter = string.sub(alphabet,letterpick,letterpick)
	return gameletter
end	

local function updateText()
	livesText.text = "Letter: "..stringGen()
	
	scoreText.text = "Score: "..score
end
---------------------------------------------------------------------------- 
function print_r ( t )    -- print all content of a table
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

table.print = print_r

local function recursiveSearch(aTable, comparison, position)   -- table search for comparison, recursive for nested tables
    for key, value in pairs(aTable) do --unordered search
        if(type(value) == "table") then
            recursiveSearch(value, comparison,position)
						
		else
            if value == tostring(comparison) then
			print("success")
			print (position)	
			--correct = display.newImageRect(sceneGroup,"checkmark.png",200+ position*100,display.contentWidth*.25)
			break
			
			else
				--print(value) --this print shows the category being answered
			end
		end
	end
	
end

--------------------------------------------------------------------------------------
-- pulling in a file
local json = require "json"


function jsonFile( filename, base )   -- basic function to open and close a file
        -- set default base dir if none specified
        if not base then base = system.ResourceDirectory; end
        
        -- create a file path for corona i/o
        local path = system.pathForFile( filename, base )
        print( "jsonFile ["..path.."]" )
        
        -- will hold contents of file
        local contents
        
        -- io.open opens a file at path. returns nil if no file found
        local file = io.open( path, "r" )
        if file then
           -- read all contents of file into a string
           contents = file:read( "*a" )
           io.close( file )     -- close the file after using it
        else
                print( "** Error: cannot open file" )
        end
        
       -- print( "contents<<<EOF")
        --print( contents )
        --print( ">>EOF")
        
        return contents
end

-- json files to pull in
local cats =  jsonFile( "categories.json" ) 
local answers1 = jsonFile ("answerfield1.json")
local t = json.decode(cats) 
local a1 = json.decode(answers1)

-- create set list


--print("here is t")
--print(t.categories[1].name)  -- It is necessary to refer directly to the last aspects of the datasets, it seems


--Text Listener for textFields
local function textListener( event )

    if ( event.phase == "began" ) then
        -- 1st time User begins editing "defaultField"
		print("1st time entering data in the field")

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
       -- print( event.target.text ) -- activated when you submit or go to a new field
	   --print(event.target.num)   -- this references the object id data set right before the eventListener
			
			--evaluate content
			--print(answerField[1].cat)
			--print(event.target.cat) -- target refers to the object being referenced. In this case, it is printing the categories
			--table.print(a1)
			--print(event.target.text)
			--indicatorLocation = tostring(event.target.num)
			recursiveSearch(a1.verified,event.target.text,indicatorLocation) -- checks for a match and marks if correct or no simialar record found
			
    elseif ( event.phase == "editing" ) then
        --print( event.newCharacters ) -- 
        --print( event.oldText )
        --print( event.startPosition ) --this didnt seem to tell me anything
        --print( event.text )
			
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on 
	
	

	physics.pause() -- Temporarily pause the physics engine
	
	-- Set up display groups
	backGroup = display.newGroup()
	sceneGroup:insert( backGroup)
	
	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup)
	
	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup)
	
	display.setDefault( "background", 1 ) -- white
	
--Border Box	
	local rect = display.newRect(sceneGroup, display.contentCenterX, 600, 550, 800 )
	rect:setFillColor( 1 ) 
	rect:setStrokeColor( 0, 0 ,0 )
	rect.strokeWidth = 5
	
	
-- Display Title & Letter & Time Remaining
	local colorTable = { red,green,blue}
	
	local gameTitle = display.newImageRect( sceneGroup, "title.png", 350, 150)
    gameTitle.x = 275
	gameTitle.y = 100

	local letterText = display.newText( sceneGroup, "Letter: ", 510, 40, native.systemFont, 24 )
	letterText:setFillColor( unpack(colorTable) )

    local chosenLetter = display.newText( sceneGroup, stringGen() , 650, 40, native.systemFont, 40 )
	chosenLetter:setFillColor( unpack(colorTable) )
		
    local timeText = display.newText( sceneGroup, "Time \nRemaining" , 530, 120, native.systemFont, 24 )
	timeText:setFillColor( unpack(colorTable) )

	-- Categories 
	
	
	
	for i = 1, 7 do
        if ( t.categories[i].name ) then
            local yPos = 200 + ( i * 100 )

            local thisCategory = display.newText( sceneGroup, t.categories[i].name, display.contentWidth*.175, yPos, native.systemFont, 36 )
			thisCategory:setFillColor( 0 )
            thisCategory.anchorX = 0
        end
    end

	
	for i = 1, 7 do
        
            local yPos2 = 200 + ( i * 100 )
	
            answerField[i] = native.newTextField( display.contentWidth*.7, yPos2, 200, 50)
			answerField[i].placeholder = "answer here"
			sceneGroup:insert(answerField[i])                	 
			
            --thisCategory.anchorX = 0
    end
	
	
--Countdown Timer   ----make sure time continues once started even if phone is turned off
-- Keep track of time in seconds
	local secondsLeft =  1*15   -- 1 minutes in 60 seconds

	local clockText = display.newText(sceneGroup,"1:00", 625, 110, native.systemFontBold, 40)
	clockText:setFillColor( 0.7, 0.7, 1 )

	local function updateTime()
		-- decrease the number of seconds
		secondsLeft = secondsLeft - 1
	
	-- time is tracked in seconds.  We need to convert it to minutes and seconds
		local minutes = math.floor( secondsLeft / 60 )
		local seconds = secondsLeft % 60
	
	-- make it a string using string format.  
		local timeDisplay = string.format( "%01d:%02d", minutes, seconds )
		clockText.text = timeDisplay
		
		--End of Game Code
		if secondsLeft == 0 then
			--.showAlert("The Response",answerField[1].text)
			display.remove(answerField	)
			--answerField:removeSelf()
			
			--Save Answers
				for i = 1, 7 do
					-- Data (string) to write
					local saveData = ("\n" .. answerField[i].text)

					-- Path for the file to write
					local path = system.pathForFile( "gameData.txt", system.DocumentsDirectory )

					-- Open the file handle
					local file, errorString = io.open( path, "a" )   -- 'a' stands for append mode. Adding additional data.

					if not file then
						-- Error occurred; output the cause
						print( "File error: " .. errorString )
					else
						-- Write data to file
						file:write( saveData )
						-- Close the file handle
						io.close( file )
					end

					file = nil
				end
			
			--goEndRound()				
		end
		
	end

			
	-- run them timer
	local countDownTimer = timer.performWithDelay( 1000, updateTime, secondsLeft )
	
	--local endGameCheck = timer.performWithDelay(1000*60,check)
	
	
	--event listeners
	

	for i = 1, 7 do
	
		answerField[i].cat = t.categories[i].name     -- adds an additional property to this table/array for use in the eventListener
		answerField[i].num = i
		answerField[i]:addEventListener( "userInput", textListener )
	end	
--	ship:addEventListener( "tap", fireLaser )
--    ship:addEventListener( "touch", dragShip )
	
end


-- show()
function scene:show( event )	

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		
       -- Runtime:addEventListener( "collision", onCollision ) --https://docs.coronalabs.com/guide/programming/05/index.html#hiding-the-scene
       

	end
end


-- hide()
function scene:hide( event ) 	

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		 
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
	--	Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene




