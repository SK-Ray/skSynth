--[[
    
        S.K. CoronaSynth   
        (Creative Commons Attribution) @StinkyKitties www.stinkykitties.com
        Have fun, everyone!


--Audio files that are from freesound.org and have kept their original file names
--Audio files that are not tagged by filename should have metadata from when I created them


-- MIDI songs: http://www.pdmusic.org/   


-- http://www.phy.mtu.edu/~suits/NoteFreqCalcs.html   --original note to frequency calc research
-- http://bradthemad.org/guitar/tempo_explanation.php   --durations
-- http://www.pjb.com.au/comp/lua/MIDI.html#play_score   MIDI.lua  --(HUGE THANK YOU!)
-- http://home.roadrunner.com/~jgglatt/tech/midifile/ppqn.htm  60 mil conversion against BPM , huh?
-- http://www.recordingblogs.com/sa/tabid/88/Default.aspx?topic=MIDI+Set+Tempo+meta+message   more on time conversion
-- http://en.wikipedia.org/wiki/Piano_key_frequencies master frequency list

--]]
local MIDI = require("MIDI")  -- http://www.pjb.com.au/comp/lua/MIDI.html#play_score

local SKCoronaSynth = {}
SKCoronaSynth.synths = {}
SKCoronaSynth.durations = {}
SKCoronaSynth.sounds = {}
SKCoronaSynth.isOn = false

local deltaTime  = 0
local lastTime = 0
local musicStart = 0
local elapsedTime =0


-- higher values can be too loud when chords, or many simultaneous notes play
local channelVolumeFactor = .2

local drumMaxChannel = 8
audio.reserveChannels( drumMaxChannel ) --reserve first 10 channels for drums

local freeDrumChannel = 1


