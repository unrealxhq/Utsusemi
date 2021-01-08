_addon.name = 'Utsusemi'
_addon.author = 'Shiraj'
_addon.commands = {'utsu','ut'}
_addon.version = '0.0.1'

require('luau')
res = require('resources')

local player = windower.ffxi.get_player()
enabled = false
local utsuDelay = 1.5
latency = .5
lastUseCheck = os.clock()

name_index = {}
language = windower.ffxi.get_info().language:lower()
--Command function, list of commands
windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = T{...}
	 if command == 'on' then
		enabled = true
		log('Auto Utsusemi: ON')
	elseif command == 'off' then
		enabled = false
		log('Auto Utsusemi: OFF')
    elseif command == 'help' then
		log('[on|off] Enable / Disable Utsusemi')
		log('It is strongly recommended that you use the Itemizer addon alongside this one')
        local cmd = args[1]     
	else
		log('Error: Unknown command')
	end
------------------------------------------------------
--Code below is part of the cancel addon
	local command = table.concat({...},' ')
	if not command then return end
	local status_id_tab = command:split(',')
	status_id_tab.n = nil
	local ids = {}
	local buffs = {}
	for _,v in pairs(windower.ffxi.get_player().buffs) do
		for _,r in pairs(status_id_tab) do
			if windower.wc_match(res.buffs[v][language],r) or windower.wc_match(tostring(v),r) then
				cancel(v)
				break
			end
		end
	end
	

   
end)

function cancel(id)
	windower.packets.inject_outgoing(0xF1,string.char(0xF1,0x04,0,0,id%256,math.floor(id/256),0,0)) -- Inject the cancel packet
end

function utsu_check()
    if not enabled then return end
    local player = windower.ffxi.get_player()--Self explanitory 
    local job = player.main_job--Self explanitory 
    local utsu_buffs = S(player.buffs):intersection(S{444, 445, 446})--Stores Copy image: 2,3 and 4+ as buffs
	if enabled then --toggle
		if utsu_buffs:empty() then -- code runs if no Copy image 2,3 or 4+ is found on our player
			local spell_recasts = windower.ffxi.get_spell_recasts()--Grabs recasts of all spells
			if player.main_job == 'NIN' then 
				if spell_recasts[340] < latency then 
					windower.chat.input('/ma "Utsusemi: San" <me>')
					windower.send_command('cancel Copy Image')
				elseif spell_recasts[339] < latency then 
					windower.chat.input('/ma "Utsusemi: Ni" <me>')
					windower.send_command('cancel Copy Image')
				elseif spell_recasts[338] < latency then 
					windower.chat.input('/ma "Utsusemi: Ichi" <me>')
					windower.send_command('cancel Copy Image')
				end    
			elseif player.sub_job == 'NIN' then 
				if spell_recasts[339] < latency then 
					windower.chat.input('/ma "Utsusemi: Ni" <me>')
					windower.send_command('cancel Copy Image')
				elseif spell_recasts[338] < latency then 
					windower.chat.input('/ma "Utsusemi: Ichi" <me>')
					windower.send_command('cancel Copy Image')
				end    
			else
				windower.add_to_chat(205,'You do not have access to Utsusemi')
			end
		end 
	end 
end	
utsu_check:loop(.2)