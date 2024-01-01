local homeassistant = require("homeassistant")

homeassistant.register_sensor("redstone_left", "Redstone Left", "number", function(value)
	print("Redstone left: " .. value)
	-- Convert value to a number
	value = tonumber(value)
	if value > 15 then
		value = 15
	end
	if value < 0 then
		value = 0
	end

	redstone.setAnalogOutput("left", value)
end, nil, nil, nil)

function watch_redstone()
	while true do
		os.pullEvent("redstone")
		local value = redstone.getAnalogInput("left")
		homeassistant.send_value("redstone_left", value)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_redstone)
print("Watcher stopped")
