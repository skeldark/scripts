-- need-training.lua
-- ver 0.9
-- Assign military training to dwarfs to let them fulfill their needs
--
--

local repeatUtil = require 'repeat-util'
local utils=require('utils')

validArgs = utils.invert({
    'start',
    'stop',
})
local args = utils.processArgs({...}, validArgs)
local scriptname = "need-training"
local repeat_time = 1000   --ticks
local ignore_flag= 30
local ignore_count = 0
local need_id = 14
local squadname ="CIVGYM"
local helpme = [===[
Enables Milatary Training to fullfill Train need

SETUP:
		-Minimum 1 squad with the name "CIVGYM"
		-An assigned squadleader that is good in teaching
		-All other Places unassigned
		-An assigned Barracks for this squads (best underground)
		-Activ Training orders for this Squads
		-Dwarfs with "Alchemy Labor" are ignored
	
arguments:    
    -start
        Starts the service
        If a labor that fullfills a need is allready activ on first start of this script, this dwarf/labor is ignored

    -stop
        Stops the service
        All labors that this script activated, will be deactivate
        
    -help
        Display this Meassage
    
    -t
        Expects an integer value.
        The negativ need  threshhold to trigger for each citizen
        Default is 3000
]===] 

--######
--Helper
--######
function getAllCititzen()
local citizen = {}
local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id
for n, unit in ipairs(df.global.world.units.all) do
        if unit.civ_id == my_civ and dfhack.units.isCitizen(unit) then
            if unit.profession ~= df.profession.BABY and unit.profession ~= df.profession.CHILD then
                if ( not unit.status.labors[ignore_flag] ) then
					table.insert(citizen, unit)				
				else	
					ignore_count = ignore_count +1 
				end
            end
        end
end
return citizen
end
local citizen = getAllCititzen()


function findNeed(unit,need_id) 
    local needs =  unit.status.current_soul.personality.needs
    local need_index = -1
    for k = #needs-1,0,-1 do
        if needs[k].id == need_id then
            need_index = k
            break
        end
    end    if (need_index ~= -1 ) then 
        return needs[need_index]
    end
    return nil
end

--######
--Main
--######

-- Find all training squads
-- Abort if no squads found
function checkSquads()
	local squads = {}
	local count = 0
	for n, mil in ipairs(df.global.world.squads.all) do
		if (mil.alias == squadname) then 
			local leader = mil.positions[0].occupant 
			if ( leader ~= -1) then
				table.insert(squads,mil)
				count = count +1
			end
		end
	end
	if ( count == 0 ) then
		dfhack.print(scriptname.." | ")
        dfhack.printerr('ERROR: You need a squad with the name ' .. squadname)
		dfhack.print(scriptname.." | ")
		dfhack.printerr('That has an activ Squad Leader')
		dfhack.color(-1)		
		return nil
	end
	return squads
end

function addTraining(squads,unit)
	for n, squad in ipairs(squads) do
		for i=1,9,1   do
			if ( unit.hist_figure_id  == squad.positions[i].occupant ) then
				return true
			end
		end
	end
	for n, squad in ipairs(squads) do
		for i=1,9,1   do
			if ( squad.positions[i].occupant  == -1 ) then
				squad.positions[i].occupant = unit.hist_figure_id 
				return true
			end
		end
	end
	return false
end

function removeTraining(squads,unit) 
	for n, squad in ipairs(squads) do
		for i=1,9,1   do
			if ( unit.hist_figure_id  == squad.positions[i].occupant ) then
				squad.positions[i].occupant = -1
				return true
			end
		end
	end
	return false
end

function removeAll(squads) 
	if ( squads == nil) then return end
	for n, squad in ipairs(squads) do
		for i=1,9,1   do
			squad.positions[i].occupant = -1
		end
	end
end


function check()
	local squads = checkSquads()
	local intraining_count = 0
	local inque_count = 0
	if ( squads == nil)then return end
	for n, unit in ipairs(citizen) do
		local need = findNeed(unit,need_id)
		if ( need  ~= nil ) then
			if ( need.focus_level  < threshold ) then
				local bol = addTraining(squads,unit)
				if ( bol ) then intraining_count = intraining_count +1
				else 
					inque_count = inque_count +1
				end
			else
				removeTraining(squads,unit)
			end
		end
	end
	dfhack.println(scriptname .. " | IGN: " .. ignore_count .. " TRAIN: " .. intraining_count .. " QUE: " ..inque_count )
end


function start() 
	threshold = -5000
	dfhack.println(scriptname ..  " | START")
	if (args.t) then threshold = 0-tonumber(args.t) end
	running = true
	repeatUtil.scheduleEvery(scriptname,repeat_time,'ticks',check)
end

function stop()
	repeatUtil.cancel(scriptname)
	local squads = checkSquads()
	removeAll(squads)
	running = false
	dfhack.println(scriptname .. " | STOP")
end


if (args.help) then 
    print(helpme)
    return
end

if (args.stop) then
    if (running) then stop() end
    return
end 

if (args.start) then	
    if (running) then stop() end
    start()
    return
end

if ( running ) then
    dfhack.println(scriptname .."    | Enabled")
else
    dfhack.println(scriptname .."   | Disabled")
end


