-- need-all.lua
-- ver 0.9
-- Script-Family to automate and fix the Need-System
-- 
--

local utils=require('utils')
local repeatUtil = require('repeat-util')


validArgs = utils.invert({
    'start',
    'stop',
    'help',
})

local args = utils.processArgs({...}, validArgs)

local helpme = [===[
Fullfill all needs without being "cheaty"
The needs are fixed or patched in a way to make it possible to fulfill them
This is done very diffrent depending on the broken need
SETUP:
	need-religion
		-No Setup needed
	need-acquire
		-An stockpile full of trinkets 
	need-goodmeal
		-No Setup needed
	need_fuf 
		-No Setup needed
	need_wander
		-An active gather Zone with plants/fruits to gather (best underground)
	need_help
		-Gazeing Animals in Cages 
	need_craft
		-Few Workshops for this Craft ( default stonecraft)
		-This Workshops only accept lower skill workers (over manager)
		-This Workshops have repeated Craft Tasks qued
	need_training
		-Minimum 1 squad with the name "CIVGYM"
		-An assigned squadleader that is good in teaching
		-All other Places unassigned
		-An assigned Barracks for this squads (best underground)
		-Activ Training orders for this Squads
	
	Dwarfs with "Alchemy Labor" are ignored!
    if you want to run the subscripts with your own settings just edit this script-file
    
arguments:
    -help 
        Display this text
    -start
        runs all need-subscripts automaticly
    -stop
        stops all need-subscripts
]===]


function stop()
    repeatUtil.cancel("need-religion")
    repeatUtil.cancel("need-acquire")
    repeatUtil.cancel("need-goodmeal")
    repeatUtil.cancel("need_fuf")
	dfhack.run_command("need-help -stop")
	dfhack.run_command("need-wander -stop")
	dfhack.run_command("need-craft -stop")
	dfhack.run_command("need-training -stop")
	repeatUtil.cancel("need-value")
	
end
-- TOEDIT feel free to add your arguments to the sup-scripts here
-- e.g.  "need-craft -start -craftID 47 "to enable Weaponsmith instead of Stonecraft
function start()
	run_need_value()
    repeatUtil.scheduleUnlessAlreadyScheduled("need-religion",1,'months',run_need_religion)
    repeatUtil.scheduleUnlessAlreadyScheduled("need-acquire",3,'days',run_need_acquire)
    repeatUtil.scheduleUnlessAlreadyScheduled("need-goodmeal",1,'months',run_need_goodmeal)
    repeatUtil.scheduleUnlessAlreadyScheduled("need_fuf",1,'months',run_need_fuf)
	dfhack.run_command("need-help -start")
	dfhack.run_command("need-wander -start")
	dfhack.run_command("need-craft -start")
	dfhack.run_command("need-training -start")
	repeatUtil.scheduleUnlessAlreadyScheduled("need-value",1000,'ticks',run_need_value)
end 

function run_need_value()
	dfhack.run_command("need-value")
end
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
    start()
    running = true    
    return
end


if ( running ) then
	dfhack.println("use -help for help")
	dfhack.println("use -stop to disable")
    dfhack.println("Status: Enabled")
else
	dfhack.println("use -help for help")
	dfhack.println("use -start to enable")
    dfhack.println("Status: Disabled")
end
