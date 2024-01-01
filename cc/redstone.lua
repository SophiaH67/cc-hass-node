local homeassistant = require("homeassistant")

homeassistant.register_sensor("redstone_left", "Redstone Left", "number", function(value)
	print("Redstone left: " .. value)
	redstone.setAnalogOutput("left", tonumber(value))
end, nil, nil, nil, 0, 15)

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
