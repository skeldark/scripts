-- need-labor.lua
-- ver 0.9
-- Assign jobs to dwarfs to let them fulfill their needs
-- Wander , Help-Someone, Craft-item
local repeatUtil = require 'repeat-util'
local utils=require('utils')

validArgs = utils.invert({
    'start',
    'stop',
    't_help',
    't_craft',
    't_wander',
    'stone',
    'armor',
    'weapon'
})

local args = utils.processArgs({...}, validArgs)


local helpme = [===[
Enables Labor according to needs of dwarfs

You have to use -stop before you save!
If you dont, the temporary activated labors stay active after loading


SETUP:
You need :
    -An Area that is marked for gather/ pick fruit with stuff to pick
    
    -Extra Workshops depending on your Crafttask that are filled with Infinity-Repeat Tasks
    (Forbit high Skill-Worker in this shops over manager to make sure you main crafter is not doing this Tasks)
    
    -Some grazing Animals in Cages, that needs to be feed.
    

arguments:    
    -start
        Starts the service
        If a labor that fullfills a need is allready activ on first start of this script, this dwarf/labor is ignored

    -stop
        Stops the service
        All labors that this script activated, will be deactivate
        
    -help
        Display this Meassage
    
    // together with start:
    -stone
        DEFAULT
        Enable Stonecraft to fulfill craft item

    -armor
        Enable ArmorSmith to fulfill craft item
    
    -weapon
        Enable WeaponSmith to fulfill craft item
        
    -t_help
        Expects an integer value.
        The negativ need  threshhold to trigger for each citizen
        Default is 3000
        
    -t_craft
        Expects an integer value.
        The negativ need  threshhold to trigger for each citizen
        Default is 3000
        
    -t_wander
        Expects an integer value.
        The negativ need  threshhold to trigger for each citizen
        Default is 3000    
        
]===] 

local repeat_time = 1000   --ticks

local verbose = false
wander_threshold = -3000
local wander_need_id = 26
local wander_labor_id= 40

help_threshold = -3000
local help_need_id = 27
local help_labor_id= 16

craft_threshold = -3000
local craft_need_id = 13
craft_labor_id= 46  --7 stone 46 weapon 47 armor


--get all citizen
local citizen = {}
local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id
for n, unit in ipairs(df.global.world.units.all) do
        if unit.civ_id == my_civ and dfhack.units.isCitizen(unit) then
            if unit.profession ~= df.profession.BABY and unit.profession ~= df.profession.CHILD then
                table.insert(citizen, unit)
            end
        end
end

function checkautolabor() 
    local output, status, output2
    output, status = dfhack.run_command_silent("autolabor") 
    outuput2 =  string.sub(output, -3, -3)
    if ( outuput2 ~= "0" ) then return true end
    output, status = dfhack.run_command_silent("labormanager") 
    outuput2 =  string.sub(output, -8, -8)
    if ( outuput2 ~= "s" ) then return true end
    return false
end

function start() 
    if (  checkautolabor()  ) then
        dfhack.print("need-labor    | ")
        dfhack.color(12)
        dfhack.println("Autolabor or Labormanager is active!")
        dfhack.color(-1)
        dfhack.print("need-labor    | ")
        dfhack.color(12)
        dfhack.println("you cant run more then 1 labor script at a time!")
        dfhack.color(-1)
        return
    end
    dfhack.println("need-labor    | START")
    wander_count_todo = 0
    help_count_todo = 0
    craft_count_todo = 0
    craft_ignore_list =  {}
    help_ignore_list = {}
    wander_ignore_list = {}
    local ignorecount = 0
    --check who is doing the task right now and save the id so we ignore him in future runs
    for i, unit in ipairs(citizen) do
            if ( unit.status.labors[wander_labor_id]) then 
                    ignorecount = ignorecount +1
                    table.insert(wander_ignore_list, unit.hist_figure_id    )
            end
            if ( unit.status.labors[help_labor_id]) then
                ignorecount = ignorecount +1
                    table.insert(help_ignore_list, unit.hist_figure_id    )
            end
            if ( unit.status.labors[craft_labor_id]) then
                ignorecount = ignorecount+1
                    table.insert(craft_ignore_list, unit.hist_figure_id    )
            end
    end
    dfhack.println("need-labor    | " .. ignorecount  .. " preset Labors ignored!" )
    --clear_jobs()
    running = true
    repeatUtil.scheduleEvery("need-labor",repeat_time,'ticks',check)
end

function stop() 
-- removing all jobs that we created
    for i, unit in ipairs(citizen) do
        local name = dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true)
            switchLabor(unit,wander_need_id,wander_labor_id,-9999999,wander_ignore_list)
            switchLabor(unit,help_need_id,help_labor_id,-9999999,help_ignore_list)
            switchLabor(unit,craft_need_id,craft_labor_id,-9999999,craft_ignore_list)
    end
    running = false
    repeatUtil.cancel("need-labor")
    dfhack.println("need-labor    | STOP" ) 
end
     

function switchLabor(unit,need_id,labor_id,need_threshold,ignore_list) 
    --return if dwarf is in the ignore list    
    for _, value in pairs(ignore_list) do
        if value == unit.hist_figure_id then
            return 0
        end
    end
    local unitneed = find_need(unit,need_id)
    if (unitneed == nil ) then 
        return 0
    end
    
    -- Over threshold?
    local is = unit.status.labors[labor_id]
    local should = unitneed.focus_level  < need_threshold

    -- Activate or Deactivate labor depending on change in need since last run
    if ( should and  not is ) then
        unit.status.labors[labor_id] = true
        return 1
    end
    if ( not  should and is ) then
        unit.status.labors[labor_id] = false
        return -1
    end
    return 0
    
end



function check() 
    for i, unit in ipairs(citizen) do    
        local name = dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true)
        wander_count_todo = wander_count_todo + switchLabor(unit,wander_need_id,wander_labor_id,wander_threshold,wander_ignore_list)
        help_count_todo = help_count_todo + switchLabor(unit,help_need_id,help_labor_id,help_threshold,help_ignore_list)
        craft_count_todo = craft_count_todo + switchLabor(unit,craft_need_id,craft_labor_id,craft_threshold,craft_ignore_list)
    end
    dfhack.println("need-labor    | Wander: " .. wander_count_todo .. " Help: " ..  help_count_todo .. " Craft: " .. craft_count_todo )
end


function clear_jobs()
    for i, unit in ipairs(citizen) do
        local name = dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true)
        unit.status.labors[wander_labor_id] = false
        unit.status.labors[help_labor_id] = false
        unit.status.labors[craft_labor_id] = false
    end
    dfhack.println("ALL CLEAR")
end


function find_need(unit,need_id) 
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

if (args.help) then 
    print(helpme)
    return
end

if (args.stone) then
    craft_labor_id = 7
end
if (args.armor) then
    craft_labor_id = 47
end
if (args.weapon) then
    craft_labor_id = 46
end
if (args.t_help) then
    help_threshold = 0-tonumber(args.t_help)
end
if (args.t_craft) then
    craft_threshold = 0-tonumber(args.t_craft)
end
if (args.t_wander) then
    wander_threshold = 0-tonumber(args.t_wander)
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
    dfhack.println("need-labor    | Enabled")
else
    dfhack.println("need-labor    | Disabled")
end





