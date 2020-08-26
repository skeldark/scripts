-- need-help.lua
-- ver 0.9
-- Assign jobs to dwarfs to let them fulfill their needs
--
--

local repeatUtil = require ('repeat-util')
local utils=require('utils')

validArgs = utils.invert({
    'start',
    'stop',
    't',
	'help'
})
local args = utils.processArgs({...}, validArgs)
local scriptname = "need-help"
local repeat_time = 1000   --ticks
local need_id = 27
local labor_id= 16
local count_todo = 0
local ignore_flag= 30
local ignore_count = 0
local helpme = [===[
Enables Feed Animal according to need Help Somebody

SETUP:
	-Gazeing Animals in Cages 
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

function findSkill(unit,skill_id) 
    local skills =  unit.status.current_soul.skills
    local index = -1
    for k = #skills-1,0,-1 do
        if skills[k].id == skill_id then
            index = k
            break
        end
    end
    if (index ~= -1 ) then 
        return skills[index]
    end
    return nil
end

function switchLabor(unit,need_id,labor_id,need_threshold,skill_threshold)   
    local need = findNeed(unit,need_id)
    if (need == nil ) then return  end
    -- Over threshold?
    local is = unit.status.labors[labor_id]
    local should = need.focus_level  < need_threshold
    -- Activate or Deactivate labor depending on change in need since last run
    if ( should and  not is ) then
        unit.status.labors[labor_id] = true
    end
    if ( not  should and is ) then
        unit.status.labors[labor_id] = false
    end
end

function isOtherLaborScript() 
    local output, status, output2
    output, status = dfhack.run_command_silent("autolabor") 
    output2 =  string.sub(output, -3, -3)
    if ( output2 ~= nil) then
		if (  output2 == "1" ) then 
			printerror() 
			return true 
		end
	end
    output, status = dfhack.run_command_silent("labormanager") 
    output2 =  string.sub(output, -9, -3)
    if ( output2 ~= nil) then
		if (  output2 == "Enabled" ) then 
			printerror() 
			return true 
		end
	end
	return false
end

function printerror() 
	dfhack.color(12)
    dfhack.println("Autolabor or Labormanager is active!")
    dfhack.println("you can not run more then 1 labor script at a time!")
    dfhack.color(-1)
end

function findNeed(unit,need_id) 
    local needs =  unit.status.current_soul.personality.needs
    local need_index = -1
    for k = #needs-1,0,-1 do
        if needs[k].id == need_id then
            need_index = k
            break
        end
    end    
	if (need_index ~= -1 ) then 
        return needs[need_index]
    end
    return nil
end

--######
--Main
--######

function start() 
    dfhack.println(scriptname .."     | START")
    if ( isOtherLaborScript()  ) then   return end
    -- Setting Global vars for future runs
	threshold = -3000
    if (args.t) then threshold = 0-tonumber(args.t) end
    running = true
	--Set repeat task to check function
    repeatUtil.scheduleEvery(scriptname,repeat_time,'ticks',check)
end


function stop() 
	-- disable all labors that this script enabled
    for i, unit in ipairs(citizen) do
            switchLabor(unit,need_id,labor_id,-9999999)
    end
    running = false
	--removing repeat task
    repeatUtil.cancel(scriptname)
    dfhack.println(scriptname .."     | STOP" ) 
end
     
	 
function check() 
	local count_active  = 0
    for i, unit in ipairs(citizen) do 
		if ( unit.status.labors[ignore_flag] ) then 
			count_ignored = count_ignored +1 
		else	
			switchLabor(unit,need_id,labor_id,threshold)
			if ( unit.status.labors[labor_id] ) then 
				count_active = count_active + 1
			end
		end
	end
    dfhack.println(scriptname.."     | IGN: " .. ignore_count .. " TODO: " .. count_active)
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
