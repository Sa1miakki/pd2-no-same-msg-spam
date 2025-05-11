local orig__receive_message = ChatManager._receive_message
local orig_receive_message_by_peer = ChatManager.receive_message_by_peer

NoSameSapm._path = NoSameSapm.path .. "MessageRecord/"

nsms_total_line = nss_total_line or 0 

NSMS_main_table = NSS_main_table or {}
NSMS_main_times = NSS_main_times or {}
NSMS_main_record = NSS_main_record or {}

local function writeline(s)
    if NoSameSapm.settings.nss_log_enabled then
		local current_time = os.date("*t")
	    local logtime = string.format("%02d-%02d-%02d.txt", current_time.year, current_time.month, current_time.day)
        local file = io.open(NoSameSapm._path .. logtime, "a")
	    local s = s .. string.format(" (%02d-%02d-%02d %02d:%02d:%02d) \n", current_time.year, current_time.month, current_time.day, current_time.hour, current_time.min, current_time.sec)
	    if file then
		    file:write(s)
		    file:close()
		end
	end
end

local function running(mod)
    if tostring(mod) == "VOIDUI" and NoSameSapm.settings.nss_hud_choice == 2 then
	    return true
	elseif tostring(mod) == "VANILLA" and NoSameSapm.settings.nss_hud_choice == 1 then
	    return true
	elseif tostring(mod) == "VANILLAPLUS" and NoSameSapm.settings.nss_hud_choice == 3 then
	    return true
	elseif tostring(mod) == "CUSTOM" and NoSameSapm.settings.nss_hud_choice == 4 then
	    return true
	end
end

function ChatManager:_receive_message(channel_id, name, message, color, icon)
	if name and message and (channel_id == 1 or channel_id == 2) then
	    nsms_total_line = nsms_total_line + 1
		
		local teststr2 = string.format("Received '%s : %s' at channel %s. Total lines: %s", name, message, channel_id, nsms_total_line)
	    writeline(teststr2)
		
		NSMS_main_table[name] = NSMS_main_table[name] or {}
		
		table.insert(NSMS_main_table[name], nsms_total_line,{
		message,
		nsms_total_line})
		
		for i = nsms_total_line - NoSameSapm.settings.nsms_record, nsms_total_line do
		    if NSMS_main_table[name][i] and message == NSMS_main_table[name][i][1] and i ~= nsms_total_line then
		        
				local teststr = string.format("!!%s's msg : '%s' is same as line %s!!", name, NSMS_main_table[name][i][1], i)
		        writeline(teststr)
		
				NSMS_main_times[i] = NSMS_main_times[i] and NSMS_main_times[i] + 1 or 2
				  
			    table.remove(NSMS_main_table[name], nsms_total_line)
				
				local newstr = string.format("%s: %s (x%s)", name, message, NSMS_main_times[i])
				
				if NSMS_main_record[i] and NSMS_main_record[i][1] then
				   NSMS_main_record[i][1]:set_text(newstr)
				end
			
			
				if running("VANILLA") and NSMS_ingame_record then
				    if NSMS_ingame_record[2 * i - 1] and NSMS_ingame_record[2 * i - 1][1] then
				        NSMS_ingame_record[2 * i - 1][1]:set_text(newstr)
				    end
				elseif running("VOIDUI") and NSMS_ingame_record then
				    local time = VoidUI.options.chattime == 2 and "[".. os.date('!%X', managers.game_play_central:get_heist_timer()) .. "] " or "[".. os.date('%X') .. "] "
					if NSMS_ingame_record[2 * i - 1] and NSMS_ingame_record[2 * i - 1][1] and NSMS_ingame_record[2 * i - 1][2] then
					    NSMS_ingame_record[2 * i - 1][1]:set_text(time..newstr)
					    NSMS_ingame_record[2 * i - 1][2]:set_text(time..newstr)
					end
				elseif ( running("CUSTOM") or running("VANILLAPLUS") ) and NSMS_ingame_record then
				    local heisttime = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0
		            local hours = math.floor(heisttime / (60*60))
		            local minutes = math.floor(heisttime / 60) % 60
		            local seconds = math.floor(heisttime % 60)
				    local time_format_text
		            if hours > 0 then
			            time_format_text = string.format("%d:%02d:%02d", hours, minutes, seconds)
		            else
			            time_format_text = string.format("%02d:%02d", minutes, seconds)
		            end
					if NSMS_ingame_record[2 * i - 1] and NSMS_ingame_record[2 * i - 1][1] and NSMS_ingame_record[2 * i - 1][2] then
					    NSMS_ingame_record[2 * i - 1][1]:set_text(time_format_text)
				        NSMS_ingame_record[2 * i - 1][2]:set_text(newstr)
					end
				end
				
				nsms_total_line = nsms_total_line - 1
				self._this_line_dup = true
				break
			else
			    self._this_line_dup = false
            end
		end
		
		if not self._this_line_dup then
		    orig__receive_message(self, channel_id, name, message, color, icon)
		end
		
	else
        orig__receive_message(self, channel_id, name, message, color, icon)
	end
end

function ChatGui:receive_message(name, message, color, icon)
	if not alive(self._panel) or not managers.network:session() then
		return
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local local_peer = managers.network:session():local_peer()
	local peers = managers.network:session():peers()
	local len = utf8.len(name) + 1
	local x = 0
	local icon_bitmap = nil

	if icon then
		local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		icon_bitmap = scroll_panel:bitmap({
			y = 1,
			texture = icon_texture,
			texture_rect = icon_texture_rect,
			color = color
		})
		x = icon_bitmap:right()
	end

	local line = scroll_panel:text({
		halign = "left",
		vertical = "top",
		hvertical = "top",
		wrap = true,
		align = "left",
		blend_mode = "normal",
		word_wrap = true,
		y = 0,
		layer = 0,
		text = name .. ": " .. message,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		x = x,
		w = scroll_panel:w() - x,
		color = color
	})
	local total_len = utf8.len(line:text())

	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)

	local _, _, w, h = line:text_rect()

	line:set_h(h)

	local line_bg = scroll_panel:rect({
		hvertical = "top",
		halign = "left",
		layer = -1,
		color = Color.black:with_alpha(0.5)
	})

	line_bg:set_h(h)
	line:set_kern(line:kern())
	table.insert(self._lines, {
		line,
		line_bg,
		icon_bitmap
	})
	table.insert(NSMS_main_record, {
		line,
		line_bg,
		icon_bitmap
	})
	self:_layout_output_panel()

	if not self._focus then
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
		self:start_notify_new_message()
	end
end

