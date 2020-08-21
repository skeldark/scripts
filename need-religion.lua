-- need-religion.lua
-- ver 0.9
-- Limit Number of Religions a Dwarf can have
--
--

local utils=require('utils')

validArgs = utils.invert({
    'help',
    'test',
    'n'
})
local deity_number = 3
local args = utils.processArgs({...}, validArgs)
local helpme = [===[
Limit Number of Religions a Dwarf can have
arguments:
    -test
        Display the Religion needs and the Deity Connections all Dwarfs have
        Does not do any changes
    -n
        Expects an integer value.
        Removes all Needs and social Connections above n deitys
        "-n 3" is advisted for a balanced Gameplay and the DEFAULT setting.
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
    end    if (need_index ~= -1 ) then 
        return needs[need_index]
    end
    return nil
end

--######
--Main
--######


function atest ()
    dfhack.println("TEST")
    for i, unit in ipairs(citizen) do
        -- Per citizen variables
        local count_needs = 0
        dfhack.print(dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true)) 
        needs =  unit.status.current_soul.personality.needs
        local count_needs = 0
        for i = #needs-1,0,-1 do
            if needs[i].id == 2 then
                count_needs = count_needs +1
            end
        end
        dfhack.print(" " .. count_needs) 
        
        local count_links = 0
        local hf = df.historical_figure.find(unit.hist_figure_id)
        for k, histfig_link in ipairs(hf.histfig_links) do
            if histfig_link._type == df.histfig_hf_link_deityst then
                count_links = count_links + 1
            end
        end
        dfhack.println(" " .. count_links) 
    end
end




function set_deities ()
    removed = 0
    for i, unit in ipairs(citizen) do
            count_needs = 0
            needs =  unit.status.current_soul.personality.needs
            hf = df.historical_figure.find(unit.hist_figure_id)    
            failed = 0
            for j = #needs-1,0,-1 do
                if needs[j].id == 2 then
                    count_needs = count_needs +1
                    if ( count_needs > deity_number)  then 
                            found = 0
                            for k = #hf.histfig_links-1,0,-1 do
                                    if hf.histfig_links[k]._type == df.histfig_hf_link_deityst then
                                    if needs[j].deity_id ==  hf.histfig_links[k].target_hf then
                                        hf.histfig_links[k]:delete()
                                        hf.histfig_links:erase(k)
                                        found = 1
										needs[j]:delete()
                                        needs:erase(j)
                                        break
                                    end
                                    end
                            end
                            if found == 1 then
                                removed = removed + 1
                            else
                                failed = failed +1
                            end
                    end
                end
            end    
            if ( failed > 0 ) then
            dfhack.print("need-religion | " .. dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true))
            dfhack.println(failed .. " FAILED! Could not find Deity-Link!")
            end
    end
    dfhack.println("need-religion | Max-Religion: " .. deity_number .. " Patched: " .. removed)
end

if (args.test) then
    atest()
    return
end

if (args.help) then 
    print(helpme)
    return
end

if (args.n) then
    deity_number = tonumber(args.n)
end

set_deities()
