-- need-fuf.lua
-- ver 0.9
-- Script-Family to automate and fix the Need-System
-- 
local utils=require('utils')
local repeatUtil = require 'repeat-util'

validArgs = utils.invert({
    'start',
    'stop',
    'help',
    'nofuf'
})

local args = utils.processArgs({...}, validArgs)

local helpme = [===[
Fullfill all needs without being "cheaty"
The needs are fixed or patched in a way to make it possible to fulfill them
This is done very diffrent depending on the broken need
Look up the sub-scripts for details:
    need-religion
    need-acquire
    need-goodmeal
    need_fuf 
    
    if you want to run the subscripts with your own settings just edit this script-file
    
arguments:
    -help 
        Display this text
    -start
        runs all need-subscripts  once per ingame day
    -stop
        stops all need-subscripts
    -nofuf
        does not activate need-fuf
]===]


local fuf_enable = true

function stop()
    repeatUtil.cancel("need-religion")
    repeatUtil.cancel("need-acquire")
    repeatUtil.cancel("need-goodmeal")
    repeatUtil.cancel("need_fuf")
end



function start()
    repeatUtil.scheduleUnlessAlreadyScheduled("need-religion",1,'months',run_need_religion)
    repeatUtil.scheduleUnlessAlreadyScheduled("need-acquire",10,'days',run_need_acquire)
    repeatUtil.scheduleUnlessAlreadyScheduled("need-goodmeal",1,'months',run_need_goodmeal)
    if ( fuf_enable) then repeatUtil.scheduleUnlessAlreadyScheduled("need_fuf",1,'months',run_need_fuf) end
end 

-- TOEDIT feel free to add your arguments to the sup-scripts here
function run_need_religion()
    dfhack.run_command("need-religion")
end

function run_need_acquire()
    dfhack.run_command("need-acquire")
end

function run_need_goodmeal()
    dfhack.run_command("need-goodmeal")
end

function run_need_fuf()
    dfhack.run_command("need-fuf")
end

if (args.help) then 
    print(helpme)
    return
end
    
	
if (args.stop) then
    if (running) then stop() end
    running = false
    return
end 


if (args.start) then
    if ( running ) then stop() end
	if (args.nofuf) then
        fuf_enable = false
    end
    start()
    running = true    
    return
end


if ( running ) then
    dfhack.println("Enabled")
else
    dfhack.println("Disabled")
end
