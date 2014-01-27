

--[[
                        
                        Example for S.K. Corona Synth
                        (cc1) S.K. Studios, LLC
                        @stinkykitties
                        www.stinkykitties.com
                        R.Delia 

--]]


--Require S.K. Corona Synth:
local skCoronaSynth  = require("SKCoronaSynth")

-- Load .mid file:
--skCoronaSynth:loadSong("assets/MIDI/23gcb.mid", system.ResourceDirectory) --Gulf Coast Blues (drums a little ways in)
--skCoronaSynth:loadSong("assets/MIDI/Dance_of_the_Mother_Goddess.mid", system.ResourceDirectory)  -- dance of the mother goddess
--skCoronaSynth:loadSong("assets/MIDI/Drum_Song.mid", system.ResourceDirectory)   -- native indian drum song
--skCoronaSynth:loadSong("assets/MIDI/Three_Blind_Mice.mid", system.ResourceDirectory)  --Three blind mice
--skCoronaSynth:loadSong("assets/MIDI/sbcatm.mid", system.ResourceDirectory)   -- She'll be coming 'round the mountain (Drums come in late in the song)
--skCoronaSynth:loadSong("assets/MIDI/Red_River_Valley.mid", system.ResourceDirectory)   -- Red River Valley (+drums)
--skCoronaSynth:loadSong("assets/MIDI/Polly_Wolly_Doodle.mid", system.ResourceDirectory)   -- Polly Wolly Doodle (+drums)

local songs = 
{ 
    {myName = "Gulf Coast Blues" , myFile = "assets/MIDI/23gcb.mid" , myFolder = "system.ResourceDirectory"},  --for some reason, the first item does not appear to be selectable 
    {myName = "Gulf Coast Blues" , myFile = "assets/MIDI/23gcb.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "Dance of the Mother Goddess" , myFile = "assets/MIDI/Dance_of_the_Mother_Goddess.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "Drum Song" , myFile = "assets/MIDI/Drum_Song.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "Three Blind Mice" , myFile = "assets/MIDI/Three_Blind_Mice.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "She'll be Comin' 'Round the Mountain" , myFile = "assets/MIDI/sbcatm.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "Red River Valley" , myFile = "assets/MIDI/Red_River_Valley.mid" , myFolder = "system.ResourceDirectory"},
    {myName = "Polly Wolly Doodle" , myFile = "assets/MIDI/Polly_Wolly_Doodle.mid" , myFolder = "system.ResourceDirectory"},
    
    
}
local songText
local function updateText(myTextObject, myNewtext)
    
    myTextObject.oldX,myTextObject.oldY =myTextObject.x,myTextObject.y 
    myTextObject.text = myNewtext
    myTextObject.anchorX = .5
    myTextObject.anchorY = .5
    myTextObject.x,myTextObject.y = myTextObject.oldX,myTextObject.oldY
end


local isSongLoaded = false
--add a button to start / stop  the music:  
local myStartButton = display.newRect(display.contentCenterX - 25, display.actualContentHeight - 50, 50, 50)
myStartButton.isOn = false

myStartButton:setFillColor(1, 0, 0, 1)
function myStartButton:touch(event)
    
    if myStartButton.isOn == false then
        return
        
    end
    
    if isSongLoaded == false then
        return
    end
    
    if skCoronaSynth.isOn == false then
        if event.phase == "ended" then
            --play
            myStartButton:setFillColor(0,1,0, 1)
            
            skCoronaSynth.isOn = true
        end
    else
        if event.phase == "ended" then
            --stop
            audio.stop()
            myStartButton:setFillColor(1,0,0, 1)
            skCoronaSynth.isOn = false
        end
    end
end
myStartButton:addEventListener("touch", myStartButton)

songText = display.newText("initial", display.contentCenterX, 340, 250  ,0   , native.systemFontBold, 12, "center")
updateText(songText,"Touch a song to load, and the button to play / stop")



local title  = display.newText("S.K. Synth", 0   , 0, native.systemFontBold   , 32)
--title:setFillColor(1,.5,.5,1)
title.anchorX, title.anchorY = .5,0
title.x,title.y = display.contentCenterX, 20



local followUs  = display.newText("@StinkyKitties", 0   , 0, native.systemFontBold   , 18)
--title:setFillColor(1,.5,.5,1)
followUs.anchorX, followUs.anchorY = .5,1
followUs.x,followUs.y = display.contentCenterX, display.actualContentHeight - 100


-- a little self promo :) 
function followUs:touch(event)
    if event.phase == "ended" then
        system.openURL("https://twitter.com/StinkyKitties")
    end
end

followUs:addEventListener("touch", followUs)
--how about some sort of thingy that lets me show a bunch of files?
--maybe a widget?
local widget = require( "widget" )

-- The "onRowRender" function may go here (see example under "Inserting Rows", above)


local onRowRender = function(event)
    local phase = event.phase
    local row = event.row
    
    if row.params == nil then
        return
    end
    
    local rowTitle = display.newText( row,row.params.myName, 0, 0, native.systemFont, 14 )
    rowTitle.anchorX = .5
    rowTitle.anchorY = .5
    
    rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 ) + 250
    rowTitle.y = row.contentHeight * 0.33
    rowTitle:setTextColor( 0, 0, 0 )
    
end

local onRowTouch = function(event)
    
    
    if event.phase == "press" then
        -- isSongLoaded = false  -- do i really need this thing?
        isSongLoaded = false
        skCoronaSynth.isOn = false
        updateText(songText,"Attempt to load:" .. event.target.params.myName )
        myStartButton.isOn = false
    end
    if event.phase == "tap" or event.phase == "release" then
        
        skCoronaSynth:loadSong(event.target.params.myFile, event.target.params.myFolder) 
        --   print("Loaded:" .. event.target.params.myName )
        updateText(songText,"Loaded:" .. event.target.params.myName )
        myStartButton.isOn = true
        isSongLoaded = true
        
        
    end
    
end

local scrollListener = function(event)
    
end

-- Create the widget: http://docs.coronalabs.com/api/library/widget/newTableView.html
local tableView = widget.newTableView
{
    left = 00,
    top = 60,
    height = 250,
    width = 300,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
    listener = scrollListener
}

-- Insert 40 rows
for i = 1, #songs do
    
    local isCategory = false
    local rowHeight = 36
    local rowColor = { default={ 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }
    local lineColor = { 0.5, 0.5, 0.5 }
    
    -- Make some rows categories
    if ( i == 1 or i == 21 ) then
        isCategory = true
        rowHeight = 40
        rowColor = { default={ 0.8, 0.8, 0.8, 0.8 } }
        lineColor = { 1, 0, 0 }
    end
    
    -- Insert a row into the tableView
    tableView:insertRow(
    {
        isCategory = isCategory,
        rowHeight = rowHeight,
        rowColor = rowColor,
        lineColor = lineColor,
        params = songs[i]
    }
    )
end






