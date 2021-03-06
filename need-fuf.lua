-- need-fuf.lua
-- ver 0.9
-- Hardcore fulfill need for Friends & Family
-- 
--

utils=require('utils')

validArgs = utils.invert({
    'help'
})
local friend_need_id = 7
local family_need_id = 8
local args = utils.processArgs({...}, validArgs)
local helpme = [===[
Hardcore fulfill need for Friends & Family

This jsut filles the need for it.
Does not remove the need in case we can fix it better later.

Quite cheaty but as long as F&F is so broken, 
i dont see a elegant fix for it.

arguments:
    -help 
        Display this text
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
    end    
	if (need_index ~= -1 ) then 
        return needs[need_index]
    end
    return nil
end

--######
--Main
--######

function fulfill()
    local patchcount = 0;
    for i, unit in ipairs(citizen) do
        local need = findNeed(unit,friend_need_id)
        if (need ~= nil ) then 
			if ( need.focus_level < -1000) then 
                need.focus_level = 0 
                need.need_level = 1
                patchcount = patchcount +1
			end
        end
        need = findNeed(unit,family_need_id)
        if (need ~= nil ) then  
		    if ( need.focus_level < -1000) then 
                need.focus_level = 0 
                need.need_level = 1
                patchcount = patchcount +1
			end
        end
        
    end
    dfhack.println("need-fuf      | Patched: "..patchcount ) 
end


if (args.help) then 
    print(helpme)
    return
end

fulfill()