SKCoronaSynth.frequenciesByNoteName = 
{
    
    --    hand jammed
    --    C4  = {frequency = 261.626},
    --    D4  = {frequency = 293.665},
    --    E4  = {frequency = 329.628},
    --    F4  = {frequency = 349.228},
    --    G4  = {frequency = 391.995},
    --    A4  = {frequency = 440.000},
    --    B4  = {frequency = 493.883},
    --    
    --    C5  = {frequency = 523.251},
    --    
    --    --From Excel and :
    C8	={frequency =	4186.01	, number =	88	},
    B7	={frequency =	3951.07	, number =	87	},
    Bb7	={frequency =	3729.31	, number =	86	},
    As7	={frequency =	3729.31	, number =	86	},
    A7	={frequency =	3520	, number =	85	},
    Ab7	={frequency =	3322.44	, number =	84	},
    Gs7	={frequency =	3322.44	, number =	84	},
    G7	={frequency =	3135.96	, number =	83	},
    Gb7	={frequency =	2959.96	, number =	82	},
    Fs7	={frequency =	2959.96	, number =	82	},
    F7	={frequency =	2793.83	, number =	81	},
    E7	={frequency =	2637.02	, number =	80	},
    Eb7	={frequency =	2489.02	, number =	79	},
    Ds7	={frequency =	2489.02	, number =	79	},
    D7	={frequency =	2349.32	, number =	78	},
    Db7	={frequency =	2217.46	, number =	77	},
    Cs7	={frequency =	2217.46	, number =	77	},
    C7	={frequency =	2093	, number =	76	},
    B6	={frequency =	1975.53	, number =	75	},
    Bb6	={frequency =	1864.66	, number =	74	},
    As6	={frequency =	1864.66	, number =	74	},
    A6	={frequency =	1760	, number =	73	},
    Ab6	={frequency =	1661.22	, number =	72	},
    Gs6	={frequency =	1661.22	, number =	72	},
    G6	={frequency =	1567.98	, number =	71	},
    Gb6	={frequency =	1479.98	, number =	70	},
    Fs6	={frequency =	1479.98	, number =	70	},
    F6	={frequency =	1396.91	, number =	69	},
    E6	={frequency =	1318.51	, number =	68	},
    Eb6	={frequency =	1244.51	, number =	67	},
    Ds6	={frequency =	1244.51	, number =	67	},
    D6	={frequency =	1174.66	, number =	66	},
    Db6	={frequency =	1108.73	, number =	65	},
    Cs6	={frequency =	1108.73	, number =	65	},
    C6	={frequency =	1046.5	, number =	64	},
    B5	={frequency =	987.767	, number =	63	},
    Bb5	={frequency =	932.328	, number =	62	},
    As5	={frequency =	932.328	, number =	62	},
    A5	={frequency =	880	, number =	61	},
    Ab5	={frequency =	830.609	, number =	60	},
    Gs5	={frequency =	830.609	, number =	60	},
    G5	={frequency =	783.991	, number =	59	},
    Gb5	={frequency =	739.989	, number =	58	},
    Fs5	={frequency =	739.989	, number =	58	},
    F5	={frequency =	698.456	, number =	57	},
    E5	={frequency =	659.255	, number =	56	},
    Eb5	={frequency =	622.254	, number =	55	},
    Ds5	={frequency =	622.254	, number =	55	},
    D5	={frequency =	587.33	, number =	54	},
    Db5	={frequency =	554.365	, number =	53	},
    Cs5	={frequency =	554.365	, number =	53	},
    C5	={frequency =	523.251	, number =	52	},
    B4	={frequency =	493.883	, number =	51	},
    Bb4	={frequency =	466.164	, number =	50	},
    As4	={frequency =	466.164	, number =	50	},
    A4	={frequency =	440	, number =	49	},
    Ab4	={frequency =	415.305	, number =	48	},
    Gs4	={frequency =	415.305	, number =	48	},
    G4	={frequency =	391.995	, number =	47	},
    Gb4	={frequency =	369.994	, number =	46	},
    Fs4	={frequency =	369.994	, number =	46	},
    F4	={frequency =	349.228	, number =	45	},
    E4	={frequency =	329.628	, number =	44	},
    Eb4	={frequency =	311.127	, number =	43	},
    Ds4	={frequency =	311.127	, number =	43	},
    D4	={frequency =	293.665	, number =	42	},
    Db4	={frequency =	277.183	, number =	41	},
    Cs4	={frequency =	277.183	, number =	41	},
    C4	={frequency =	261.626	, number =	40	},
    B3	={frequency =	246.942	, number =	39	},
    Bb3	={frequency =	233.082	, number =	38	},
    As3	={frequency =	233.082	, number =	38	},
    A3	={frequency =	220	, number =	37	},
    Ab3	={frequency =	207.652	, number =	36	},
    Gs3	={frequency =	207.652	, number =	36	},
    G3	={frequency =	195.998	, number =	35	},
    Gb3	={frequency =	184.997	, number =	34	},
    Fs3	={frequency =	184.997	, number =	34	},
    F3	={frequency =	174.614	, number =	33	},
    E3	={frequency =	164.814	, number =	32	},
    Eb3	={frequency =	155.563	, number =	32	},
    Ds3	={frequency =	155.563	, number =	31	},
    D3	={frequency =	146.832	, number =	30	},
    Db3	={frequency =	138.591	, number =	30	},
    Cs3	={frequency =	138.591	, number =	29	},
    C3	={frequency =	130.813	, number =	28	},
    B2	={frequency =	123.471	, number =	27	},
    Bb2	={frequency =	116.541	, number =	27	},
    As2	={frequency =	116.541	, number =	26	},
    A2	={frequency =	110	, number =	25	},
    Ab2	={frequency =	103.826	, number =	25	},
    Gs2	={frequency =	103.826	, number =	24	},
    G2	={frequency =	97.9989	, number =	23	},
    Gb2	={frequency =	92.4986	, number =	23	},
    Fs2	={frequency =	92.4986	, number =	22	},
    F2	={frequency =	87.3071	, number =	21	},
    E2	={frequency =	82.4069	, number =	20	},
    Eb2	={frequency =	77.7817	, number =	19	},
    Ds2	={frequency =	77.7817	, number =	19	},
    D2	={frequency =	73.4162	, number =	18	},
    Db2	={frequency =	69.2957	, number =	18	},
    Cs2	={frequency =	69.2957	, number =	17	},
    C2	={frequency =	65.4064	, number =	16	},
    B1	={frequency =	61.7354	, number =	15	},
    Bb1	={frequency =	58.2705	, number =	14	},
    As1	={frequency =	58.2705	, number =	14	},
    A1	={frequency =	55	, number =	13	},
    Ab1	={frequency =	51.9131	, number =	12	},
    Gs1	={frequency =	51.9131	, number =	12	},
    G1	={frequency =	48.9994	, number =	11	},
    Gb1	={frequency =	46.2493	, number =	10	},
    Fs1	={frequency =	46.2493	, number =	10	},
    F1	={frequency =	43.6535	, number =	9	},
    E1	={frequency =	41.2034	, number =	8	},
    Eb1	={frequency =	38.8909	, number =	7	},
    Ds1	={frequency =	38.8909	, number =	7	},
    D1	={frequency =	36.7081	, number =	6	},
    Db1	={frequency =	34.6478	, number =	5	},
    Cs1	={frequency =	34.6478	, number =	5	},
    C1	={frequency =	32.7032	, number =	4	},
    B0	={frequency =	30.8677	, number =	3	},
    Bb0	={frequency =	29.1352	, number =	2	},
    As0	={frequency =	29.1352	, number =	2	},
    A0	={frequency =	27.5	, number =	1	},
    
    
}

