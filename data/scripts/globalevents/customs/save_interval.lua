-- To switch to minutes change " .. math.floor(interval/3600000) .. " hour(s)!" for " .. math.floor(interval/66000) .. " minutes!"
-- (configKeys.SAVE_INTERVAL_TIME) * 60 * 60 * 1000) for (configKeys.SAVE_INTERVAL_TIME) * 60 * 1000)

local function serverSave(interval)
	if configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL_CLEAN_MAP) then
		cleanMap()
	end

    saveServer()
    local message = "Server save complete. Next save in " .. math.floor(interval/3600000) .. " hour(s)!", MESSAGE_STATUS_WARNING
        Webhook.send("Server save", message, WEBHOOK_COLOR_WARNING)
        Game.broadcastMessage(message, MESSAGE_GAME_HIGHLIGHT)
end

local save = GlobalEvent("save")
function save.onTime(interval)
	local remaningTime = 60 * 1000
	if configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL) then
		local message = "The server will save all accounts within " .. (remaningTime/1000) .." seconds. \z
		You might lag or freeze for 5 seconds, please find a safe place."
		Game.broadcastMessage(message, MESSAGE_GAME_HIGHLIGHT)
		Spdlog.info(string.format(message, SAVE_INTERVAL_CONFIG_TIME, SAVE_INTERVAL_TYPE))
		addEvent(serverSave, remaningTime, interval)
		return true
	end
	return not configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL)
end

if SAVE_INTERVAL_TIME ~= 0 then
	save:interval(SAVE_INTERVAL_CONFIG_TIME * SAVE_INTERVAL_TIME)
else
	return Spdlog.error(string.format("[save.onTime] - Save interval type '%s' is not valid, use 'second', 'minute' or 'hour'", SAVE_INTERVAL_TYPE))
end

save:interval(configManager.getNumber(configKeys.SAVE_INTERVAL_TIME) * 60 * 60 * 1000)
save:register()
