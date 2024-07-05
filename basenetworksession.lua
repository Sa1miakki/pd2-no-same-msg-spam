Hooks:PostHook(BaseNetworkSession, "on_entered_lobby", "nsms_on_entered_lobby", function()
	nsms_total_line = 0
	NSMS_main_table = {}
	NSMS_main_times = {}
	NSMS_main_record = {}
	NSMS_ingame_record = {}
end)