-- need-value.lua
-- ver 0.9
-- Outputs average need value
--
--

function avgNeed()
	local avg = 0
	local count = 0
	local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id
	for n, unit in ipairs(df.global.world.units.all) do
        if unit.civ_id == my_civ and dfhack.units.isCitizen(unit) then
            if unit.profession ~= df.profession.BABY and unit.profession ~= df.profession.CHILD then
                count = count +1
				local needs =   unit.status.current_soul.personality.needs
				for k = #needs-1,0,-1 do
					if (needs[k] ~= nil ) then  
						avg = avg + needs[k].focus_level
					end
				end
			end    
        end
    end
	avg = math.floor(avg/count)
	dfhack.println("need-avg      | AVG NEED: " .. avg)
end

avgNeed()