_G.NoSameSapm = NoSameSapm or {}
NoSameSapm.path = ModPath
NoSameSapm.save_path = SavePath .. "NoSameSapm.txt"
NoSameSapm.settings = {
    nss_hud_choice = 1,
	nsms_record = 11,
	nss_log_enabled = false
}

function NoSameSapm:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function NoSameSapm:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

Hooks:Add("LocalizationManagerPostInit", "NoSameSapm_LocalizationManagerPostInit", function(loc)
	local t = NoSameSapm.path .. "loc/"
	for _, filename in pairs(file.GetFiles(t)) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(t .. filename)
			return
		end
	end
	loc:load_localization_file(t .. "english.txt")
end)

Hooks:Add("MenuManagerInitialize", "NoSameSapm_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.no_same_spam_hud_choice_callback = function(self,item)
		local value = tonumber(item:value())
		NoSameSapm.settings.nss_hud_choice = value
		NoSameSapm:Save()
	end
	
	MenuCallbackHandler.no_same_spam_record_bar_callback = function(self,item)
		local value = math.floor(item:value())
		NoSameSapm.settings.nsms_record = value
		NoSameSapm:Save()
	end
	
	MenuCallbackHandler.no_same_spam_log_file_callback = function(self,item)
		local value = item:value() == "on"
		NoSameSapm.settings.nss_log_enabled = value
		NoSameSapm:Save()
	end
	
	MenuCallbackHandler.no_same_spam_back = function(self)
		NoSameSapm:Save()
	end
	
	NoSameSapm:Load()
	MenuHelper:LoadFromJsonFile(NoSameSapm.path .. "menu/options.txt", NoSameSapm, NoSameSapm.settings)
end)