local drumMap ={}
drumMap[33] = audio.loadSound('assets/sounds/samples/kits/default/MetronomeClick.wav')
drumMap[34] = audio.loadSound('assets/sounds/samples/kits/default/MetronomeBell.wav')
drumMap[35] = audio.loadSound('assets/sounds/samples/kits/default/208871__adammusic18__bass-drum-kick.wav') --AcousticBassDrum.wav')
drumMap[36] = audio.loadSound('assets/sounds/samples/kits/default/89466__menegass__bd11.wav') -- BassDrum1.wav')
drumMap[37] = audio.loadSound('assets/sounds/samples/kits/default/73385__soundhead__single-stick-hit.wav') --SideStick.wav')
drumMap[38] = audio.loadSound('assets/sounds/samples/kits/default/99837__menegass__linnsd1.wav') --AcousticSnare.wav')
drumMap[39] = audio.loadSound('assets/sounds/samples/kits/default/147597__kendallbear__never-be-clap.wav') -- HandClap.wav')
drumMap[40] = audio.loadSound('assets/sounds/samples/kits/default/ElectricSnare.wav')
drumMap[41] = audio.loadSound('assets/sounds/samples/kits/default/171485__xicecoffeex__savannah-floor-tom.wav') -- LowFloorTom.wav')
drumMap[42] = audio.loadSound('assets/sounds/samples/kits/default/75040__cbeeching__hat-05-44.wav') -- ClosedHi-Hat.wav')
drumMap[43] = audio.loadSound('assets/sounds/samples/kits/default/46552__pjcohen__yamaha-oak-custom-tom-high.wav') -- HighFloorTom.wav')
drumMap[44] = audio.loadSound('assets/sounds/samples/kits/default/PedalHi-Hat.wav')
drumMap[45] = audio.loadSound('assets/sounds/samples/kits/default/53551__bluesplayer59__purple-low-tom-4.wav') --LowTom.wav')
drumMap[46] = audio.loadSound('assets/sounds/samples/kits/default/91791__zinzan-101__short-open.wav') -- OpenHi-Hat.wav')
drumMap[47] = audio.loadSound('assets/sounds/samples/kits/default/46551__pjcohen__yamaha-maple-custom-tom-mid.wav') -- Low-MidTom.wav')
drumMap[48] = audio.loadSound('assets/sounds/samples/kits/default/104273__minorr__yamaha-custom-birch-tom-8-p.wav') -- Hi-MidTom.wav')
drumMap[49] = audio.loadSound('assets/sounds/samples/kits/default/78513__irjames__cymbal.wav') --CrashCymbal1.wav')
drumMap[50] = audio.loadSound('assets/sounds/samples/kits/default/104272__minorr__yamaha-custom-birch-tom-8-ff.wav') --HighTom.wav')
drumMap[51] = audio.loadSound('assets/sounds/samples/kits/default/29791__stomachache__ride2.wav') --RideCymbal1.wav')
drumMap[52] = audio.loadSound('assets/sounds/samples/kits/default/ChineseCymbal.wav')
drumMap[53] = audio.loadSound('assets/sounds/samples/kits/default/171482__xicecoffeex__savannah-bell.wav') -- RideBell.wav')
drumMap[54] = audio.loadSound('assets/sounds/samples/kits/default/53555__bluesplayer59__tambourine-art.wav') --Tambourine.wav')
drumMap[55] = audio.loadSound('assets/sounds/samples/kits/default/SplashCymbal.wav')
drumMap[56] = audio.loadSound('assets/sounds/samples/kits/default/53523__bluesplayer59__cowbell-stones.wav') --Cowbell.wav')
drumMap[57] = audio.loadSound('assets/sounds/samples/kits/default/15574__lewis__crash-1.wav') -- CrashCymbal2.wav')
drumMap[58] = audio.loadSound('assets/sounds/samples/kits/default/Vibraslap.wav')
drumMap[59] = audio.loadSound('assets/sounds/samples/kits/default/RideCymbal2.wav')
drumMap[60] = audio.loadSound('assets/sounds/samples/kits/default/99751__menegass__bongo1.wav') -- HiBongo.wav')
drumMap[61] = audio.loadSound('assets/sounds/samples/kits/default/99754__menegass__bongo4.wav') --LowBongo.wav')
drumMap[62] = audio.loadSound('assets/sounds/samples/kits/default/90535__suicidity__metal-timbale-closed-020.wav') -- MuteHiConga.wav')
drumMap[63] = audio.loadSound('assets/sounds/samples/kits/default/99864__menegass__cngah.wav') -- OpenHiConga.wav')
drumMap[64] = audio.loadSound('assets/sounds/samples/kits/default/99865__menegass__cngal.wav') -- LowConga.wav')
drumMap[65] = audio.loadSound('assets/sounds/samples/kits/default/HighTimbale.wav')
drumMap[66] = audio.loadSound('assets/sounds/samples/kits/default/LowTimbale.wav')
drumMap[67] = audio.loadSound('assets/sounds/samples/kits/default/HighAgogo.wav')
drumMap[68] = audio.loadSound('assets/sounds/samples/kits/default/LowAgogo.wav')
drumMap[69] = audio.loadSound('assets/sounds/samples/kits/default/Cabasa.wav')
drumMap[70] = audio.loadSound('assets/sounds/samples/kits/default/Maracas.wav')
drumMap[71] = audio.loadSound('assets/sounds/samples/kits/default/ShortWhistle.wav')
drumMap[72] = audio.loadSound('assets/sounds/samples/kits/default/LongWhistle.wav')
drumMap[73] = audio.loadSound('assets/sounds/samples/kits/default/ShortGuiro.wav')
drumMap[74] = audio.loadSound('assets/sounds/samples/kits/default/LongGuiro.wav')
drumMap[75] = audio.loadSound('assets/sounds/samples/kits/default/Claves.wav')
drumMap[76] = audio.loadSound('assets/sounds/samples/kits/default/HiWoodBlock.wav')
drumMap[77] = audio.loadSound('assets/sounds/samples/kits/default/LowWoodBlock.wav')
drumMap[78] = audio.loadSound('assets/sounds/samples/kits/default/MuteCuica.wav')
drumMap[79] = audio.loadSound('assets/sounds/samples/kits/default/OpenCuica.wav')
drumMap[80] = audio.loadSound('assets/sounds/samples/kits/default/13147__looppool__triangle1.wav') --MuteTriangle.wav')
drumMap[81] = audio.loadSound('assets/sounds/samples/kits/default/164088__hypocore__chime.wav') --OpenTriangle.wav')

