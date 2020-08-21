-- need-goodmeal.lua
-- ver 0.9
-- Change the Preference of Food to a more broader range
-- 
--

local utils=require('utils')

validArgs = utils.invert({
    'help',
    'undo',
	'list'
})
local seed = false
local pss_counter=21416926
local args = utils.processArgs({...}, validArgs)

local helpme = [===[
Change the preference of food to a more broader range

Each Dwarfs gets randomly one of the folling broad preference applied
MEAT
EGG
CHEESE
PLANT_GROWTH
PLANT
FISH
[SEED] DEFAULT = off


arguments:
    -help 
        Display this text
    -undo
        Removes the added Preferenzes again
    -seed
        DEFAULT = off
        For extra "fun" include seed as a random Pref Categorie
	-list 
		List all dwarfs and their new Food Preference
		Does not change them
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
                table.insert(citizen, unit)
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
   
function modded( unit) 
    for i, pref in ipairs(unit.status.current_soul.preferences) do
        if ( pref.prefstring_seed == pss_counter) then
            return true
        end
    end
    return false
end

--Generates Random Food Type
local randomGen = randomGen or dfhack.random.new()        
function randomFood() 
    local irtype = {}
    irtype[0] = df.item_type.MEAT --47
    irtype[1]= df.item_type.EGG --87
    irtype[2] = df.item_type.CHEESE --70
    irtype[3] = df.item_type.PLANT_GROWTH --55 --fruit&leaves 
    irtype[4] = df.item_type.PLANT --53
    irtype[5] = df.item_type.FISH --48
    irtype[6] = df.item_type.SEEDS --52
    local nr = 6
    if (seed) then nr = 7 end
    local r = randomGen:random(nr)
    return irtype[r]
end
        
function undo()
    local removecounter = 0
    for i, unit in ipairs(citizen) do
        local b = modded(unit)
        local preflist = unit.status.current_soul.preferences
        if ( b ) then 
            for j, pref in ipairs(preflist)   do
                if ( pref.prefstring_seed == pss_counter) then
                    removecounter = removecounter +1
                    utils.erase_sorted(unit.status.current_soul.preferences,pref,'prefstring_seed')
                end
            end
        end
    end
    dfhack.println("need-goodmeal | Undid: ".. removecounter .. "  Preferences!") 
end

       
function list()
    for i, unit in ipairs(citizen) do
        local b = modded(unit)
        local preflist = unit.status.current_soul.preferences
        if ( b ) then 
            for j, pref in ipairs(preflist)   do
                if ( pref.prefstring_seed == pss_counter) then
				  dfhack.print(dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true)) 
				  local name = pref.item_type
				  if (pref.item_type== 47) then   name = "MEAT" end
				  if (pref.item_type== 87) then   name = "EGG" end
				  if (pref.item_type== 70) then   name = "CHEESE" end
				  if (pref.item_type== 55) then   name = "PLANT_GROWTH" end
				  if (pref.item_type== 53) then   name = "PLANT" end
				  if (pref.item_type== 48) then   name = "FISH" end
				  if (pref.item_type== 52) then   name = "SEEDS" end
				  dfhack.println(" : " .. name)
               end
            end
        end
    end
end

        
function selectFood()
    local itype
    local counter = 0
    for i, unit in ipairs(citizen) do
        --already modded?  
        local b = modded(unit)
        if ( not b ) then 
            counter = counter +1
            itype = randomFood()
            utils.insert_or_update(unit.status.current_soul.preferences, { new = true, type = 2 , item_type = itype , creature_id = itype , color_id = itype , shape_id = itype , plant_id = itype , item_subtype = 1 , mattype = -1 , matindex = -1 , active = true, prefstring_seed = pss_counter }, 'prefstring_seed')
        end
    end
    dfhack.println("need-goodmeal | Patched: ".. counter) 
end

if (args.help) then 
    print(helpme)
    return
end

if (args.seed) then 
    seed = true
end

if (args.undo) then 
    undo()
    return
end

if (args.list) then 
    list()
    return
end


selectFood()
     