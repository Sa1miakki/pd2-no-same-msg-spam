NSMS_ingame_record = NSMS_ingame_record or {}

function HUDChat:receive_message(name, message, color, icon)
    --#### VOID UI ####--
	if NoSameSapm.settings.nss_hud_choice == 2 then
	local output_panel = self._panel:child("output_panel")
		local scrollbar = self._panel:child("scrollbar_panel"):child("scrollbar")
		local peer = (managers.network and managers.network:session() and managers.network:session():local_peer():name() == name and managers.network:session():local_peer()) or (managers.network and managers.network:session() and managers.network:session():peer_by_name(name))
		local character = peer and " (".. managers.localization:text("menu_" ..peer:character())..")" or ""
		local full_message = name .. (VoidUI.options.show_charactername and peer and peer:character() and character or "") .. ": " .. message
		if name == managers.localization:to_upper_text("menu_system_message") then 
			name = message
			full_message = name
		end
		if VoidUI.options.chattime > 1 and managers.game_play_central then
			local time = VoidUI.options.chattime == 2 and "[".. os.date('!%X', managers.game_play_central:get_heist_timer()) .. "] " or "[".. os.date('%X') .. "] "
			full_message =  time .. full_message
			name = time .. name
		end
		local len = utf8.len(name) + (VoidUI.options.show_charactername and utf8.len(character) or 0) + 1 
		local panel = output_panel:panel({
			name = tostring(#self._lines),
			w = self._output_width
		})
		local line = panel:text({
			name = "line",
			text = full_message,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_small_font_size * 0.85 * self._scale,
			x = 0,
			y = 0,
			align = "left",
			halign = "left",
			vertical = "bottom",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = color,
			layer = 0
		})
		line:set_w(output_panel:w() - line:left())
		local line_shadow = panel:text({
			name = "line_shadow",
			text = full_message,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_small_font_size * 0.85 * self._scale,
			x = 1,
			y = 1,
			align = "left",
			halign = "left",
			vertical = "bottom",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.black,
			alpha = 0.9,
			layer = -1
		})
		line_shadow:set_w(output_panel:w() - line:left())
		
		local total_len = utf8.len(line:text())
		local line_height = HUDChat.line_height
		local lines_count = line:number_of_lines()
		self._lines_count = self._lines_count + lines_count
		line:set_range_color(0, len, color)
		line:set_range_color(len, total_len, Color.white)
		panel:set_h(HUDChat.line_height * self._scale * lines_count)
		line:set_h(panel:h())
		line_shadow:set_h(panel:h())
		panel:set_bottom(self._input_panel:bottom())
		table.insert(self._lines, {
			panel = panel,
			message = message,
			name = name,
			character = character
		})
		table.insert(NSMS_ingame_record, {
		line,
		line_shadow
	    })
		
		line:set_kern(line:kern())
		self:_layout_custom_output_panel()
		line:animate(callback(self, self, "_animate_message_received"), line_shadow)
		if not self._focus then
			local output_panel = self._panel:child("output_panel")
			output_panel:stop()
			output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
			output_panel:animate(callback(self, self, "_animate_fade_output"))
		end
	elseif NoSameSapm.settings.nss_hud_choice == 1 then
	--##VANILLA##--
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
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
		color = color
	})
	local total_len = utf8.len(line:text())

	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)

	local _, _, w, h = line:text_rect()

	line:set_h(h)
	table.insert(self._lines, {
		line,
		icon_bitmap
	})
	line:set_kern(line:kern())
	self:_layout_output_panel()
    table.insert(NSMS_ingame_record, {
		line,
		icon_bitmap
	})
	
	if not self._focus then
		scroll_panel:set_bottom(output_panel:h())
		self:set_scroll_indicators()
	end

	if not self._focus then
		local output_panel = self._panel:child("output_panel")

		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
	
	elseif NoSameSapm.settings.nss_hud_choice == 3 then
	    --##VANILLAHUDPLUS##--
		local output_panel = self._panel:child("output_panel")
		local scroll_bar_bg = output_panel and output_panel:child("scroll_bar_bg")
		local x_offset = HUDChat.COLORED_BG and 2 or 0

		local msg_panel = output_panel:panel({
			name = "msg_" .. tostring(#self._messages),
			w = output_panel:w() - scroll_bar_bg:w(),
		})
		if HUDChat.SCROLLBAR_ALIGN == 1 then
			msg_panel:set_left(scroll_bar_bg:w())
		end
		local msg_panel_bg
		if HUDChat.COLORED_BG then
			msg_panel_bg = msg_panel:rect({
				name = "bg",
				alpha = 0.25,
				color = color,
				w = msg_panel:w(),
			})
		else
			msg_panel_bg = msg_panel:bitmap({
				name = "bg",
				alpha = 1,
				color = Color.white / 3,
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {84, 0, 44, 32},
			})
		end

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

		local time_text = msg_panel:text({
			name = "time",
			visible = VHUDPlus:getSetting({"HUDChat", "HEISTTIMER"}, true),
			text = time_format_text,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			h = HUDChat.LINE_HEIGHT,
			w = msg_panel:w(),
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local _, _, w, _ = time_text:text_rect()

		if VHUDPlus:getSetting({"HUDChat", "HEISTTIMER"}, true) then
		    x_offset = x_offset + w + 2
		else
		    x_offset = x_offset
		end

		if icon then
			local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
			local icon_bitmap = msg_panel:bitmap({
				name = "icon",
				texture = icon_texture,
				texture_rect = icon_texture_rect,
				color = color,
				h = HUDChat.LINE_HEIGHT * 0.85,
				w = HUDChat.LINE_HEIGHT * 0.85,
				x = x_offset,
				layer = 1,
			})
			icon_bitmap:set_center_y(HUDChat.LINE_HEIGHT / 2)
			x_offset = x_offset + icon_bitmap:w() + 1
		end

		local message_text = msg_panel:text({
			name = "msg",
			text = name .. ": " .. message,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			w = msg_panel:w() - x_offset,
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local no_lines = message_text:number_of_lines()

		message_text:set_range_color(0, utf8.len(name) + 1, color)
		message_text:set_h(HUDChat.LINE_HEIGHT * no_lines)
		message_text:set_kern(message_text:kern())
		msg_panel:set_h(HUDChat.LINE_HEIGHT * no_lines)
		msg_panel_bg:set_h(HUDChat.LINE_HEIGHT * no_lines)
		if not HUDChat.COLORED_BG then
			local _, _, msg_w, _ = message_text:text_rect()
			msg_panel_bg:set_width(x_offset + msg_w + 2)
		end

		self._total_message_lines = self._total_message_lines + no_lines
		table.insert(self._messages, { panel = msg_panel, name = name, lines = no_lines })
        table.insert(NSMS_ingame_record, {
		time_text,
		message_text
	    })
		self:_layout_output_panel()
		if not self._focus then
			local output_panel = self._panel:child("output_panel")
			output_panel:stop()
			output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
			output_panel:animate(callback(self, self, "_animate_fade_output"))
		end
	elseif NoSameSapm.settings.nss_hud_choice == 4 then
	    --##CUSTOM CHAT ##--
		local output_panel = self._panel:child("output_panel")
		local scroll_bar_bg = output_panel and output_panel:child("scroll_bar_bg")
		local x_offset = HUDChat.COLORED_BG and 2 or 0

		local msg_panel = output_panel:panel({
			name = "msg_" .. tostring(#self._messages),
			w = output_panel:w() - scroll_bar_bg:w(),
		})
		if HUDChat.SCROLLBAR_ALIGN == 1 then
			msg_panel:set_left(scroll_bar_bg:w())
		end
		local msg_panel_bg
		if HUDChat.COLORED_BG then
			msg_panel_bg = msg_panel:rect({
				name = "bg",
				alpha = 0.25,
				color = color,
				w = msg_panel:w(),
			})
		else
			msg_panel_bg = msg_panel:bitmap({
				name = "bg",
				alpha = 1,
				color = Color.white / 3,
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {84, 0, 44, 32},
			})
		end

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

		local time_text = msg_panel:text({
			name = "time",
			visible = HUDChat.SHOW_HEIST_TIME,
			text = time_format_text,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			h = HUDChat.LINE_HEIGHT,
			w = msg_panel:w(),
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local _, _, w, _ = time_text:text_rect()
		
		if HUDChat.SHOW_HEIST_TIME then
		    x_offset = x_offset + w + 2
		else 
		    x_offset = x_offset
		end

		if icon then
			local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
			local icon_bitmap = msg_panel:bitmap({
				name = "icon",
				texture = icon_texture,
				texture_rect = icon_texture_rect,
				color = color,
				h = HUDChat.LINE_HEIGHT * 0.85,
				w = HUDChat.LINE_HEIGHT * 0.85,
				x = x_offset,
				layer = 1,
			})
			icon_bitmap:set_center_y(HUDChat.LINE_HEIGHT / 2)
			x_offset = x_offset + icon_bitmap:w() + 1
		end

		local message_text = msg_panel:text({
			name = "msg",
			text = name .. ": " .. message,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			w = msg_panel:w() - x_offset,
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local no_lines = message_text:number_of_lines()

		message_text:set_range_color(0, utf8.len(name) + 1, color)
		message_text:set_h(HUDChat.LINE_HEIGHT * no_lines)
		message_text:set_kern(message_text:kern())
		msg_panel:set_h(HUDChat.LINE_HEIGHT * no_lines)
		msg_panel_bg:set_h(HUDChat.LINE_HEIGHT * no_lines)
		if not HUDChat.COLORED_BG then
			local _, _, msg_w, _ = message_text:text_rect()
			msg_panel_bg:set_width(x_offset + msg_w + 2)
		end

		self._total_message_lines = self._total_message_lines + no_lines
		table.insert(self._messages, { panel = msg_panel, name = name, lines = no_lines })
		table.insert(NSMS_ingame_record, {
		time_text,
		message_text
	    })

		self:_layout_output_panel()
		if not self._focus then
			local output_panel = self._panel:child("output_panel")
			output_panel:stop()
			output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
			output_panel:animate(callback(self, self, "_animate_fade_output"))
		end
	end
end