SKCoronaSynth.drumMap = drumMap


-- create a table of frequencies by MIDI note number from the  frequenciesByNoteName table created earlier
SKCoronaSynth.frequenciesByNoteNumber = {}
for i = 1, 88 do
    for j,k in pairs(SKCoronaSynth.frequenciesByNoteName) do
        if k.number == i then
            SKCoronaSynth.frequenciesByNoteNumber [i] = k
            break                    
        end
    end
end

--TODO   pass in sound, channel (not audio channel, but more like instrument number that will play a track) that we want.... when we play a midi file, if we don't havea  channel, default to one or somehtng...
function SKCoronaSynth:newSynth(mySampleFile, sampleFrequency)
    
    local mySynth = {}
    mySynth.baseFrequency = sampleFrequency or 440
    mySynth.audio = audio.loadSound(mySampleFile)
    mySynth.audioDuration = audio.getDuration(mySynth.audio)    --  print(mySynth.audioDuration) -- Test case shows 30,000 or 30 seconds, as generated
    
    
    function mySynth:playNoteByName(myNote, myDuration)
        local pitchFactor = SKCoronaSynth.frequenciesByNoteName[myNote].frequency / mySynth.baseFrequency
        local ch,src =  audio.play(mySynth.audio)   -- plays the sound
        al.Source( src, al.PITCH,pitchFactor )
        
        local timer = timer.performWithDelay(myDuration, function()
            audio.stop()
        end)
        
    end
    
    function mySynth:playNoteByMIDINumber(myNoteNumber, myDuration, myVelocity, myTrack)
        
        if myNoteNumber > 88 then
            print("********** NOTE OUT OF RANGE: Need to add note:" .. myNoteNumber  .. " to frequenciesByNoteName table.")
            return
        end
        
        local pitchFactor = SKCoronaSynth.frequenciesByNoteNumber[myNoteNumber].frequency / mySynth.baseFrequency
        local ch,src =  audio.play(mySynth.audio)   -- plays the sound
        --print("Channel",ch)
        
        
        if ch == 0 then 
            
            local freeChannel = audio.findFreeChannel()
            ch,src =  audio.play(mySynth.audio, {channel = freeChannel})
            if ch == 0 then 
                print("Missed synth note:" .. myNoteNumber ..  " channel: " ..freeChannel .. "  track:" ..myTrack )
            end
        end
        
        -- we need to arbitrate how channels are reserved for maximum control
        audio.setVolume(myVelocity/128 *  1, {channel = ch})
        
        -- takes out most of the click
        audio.fade(  { channel=ch , time=myDuration * 2, volume=0  }  )
        
        al.Source( src, al.PITCH,pitchFactor )
        
        local timer = timer.performWithDelay(myDuration , function()
            
            audio.setVolume(0, {channel = ch})
            audio.stopWithDelay(1, {channel = ch} )
        end)
    end
    
    
    SKCoronaSynth.synths[#SKCoronaSynth.synths+1] = mySynth
    
    return mySynth
end

local function getBaseBPMFromOpus(myOpus)
    
    local baseBPM = 120
    
    --search every event in every track for set_tempo in the song.[ch][1] position, then take song.[ch][3] 
    for trackParser = 2,  #myOpus do
        for eventParser = 1 , #myOpus[trackParser] do
            if myOpus[trackParser][eventParser][1] == "set_tempo" then
                
                local rawBPM  = myOpus[trackParser][eventParser][3]
                
                baseBPM =  ( 6000000 / (rawBPM * .1) )
                do return baseBPM end
                
            end
        end
    end
   
    
    return baseBPM
    
end

function SKCoronaSynth.returnMIDIScoreFromFile(myFile,myDirectory)
    
    local contents
    local path = system.pathForFile( myFile, myDirectory )  --excellent
    -- io.open opens a file at path. returns nil if no file found
    local fh, reason = io.open( path, "r" )
    
    if fh then
        -- read all contents of file into a string
        contents = fh:read( "*a" )
        --  print( "Contents of " .. path .. "\n" .. contents )
    else
        print( "Reason open failed: " .. reason )  -- display failure message in terminal
    end
    
    io.close( fh )
    
    
    local opusFormattedMIDI = MIDI.midi2opus(contents)
    SKCoronaSynth.baseBPM = getBaseBPMFromOpus(opusFormattedMIDI)
    opusFormattedMIDI = nil
    
    local scoreFormattedMIDI = MIDI.midi2ms_score(contents)
    
    
    
    return scoreFormattedMIDI
    
end

--first crack at a drum manager thingy.....
SKCoronaSynth.drumManager1 = {}

--[[
            What do we want?
            
            A structure kind of like:
            
            [Note: 33] 
                  -- [audio handle 1] [audio handle 2] [audio handle 3] etc
                  
                  
--]]
local highestNoteCount = 0


local function sampleFinishListener(event)
    
    local dm = SKCoronaSynth.drumManager1
    --[[
            Event gives us:
            completed = true / false
            name = audio
            channel = 
            handle = 
            phase = 
            source = 2400 audio handle of some sort i think...
    --]]
    
    --remove stuff from table in here
    
    --loop through, find the source, and remove that record:
    local removed = false
    for i,v in pairs(SKCoronaSynth.drumManager1) do
        local noteTable = v
        
        local noteTableCount = 0
        for j,k in pairs(noteTable) do
            
            local c = k.source
            
            if event.source == k.source then
                --   print("EVENT.channel:" .. event.channel ..  " .phase:" .. event.phase .. " .source:" .. event.source .. " noteNumber:".. k.noteNumber)
                
                table.remove(noteTable, j)
                removed = true
                -- return
                
            end
            noteTableCount = noteTableCount  + 1
        end
        
        if noteTableCount - (#SKCoronaSynth.drumManager1) > highestNoteCount then
            highestNoteCount = noteTableCount
            --   print("Notes being played: ".. highestNoteCount)
        end
    end
    
    if removed == false then
        local uhOh = 3
    end
    
end


local missedNotes = 0
function SKCoronaSynth:playDrumNote(myNote,myVelocity)
    local noteNumber = myNote
    local velocity = myVelocity
    
    if SKCoronaSynth.drumMap[noteNumber] == nil then
        print("**MISSING Drum note:" .. noteNumber)
        
        return
    else
        
        local ch,src =  audio.play(SKCoronaSynth.drumMap[noteNumber], {channel = freeDrumChannel, onComplete = sampleFinishListener})
        
        local myNoteCount
        if  SKCoronaSynth.drumManager1[noteNumber] == nil then
            
            SKCoronaSynth.drumManager1[noteNumber] = {}
        else
            
        end
        myNoteCount = #SKCoronaSynth.drumManager1[noteNumber] +1
        
        
        SKCoronaSynth.drumManager1[noteNumber][myNoteCount] = {noteNumber = noteNumber, channel = ch, source = src }
        --      print("My Note: " .. myNote .. " count:".. myNoteCount)
        --      print("Source: " .. src .. " Channel: " ..ch)
        
        audio.setVolume( velocity/128 * 1 , {channel = ch})
        if ch == 0 then
            --    print("Missed playing Drum note:" .. noteNumber ..  " channel: " ..ch .. " attempted channel:" ..freeDrumChannel .. " Total Missed:" ..missedNotes)
        end
        
        if ch == 0 then
            
            freeDrumChannel = freeDrumChannel + 1
            if freeDrumChannel > drumMaxChannel then
                freeDrumChannel = 1
            end
            
            --  print("Missed playing Drum note:" .. noteNumber ..  " channel: " ..ch .. " attempted channel:" ..freeDrumChannel )
            local freeChannel = audio.findFreeChannel()
            local function listener1(event)
                local k = 3
            end
            
            
            ch,src =  audio.play(SKCoronaSynth.drumMap[noteNumber], {channel = freeChannel})
            
            audio.setVolume( velocity/128 * 1 , {channel = ch})
            
            if ch == 0 then
                missedNotes = missedNotes + 1
                
                print("Missed with findChannel() playing Drum note:" .. noteNumber ..  " channel: " ..ch .. " attempted channel:" ..freeDrumChannel .. "Total Missed: " .. missedNotes)
                
            end
            
        end
        
        freeDrumChannel = freeDrumChannel + 1
        if freeDrumChannel > drumMaxChannel then
            freeDrumChannel = 1
        end
    end
    
end



--it would be nice to find out how many channels there are ,so  that I can set the default synth for it....


-- this just creates a bunch of synths, so that each midi channel will have a voice to play...


SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/66348__iut-paris8__ldurand02.wav")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/440LoopDist.mp3")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/440LoopDist.mp3")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/440LoopDist.mp3")
SKCoronaSynth:newSynth("assets/sounds/samples/synths/440LoopDist.mp3",440)  --this guy causes a lot of missed notes :(
SKCoronaSynth:newSynth("assets/sounds/samples/synths/440LoopDist.mp3",440)  --includes optional paramater for synth sample frequency






-- 23gcb.mid  Gulf Coast Blues... drums don't start till pretty late..... 
--manual load, set up for enterframe listener


--SKCoronaSynth.song = SKCoronaSynth.returnMIDIScoreFromFile("assets/MIDI/23gcb.mid", system.ResourceDirectory)
local tracks 
local speedFactor = 1
function SKCoronaSynth:loadSong(myFileName, myDirectory)
    
    speedFactor = 1
    
    SKCoronaSynth.isOn = false
    tracks = {}
    audio.stop()
    
    SKCoronaSynth.song = nil
    SKCoronaSynth.song = SKCoronaSynth.returnMIDIScoreFromFile(myFileName, myDirectory)
    elapsedTime = 0
    musicStart = 0
    lastTime = 0
    deltaTime = 0
    -- SKCoronaSynth.isOn = true
    
    
    
    
    --song format
    -- [1] == bpm, , 
    -- [2] == track name, time signature , key signature, set_tempo in Tempo Meta-Event's
    -- [3] =  First track:
    --------[1]raw meta event, 0 , 33 
    --------[2]track name , 0 , Bass (BB)
    --------[3]patch change ,0,1,32
    --------[4]control change, 0 , 1 , 7 , 112
    --
    ---------[8] note . 960  = time, 106 = duration , 1 = channel / track ,38 = note number ,80 = velocity
    
    
    
    -- load  up the track that have music data:
    
    for trackParser = 2,  #SKCoronaSynth.song do
        tracks[trackParser] = SKCoronaSynth.song[trackParser]
    end
    
    
end



-- the local speedFactor is a private variable that is used when trying to modify the BPM of a song



function SKCoronaSynth.getTempo()
    
    return (SKCoronaSynth.baseBPM * speedFactor)
    
end

function SKCoronaSynth:setTempo(newTempo)
    print("New tempo: " .. newTempo)
    --we need to change the speed factor, based on the song's original
    --tempo to get the target 'newTempo'
    local targetFactor = newTempo / SKCoronaSynth.baseBPM
    
    print("Speed multiplier: " .. targetFactor)
    speedFactor = targetFactor
    
end

local function listener(event)
    
    
    
    
    
    if SKCoronaSynth.isOn == false then
        return
    end
    
    
    
    
    
    deltaTime = event.time - lastTime
    
    if deltaTime > 100 then
        deltaTime = 10
    end
    
    
    lastTime = event.time
    elapsedTime = (elapsedTime + deltaTime * speedFactor ) 
    
    --now we should be able to loop through the score tracks, one at a time, and see if they need to be played:
    for trackParser = 2, #tracks do
        
        local track1 = tracks[trackParser]
        local track1Length = #track1
        
        local deleteMe = true
        if track1Length > 0 then
            
            --          print("track " .. trackParser .. " length in notes: " .. track1Length)
            if track1[1][1] == "note"  then
                deleteMe = false
                --              print ("Note!")
                
                --check to see if we need to play it yet:
                local startTime = ( track1[1][2]     ) + musicStart   
                --              print("Start time:" ..startTime , "lapse time:" .. elapsedTime)
                local duration = track1[1][3] / speedFactor --addition for cutting down the note durations if you cut the time between notes
                local channel =  track1[1][4] + 1   --TODO  make sure we have a synth for each channel, otherwise we do not play
                --  print("Channel: "..channel)
                local noteNumber = track1[1][5]
                local velocity = track1[1][6]
                
                --can we play the note yet?
                if startTime < elapsedTime then
                    
                    if channel == 10 then    --channel 10 should always be percussion
                        SKCoronaSynth:playDrumNote(noteNumber,velocity)
                    else
                        -- play regular note here
                        SKCoronaSynth.synths[channel]:playNoteByMIDINumber(noteNumber , duration, velocity * channelVolumeFactor , channel )
                    end
                    deleteMe = true
                else
                end
            end
            
            if deleteMe == true then
                track1[1]= nil
                table.remove(track1, 1)
            end
        end 
    end
    
    
    
    
    
end
Runtime:addEventListener("enterFrame", listener)





return SKCoronaSynth

